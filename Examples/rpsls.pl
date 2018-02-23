#!/usr/bin/env perl
#A test script that  plays Rock Paper Scissors Lizard Spock
#use GUIDeFATE (which in turn depends on Wx and Wx::Perl::Imagick)

use strict;
use warnings;
use GUIDeFATE qw<$frame>;

my $window=<<END;
+------------------------------------------------+
|T Rock Paper Scissors Lizard Spock              |
+------------------------------------------------+
|                                                |
| Play Rock Paper   +I------+                    |
| Scissors Lizard   |rock.jp|                    |
| Spock.  Click     |g      |                    |
| any button to     +-------+                    |
| play              { Rock }                     |
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
|          { Lizard }       { Scissors }         |
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

GUIDeFATE::convert($window, "v");
my $gui=GUIDeFATE->new();
$gui->MainLoop;

#Subroutines called by clicking buttons
#function names are btn<id>
sub btn5 { getResults("rock") ;    }
sub btn10{ getResults("spock");    }
sub btn11{ getResults("paper");    }
sub btn15{ getResults("lizard");   }
sub btn16{ getResults("scissors"); }

#Function described by u/choroba at reddit
sub getResults {
	my $player = shift;
	my $computer = (keys %rpsls)[rand 5];

	# setImage takes the Filename, id number of subpanel, and a pixel size (as a list)
	$frame->setImage($rpsls{$computer}{file},9,[136,128]);

	if ($rpsls{$player}{$computer}) {
    $frame->{stattext12}->SetLabel("You $rpsls{$player}{$computer} me!");
  }
  elsif ($player eq $computer) {
    $frame->{stattext12}->SetLabel("Draw");
  }
  else {
    $frame->{stattext12}->SetLabel("I $rpsls{$computer}{$player} you!");
  }
}
