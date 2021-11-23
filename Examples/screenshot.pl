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
|     [Full Screen      ]{s}     |
|     +I-------------------+     |
|     |/tmp/screenshot/scre|     |
|     |enshot.png          |     |
|     |                    |     |
|  {<}|                    |{>}  |
|     |                    |     |
|     |                    |     |
|     +--------------------+     |
| {Save as }{  Copy  }{Refresh } |
| {Edit }{Delayed}^times^{Multi} |
+--------------------------------+

times=5 secs,10 secs,30 secs
END

my $workingDir="/tmp/screenshot/";
mkdir $workingDir;
my $workingFile="screenshot.png";
my $multiMax=30;
my @winIds;
my $currentID=0;
makeList();
my %images;
   $images{0} = screenshot();
   $images{0} -> write(file => $workingDir.$workingFile, type => 'png' ) ||
                         die "cannot write $workingDir.$workingFile $!";
my %names;
   $names{0}='Full Screen';

my $backend=$ARGV[0]?$ARGV[0]:'wx';
my $assist=$ARGV[1]?$ARGV[1]:'a';
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
 
$gui->MainLoop();

sub sound{   # makes a sound
	#https://unix.stackexchange.com/questions/1974/how-do-i-make-my-pc-speaker-beep
  	system('( speaker-test -t square -f 1000  >/dev/null)& pid=$! ; sleep 0.1s ; kill -9 $pid');
};

sub showScreenshot{
	 my ($id,$refresh)=@_;
	 $id=$winIds[$id];
	 if ((! exists $images{$id})||$refresh){
		 $images{$id} = screenshot(id=>hex $id)  ;
		 getName($id);
	 }
	 $images{$id} ->write(file => $workingDir.$workingFile, type => 'png') ||
                         die "cannot write $workingDir.$workingFile $!";
     $frame->setImage('Image2',$workingDir.$workingFile);
     $frame->setValue('textctrl1',$names{$id});
}

sub getName{       # gets Name from given winodw ID (or returns Id if no name found)
	 my $id=shift;
	 if (! exists $names{$id}){ 
       my $name=`xprop -id $id|grep '^WM_NAME(STRING)'`;
       $name=~s/WM_NAME\(STRING\) =//;
       $name=~s/"//g;
       chomp $name;
       $names{$id}=$name ? $name: $id ;
   }
	 return $names{$id};
};

sub makeList{  # makes a list of Ids, and filters the list if needed
	my $searchTerm=shift;
	my $windowList= `xprop -root|grep ^_NET_CLIENT_LIST`;
    @winIds=$windowList=~m/(0x[0-9a-f]{7})/g;
    unshift @winIds, 0;
    if ((defined $searchTerm)&&($searchTerm)){
		my @filtered;
		foreach my $id (@winIds){
			my $name=getName($id);
			if ($name=~/$searchTerm/i){
				push @filtered, $id;
			}
		}
		if (@filtered){ @winIds=@filtered }
		else {sound()};
	}
	$currentID=0;
};

sub textctrl1{ # called using textctrl1
	
}

sub btn0{
	my $search=$frame->getValue('textctrl1');
	makeList($search);
	showScreenshot(0);
};

sub btn4 {#called using button with label < 
    $currentID-- if ($currentID>0);
    showScreenshot($currentID);
   };

sub btn5 {#called using button with label > 
    $currentID++ if ($currentID<$#winIds);
    showScreenshot($currentID);
   };

sub btn6 {#called using button with label Save as 
  	my $outFile= $frame->showFileSelectorDialog('Save file',0);
	if ($outFile) {
		  copy($workingDir.$workingFile,$outFile)  or die "could not copy file $workingDir$workingFile into $outFile $!";
	  }
   };
   
sub btn7 {#called using button with label Clipboard 
  system("xclip -selection clipboard -t image/png -i $workingDir.$workingFile ");
   };
   
sub btn8 {#called using button with label Refresh 
	sound();
    showScreenshot($currentID,1);
   };

sub combo9 {#called using combobox with data from @times
   };
   
sub btn10{
  my $pid = fork;
  return if $pid;
  system("gimp $workingDir$workingFile");
  exit;
};

sub btn11 {#called using button with label Delayed 
  my $pid = fork;
  return if $pid;
    my $delay=$frame->getValue("combo9");
    $delay=~s/[^\d]//g;
    sleep $delay;
    sound();
    showScreenshot($currentID,1);
    exit;
   };
   
sub btn12{
	if (-e $workingDir."multi"){
		unlink ( $workingDir."multi")
	}
	else {
		open(my $fh, '>', $workingDir."multi");
        print $fh $multiMax;
        close $fh;
          my $pid = fork;
          return if $pid;
          while ((-e $workingDir."multi") && ($multiMax--)){ 
              my $delay=$frame->getValue("combo9");
              $delay=~s/[^\d]//g;
              sleep $delay;
              sound();
		  }
          exit;
        
	}
	
	
}

