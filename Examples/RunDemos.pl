#!/usr/bin/env perl 
#A test script that calls the test files in scripts folder
#uses GUIDeFATE (which in turn depends on Wx or Tk)

# For experimental purposes, before installlation use a 
# set this to where the GUIDeFATE moduels are...
my $lib='../../../lib';
use lib '../../../lib';
use strict;
use warnings;
use GUIDeFATE;

# an external program that returns a list of available backends
# that work. The Gtk module always generates errors so added
# manually but not guaranteed to work unless setup is ok
#my $backends=`perl -I$lib GFModules.pl`;
#$backends.=",Gtk,Gtk2";
my @workingModules;
BEGIN {
	# Uncomment the following line to debug.
	#$DB::single = 1;
	eval {
            eval "use GUIDeFATE" or die; 
        };
     if ($@ && $@ =~ /GUIDeFATE/) {
            print " GUIDeFATE not installed\n";
            exit;
        }
    # contains list of modules reuired for each backend
    # in order of preference
    foreach my $module ( qw/ GFwin32 GFwx GFtk GFqt GFhtml GFweb / ) {
        eval {
            eval "use GUIDeFATE::$module" or die; 
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
$backends.=",gtk,gtk2"; # Assuming gtk2 available (can't test gtk3 and gtk2 at the same time (conflicts)
print "carrying on with $backends\n";



my $window=<<END;
+--------------------------------------+
|T Available Demos                     |
+M-------------------------------------+
|  ^bends ^     Options       ^optns^  |
|  {Hello World                     }  |
|  {Calculator                      }  |
|  {Rock Paper Scissors Lizard Spock}  |
|  {GUI Gnuplotter                  }  |
|  {Text editor                     }  |
|  {Image Magick GUI                }  |
|  {The Plants List                 }  |
|  {Screenshot                      }  |
|  {Simple Logo                     }  |
|  {Servo controller                }  |
|  {RunDemos (this)                 }  |
|  [                    ]{Execute   }  |
+--------------------------------------+


bends=$backends
optns=Quiet,Verbose,Assist,Debug

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

sub btn3 #called using button with label Hello World
  {
  system("$preLine perl -I$lib HelloWorld.pl $backend $assist $postLine");
   };
sub btn4 #called using button with label Calculator                       
  {
  system("$preLine perl -I$lib calculator.pl $backend $assist $postLine");
   };
sub btn5 #called using button with label Rock Paper Scissors Lizard Spock 
  {
  system("cd rpsls; $preLine perl -I$lib rpsls.pl $backend $assist $postLine");
  };
sub btn6 #called using button with label GUI Gnuplotter                   
  {
  system("cd GUIgnuplot; $preLine perl -I$lib GUIgnuplot.pl $backend $assist $postLine");
   };
sub btn7 #called using button with label GUI Gnuplotter                   
  {
  system("$preLine perl -I$lib texteditor.pl $backend $assist $postLine");
   };
sub btn8 #called using button with label  Text editor                     
  {
  system("cd ImageMagickGUI; $preLine perl -I$lib ImageMagickGUI.pl $backend $assist $postLine");
   };
sub btn9 #called using button with label PlantList
  {
  system("cd PlantsList; $preLine perl -I$lib plantslist.pl $backend $assist $postLine");
   };
sub btn10 #called using button with label screenshot
  {
  system("$preLine perl -I$lib screenshot.pl $backend $assist $postLine");
   };
sub btn11 #called using button with label SimpleLogo
  {
  system("cd SimpleLogo; $preLine perl -I$lib SimpleLogo.pl $backend $assist $postLine");
   };
sub btn12 #called using button with label Servocontroler
  {
  system("cd Servocontroller; $preLine perl -I$lib Servocontroller.pl $backend $assist $postLine");
   };
sub btn13 #called using button with label RunDemos
  {
  system("$preLine perl -I$lib RunDemos.pl $backend $assist $postLine");
   };
sub textctrl15
   {
   system("$preLine perl -I$lib ". $frame->getValue("textctrl15") . " $backend $assist $postLine");
   };
sub btn14 #called using button with label from textctrl15
  {
  system("$preLine perl -I$lib ". $frame->getValue("textctrl15") . " $backend $assist $postLine");
   };
