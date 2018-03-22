#!/usr/bin/env perl 
#A test script that creates a minimalist image magick
#uses GUIDeFATE (which in turn depends on Wx, Tk or Gtk)
#uses Image Magick https://xkcd.com/979/

use strict;
use warnings;
use lib "../lib/";
use GUIDeFATE;
use Image::Magick;
use File::Copy;

my %IMCommands;
open my $in, '<', "IMCommands.pl" or die $!;
{   local $/;   
    %IMCommands = eval <$in>;
}
close $in;

my $menuString=makeGFMenu(17);

my $window=<<END;
+--------------------------------------------------------+
|T  Image Magick GUI                                     |
+M-------------------------------------------------------+
|+T--------------++I------------------------------------+|
||#script;       ||ImageMagick.png                      ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
||               ||                                     ||
|+---------------++-------------------------------------+|
+--------------------------------------------------------+

Menu
-File
--New Script
--Open Script
--Save Script
--Quit
-Image
--Load Image
--Reload Image
--Run Script
--Save Image
--Undo
--Batch Process
$menuString
END


my $inFile;
my $workingFile;
my $outFile;
my $workingDir="tmp";

unless (-e $workingDir and -d $workingDir){mkdir $workingDir};


my $backend=$ARGV[0]?$ARGV[0]:"gtk";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame||$gui;
$gui->MainLoop;


sub menu6 { #called using Menu with label New
	if($frame->showDialog("Sure?","This will wipe existing script...proceed?","OKC","!")){
	   $frame->setValue("TextCtrl1","");
   }
   };

sub menu7 {#called using Menu with label Open
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
sub menu8 {#called using Menu with label Save
	my $file= $gui->getFrame()->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl1");
       close $fh
       }
   };

#Menu Quit found, calls function &menu9 
sub menu9 {#called using Menu with label Quit
	$frame->quit();
   };

#Menuhead Image found
#Menu Load found, calls function &menu12 
sub menu12 {#called using Menu with label Load Image
  	if($frame->showDialog("Sure?","This will wipe existing image...proceed?","OKC","!")){
	  $inFile= $frame->showFileSelectorDialog("Open file",1);
	  if ($inFile) {loadImage($inFile) };
    }
   };


sub menu13 {#called using Menu with label Reload Image
  	if($frame->showDialog("Sure?","This will wipe existing image...proceed?","OKC","!")){
	  if ($inFile) {loadImage($inFile) };
	}
};

sub menu14 {#called using Menu with label Run Script
     my $p = new Image::Magick;
     $p->Read($workingFile);
     my @script=split (";",$frame->getValue("TextCtrl1"));
     foreach my $line (@script){
		 $line=~s/\n//;
		 $line="\$p->".$line;
		 eval $line;
		 print $!;
	 }
	 copy($workingFile,$workingFile.".bak") ;
	 $p->Write($workingFile);
	 $frame->setImage("Image2",$workingFile);

   };

sub menu15 {#called using Menu with label Undo
	if (-e $workingDir."/".$inFile.".bak")
		{copy($workingFile.".bak",$workingFile)};
	loadImage($workingFile);
	
	
};


sub menu16 {
	  $outFile= $frame->showFileSelectorDialog("Save file",0);
	  if ($outFile) {
		  copy($workingFile,$outFile)  or die "could not copy file $workingFile into $outFile $!";
	  }

   };


sub loadImage{
	my $fileToLoad=shift;
	$workingFile= $fileToLoad; 
	$workingFile=$workingDir."/".(split(/[\/\\]/,$workingFile))[-1];
	if (-e $workingFile) {   copy($workingFile,$workingFile.".bak")  };
	copy($fileToLoad,$workingFile)  or die "could not copy file $fileToLoad into $workingFile $!";
	$frame->setImage("Image2",$workingFile);
}

sub makeGFMenu{
	my %IMMenu; my $type; my $menuString;my $commandsList; my $index=shift;
	foreach  my $function (keys %IMCommands){
		$type= ($IMCommands{$function}{Type} eq "")?"Misc":$IMCommands{$function}{Type};
		if (!exists $IMMenu{$type}){ $IMMenu{$type}=[];};
		push (@{$IMMenu{$type}}, $function);
	}
	foreach  my $menuHead (sort(keys %IMMenu)){
		$menuString.="-$menuHead\n";
		$index+=2;
		foreach my $menuItem (sort(@{$IMMenu{$menuHead}})){
			$index++;
			$menuString.="--$menuItem\n";
			eval "sub menu$index {makePopUp($menuItem)};";
		}
	} 
	return $menuString;	
}

sub makePopUp{

	my $command=shift;
	if ($frame->showDialog($command,$IMCommands{$command}{Description}, "OKC" , "I") ){
		my $params=$IMCommands{$command}{Parameters};
		$params=~s/(([a-z]+=>[^{,]+,)|([a-z]+=>{[^}]+}),)/ $1\n/g;  
		$frame->appendValue("TextCtrl1","\n$command(\n$params\n);\n");
	}
	
}

