#!/usr/bin/env perl 
#A test script that crtaes a minimalist text editor
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE;

my $window=<<END;
+---------------------------------------+
|T  Test Minimalist Text Editor         |
+M--------------------------------------+
|+T------------------------------------+|
||text editor                          ||
||                                     ||
||                                     ||
||                                     ||
||                                     ||
||                                     ||
||                                     ||
||                                     ||
|+-------------------------------------+|
|                                       |
+---------------------------------------+

Menu
-File
--New
--Open
--Save
--Quit

END

my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame||$gui;
$gui->MainLoop;

sub menu4{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	   $frame->setValue("TextCtrl1","");
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
	my $file= $frame->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl1");
       close $fh
       }
    }
    
sub menu7{
	$frame->quit();
}
