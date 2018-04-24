#!/usr/bin/env perl 
# A test script that creates a minimalist test environment for
# websockets file operations and dialog boxes for GUIDeFATE

use strict;
use warnings;
use lib "./";
use GUIDeFATE;

use File::Copy qw(copy);

my $window=<<END;
+-------------------------------------------------------------+
|T  Test Dialogs For Web                                      |
+M------------------------------------------------------------+
|+T------------------------------++I-------------------------+|
||TextCtrl1:                     ||dataFiles/trump.jpg       ||
||                               ||                          ||
||                               ||                          ||
||                               ||                          ||
||                               ||                          ||
||                               ||                          ||
|+-------------------------------------++--------------------+|
| {Dialog} {FileSelector to Open} {File  selector to save}    |
+-------------------------------------------------------------+

END

my $gui=GUIDeFATE->new($window,"web","a");
my $frame=$gui->getFrame()||$gui;
$gui->MainLoop();


sub btn4{
	# the follwing lines add actions to each potential response to
	#the Dialog.  Allowed responses Ok, Cancel, Yes, No and is
	# defined by the parameter in showDialog e.g. OKC= Ok and Cancel,
	# YNC is Yes No and Cancel
	$frame->dialogAction(  "OK",
	     sub{$frame->appendValue("TextCtrl1","\nClicked OK\n"    )   } );
	$frame->dialogAction(  "Cancel",
	     sub{$frame->appendValue("TextCtrl1","\nClicked Cancel\n")   } );
	$frame->showDialog("The Dialog Title",
	                   "The dialog Message goes here",
	                   "OKC","!");
}

sub btn5{
	# the following allows the user to upload a file to the server
	# the server stores the file in a folder called dataFiles in the
	# directory of the running application
	$frame->dialogAction(  "Cancel",
	     sub{$frame->appendValue("TextCtrl1","\nClicked Cancel\n")   } );
	$frame->dialogAction(  "File",
	     sub{  # action to run after file is loaded.
			   # In this example add the filename to the text box
			   # and set the Imagepanel to have this picture
		    my $file=shift;  #the name of the file is passed as parameter
		    $frame->appendValue("TextCtrl1","\n Loaded File: $file \n"),
		    $frame->setImage("Image2","dataFiles/$file")
		 }	);
	$frame->showFileSelectorDialog("Pick a picture File",1,"");
}

sub btn6{
	# the following allows the user to download a file from the server
	# the location of files are in a folder called dataFiles  in the
	# directory of the running application
	$frame->dialogAction(  "Cancel",
	     sub{$frame->appendValue("TextCtrl1","\nClicked Cancel\n")   } );
	$frame->showFileSelectorDialog("Test File Downloader",0,"trump.jng");
}
