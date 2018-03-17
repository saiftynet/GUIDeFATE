#!/usr/bin/env perl 
#A test script that  generates a calculator style interface
#uses GUIDeFATE (which in turn depends on Wx or Tk)
#This file designed to be called by Executioner for backend testing

use strict;
use warnings;
use GUIDeFATE;

my $window=<<END;
+------------------------+
|T  Calculator           |
+M-----------------------+
|  [                  ]  |
|  {sqr}{pi }{ C }{AC }  |
|  { 1 }{ 2 }{ 3 }{ + }  |
|  { 4 }{ 5 }{ 6 }{ - }  |
|  { 7 }{ 8 }{ 9 }{ * }  |
|  { . }{ 0 }{ = }{ / }  |
|  made with GUIdeFATE   |
|  and happy things      |
+------------------------+


END

my $result=0;
my $acc="";

my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
$gui->MainLoop();

sub textctrl0 #called using Text Control with default text '                    '
  {
  $result=$frame->getValue("textctrl0");
   };

sub btn1 #called using button with label V 
  {
  $result=sqrt($frame->getValue("textctrl0"));
  $frame->setValue("textctrl0", $result)
   };

sub btn2 #called using button with label pi 
  {
     $frame->setValue("textctrl0", 3.14159267)
   };

sub btn3 #called using button with label C 
  {
  $result=0;
  $frame->setValue("textctrl0", $result)
   };

sub btn4 #called using button with label AC 
  {
  $result=0;
  $frame->setValue("textctrl0", $result) 
   };

sub btn5 #called using button with label 1 
  {
	 if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 1) }
     else {$frame->appendValue("textctrl0", 1) }
   };

sub btn6 #called using button with label 2 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 2) }
     else {$frame->appendValue("textctrl0", 2) }
   };

sub btn7 #called using button with label 3 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 3) }
	  else {$frame->appendValue("textctrl0", 3) }
   };

sub btn8 #called using button with label + 
  {
	  $acc.=$frame->getValue("textctrl0")."+";
  $frame->setValue("textctrl0", 0)
   };

sub btn9 #called using button with label 4 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 4) }
	  else {$frame->appendValue("textctrl0", 4) }
  
   };

sub btn10 #called using button with label 5 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 5) }
	  else {$frame->appendValue("textctrl0", 5) }
   };

sub btn11 #called using button with label 6 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 6) }
	  else {$frame->appendValue("textctrl0", 6) }
   };

sub btn12 #called using button with label - 
  {
  	  $acc.=$frame->getValue("textctrl0")."-";
  $frame->setValue("textctrl0", 0)
   };

sub btn13 #called using button with label 7 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 7) }
	  else {$frame->appendValue("textctrl0", 7) }
   };

sub btn14 #called using button with label 8 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 8) }
	  else {$frame->appendValue("textctrl0", 8) }
   };

sub btn15 #called using button with label 9 
  {
	  if ($frame->getValue("textctrl0") eq "0"){ $frame->setValue("textctrl0", 9) }
	  else {$frame->appendValue("textctrl0", 9)}
  }

sub btn16 #called using button with label * 
  {
	  if ($frame->getValue("textctrl0")==0){ $frame->setValue("textctrl0", "") }
	  $acc.=$frame->getValue("textctrl0")."*";
  $frame->setValue("textctrl0", 0)
   };

sub btn17 #called using button with label . 
  {
	  $frame->appendValue("textctrl0", ".")
   };

sub btn18 #called using button with label 0 
  {
	  $frame->appendValue("textctrl0", 0)
   };

sub btn19 #called using button with label = 
  {   
	  $acc.=$frame->getValue("textctrl0");
	  $result=eval($acc);
	  print $acc."=".$result."\n";
	  $frame->setValue("textctrl0", $result );
	  $acc="";
   };

sub btn20 #called using button with label / 
  {
	   $acc.=$frame->getValue("textctrl0")."/";
	   $frame->setValue("textctrl0", 0)
   };

#Static text 'made with GUIdeFATE'  with id stattext21
#Static text 'and happy things'  with id stattext22
#Menu found
