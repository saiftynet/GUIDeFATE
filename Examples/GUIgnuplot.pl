#!/usr/bin/env perl 
#A test script that crtaes a minimalist gui gnuplot
#use GUIDeFATE (which in turn depends on Wx)

use strict;
use warnings;
use GUIDeFATE qw<$frame>;
use File::Copy qw(copy);

my $window=<<END;
+------------------------------------------------------------------------------+
|T  Test GnuPlot                                                               |
+M-----------------------------------------------------------------------------+
|+T------------------------------------++I------------------------------------+|
||text editor                          ||plotter.png                          ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
|+-------------------------------------++-------------------------------------+|
|                                                                              |
+------------------------------------------------------------------------------+

Menu
-File
--New
--Open
--Save
--Quit
-Chart
--Plot
--Save As

END

GUIDeFATE::convert($window, "v");
my $gui=GUIDeFATE->new();
#  $frame->setImage("Spock.jpg",2);
$gui->MainLoop;

sub menu6{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	   $frame->{TextCtrl1}->SetValue("");
   }
}
sub menu7{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	  $frame->{TextCtrl1}->SetValue("");
	  my $file= $frame->showFileSelectorDialog("Open file",1);
	    if (open(my $fh, '<:encoding(UTF-8)', $file)) {
          while (my $row = <$fh>) {
             $frame->{TextCtrl1}->AppendText($row)
          }
       close $fh;
      }
  }
}
sub menu8{
	my $file= $frame->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->{TextCtrl1}->GetValue();
       close $fh
       }
    }
    
sub menu9{
	$frame->quit();
}
sub menu12{
	open(GP, "| gnuplot") or die "Error while piping to Gnuplot: $! \n";
	print GP "\nset terminal png\nset output 'plotter.png'\n";
	print GP $frame->{TextCtrl1}->GetValue();
    
    close(GP);
    $frame->setImage("plotter.png",2)
}
sub menu13{
	my $file= $frame->showFileSelectorDialog("Save plot image file",0);
	copy("plotter.png", $file)

}
sub menu14{
	
}
