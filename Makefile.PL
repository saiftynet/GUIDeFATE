use strict;
use warnings;
 
use ExtUtils::MakeMaker;

sub MY::postamble {
    my $string = <<EOF;
deb :: manifest rpm_prep dist
\tmkdir -p /tmp/scdeb
\tmv \$(NAME)-\$(VERSION).tar.gz /tmp/scdeb
\tcd /tmp/scdeb && tar -xvzf \$(NAME)-\$(VERSION).tar.gz
\tcd /tmp/scdeb/\$(NAME)-\$(VERSION) && dpkg-buildpackage -rfakeroot -us -uc
\techo "Debian packages are available in /tmp/scdeb"
\trm -rf /tmp/scdeb/\$(NAME)-\$(VERSION)

rpm_prep ::
\tsed -e 's/__VERSION__/\$(VERSION)/g' perl-GUIDeFATE.spec.in > perl-GUIDeFATE.spec

rpm :: rpm_prep manifest dist
\trpmbuild -tb --target noarch \$(NAME)-\$(VERSION).tar.gz

srpm :: rpm_prep manifest dist
\trpmbuild -ts --target noarch --nodeps \$(NAME)-\$(VERSION).tar.gz

EOF
}

WriteMakefile
(
    NAME         => 'GUIDeFATE',
    VERSION_FROM => 'lib/GUIDeFATE.pm',
    AUTHOR       => 'Saif Ahmed <saiftynet { at } gmail.com>',
    ABSTRACT_FROM  => 'man/GUIDeFATE.pod',
    LICENSE      =>  'Perl',
    PREREQ_PM    => {
    },
    BUILD_REQUIRES => {
    
    },
    TEST_REQUIRES => {
	'Test::More' => 1.001014,
    },
    dist	=> {
	COMPRESS	=> 'bzip2',
	SUFFIX		=> 'bz2'
    },
    realclean	=> {FILES => "*.old *.bak *.tar.gz *.spec Makefile MANIFEST"},
    test	=> {TESTS => 't/*.t'},
);
