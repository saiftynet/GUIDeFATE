#!/usr/bin/perl -w
#A test script that  generates a calculator style interface
#uses GUIDeFATE (which in turn depends on Wx)

use strict;
use GUIDeFATE;
use GUIDeFATE qw<$frame>;
package Main;

my $window=<<END;
+------------------------+
|T  Calculator           |
+M-----------------------+
|  [                  ]  |
|  { V }{ % }{ C }{AC }  |
|  { 1 }{ 2 }{ 3 }{ + }  |
|  { 4 }{ 5 }{ 6 }{ - }  |
|  { 7 }{ 8 }{ 9 }{ * }  |
|  { . }{ 0 }{ = }{ / }  |
|  made with GUIdeFATE   |
+------------------------+

END

GUIDeFATE::convert($window);
my $gui=GUIDeFATE->new();
$gui->MainLoop;
