#!perl
use GUIDeFATE;
my $window=<<END;
+-----------------+
|T My 1st GUI     |
+-----------------+
|  Hello World! ! |
|                 |
+-----------------+

END

my $backend=$ARGV[0]?$ARGV[0]:"tk";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame||$gui;
$gui->MainLoop;
