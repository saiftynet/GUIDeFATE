use strict;
use warnings;
 
use ExtUtils::MakeMaker;

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
	COMPRESS	=> 'bzip2 -f',
	SUFFIX		=> 'bz2'
    },
    realclean	=> {FILES => "*.old *.bak *.tar.bz2 *.tar *.tar.gz *.spec Makefile debian/changelog"},
    test	=> {TESTS => 't/*.t'},
);

package MY;

sub postamble {
    my $string = <<EOF;
debian/changelog :: debian/changelog.in
\tsed -e 's/__VERSION__/\$(VERSION)/' < \$< > \$@

perl-GUIDeFATE.spec :: perl-GUIDeFATE.spec.in
\tsed -e 's/__VERSION__/\$(VERSION)/' < \$< > \$@

deb :: dist
\tmkdir -p /tmp/scdeb
\tmv \$(NAME)-\$(VERSION).tar.bz2 /tmp/scdeb
\tcd /tmp/scdeb && tar -xvzf \$(NAME)-\$(VERSION).tar.bz2
\tcd /tmp/scdeb/\$(NAME)-\$(VERSION) && dpkg-buildpackage -rfakeroot -us -uc
\techo "Debian packages are available in /tmp/scdeb"
\trm -rf /tmp/scdeb/\$(NAME)-\$(VERSION)

rpm :: dist
\trpmbuild -tb --target noarch \$(NAME)-\$(VERSION).tar.bz2

srpm :: dist
\trpmbuild -ts --target noarch --nodeps \$(NAME)-\$(VERSION).tar.bz2

EOF
}

sub dist_core {
    my $dist = shift->SUPER::dist_core(@_);
    $dist =~ s/^(\S.* :.*)/$1 perl-GUIDeFATE.spec debian\/changelog/mg;
    $dist
}


