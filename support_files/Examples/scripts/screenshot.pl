#!/usr/bin/env perl 
#A test script that captures a screenshot for Linux
# uses GUIDeFATE, which in turn depends on a backends 
# (e.g. Wx, Tk, Gtk, but not yet Win32 ) 
# requires commands xprop (normally installed in Ubuntu) in Ubuntu 
# and xclip for the clipboard (sudo apt-get install xclip)
# This file designed to be called by Executioner for backend testing

use strict;
use warnings;
my $lib='../lib/';
use lib '../lib/';
use GUIDeFATE;
use Imager;
use Imager::Screenshot 'screenshot';    #This version uses Imager to get screenshot
use File::Copy;

my $window=<<END;
+--------------------------------+
|T Screenshot                    |
+--------------------------------+
|     [Full Screen         ]     |
|     +I-------------------+     |
|     |/tmp/screenshot/scre|     |
|     |enshot.png          |     |
|     |                    |     |
|  {<}|                    |{>}  |
|     |                    |     |
|     |                    |     |
|     +--------------------+     |
| {Save as }{  Copy  }{Refresh } |
| {Edit    }{Delayed }^times^    |
+--------------------------------+

times=5 secs,10 secs,30 secs
END

my $windowList= `xprop -root|grep ^_NET_CLIENT_LIST`;
my @winIds=$windowList=~m/(0x[0-9a-f]{7})/g;
unshift @winIds, 0;
my $currentID=0;
my $workingDir="/tmp/screenshot/";
mkdir $workingDir;
my $workingFile="screenshot.png";
my %images;
   $images{0} = screenshot();
   $images{0} -> write(file => $workingDir.$workingFile, type => 'png' ) || die "cannot write $workingDir.$workingFile $!";
my %names;
   $names{0}='Full Screen';

my $backend=$ARGV[0]?$ARGV[0]:'wx';
my $assist=$ARGV[1]?$ARGV[1]:'a';
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
 
$gui->MainLoop();

sub showScreenshot{
	 my ($id,$refresh)=@_;
	 $id=$winIds[$id];
	 if ((! exists $images{$id})||$refresh){
		 $images{$id}=screenshot(id=>hex $id, decor => 1 )  ;
		 if ($id){
	       my $name=`xprop -id $id|grep '^WM_NAME(STRING)'`;
	       $name=~s/WM_NAME\(STRING\) =//;
	       $name=~s/"//g;
	       chomp $name;
	       $names{$id}=$name?$name:$id;
	   }
	 }
	 $images{$id} ->write(file => $workingDir.$workingFile, type => 'png');
     $frame->setImage('Image1',$workingDir.$workingFile);
     $frame->setValue('textctrl0',$names{$id});
}

sub textctrl0{ # called using textctrl0
}

sub btn3 {#called using button with label < 
    $currentID-- if ($currentID>0);
    showScreenshot($currentID);
   };

sub btn4 {#called using button with label > 
    $currentID++ if ($currentID<$#winIds);
    showScreenshot($currentID);
   };

sub btn5 {#called using button with label Save as 
  	my $outFile= $frame->showFileSelectorDialog('Save file',0);
	if ($outFile) {
		  copy($workingDir.$workingFile,$outFile)  or die "could not copy file $workingDir$workingFile into $outFile $!";
	  }
   };
   
sub btn6 {#called using button with label Clipboard 
  system("xclip -selection clipboard -t image/png -i $workingDir.$workingFile ");
   };
   
sub btn7 {#called using button with label Refresh 
  	system('( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid');
    showScreenshot($currentID,1);
   };

sub combo8 {#called using combobox with data from @times
   };
   
sub btn9{
	system("gimp $workingDir$workingFile");
};

sub btn10 {#called using button with label Delayed 
 my $delay=$frame->getValue("combo8");
 $delay=~s/[^\d]//g;
 sleep $delay;
 #https://unix.stackexchange.com/questions/1974/how-do-i-make-my-pc-speaker-beep
 system('( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid');
 showScreenshot($currentID,1);
   };


