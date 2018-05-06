#!/usr/bin/env perl 
#A test script that calls the test files in scripts folder
#uses GUIDeFATE (which in turn depends on Wx or Tk)

# For experimental purposes, before installlation use a 
# set this to where the GUIDeFATE moduels are...
my $lib='../lib/';
use lib '../lib/';
use strict;
use warnings;
use GUIDeFATE;

# an external program that returns a list of available backends
# that work. The Gtk module always generates errors so added
# manually but not guaranteed to work unless setup is ok
my $backends=`perl -I$lib GFModules.pl`;
$backends.=",Gtk";


my $window=<<END;
+--------------------------------------+
|T Executioner                         |
+M-------------------------------------+
|  ^bends ^     Options       ^optns^  |
|  {Calculator                      }  |
|  {Rock Paper Scissors Lizard Spock}  |
|  {GUI Gnuplotter                  }  |
|  { Text editor                    }  |
|  {Image Magick GUI                }  |
|  { Executioner (this)             }  |
|  [                    ]{Execute   }  |
+--------------------------------------+


bends=$backends
optns=Quiet,Verbose,Assist

END

my $preLine=($^O=~/Win/)?"START ":"";
my $postLine=($^O=~/Win/)?"":" &";

my $backend=$ARGV[0]?$ARGV[0]:(split(",",$backends))[0];
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame||$gui;
$gui->MainLoop;

sub combo0{
	$backend=$frame->getValue("combo0");
}
sub combo1{
	$assist=$frame->getValue("combo1");
}

sub btn3 #called using button with label Calculator                       
  {
  system("$preLine perl -I$lib -I /lin/GUIdeFATE/ calculator.pl $backend $assist $postLine");
   };
sub btn4 #called using button with label Rock Paper Scissors Lizard Spock 
  {
  system("$preLine perl -I$lib rpsls.pl $backend $assist $postLine");
  };

sub btn5 #called using button with label GUI Gnuplotter                   
  {
  system("$preLine perl -I$lib GUIgnuplot.pl $backend $assist $postLine");
   };

sub btn6 #called using button with label GUI Gnuplotter                   
  {
  system("$preLine perl -I$lib texteditor.pl $backend $assist $postLine");
   };

sub btn7 #called using button with label  Text editor                     
  {
  system("$preLine perl -I$lib  ImageMagickGUI.pl $backend $assist $postLine");
   };
sub btn8 #called using button with label Executioner                       
  {
  system("$preLine perl -I$lib Executioner.pl $backend $assist $postLine");
   };

sub textctrl10
   {
	system("$preLine perl -I$lib ". $frame->getValue("textctrl10") . " $backend $assist $postLine");
   };
sub btn9 #called using button with label Executioner                       
  {
  system("$preLine perl -I$lib ". $frame->getValue("textctrl10") . " $backend $assist $postLine");
   };
