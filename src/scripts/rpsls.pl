#!/usr/bin/env perl 
#A test script that  plays Rock Paper Scissors Lizard Spock
#use GUIDeFATE 

use strict;
use warnings;
use lib"../lib/";
use GUIDeFATE;

my $window=<<END;
+------------------------------------------------+
|T Rock Paper Scissors Lizard Spock              |
+------------------------------------------------+
|                                                |
| Play Rock Paper   +I------+                    |
| Scissors Lizard   |rock.bm|                    |
| Spock. Click      |p      |                    |
| any button to     +-------+                    |
| play              { Rock  }                    |
|                                                |
|   +I------+                       +I------+    |
|   |Spock.j|       +I------+       |paper.j|    |
|   |pg     |       |sister.|       |pg     |    |
|   +-------+       |jpg    |       +-------+    |
|   { Spock }       +-------+       { Paper }    |
|                  I am ready                    |
|                                                |
|          +I------+         +I------+           |
|          |Lizard.|         |scissor|           |
|          |jpg    |         |s.jpg  |           |
|          +-------+         +-------+           |
|          {Lizard }         {Scissrs}           |
|                                                |
+------------------------------------------------+


END

my %rpsls = (rock     => {scissors => 'crush',
                          lizard   => 'crush',
                          file     => 'rock.jpg'},
             paper    => {rock     => 'cover',
                          spock    => 'disprove',
                          file     => 'paper.jpg'},
             scissors => {paper    => 'cut',
                          lizard   => 'decapitate',
                          file     => 'scissors.jpg'},
             lizard   => {spock    => 'poison',
                          paper    => 'eat',
                          file     => 'Lizard.jpg'},
             spock    => {scissors => 'smash',
                          rock     => 'vaporize',
                          file     => 'Spock.jpg'});


my $backend=$ARGV[0]?$ARGV[0]:"wx";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame|| $gui;
$gui->MainLoop;

#Subroutines called by clicking buttons
#function names are btn<id>
sub btn6 {  getResults("rock") ;   }
sub btn14{  getResults("spock");   }
sub btn15{  getResults("paper");   }
sub btn21{  getResults("lizard");  }
sub btn22{  getResults("scissors");}

#Function described by u/choroba at reddit
sub getResults{
	my $player= shift;
	my $computer=(keys %rpsls)[rand 5];
	
	# setImage takes the Filename, id number of subpanel
	$frame->setImage("Image12",$rpsls{$computer}{file}); 

	if ($rpsls{$player}{$computer}) {
       $frame->setLabel("stattext16","You $rpsls{$player}{$computer} me!");
    }
    elsif ($player eq $computer) {
       $frame->setLabel("stattext16","Draw");
    }
    else {
       $frame->setLabel("stattext16","I $rpsls{$computer}{$player} you!");
    }
}




