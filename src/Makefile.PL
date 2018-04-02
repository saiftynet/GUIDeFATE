use strict;
use warnings;
 
use ExtUtils::MakeMaker;
WriteMakefile
(
    NAME         => 'GUIDeFATE',
    VERSION_FROM => 'lib/GUIDeFATE.pm',
    AUTHOR       => 'Saif Ahmed <saiftynet { at } gmail.com>',
    ABSTRACT_FROM  => 'GUIDeFATE.pod',
    LICENSE      =>  'Perl',
    PREREQ_PM    => {
          'Wx::Perl::Imagick' => '0',
          'Wx'          => '0',
    },
    BUILD_REQUIRES => {
    
    }
);
