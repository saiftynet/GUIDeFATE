package GUIDeFATE;

   use strict;
   use warnings;
   
   our $VERSION = '0.06';
   
   use Exporter 'import';
   
   our @EXPORT_OK      = qw<$frame>;  # allows manipulation of frame from main.
   our $target="wx";
   our $AppObject;
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $winScale=6.5;     
   my  $autoGen="";
   my  $log="";

sub new{
	my ($class,$textGUI,$target,$assist)=@_;
	if ((!$target)||($target=~/wx/i)){
		$target="wx";
		eval " use GFwx qw<addButton addStatText addTextCtrl addMenuBits addPanel setScale
		           \$frame \$winScale \$winWidth \$winHeight \$winTitle>;";
		convert($textGUI,$assist);
		return GFwx->new(); ;
	}
	elsif ($target =~m/tk/i){
		eval " use GFtk qw<addButton addStatText addTextCtrl addMenuBits addPanel setScale 
		           \$frame \$winScale \$winWidth \$winHeight \$winTitle>;";
		convert($textGUI, $target);
		return GFtk->new(); 
	}
}


sub convert{
	my($textGUI,$assist)=@_;
	my @lines=(split /\n/ ,$textGUI) ;
	if (!$assist){$assist="q"};
		           
	my $verbose= $assist=~/v/;
	my $debug= $assist=~/d/;
	my $auto= $assist=~/a/;
	
	setScale($winScale);  # makes scaling in the two modules match
	
	if ($lines[0] =~ /\-(\d+)x(\d+)-/){
		$winWidth=$1;
	    $winHeight=$2;
	}
	else{
	    $winWidth=$winScale*(2*(length $lines[0])-2);
	}
	shift @lines;
	if ($lines[0]=~/\|T\s*(\S.*\S)\s*\|/){
		$winTitle=$1;
		if ($verbose){print "Title=".$winTitle."\n"};
		shift @lines;
	}
	my $l=0;my $bid=0;
	
	
	foreach my $line (@lines){
		last if ($line eq "");         # blank line determines end of window 
		while  ($line =~m/(\+([A-z]?)[A-z\-]+\+)/){
			my $ps=length($`); my $fl=length($1)-2;my $fh=1; my $panelType=$2;
			$lines[$l]=~s/(\+([A-z]?)[A-z\-]+\+)/" " x ($fl+2)/e;
			my $reg=qr/^.{$ps}\K(\|.{$fl}\|)/;my $content="";   #\K operator protects the previous match from the deletion to follow
			while  ($ps && ($lines[$l+$fh] =~m/$reg/g)){
				my $tmp=$1;  
				$tmp=~s/^\||\|//g;
				$content.=$tmp;
				$lines[$l+$fh]=~s/$reg/" " x ($fl+2)/e;       #delete the frame by overwriting with spaces
				$fh++;
			}
			$fh++;
			if ($ps  && ($fh-2)) {
				$log="SubPanel '$panelType' Id $bid found position  $ps height $fh width $fl at row $l with content $content \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log; }
				addPanel([$bid,$panelType,$content,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*($fl*2+3),$winScale*$fh*4]]);
				$bid+=2; # id goes up by 2, one for the panel and one for the content;
			};    
		}
		
		
		while ($line =~m/(\{([^}]*)\})/g){   # buttons are made from { <label> } 
			my $ps=length($`);my $label=$2; my $len=length ($label);$label=~s/^(\s+)|(\s+)$//g;
			$log= "Button with label '$label' calls function &btn$bid\n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.=makeSub("btn$bid", "button with label $label "); }			
			addButton([$bid, $label,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*($len*2+3),$winScale*4], \&{"main::btn".$bid++}]);
			$line=~s/(\{([^}]*)\})/" " x length($1)/e;     #remove buttons replacing with spaces
		}
		while ($line=~m/(\[([^\]]+)\])/g){   # text ctrls are made from [ default text ] 
			my ($ps,$all,$content)=(length($`),$1,$2);
			$log= "Text Control with default text ' $content ', calls function &textctrl$bid \n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.=makeSub("textctrl$bid","Text Control with default text ' $content '" ); }	
			addTextCtrl([$bid, $content,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*(length($content)*2+3),$winScale*4], \&{"main::textctrl".$bid++}]);
			$line=~s/(\[([^\]]+)\])/" " x length($1)/e;     #remove text controls replacing with spaces
		}
		if ($line !~ m/\+/){
		  my $tmp=$line;
		  $tmp=~s/(\[([^\]]+)\])|(\{([^}]*)\})/" " x length $1/ge;    
		  $tmp=~s/^(\|)|(\|)$//g;                                     #remove starting and ending border
		  $tmp=~s/^(\s+)|(\s+)$//g;                                   #remove spaces                                 
		  if (length $tmp){
			  $log= "Static text '".$tmp."'  with id stattext$bid\n"; ##
			  if ($verbose){ print $log; }
			  if ($auto){ $autoGen.="#".$log; }
		      $line=~m/$tmp/;my $ps=length($`);
		      addStatText([$bid++, $tmp,[$winScale*($ps*2-1),$winScale*$l*4]]);
		  }
	     }
		$l++;		
	}
	if(!$winHeight) {$winHeight=$winScale*4*($l-1)};
	
	my $mode="";
	while ($l++<=scalar(@lines)){
		next if ((!$lines[$l]) || ($lines[$l] eq "")||($lines[$l]=~m/^#/));
		if ($lines[$l]=~/menu/i){
			$log="Menu found\n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.="#".$log; }
			$mode="menu";
			next;};
		
		if($mode eq "menu"){
			if ($lines[$l]=~/^\-([A-z0-9].*)/i){
				$log= "Menuhead $1 found\n"; ##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log; }
				addMenuBits([$bid++, $1, "menuhead", undef]);
				}
			elsif($lines[$l]=~/^\-{2}([A-z0-9].*)\;radio/i){
				$log= "Menu $1  as radio found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid"); }
				addMenuBits([$bid, $1, "radio", \&{"main::menu".$bid++}]);
				}
			elsif($lines[$l]=~/^\-{2}([A-z0-9].*)\;check/i){
				$log= "Menu $1 as check found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid"); }
				addMenuBits([$bid, $1, "check", \&{"main::menu".$bid++}]);
				}
			elsif($lines[$l]=~/^\-{6}/){
				$log= "Separator found,\n"; ##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid"); }
				addMenuBits([$bid++, "", "separator",""]);
				}
		    elsif($lines[$l]=~/^\-{2}([A-z0-9].*)/i){
				$log= "Menu $1 found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid"); }
				}
				addMenuBits([$bid, $1, "normal", \&{"main::menu".$bid++}]);
				}
		    elsif($lines[$l]=~/^\-{3}([A-z0-9].*)/i){
				$log= "SubMenu $1 found\n";##
				}
		}
		
		if ($auto){
			open(my $fh, '>', 'autogen.txt');
            print $fh $autoGen;
            close $fh;
		}
	
	sub makeSub{
	  my ($subName, $trigger)=@_;
	  return "sub $subName #called using $trigger\n  {\n  # subroutione code goes here\n   };\n\n";
    }


    sub debugGui{ # for debugging parsing...insert after deletion of discovered content
       my @gui=shift;
	   foreach my $deb (@gui){
		  last if ($deb eq "");
		  print $deb."\n";
	}
  }
}

1;
=head1 GUIDeFATE

GUIDeFATE  -  Graphical User Interface Design From A Text Editor

=head1 SYNOPSIS

    use GUIDeFATE qw<$frame>;

    my $window=<<END;
    +------------------------+
    |T  Calculator           |
    +M-----------------------+
    |  [                  ]  |
    |  { V }{ % }{ C }{AC }  |
    |  { 1 }{ 2 }{ 3 }{ + }  |
    |  { 4 }{ 5 }{ 6 }{ - }  |
    |  { 7 }{ 8 }{ 9 }{ * }  |
    |  { . }{ 0 }{ = }{ / }  |
    |  made with GUIdeFATE   |
    |  and happy things      |
    +------------------------+

    END

    my $gui=GUIDeFATE->new($window);
    $frame=$gui->getFrame;
    $gui->MainLoop;

=head1 REQUIRES

Perl5.8.8, Exporter, Wx, Wx::Perl::Imagick (for Wx interface)
Perl5.8.8, Exporter, Tk, Image::Imagick, Tk::JPEG, MIME::Base64 (for Tk interface)

=head1 EXPORTS

$frame

=head1 DESCRIPTION

GUIDeFATE enables the user to convert a textual representtaion into a Graphical user Interface
It attempts to abstract out the underlying framework.  A visually recognisable pattern is passed
as a string to GUIDeFATE and this is transformed into an Interactive Interface.

=head1 METHODS

=head2 Creation

=over 4

=item my $gui=GUIDeFATE->new($window, $backend, $options);

Extracts dimensions and wdigets in a window from the textual representation

=item my $frame=$gui->getFrame;

Returns reference to the frame for both abstracted and backend specific functions 

=back

=head1 AUTHOR

Saif Ahmed, SAIFTYNET { at } gmail.com

=head1 SEE ALSO

L<Wx>, L<Tk>, L<Image::Magick>, L<Wx::Perl::Imagick>,

=cut
