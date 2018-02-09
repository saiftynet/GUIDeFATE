#!/usr/bin/env perl 
#A test script that  generates a calculator style interface
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE qw<$frame>;

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
#$frame->{stattext21}->SetLabel("Test Control frame elements!");
$gui->MainLoop;
