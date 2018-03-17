#!/usr/bin/env perl 
#A test script that creates a minimalist image magick
#uses GUIDeFATE (which in turn depends on Wx, Tk or Gtk)
#uses Image Magick

use strict;
use warnings;
use GUIDeFATE;
use Image::Magick;
use File::Copy;

my $window=<<END;
+-------------------------------------------------------------------+
|T  Image Magick GUI                                                |
+M------------------------------------------------------------------+
|+T-------------------------++I------------------------------------+|
||Script                    ||ImageMagick.png                      ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
||                          ||                                     ||
|+--------------------------++-------------------------------------+|
|                                                                   |
+-------------------------------------------------------------------+

Menu
-File
--New Script
--Open Script
--Save Script
--Quit
-Image
--Load Image
--Run Script
--Save Image
--Batch Process
-Functions
--Flip
--
END


my $inFile;
my $workingDir="tmp";

unless (-e $workingDir and -d $workingDir){mkdir $workingDir};


my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame||$gui;
$gui->MainLoop;



#SubPanel 'T' Id 0 found position  1 height 14 width 26 at row 1 with content Script 
#SubPanel 'I' Id 2 found position  29 height 14 width 37 at row 1 with content ImageMagick.png 
#Menu found
#Menuhead File found
#Menu New found, calls function &menu6 
sub menu6 { #called using Menu with lable New
	if($frame->showDialog("Sure?","This will wipe existing script...proceed?","OKC","!")){
	   $frame->setValue("TextCtrl1","");
   }
   };

#Menu Open found, calls function &menu7 
sub menu7 {#called using Menu with lable Open
	if($frame->showDialog("Sure?","This will wipe existing script...proceed?","OKC","!")){
	  $frame->setValue("TextCtrl1","");
	  my $file= $frame->showFileSelectorDialog("Open file",1);
	    if (open(my $fh, '<:encoding(UTF-8)', $file)) {
          while (my $row = <$fh>) {
             $frame->appendValue("TextCtrl1",$row)
          }
       close $fh;
      }
  }
   };

#Menu Save found, calls function &menu8 
sub menu8 {#called using Menu with lable Save
	my $file= $gui->getFrame()->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl1");
       close $fh
       }
   };

#Menu Quit found, calls function &menu9 
sub menu9 {#called using Menu with lable Quit
	$frame->quit();
   };

#Menuhead Image found
#Menu Load found, calls function &menu12 
sub menu12 {#called using Menu with lable Load
  	if($frame->showDialog("Sure?","This will wipe existing image...proceed?","OKC","!")){
	  $inFile= $frame->showFileSelectorDialog("Open file",1);
	  if ($inFile) {
		  $inFile=(split(/[\/\\]/,$inFile))[-1];
		  copy($inFile,$workingDir."/".$inFile)  or die "could not copy file $inFile in to $workingDir"."/"."$inFile $!";
		  $frame->setImage("Image2",$workingDir."/".$inFile);
	  }
      }
   };


sub menu13 {
     my $p = new Image::Magick;
     $p->Read($workingDir."/".$inFile);
     my @script=split ("\n",$frame->getValue("TextCtrl1"));
     foreach my $line (@script){
		 $line="\$p->".$line;
		 eval $line;
		 print $!;
	 }
	 $p->Write($workingDir."/".$inFile);
	 $frame->setImage("Image2",$workingDir."/".$inFile);

   };


sub menu14 {
	  $outFile= $frame->showFileSelectorDialog("Save file",0);
	  if ($outFile) {
		  copy($workingDir."/".$inFile,$outFile)  or die "could not copy file $workingDir" ."/". "$inFile in to $outFile $!";
	  }

   };


