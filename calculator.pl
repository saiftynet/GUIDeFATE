#!/usr/bin/env perl 
#A test script that  generates a calculator style interface
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE qw<$frame>;

my $window=<<END;
+------------------------+
|T  Calculator test      |
+M-----------------------+
|    +I------------+     |
|    |sister.jpg   |     |
|    |             |     |
|    +-------------+     |
|                        |
|  [                  ]  |
|  { V }{ % }{ C }{AC }  |
|  { 1 }{ 2 }{ 3 }{ + }  |
|  { 4 }{ 5 }{ 6 }{ - }  |
|  { 7 }{ 8 }{ 9 }{ * }  |
|  { . }{ 0 }{ =      }  |
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

GUIDeFATE::convert($window);
my $gui=GUIDeFATE->new();
#$frame->{stattext21}->SetLabel("The button was clicked!");
#$frame->{stattext21}->SetForegroundColour( Wx::Colour->new(255, 0, 0) );

$gui->MainLoop;
