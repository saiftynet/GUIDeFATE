#!/usr/bin/env perl 
#A test script that crtaes a minimalist text editor
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE qw<$frame>;

my $window=<<END;
+--------------------------------------+
|T  Test Minimalist Text Editor        |
+M-------------------------------------+
|+T------------------------------------+
||text editor                          |
||                                     |
||                                     |
||                                     |
||                                     |
||                                     |
||                                     |
||                                     |
|+-------------------------------------+
|                                      |
+--------------------------------------+

Menu
-File
--New
--Open
--Save
--Quit

END

my $backend=$ARGV[0];
my $gui=GUIDeFATE->new($window,$backend);
my $frame=$gui->getFrame;
$gui->MainLoop;

sub menu4{
	if($gui->getFrame()->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	   $gui->getFrame()->{TextCtrl1}->SetValue("");
   }
}
sub menu5{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	  $frame->setValue("TextCtrl1","");
	  my $file= $frame->showFileSelectorDialog("Open file",1);
	    if (open(my $fh, '<:encoding(UTF-8)', $file)) {
          while (my $row = <$fh>) {
             $frame->appendValue("TextCtrl1",$row)
          }
       close $fh;
      }
  }
}
sub menu6{
	my $file= $gui->getFrame()->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl1");
       close $fh
       }
    }
    
sub menu7{
	$frame->quit();
}
