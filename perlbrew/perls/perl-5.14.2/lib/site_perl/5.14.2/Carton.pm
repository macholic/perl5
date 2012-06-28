package Carton;

use strict;
use warnings;
use 5.008_001;
use version; our $VERSION = "v0.9.4";

use Cwd;
use Config qw(%Config);
use Carton::Util;
use CPAN::Meta;
use File::Path ();
use File::Basename ();
use File::Spec ();
use File::Temp ();
use Capture::Tiny 'capture';

use constant CARTON_LOCK_VERSION => '0.9';
our $DefaultMirror = 'http://cpan.metacpan.org/';

sub new {
    my($class, %args) = @_;
    bless {
        path => $ENV{PERL_CARTON_PATH} || 'local',
        mirror => $ENV{PERL_CARTON_MIRROR} || $DefaultMirror,
    }, $class;
}

sub configure {
    my($self, %args) = @_;
    %{$self} = (%$self, %args);
}

sub lock { $_[0]->{lock} }

sub local_mirror { File::Spec->rel2abs("$_[0]->{path}/cache") }

sub download_from_build_file {
    my($self, $build_file, $local_mirror) = @_;

    my @modules = $self->list_dependencies;
    $self->download_conservative(\@modules, $local_mirror, 1)
        or die "Bundling modules failed\n";
}

sub install_from_build_file {
    my($self, $file) = @_;

    my @modules;
    if ($self->lock) {
        my $tree = $self->build_tree($self->lock->{modules});
        push @modules, map $_->spec, $tree->children;
    }

    push @modules, $self->list_dependencies;
    $self->install_conservative(\@modules, 1)
        or die "Installing modules failed\n";
}

sub list_dependencies {
    my $self = shift;

    my @deps = grep !/^perl~/, $self->run_cpanm_output("--showdeps", ".");
    for my $line (@deps) {
        chomp $line;
    }

    return @deps;
}

sub install_modules {
    my($self, $modules) = @_;
    $self->install_conservative($modules, 1)
        or die "Installing modules failed\n";
}

sub install_from_lock {
    my($self) = @_;

    my $tree = $self->build_tree($self->lock->{modules});
    my @root = map $_->spec, $tree->children;

    $self->install_conservative(\@root, 0)
        or die "Installing modules failed\n";
}

sub dedupe_modules {
    my($self, $modules) = @_;

    my %seen;
    my @result;
    for my $spec (reverse @$modules) {
        my($mod, $ver) = split /~/, $spec;
        next if $seen{$mod}++;
        push @result, $spec;
    }

    return [ reverse @result ];
}

sub download_conservative {
    my($self, $modules, $dir, $cascade) = @_;

    $modules = $self->dedupe_modules($modules);

    my $mirror = $self->{mirror} || $DefaultMirror;

    local $self->{path} = File::Temp::tempdir(CLEANUP => 1); # ignore installed
    $self->run_cpanm(
        "--mirror", $mirror,
        "--mirror", "http://backpan.perl.org/", # fallback
        "--no-skip-satisfied",
        ( $mirror ne $DefaultMirror ? "--mirror-only" : () ),
        ( $cascade ? "--cascade-search" : () ),
        "--scandeps",
        "--format", "dists",
        "--save-dists", $dir,
        @$modules,
    );
}

sub install_conservative {
    my($self, $modules, $cascade) = @_;

    $modules = $self->dedupe_modules($modules);

    if ($self->lock) {
        my $index = $self->build_index($self->lock->{modules});
        $self->build_mirror_file($index, $self->{mirror_file});
    }

    my $mirror = $self->{mirror} || $DefaultMirror;

    $self->run_cpanm(
        "--mirror", $mirror,
        "--mirror", "http://backpan.perl.org/", # fallback
        "--skip-satisfied",
        ( $mirror ne $DefaultMirror ? "--mirror-only" : () ),
        ( $self->lock ? ("--mirror-index", $self->{mirror_file}) : () ),
        ( $cascade ? "--cascade-search" : () ),
        @$modules,
    );
}

sub build_mirror_file {
    my($self, $index, $file) = @_;

    my @packages = $self->build_packages($index);

    my $fh;
    if ($file =~ /\.gz$/i) {
        require IO::Compress::Gzip;
        $fh = IO::Compress::Gzip->new($file) or die $IO::Compress::Gzip::GzipError;
    } else {
        open $fh, ">", $file or die $!;
    }

    print $fh <<EOF;
File:         02packages.details.txt
URL:          http://www.perl.com/CPAN/modules/02packages.details.txt
Description:  Package names found in carton.lock
Columns:      package name, version, path
Intended-For: Automated fetch routines, namespace documentation.
Written-By:   Carton $Carton::VERSION
Line-Count:   @{[ scalar(@packages) ]}
Last-Updated: @{[ scalar localtime ]}

EOF
    for my $p (@packages) {
        print $fh sprintf "%s %s  %s\n", pad($p->[0], 32), pad($p->[1] || 'undef', 10, 1), $p->[2];
    }

    return $file;
}

sub pad {
    my($str, $len, $left) = @_;

    my $howmany = $len - length($str);
    return $str if $howmany <= 0;

    my $pad = " " x $howmany;
    return $left ? "$pad$str" : "$str$pad";
}

sub build_packages {
    my($self, $index) = @_;

    my @packages;
    for my $package (sort keys %$index) {
        my $module = $index->{$package};
        push @packages, [ $package, $module->{version}, $module->{meta}{pathname} ];
    }

    return @packages;
}


sub build_index {
    my($self, $modules) = @_;

    my $index;

    while (my($name, $metadata) = each %$modules) {
        for my $mod (keys %{$metadata->{provides}}) {
            $index->{$mod} = { %{$metadata->{provides}{$mod}}, meta => $metadata };
        }
    }

    return $index;
}

sub build_mirror_index {
    my($self, $local_mirror) = @_;

    require File::chdir;
    require Dist::Metadata;

    my $index = {};

    local $File::chdir::CWD = "$local_mirror/authors/id";

    for my $file (<*/*/*/*>) { # D/DU/DUMMY/Foo-Bar-0.01.tar.gz
        my $dist = Dist::Metadata->new(file => $file);

        my $provides = $dist->package_versions;
        while (my($package, $version) = each %$provides) {
            $index->{$package} = { version => $version, meta => { pathname => $file } };
        }
    };

    return $index;
}

sub is_core {
    my($self, $module, $want_ver, $perl_version) = @_;
    $perl_version ||= $];

    require Module::CoreList;
    my $is_core  = exists $Module::CoreList::version{$perl_version + 0}{$module}
        or return;

    my $core_ver = $Module::CoreList::version{$perl_version + 0}{$module};
    return 1 unless $want_ver;
    return version->new($core_ver) >= version->new($want_ver);
};

sub walk_down_tree {
    my($self, $tree, $cb, $no_warn) = @_;

    my %seen;
    $tree->walk_down(sub {
        my($node, $depth, $parent) = @_;
        return $tree->abort if $seen{$node->key}++;

        if ($node->metadata->{dist}) {
            $cb->($node->metadata, $depth);
        } elsif (!$self->is_core($node->key, 0) && !$no_warn) {
            warn "Couldn't find ", $node->key, "\n";
        }
    });
}

sub build_tree {
    my($self, $modules, $root) = @_;

    my $idx  = $self->build_index($modules);
    my $pool = { %$modules }; # copy

    my $tree = Carton::Tree->new;

    while (my $pick = (keys %$pool)[0]) {
        $self->_build_tree($pick, $tree, $tree, $pool, $idx);
    }

    $tree->finalize($root);

    return $tree;
}

sub _build_tree {
    my($self, $elem, $tree, $curr_node, $pool, $idx) = @_;

    if (my $cached = Carton::TreeNode->cached($elem)) {
        $curr_node->add_child($cached);
        return;
    }

    my $node = Carton::TreeNode->new($elem, $pool);
    $curr_node->add_child($node);

    for my $child ( $self->build_deps($node->metadata, $idx) ) {
        $self->_build_tree($child, $tree, $node, $pool, $idx);
    }
}

sub merge_prereqs {
    my($self, $prereqs) = @_;

    my %requires;
    for my $phase (qw( configure build test runtime )) {
        %requires = (%requires, %{$prereqs->{$phase}{requires} || {}});
    }

    return \%requires;
}

sub build_deps {
    my($self, $meta, $idx) = @_;

    my $requires = $self->merge_prereqs($meta->{mymeta}{prereqs});

    my @deps;
    for my $module (keys %$requires) {
        next if $module eq 'perl';
        if (exists $idx->{$module}) {
            push @deps, $idx->{$module}{meta}{name};
        } else {
            push @deps, $module;
        }
    }

    return @deps;
}

sub run_cpanm_output {
    my($self, @args) = @_;

    my $deps = capture {
        local $ENV{PERL_CPANM_OPT};
        system "cpanm", "--quiet", "-L", $self->{path}, @args;
    };
    my @deps = split $/, $deps;

    return @deps;
}

sub run_cpanm {
    my($self, @args) = @_;
    local $ENV{PERL_CPANM_OPT};
    !system "cpanm", "--quiet", "-L", $self->{path}, "--notest", @args;
}

sub update_mirror_index {
    my($self, $local_mirror) = @_;

    my $index = $self->build_mirror_index($local_mirror);

    my $file = "$local_mirror/modules/02packages.details.txt.gz";
    File::Path::mkpath(File::Basename::dirname($file));
    $self->build_mirror_file($index, $file)
        or die "Bundling modules failed\n";
}

sub update_lock_file {
    my($self, $file) = @_;

    my $lock = $self->build_lock;
    Carton::Util::dump_json($lock, $file);

    return 1;
}

sub build_lock {
    my $self = shift;

    my %installs = $self->find_installs;

    return {
        modules => \%installs,
        version => CARTON_LOCK_VERSION,
    };
}

sub find_installs {
    my $self = shift;

    require File::Find;

    my $libdir = "$self->{path}/lib/perl5/$Config{archname}/.meta";
    return unless -e $libdir;

    my @installs;
    my $wanted = sub {
        if ($_ eq 'install.json') {
            push @installs, [ $File::Find::name, "$File::Find::dir/MYMETA.json" ];
        }
    };
    File::Find::find($wanted, $libdir);

    return map {
        my $module = Carton::Util::load_json($_->[0]);
        my $mymeta = -f $_->[1] ? CPAN::Meta->load_file($_->[1])->as_struct({ version => "2" }) : {};
        ($module->{name} => { %$module, mymeta => $mymeta }) } @installs;
}

sub check_satisfies {
    my($self, $lock, $deps) = @_;

    my @unsatisfied;
    my $index = $self->build_index($lock->{modules});
    my %pool = %{$lock->{modules}}; # copy

    my @root = map { [ split /~/, $_, 2 ] } @$deps;

    for my $dep (@root) {
        $self->_check_satisfies($dep, \@unsatisfied, $index, \%pool);
    }

    my $tree = keys %pool ? $self->build_tree(\%pool) : undef;

    return {
        unsatisfied => \@unsatisfied,
        superflous  => $tree,
    };
}

sub _check_satisfies {
    my($self, $dep, $unsatisfied, $index, $pool) = @_;

    my($mod, $ver) = @$dep;

    my $found = $index->{$mod};
    if ($found) {
        delete $pool->{$found->{meta}{name}};
    } elsif ($self->is_core($mod, $ver)) {
        return;
    }

    unless ($found and (!$ver or version->new($found->{version}) >= version->new($ver))) {
        push @$unsatisfied, {
            module => $mod,
            version => $ver,
            found => $found ? $found->{version} : undef,
        };
        return;
    }

    my $requires = $self->merge_prereqs($found->{meta}{mymeta}{prereqs});
    for my $module (keys %$requires) {
        next if $module eq 'perl';
        $self->_check_satisfies([ $module, $requires->{$module} ], $unsatisfied, $index, $pool);
    }
}

sub uninstall {
    my($self, $lock, $module) = @_;

    my $meta = $lock->{modules}{$module};
    (my $path_name = $meta->{name}) =~ s!::!/!g;

    my $path = Cwd::realpath($self->{path});
    my $packlist = "$path/lib/perl5/$Config{archname}/auto/$path_name/.packlist";

    open my $fh, "<", $packlist or die "Couldn't locate .packlist for $meta->{name}";
    while (<$fh>) {
        # EUMM merges with site and perl library paths
        chomp;
        next unless /^\Q$path\E/;
        unlink $_ or warn "Couldn't unlink $_: $!";
    }

    unlink $packlist;
    if ($meta->{dist}) { # safety guard not to rm -r auto/meta
        File::Path::rmtree("$self->{path}/lib/perl5/$Config{archname}/.meta/$meta->{dist}");
    }
}

1;
