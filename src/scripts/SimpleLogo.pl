#!/usr/bin/env perl 
# A test script that allows a Logo-like program to be editted and run 
# uses GUIDeFATE (which in turn depends on Wx , GTK, QT, or Tk)
# This file designed to be called by Executioner for backend testing
# It uses Language::SIMPLE extended to interpret a script that can then be used
# to generate an SVG file, which is displayed in a graphical panel

use strict;
use warnings;
use GUIDeFATE;
use lib '../lib/';
use Language::SIMPLE;

use File::Copy qw(copy);

my $window=<<END;
+------------------------------------------------------------------------------+
|T  LOGO to SVG convertor                                                      |
+M-----------------------------------------------------------------------------+
|{Draw}{Logs} {Zoom in }{Zoom out}{Zoom All}{<}{^}{v}{>}{Center all}{AC}{Reset}|
|+T---------------------++I---------------------------------------------------+|
||# Simple Logo         ||simplelogo.svg                                      ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
||                      ||                                                    ||
|+----------------------+|                                                    ||
|[                      ]+----------------------------------------------------+|
+------------------------------------------------------------------------------+

Menu
-File
--New
--Open
--Save Script
--Quit
-Image
--Draw
--Save SVG
--Save PNG
-Examples
--Star
--Spiral
--Flower
--About
END

my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;

my $test= SIMPLE->new();
$test->extend("logo");
my $refresh=sub{$frame->setImage("Image14","simplelogo.svg");};
$test->setRefresh($refresh);
my $turtle="";
my $logMode=0;
menu33();
$gui->MainLoop;

sub menu19{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	   $frame->setValue("TextCtrl13","");
   }
}
sub menu20{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	  $frame->setValue("TextCtrl13","");
	  my $file= $frame->showFileSelectorDialog("Open file",1);
	    if (open(my $fh, '<:encoding(UTF-8)', $file)) {
          while (my $row = <$fh>) {
             $frame->appendValue("TextCtrl13",$row);
          }
       close $fh;
      }
  }
}
sub menu21{
	my $file= $frame->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl13");
       close $fh
       }
    }
sub menu22{
	$frame->quit();
}
sub menu25{
	if ($logMode==1){
		$frame->setValue("TextCtrl13",$turtle);
		$logMode=0;
	}
	else{
		$turtle=$frame->getValue("TextCtrl13");
	}
    $test->runCode($turtle);
	$test->execBlock();
	$test->execBlock("svgout simplelogo");
	$test->execBlock("refresh");
    #$frame->setImage("Image15","simplelogo.svg");
}
sub menu26{
	my $file= $frame->showFileSelectorDialog("Save SVG image file",0);
	copy("simplelogo.svg", $file)
}


sub btn0{
	menu25();
}
sub btn1{
	my $logs=$test->logs();
	$turtle=$frame->getValue("TextCtrl13");
	$logMode=1;
	$frame->setValue("TextCtrl13",$logs);
}
sub btn2{
	$test->execBlock(['zoom in',   'svgout simplelogo','refresh']);
}
sub btn3{
	$test->execBlock(['zoom out',  'svgout simplelogo','refresh']);
}
sub btn4{
	$test->execBlock(['zoom all',  'svgout simplelogo','refresh']);
}
sub btn5{
	$test->execBlock(['pan right','svgout simplelogo','refresh']);
}
sub btn6{
	$test->execBlock(['pan up',   'svgout simplelogo','refresh']);
}
sub btn7{
	$test->execBlock(['pan down', 'svgout simplelogo','refresh']);
}
sub btn8{
	$test->execBlock(['pan left', 'svgout simplelogo','refresh']);
}
sub btn9{
	$test->execBlock(['center all', 'svgout simplelogo','refresh']);
}
sub btn10{
	$frame->setValue("TextCtrl13","");
	$test->execBlock(['clear"', 'svgout simplelogo','refresh']);
}
sub btn11{
	
}


sub menu30{
	$turtle=<<END;
# Simple Logo
# drawing a star
clear; center

points=9
length=400

bk length/2
repeat points*2{
   fd length
   left 180-(360/(points*2))
}

END

$frame->setValue("TextCtrl13",$turtle);
menu25();
}
sub menu31{
	$turtle=<<END;
# Spiral hello
# a is starting length, b is turn angle 
# c is length increment, f is font size

a=2; b=18.3; c=0.8; f=3
clear;center
#main loop
repeat 40{ h; e; l; l; o}

sub h { # function to draw a 'H'
  lt 90; fd 10*f; bk 5*f ; rt 90; fd 5*f; lt 90 ; fd 5*f ; 
  bk 10*f ; rt 90;  nextpos
}

sub e { # function to draw a 'E'
  lt 90; fd 10*f;rt 90 ; fd 5*f; bk 5*f; rt 90; fd 5*f; 
  lt 90; fd 5*f; bk 5*f; rt 90; fd 5*f; lt 90; fd 5*f;
  nextpos
}

sub l { # function to draw a 'L'
  left 90; fd 10*f; bk 10*f ; right 90; fd 5*f 
  nextpos
}

sub o{ # function to draw a 'O'
  fd 1.5*f; lt 120; fd 2.5*f; rt 30; fd 6*f; rt 30; fd 2.5*f ; 
  rt 60; fd 2.5*f; rt 60;   fd 2.5*f; rt 30; fd 6*f ; rt 30;
  fd 2.5*f;  rt 60; fd 2.5*f; rt 180; fd 4*f;  nextpos
}

sub nextpos{
  right b; colour lightgray; fd a*f; right b
  colour random; a=a+c
}
END

$frame->setValue("TextCtrl13",$turtle);
menu25();
}
sub menu32{
	$turtle=<<END;
# Simple Logo
# drawing random flowers
clear; center

arc=230
steps=7
segMax=30   ; segMin=10
petalsMin=5 ; petalsMax=9
maxX=600    ; minX=100
maxY=600    ; minY=100

repeat 30{
  seg=segMin+int(rand(segMax))
  petals=petalsMin+int(rand(petalsMax))
  colour random
  move minX+int(rand(maxX)),minY+int(rand(maxY))
  flower
}

sub flower{
  mode polygon
  fill random
  repeat petals{
    petal
    right 360-arc-360/petals
  }
}

sub petal{
   fd seg
   repeat steps{
     right arc/steps
     fd seg
   }
}

END

$frame->setValue("TextCtrl13",$turtle);
menu25();
}
sub menu33{
	$turtle=<<END;
# Simple Logo
# drawing LOGO
clear; center

text "SIMPLE"    # writes the word SIMPLE
pen up; bk 120;  # moves cursor
pen down       
L; O; G; O;      # call drawing functions
center all       # centers drawing

sub L{
mode polygon
fill random
fd 100; rt;fd 20;rt;  fd 80; lt;fd 40;rt ; fd 20
rt; fd 60;
mode line; pen up; bk 75; rt; pen down
}

sub O{
pen up;rt; fd 12;lt;pen down;
mode path
fill random
 lt 45; fd 20; rt 45; fd 70; rt 45; fd 20; rt 45;  fd 40;
rt 45; fd 20; rt 45; fd 70; rt 45; fd 20; rt 45 ; fd 40
pen up; rt; fd 20;pen down; fd 60; rt; fd 40; rt;
fd 60; closepath;
mode line; pen up; fd 20;lt; fd 30; lt; pen down
}

sub G{
pen up;rt; fd 12;lt;pen down;
mode path
fill random
 lt 45; fd 20; rt 45; fd 70; rt 45; fd 20; rt 45;  fd 40;
rt 45; fd 20; rt 45; fd 10; rt ;fd 20; rt;fd 10; lt; fd 30;
lt; fd 70;lt; fd 30; lt ; fd 20; lt; fd 10; rt; fd 15; rt; fd 30;
rt; fd 40; rt 45; fd 12; closepath;
mode line; pen up; lt 135; fd 25; lt; pen down
}
END

$frame->setValue("TextCtrl13",$turtle);
menu25();
}
