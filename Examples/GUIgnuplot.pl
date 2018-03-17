#!/usr/bin/env perl 
#A test script that crtaes a minimalist gui gnuplot
#uses GUIDeFATE (which in turn depends on Wx or Tk)
#This file designed to be called by Executioner for backend testing

use strict;
use warnings;
use GUIDeFATE;
use File::Copy qw(copy);

my $window=<<END;
+------------------------------------------------------------------------------+
|T  Test GnuPlot                                                               |
+M-----------------------------------------------------------------------------+
|+T------------------------------------++I------------------------------------+|
||plot sin(x)                          ||plotter.png                          ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
||                                     ||                                     ||
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
-Examples
--Sin
--Multiaxis
--Tori

END

my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
$gui->MainLoop;

sub menu6{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	   $frame->setValue("TextCtrl1","");
   }
}
sub menu7{
	if($frame->showDialog("Sure?","This will wipe existing text...proceed?","OKC","!")){
	  $frame->setValue("TextCtrl1","");
	  my $file= $frame->showFileSelectorDialog("Open file",1);
	    if (open(my $fh, '<:encoding(UTF-8)', $file)) {
          while (my $row = <$fh>) {
             $frame->appendValue("TextCtrl1",$row);
          }
       close $fh;
      }
  }
}
sub menu8{
	my $file= $frame->showFileSelectorDialog("Save file",0);
	if (open(my $fh, '>', $file)) {
       print $fh  $frame->getValue("TextCtrl1");
       close $fh
       }
    }
    
sub menu9{
	$frame->quit();
}
sub menu12{
	open(GP, "| gnuplot") or die "Error while piping to Gnuplot: $! \n";
	print GP <<END;
set terminal png size 1024,600
set output 'plotter.png'

END
	print GP $frame->getValue("TextCtrl1");
    
    close(GP);
    $frame->setImage("Image2","plotter.png")
}
sub menu13{
	my $file= $frame->showFileSelectorDialog("Save plot image file",0);
	copy("plotter.png", $file)

}
sub menu16{
	my $plot=<<END;

set title "Simple Plots" font ",20"
set key left box
plot [-30:20] besj0(x)*0.12e1 with impulses, (x**besj0(x))-2.5 with points

END

$frame->setValue("TextCtrl1",$plot);
menu12();
}
sub menu17{
	my $plot=<<END;

A(jw) = ({0,1}*jw/({0,1}*jw+p1)) * (1/(1+{0,1}*jw/p2))
p1 = 10
p2 = 10000
set dummy jw
set grid x y2
set key center top title " "
set logscale xy
set log x2
unset log y2
set title "Transistor Amplitude and Phase Frequency Response"
set xlabel "jw (radians)"
set xrange [1.1 : 90000.0]
set x2range [1.1 : 90000.0]
set ylabel "magnitude of A(jw)"
set y2label "Phase of A(jw) (degrees)"
set ytics nomirror
set y2tics
set tics out
set autoscale  y
set autoscale y2
plot abs(A(jw)) axes x1y1, 180./pi*arg(A(jw)) axes x2y2
END

$frame->setValue("TextCtrl1",$plot);
menu12();
}
sub menu18{
	my $plot=<<END;
set multiplot title "Interlocking Tori"
set title "PM3D surface\\nno depth sorting"

set parametric
set urange [-pi:pi]
set vrange [-pi:pi]
set isosamples 50,20

set origin -0.02,0.0
set size 0.55, 0.9

unset key
unset xtics
unset ytics
unset ztics
set border 0
set view 60, 30, 1.5, 0.9
unset colorbox

set pm3d scansbackward
splot cos(u)+.5*cos(u)*cos(v),sin(u)+.5*sin(u)*cos(v),.5*sin(v) with pm3d, 1+cos(u)+.5*cos(u)*cos(v),.5*sin(v),sin(u)+.5*sin(u)*cos(v) with pm3d

set title "PM3D surface\\ndepth sorting"

set origin 0.40,0.0
set size 0.55, 0.9
set colorbox vertical user origin 0.9, 0.15 size 0.02, 0.50
set format cb "%.1f"

set pm3d depthorder
splot cos(u)+.5*cos(u)*cos(v),sin(u)+.5*sin(u)*cos(v),.5*sin(v) with pm3d, 1+cos(u)+.5*cos(u)*cos(v),.5*sin(v),sin(u)+.5*sin(u)*cos(v) with pm3d

unset multiplot

END

$frame->setValue("TextCtrl1",$plot);
menu12();
}
