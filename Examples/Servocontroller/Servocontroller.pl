#!/usr/bin/env perl 
#A test script that test servo state 
# You need the following available binary to run this demo: fswebcam
#use GUIDeFATE 

use strict;
use warnings;
use lib"../lib/";
use GUIDeFATE;

#use Device::PWMGenerator::PCA9685;
 
#my $dev = Device::PWMGenerator::PCA9685->new(
    #I2CBusDevicePath => '/dev/i2c-1', # this would be '//dev/i2c-dev-0 for Model A Pi
    #debug            => 1,
    #frequency        => 400, #Hz
#);
#$dev->enable();
##$dev->setChannelPWM(4,0,$dutycycle); # Duty cycle values between 0 and 4096 channel 4


my $window=<<END;
+-----------------------------------------------------------------+
|T Servocontroller                                                |
+-----------------------------------------------------------------+
| To calibrate: Capture image then adjust diagram                 |
| To verify: Adjust servo, capture image and match with diagram   |
|                  +I---------------+   +I----------------+       |
|   Camera         | dial.svg       |   | servocam.jpg    |       |
|                  |                |   |                 |       |
|  Controller      |                |   |                 |       |
|                  |                |   |                 |       |
|                  |                |   |                 |       |
|                  |                |   |                 |       |
| [Value   ]{Send} +----------------+   +-----------------+       |
|                      {Calibrate}          {Capture}             |
|                    {CCW}     {CW }      {CCW}     {CW }         |
+-----------------------------------------------------------------+

END

my $degrees=0;
my $pwm=512;

my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"v";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;
drawDial();
$gui->MainLoop;


sub drawDial{
  my $filename = 'dial.svg';
  open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
  print $fh "<svg height='100' width='100'>\n<circle cx='50' cy='50' r='10' />\n<rect x='45' y='5' width='10' height='50' transform=' rotate($degrees 50 50)' />\n</svg>\n";
  close $fh;
  $frame->setImage("Image2","dial.svg"); 
}

sub textctrl9{
	
}

sub btn8{   #send
	
	
}

sub btn10{  #callibrate button pressed
	
	
}

sub btn11{   #capture button pressed
	 `fswebcam -r 640x480 --jpeg 85 -D 1 servocam.jpg`;
	 $frame->setImage("Image2","servocam.jpg"); 
	
}

sub btn12{  #CW button pressed
	 $degrees-=10;
	 drawDial();
}

sub btn13{  #CW button pressed
	 $degrees+=10;
	 drawDial();
}
