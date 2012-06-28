package Carton::CLI;
use strict;
use warnings;

use Cwd;
use Config;
use Getopt::Long;
use Term::ANSIColor qw(colored);

use Carton;
use Carton::Util;
use Carton::Error;
use Carton::Tree;
use Try::Tiny;

use constant { SUCCESS => 0, INFO => 1, WARN => 2, ERROR => 3 };

our $Colors = {
    SUCCESS, => 'green',
    WARN,    => 'yellow',
    INFO,    => 'cyan',
    ERROR,   => 'red',
};

sub new {
    my $class = shift;
    bless {
        color => 1,
        verbose => 0,
    }, $class;
}

sub carton {
    my $self = shift;
    $self->{carton} ||= Carton->new;
}

sub work_file {
    my($self, $file) = @_;
    return "$self->{work_dir}/$file";
}

sub run {
    my($self, @args) = @_;

    $self->{work_dir} = $ENV{PERL_CARTON_HOME} || (Cwd::cwd() . "/.carton");
    mkdir $self->{work_dir}, 0777 unless -e $self->{work_dir};

    local @ARGV = @args;
    my @commands;
    my $p = Getopt::Long::Parser->new(
        config => [ "no_ignore_case", "pass_through" ],
    );
    $p->getoptions(
        "h|help"    => sub { unshift @commands, 'help' },
        "v|version" => sub { unshift @commands, 'version' },
        "color!"    => \$self->{color},
        "verbose!"  => \$self->{verbose},
    );

    push @commands, @ARGV;

    my $cmd = shift @commands || 'usage';
    my $call = $self->can("cmd_$cmd");

    if ($call) {
        try {
            $self->$call(@commands);
        } catch {
            /Carton::Error::CommandExit/ and return;
            die $_;
        }
    } else {
        $self->error("Could not find command '$cmd'\n");
    }
}

sub commands {
    my $self = shift;

    no strict 'refs';
    map { s/^cmd_//; $_ }
        grep /^cmd_(.*)/, sort keys %{__PACKAGE__."::"};
}

sub cmd_usage {
    my $self = shift;
    $self->print(<<HELP);
Usage: carton <command>

where <command> is one of:
  @{[ join ", ", $self->commands ]}

Run carton -h <command> for help.
HELP
}

sub parse_options {
    my($self, $args, @spec) = @_;
    Getopt::Long::GetOptionsFromArray($args, @spec);
}

sub printf {
    my $self = shift;
    my $type = pop;
    my($temp, @args) = @_;
    $self->print(sprintf($temp, @args), $type);
}

sub print {
    my($self, $msg, $type) = @_;
    $msg = colored $msg, $Colors->{$type} if defined $type && $self->{color};
    my $fh = $type && $type >= WARN ? *STDERR : *STDOUT;
    print {$fh} $msg;
}

sub error {
    my($self, $msg) = @_;
    $self->print($msg, ERROR);
    Carton::Error::CommandExit->throw;
}

sub cmd_help {
    my $self = shift;
    my $module = $_[0] ? ("Carton::Doc::" . ucfirst $_[0]) : "Carton";
    system "perldoc", $module;
}

sub cmd_version {
    my $self = shift;
    $self->print("carton $Carton::VERSION\n");
}

sub cmd_bundle {
    my($self, @args) = @_;

    $self->parse_options(\@args, "p|path=s" => sub { $self->carton->{path} = $_[1] });

    my $local_mirror = $self->carton->local_mirror;

    if (my $build_file = $self->has_build_file) {
        $self->print("Bundling modules using $build_file\n");
        $self->carton->download_from_build_file($build_file, $local_mirror);
        $self->carton->update_mirror_index($local_mirror);
    } else {
        $self->error("Can't locate build file\n");
    }

    $self->printf("Complete! Modules were bundled into %s\n", $local_mirror, SUCCESS);
}

sub cmd_install {
    my($self, @args) = @_;

    $self->parse_options(
        \@args,
        "p|path=s"    => sub { $self->carton->{path} = $_[1] },
        "deployment!" => \$self->{deployment},
        "cached!"     => \$self->{use_local_mirror},
    );

    my $lock = $self->find_lock;
    my $local_mirror = $self->carton->local_mirror;

    $self->carton->configure(
        lock => $lock,
        mirror_file => $self->mirror_file, # $lock object?
        ( $self->{use_local_mirror} && -d $local_mirror ? (mirror => $local_mirror) : () ),
    );

    my $build_file = $self->has_build_file;

    if (@args) {
        $self->print("Installing modules from the command line\n");
        $self->carton->install_modules(\@args);
        $self->carton->update_lock_file($self->lock_file);
    } elsif ($self->{deployment} or not $build_file) {
        $self->print("Installing modules using carton.lock (deployment mode)\n");
        $self->carton->install_from_lock;
    } elsif ($build_file) {
        $self->print("Installing modules using $build_file\n");
        $self->carton->install_from_build_file($build_file);
        $self->carton->update_lock_file($self->lock_file);
    } else {
        $self->error("Can't locate build file or carton.lock\n");
    }

    $self->printf("Complete! Modules were installed into %s\n", $self->carton->{path}, SUCCESS);
}

sub cmd_uninstall {
    my($self, @args) = @_;

    $self->parse_options(\@args, "p|path=s", sub { $self->carton->{path} = $_[1] });

    my $lock = $self->find_lock
        or $self->error("Can't find carton.lock: Run `carton install`");

    my $index = $self->carton->build_index($lock->{modules});

    my @meta;
    for my $module (@args) {
        if (exists $index->{$module}) {
            push @meta, $index->{$module}{meta};
        } else {
            $self->print("Can't locate module $module\n", WARN);
        }
    }

    my %root;
    if ($self->has_build_file) {
        for my $dep ($self->carton->list_dependencies) {
            my($mod, $ver) = split /~/, $dep;
            if (exists $index->{$mod}) {
                $root{ $index->{$mod}{meta}{name} } = 1;
            }
        }
    }

    # only can uninstall root dependencies
    my $tree = $self->carton->build_tree($lock->{modules}, \%root);
    for my $root ($tree->children) {
        if (grep $_->{name} eq $root->key, @meta) {
            $tree->remove_child($root);
        }
    }

    my @missing = grep !$tree->find_child($_), keys %{$lock->{modules}};
    for my $module (@missing) {
        my $meta = $lock->{modules}{$module};
        $self->print("Uninstalling $meta->{dist}\n");
        $self->carton->uninstall($lock, $module);
    }

    for my $meta (@meta) {
        unless (grep $meta->{name} eq $_, @missing) {
            $self->print("$meta->{name} is dependent by some other modules. Can't uninstall it.\n", WARN);
        }
    }

    $self->carton->update_lock_file($self->lock_file);

    if (@missing) {
        $self->printf("Complete! Modules and its dependencies were uninstalled from %s\n",
                      $self->carton->{path}, SUCCESS);
    }
}

sub mirror_file {
    my $self = shift;
    return $self->work_file("02packages.details.txt");
}

sub has_build_file {
    my $self = shift;

    my $file = (grep -e, qw( Build.PL Makefile.PL ))[0]
        or return;

    return $file;
}

sub cmd_show {
    my($self, @args) = @_;

    my $lock = $self->find_lock
        or $self->error("Can't find carton.lock: Run `carton install`\n");
    my $index = $self->carton->build_index($lock->{modules});

    for my $module (@args) {
        my $meta = $index->{$module}{meta}
            or $self->error("Couldn't locate $module in carton.lock\n");
        $self->print( Carton::Util::to_json($meta) );
    }
}

sub cmd_tree {
    my $self = shift;
    $self->cmd_list("--tree", @_);
}

sub cmd_list {
    my($self, @args) = @_;

    my $tree_mode;
    $self->parse_options(\@args, "tree!" => \$tree_mode);

    my $lock = $self->find_lock
        or $self->error("Can't find carton.lock: Run `carton install` to rebuild the lock file.\n");

    if ($tree_mode) {
        my $tree = $self->carton->build_tree($lock->{modules});
        $self->carton->walk_down_tree($tree, sub {
            my($module, $depth) = @_;
            my $line = " " x $depth . "$module->{dist}\n";
            $self->print($line);
        });
    } else {
        for my $module (values %{$lock->{modules} || {}}) {
            $self->print("$module->{dist}\n");
        }
    }
}

sub cmd_check {
    my($self, @args) = @_;

    my $file = $self->has_build_file
        or $self->error("Can't find a build file: nothing to check.\n");

    $self->parse_options(\@args, "p|path=s", sub { $self->carton->{path} = $_[1] });

    my $lock = $self->carton->build_lock;
    my @deps = $self->carton->list_dependencies;

    my $res = $self->carton->check_satisfies($lock, \@deps);

    my $ok = 1;
    if (@{$res->{unsatisfied}}) {
        $self->print("Following dependencies are not satisfied. Run `carton install` to install them.\n", WARN);
        for my $dep (@{$res->{unsatisfied}}) {
            $self->print("$dep->{module} " . ($dep->{version} ? "($dep->{version})" : "") . "\n");
        }
        $ok = 0;
    }

    if ($res->{superflous}) {
        $self->printf("Following modules are found in %s but couldn't be tracked from your $file\n",
                      $self->carton->{path}, WARN);
        $self->carton->walk_down_tree($res->{superflous}, sub {
            my($module, $depth) = @_;
            my $line = "  " x $depth . "$module->{dist}\n";
            $self->print($line);
        }, 1);
        $ok = 0;
    }

    if ($ok) {
        $self->printf("Dependencies specified in your $file are satisfied and matches with modules in %s.\n",
                      $self->carton->{path}, SUCCESS);
    }
}

sub cmd_update {
    # "cleanly" update distributions in extlib
    # rebuild the tree, update modules with DFS
    die <<EOF;
carton update is not implemented yet.

The command is supposed to update all the dependencies to the latest
version as if you don't have the current local environment doesn't
exist.

For now, you can remove the local environment and re-run carton install
to get the similar functionality.

EOF

}

sub cmd_exec {
    my($self, @args) = @_;

    # allows -Ilib
    @args = map { /^(-[I])(.+)/ ? ($1,$2) : $_ } @args;

    my $system; # for unit testing
    my @include;
    $self->parse_options(\@args, 'I=s@', \@include, "system", \$system);

    my $path = $self->carton->{path};
    my $lib  = join ",", @include, "$path/lib/perl5", ".";

    local $ENV{PERL5OPT} = "-Mlib::core::only -Mlib=$lib";
    local $ENV{PATH} = "$path/bin:$ENV{PATH}";

    $system ? system(@args) : exec(@args);
}

sub find_lock {
    my $self = shift;

    if (-e $self->lock_file) {
        return $self->lock_data; # TODO object
    }

    return;
}

sub lock_data {
    my $self = shift;

    my $lock;
    try {
        $lock = Carton::Util::load_json($self->lock_file);
    } catch {
        if (/No such file/) {
            $self->error("Can't locate carton.lock\n");
        } else {
            $self->error("Can't parse carton.lock: $_\n");
        }
    };

    return $lock;
}

sub lock_file {
    my $self = shift;
    return 'carton.lock';
}


1;
