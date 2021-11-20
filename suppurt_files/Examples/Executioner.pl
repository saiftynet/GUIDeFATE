#!/usr/bin/env perl 
#A test script that calls the test files in scripts folder
#uses GUIDeFATE (which in turn depends on Wx or Tk)

use lib '../lib/';
use strict;
use warnings;
use GUIDeFATE;


my @workingModules;
BEGIN {
	eval {
            eval "use GUIDeFATE" or die; 
        };
     if ($@ && $@ =~ /GUIDeFATE/) {
            print " GUIDeFATE not installed\n";
            exit;
        }
    # contains list of modules reuired for each backend
    # in order of preference
    foreach my $module ( qw/ GFwin32 GFwx GFtk  GFqt/ ) {
        eval {
            eval "use $module" or die; 
        };
        if ($@ && $@ =~ /$module/) {
            print " $module not installed\n";
        }
        else {
			print " $module found\n";
			my $m=$module;
			$m=~s/^GF//;
			push (@workingModules, ucfirst $m);
			}
    }
    if (! $workingModules[0]){ # at least one module works
		print "no working GFxx modules intalled";
		exit;
		};
}
my $backends=join(",",@workingModules);
print "carrying on with $backends";

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


bends=$backends,Gtk
optns=Quiet,Verbose,Assist

END

my $preLine=($^O=~/Win/)?"START ":"";
my $postLine=($^O=~/Win/)?"":" &";

my $backend=$ARGV[0]?$ARGV[0]:$workingModules[0];
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
  system("$preLine perl -I../lib/ calculator.pl $backend $assist $postLine");
   };
sub btn4 #called using button with label Rock Paper Scissors Lizard Spock 
  {
  system("$preLine perl -I../lib/ rpsls.pl $backend $assist $postLine");
  };

sub btn5 #called using button with label GUI Gnuplotter                   
  {
  system("$preLine perl -I../lib/ GUIgnuplot.pl $backend $assist $postLine");
   };

sub btn6 #called using button with label GUI Gnuplotter                   
  {
  system("$preLine perl -I../lib/ texteditor.pl $backend $assist $postLine");
   };

sub btn7 #called using button with label  Text editor                     
  {
  system("$preLine perl -I../lib/ ImageMagickGUI.pl $backend $assist $postLine");
   };
sub btn8 #called using button with label Executioner                       
  {
  system("$preLine perl -I../lib/ Executioner.pl $backend $assist $postLine");
   };

sub textctrl10
   {
	system("$preLine perl -I../lib/ ". $frame->getValue("textctrl10") . " $backend $assist $postLine");
   };
sub btn9 #called using button with label Executioner                       
  {
  system("$preLine perl -I../lib/ ". $frame->getValue("textctrl10") . " $backend $assist $postLine");
   };
