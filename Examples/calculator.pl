#!/usr/bin/env perl 
#A test script that  generates a calculator style interface
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE;

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
|  and happy things      |
+------------------------+

Menu
-File
--Save
--Open
--New
--Quit
-Edit
--Undo
--Cut
--Paste
-Options
--red;check
--blue;check
--green;check

END

my $backend=$ARGV[0];

my $gui=GUIDeFATE->new($window,$backend,"v");
my $frame=$gui->getFrame();
$gui->MainLoop();
