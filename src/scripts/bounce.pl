#!/usr/bin/env perl 
#A test script that tests timers 
#using GUIDeFATE 

use strict;
use warnings;
use lib"../lib/";
use GUIDeFATE;

my $window=<<END;
+--------------------------+
|T Animation               |
+--------------------------+
| +I--------------------+  |
| | clock.svg           |  |
| |                     |  |
| |                     |  |
| |                     |  |
| |                     |  |
| |                     |  |
| +---------------------+  |
|  ^Choose       ^         |
+--------------------------+

Choose=Slideshow,Spin,Bounce,Clock,ECG
timer 100 choose 1

END

my @chart=();

#for clock
my $hStep=atan2(1,0)/3;
#for spin
my $degrees=0;
#for bounce
my %ball=(
	x   =>50,
	y   =>50,
	dirX=>2.5,
	dirY=>4,
);
# for ecg
my @ecg=(50,45,50,50,60,10,60,50,50,40,40,50,50,50,50,50)x10;
my $index=0;                             #
# for slideshow
my @files = </home/saif/Pictures/*.jpg>; # list picture files
my $number=0;                            # picture number
my $t=10;                                # number of calls before action
# for timing and memory tests
$time=time();

my $backend=$ARGV[0]?$ARGV[0]:"gtk";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
$gui->MainLoop;

sub slideshow{
	return if $t++<10;
	if ($files[$number] && (-f "$files[$number]")){
		$frame->setImage("Image0",$files[$number++]);
	}
	elsif($number>=@files){
		$number=0;
	}
	else {$number++}
	$t=0;
}
sub spin{
     $degrees=($degrees+10)%360;
     my $svg= "<svg height='100' width='100'>
            <circle cx='50' cy='50' r='10' />\n<rect x='45' y='5' width='10' height='50' transform=' rotate($degrees 50 50)' />
            </svg>";
     loadImage ('dial.svg',$svg);     
 }
sub bounce{
	$ball{x}+=$ball{dirX};
	$ball{y}+=$ball{dirY};
	if ($ball{x}>95)   { $ball{x}=95; $ball{dirX}=-$ball{dirX} }
	elsif ($ball{x}<5)  { $ball{x}=5  ; $ball{dirX}=-$ball{dirX} }
	if ($ball{y}>95)   { $ball{y}=95; $ball{dirY}=-$ball{dirY} }
	elsif ($ball{y}<5)  { $ball{y}=5  ; $ball{dirY}=-$ball{dirY} };
	my $svg="<svg height='100' width='100'>\n<circle cx='$ball{x}' cy='$ball{y}' r='10' />\n</svg>\n";
	loadImage('ball.svg',$svg); 
}
sub clock{
	my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	my @numbers=1..12;
    my $clockFace=	"<svg height='100' width='100'>\n  <circle cx='50' cy='50' r='47'  fill='beige' stroke='black' />";
    my $pos=$hStep;
	foreach $number(@numbers){
			$clockFace.="\n  <text  text-anchor='middle' x='". int(50+42*sin($pos) )."' y='". int(55-40*cos($pos)). "'>$number</text>";
			$pos+=$hStep;
		}  
	 $clockFace.= "\n  <rect x='47' y='15' width='6' height='45' fill='red'   transform=' rotate(".int($hour*30+$min/2-5) ." 50 50)' />".
                  "\n  <rect x='48' y='10' width='4' height='50' fill='green' transform=' rotate(".$min*6 .                " 50 50)' />".
                  "\n  <rect x='49' y='5'  width='2' height='50'              transform=' rotate(".$sec*6 .                " 50 50)' />".
                  "</svg>\n";  
                  
	loadImage('clock.svg',$clockFace);
}
sub ecg{
	my $limit=$#ecg;
	my $points="";
	my $x=0;
	foreach ($index..$limit,0..($index-1)){ # the array of points is cycled around $index
		$points.="$x,$ecg[$_] \n";
		$x+=2;
	}
	if ($ecg[$index] <30){ # a peak is detected; Uses system call to produce beep  
		system('( speaker-test -t square -f 500  >/dev/null)& pid=$! ; sleep 0.1s ; kill -9 $pid');
	}
	$index=($index>=$limit)?0:$index+1;  
	my $svg= "<svg height='100' width='100'><polyline points='$points' fill='none' stroke='black'/></svg>\n";
	
	loadImage(	'ecg.svg',$svg);
}
sub choose{            # This is the function called by the timer. 
	my $fn=lc($frame->getValue("combo2") );  
	my $sub=\&{$fn};   # Calls the function selected in the combo 
	$sub->();	
}	
sub combo2{};
sub loadImage{
	my ($filename,$data)=@_;
	open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh $data;
    close $fh;
	$frame->setImage("Image0",$filename); 
}	
