#!perl

# We are miniperl, building extensions
# Reset @INC completely, adding the directories we need, and removing the
# installed directories (which we don't need to read, and may confuse us)
@INC = (q /home/macholic/perl5/perlbrew/build/perl-5.14.2/cpan/AutoLoader/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/dist/Cwd ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/dist/Cwd/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/dist/ExtUtils-Command/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/dist/ExtUtils-Install/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/cpan/ExtUtils-MakeMaker/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/dist/ExtUtils-Manifest/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/cpan/File-Path/lib ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/ext/re ,
        q /home/macholic/perl5/perlbrew/build/perl-5.14.2/lib ,
        q . );
