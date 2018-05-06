package GUIDeFATE;

   use strict;
   use warnings;
   
   our $VERSION = '0.10';
   
   use Exporter 'import';
   
   our @EXPORT_OK      = qw<$frame>;  # allows manipulation of frame from main.
   our $target="";
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
	(my $class,my $textGUI,$target,my $assist, my $port)=@_;
	if ((!$target)||($target=~/^wx/i)){
		$target="wx";
		die "Failed to load Wx backend: $@" unless eval { require GFwx} ;  GFwx->import;
		convert($textGUI,$assist);
		return  GFwx->new(); ;
	}
	elsif ($target =~m/^gtk/i){
		$target="gtk";
		die "Failed to load Gtk backend: $@" unless eval { require GFgtk} ; GFgtk->import;
		convert($textGUI, $assist);
		return GUIDeFATE::GFgtk->new(); 
		
	}	
	elsif ($target =~m/^tk/i){
		$target="tk";
		die "Failed to load Tk backend: $@" unless eval { require GFtk };  GFtk->import;
		convert($textGUI, $assist);
		return GFtk->new(); 
	}
	elsif ($target =~m/^qt/i){
		$target="qt";
		die "Failed to load Qt backend: $@" unless eval  { require  GFqt }; GFqt->import;
		convert($textGUI, $assist);
		my $qtWin=GFqt->new(); 
		return $qtWin;
	}
	elsif ($target =~m/^win32/i){
		$target="win32";
		die "Failed to load Win32 backend: $@" unless eval { require GFwin32 };GFwin32->import;
		convert($textGUI, $assist);
		return GFwin32->new(); 
	}
	elsif ($target =~m/^html/i){
		$target="html";
		die "Failed to load HTML backend: $@" unless eval { require GFhtml }; GFhtml->import;
		convert($textGUI, $assist);
		return GFhtml->new(); 
	}
	elsif ($target =~m/^web$/i){
		$target="web"; 
		die "Failed to load WebSocket backend: $@" unless eval {require GFweb }; GFweb->import;
		convert($textGUI, $assist);
		return GFweb->new($port,($assist=~/d/i)); 
	}
}

sub convert{
	my($textGUI,$assist)=@_;
	my @lines=(split /\n/ ,$textGUI) ;
	if (!$assist){$assist="q"};
		           
	my $verbose= $assist=~/^v/i;
	my $debug= $assist=~/^d/i;
	my $auto= $assist=~/^a/i;
	
	if (!exists &{"setScale"}){print "Error exists in GF$target\n"; return;}
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
				$content=~s/^\s+|\s+$//g;
				$log="SubPanel '$panelType' Id $bid found position  $ps height $fh width $fl at row $l with content $content \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log; }
				addWidget(["sp",$bid,$panelType,$content,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*($fl*2+3),$winScale*$fh*4]]);
				$bid+=2; # id goes up by 2, one for the panel and one for the content;
			};    
		}
		
		while ($line =~m/(\^([A-z]+)\s*\^)/g){ #ComboBoxes
			my $ps=length($`);my $label=$2; my $len=length ($label);$label=~s/^(\s+)|(\s+)$//g;
			$line=~s/(\^([A-z]+)\s*\^)/" " x length($1)/e;
			$log= "combobox calls function &combo$bid\n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.=makeSub("combo$bid", "combobox with data from \@$label"); }
			addWidget(["combo",$bid,$label,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*($len*2+3),$winScale*4], \&{"main::combo".$bid}]);
			$bid++;
		}
		while ($line =~m/(\{([^}]*)\})/g){   # buttons are made from { <label> } 
			my $ps=length($`);my $label=$2; my $len=length ($label);$label=~s/^(\s+)|(\s+)$//g;
			$log= "Button with label '$label' calls function &btn$bid\n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.=makeSub("btn$bid", "button with label $label "); }			
			addWidget(["btn",$bid, $label,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*($len*2+3),$winScale*4], \&{"main::btn".$bid}]);
			$bid++;
			$line=~s/(\{([^}]*)\})/" " x length($1)/e;     #remove buttons replacing with spaces
		}
		while ($line=~m/(\[([^\]]+)\])/g){   # text ctrls are made from [ default text ] 
			my ($ps,$all,$content)=(length($`),$1,$2);
			$log= "Text Control with default text ' $content ', calls function &textctrl$bid \n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.=makeSub("textctrl$bid","Text Control with default text ' $content '" ); }	
			my $trimmed=$content; $trimmed=~s/(\s+)|(\s+)$//g; 
			addWidget(["textctrl",$bid, $trimmed,[$winScale*($ps*2-1),$winScale*$l*4],[$winScale*(length($all)*2-1),$winScale*4], \&{"main::textctrl".$bid}]);
			$bid++;
			$line=~s/(\[([^\]]+)\])/" " x length($1)/e;     #remove text controls replacing with spaces
		}
		if ($line !~ m/^\+/){
		  my $tmp=$line;
		  $tmp=~s/(\[([^\]]+)\])|(\{([^}]*)\})/" " x length $1/ge;    
		  $tmp=~s/^(\|)|(\|)$//g;                                     #remove starting and ending border
		  $tmp=~s/^(\s+)|(\s+)$//g;                                   #remove spaces                                 
		  if (length $tmp){
			  $log= "Static text '".$tmp."'  with id stattext$bid\n"; ##
			  if ($verbose){ print $log; }
			  if ($auto){ $autoGen.="#".$log; }
		      $line=~m/\Q$tmp\E/;my $ps=length($`);
		      addWidget(["stattext",$bid++, $tmp,[$winScale*($ps*2-1),$winScale*$l*4]]);
		  }
	     }
		$l++;		
	}
	if(!$winHeight) {$winHeight=$winScale*4*($l-1)};
	
	my $mode="";
	while ($l++<=scalar(@lines)){
		my $line=$lines[$l];
		if ((!$line) || ($line eq "")||($line=~/^#/)){
			$mode="";next;
			}
		elsif ($line=~/menu/i){
			$log="Menu found\n"; ##
			if ($verbose){ print $log; }
			if ($auto){ $autoGen.="#".$log; }
			$mode="menu";
			next;}
		elsif($line=~/^([A-z]+=)/){
			chomp $line;
			my ($varName,$value)=split(/=/,$line,2);
			$log="var ' $varName ' has value ' $value '\n"; ##
			addVar($varName,$value);
		}
		
		if($mode eq "menu"){
			if ($line=~/^\-([A-z0-9].*)/i){
				$log= "Menuhead $1 found\n"; ##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log; }
				addWidget(["mb",$bid, $1, "menuhead", undef]);
				$bid++;
				}
			elsif($line=~/^\-{2}([A-z0-9].*)\;radio/i){
				$log= "Menu $1  as radio found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid","Menu with label $1"); }
				addWidget(["mb",$bid, $1, "radio", \&{"main::menu".$bid}]);
				}
			elsif($line=~/^\-{2}([A-z0-9].*)\;check/i){
				$log= "Menu $1 as check found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid","Menu with label $1"); }
				addWidget(["mb",$bid, $1, "check", \&{"main::menu".$bid}]);
				}
			elsif($lines[$l]=~/^\-{6}/){
				$log= "Separator found,\n"; ##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid","Menu with label $1"); }
				addWidget(["mb",$bid, "", "separator",""]);
				}
		    elsif($line=~/^\-{2}([A-z0-9].*)/i){
				$log= "Menu $1 found, calls function &menu$bid \n";##
				if ($verbose){ print $log; }
				if ($auto){ $autoGen.="#".$log.makeSub("menu$bid","Menu with label $1"); }
				}
				addWidget(["mb",$bid, $1, "normal", \&{"main::menu".$bid}]);
				}
		    elsif($line=~/^\-{3}([A-z0-9].*)/i){
				$log= "SubMenu $1 found\n";##
				}
			$bid++;
		}
		
		if ($auto){
			open(my $fh, '>', 'autogen.txt');
            print $fh $autoGen;
            close $fh;
		}
	
	sub makeSub{
	  my ($subName,$trigger)=@_;
	  return "sub $subName {#called using $trigger\n  # subroutione code goes here\n   };\n\n";
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

    use GUIDeFATE;

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

    my $gui=GUIDeFATE->new($window,[$backend],[$assist]); # API changed at version 0.06
    # $backend is one of Wx(Default), Tk or Gtk
    # $assist is one or  "q" (quiet, default), "v" (verbose), "d" for debug (websocket) or "a" for Autogenerate
    
    $frame=$gui->getFrame||$gui;
    $gui->MainLoop;

=head1 REQUIRES

Perl5.8.8, Exporter, Wx, Wx::Perl::Imagick (for Wx interface)
Perl5.8.8, Exporter, Tk, Image::Magick, Tk::JPEG, MIME::Base64 (for Tk interface)
Perl5.8.8, Exporter, Glib, Gtk (for Gtk interface)
Perl5.8.8, Exporter, QtCore4, QtGui4 (for Qt interface)
Perl5.8.8, Exporter, Win32, Imager (for Win32 interface)
Perl5.8.8, Exporter (for HTML interface)
Perl5.8.8, Exporter, Net::WebSocket::Server, IO::Socket::PortState (for WebSocket interface)

=head1 EXPORTS

getFrame()
returns an object containing Widgets (referencesd by id) and
GUI interaction functions. This is actually provided by the middle-man
((GFwx, GFtk etc) but not availlable for GFhtml  of GFweb

=head1 DESCRIPTION

GUIDeFATE enables the user to convert a textual representation into a
Graphical User Interface. It attempts to abstract out the underlying
framework.  A visually recognisable pattern is passed as a string to
GUIDeFATE and this is transformed into an Interactive Interface.

=head1 METHODS

=head2 Creation

=over 4

=item my $gui=GUIDeFATE->new($window, $backend, $options);

Extracts dimensions and widgets in a window from the textual
representation.
If $backend not provided, defaults to "Wx"; options are Wx and Tk,
Gtk, Qt, Win32 and Web
If $options contains "v", then a verbose output is sent to console,
if it contains "a", and autogenerated file is produced with all the
called functions

Web Socket applications can made.  In such cases generating the client
and server parts can be directed to use a particular port/host

    my $gui=GUIDeFATE->new($window,[$backend],[$assist],[$port]);

$port can be a port number (default 8085), or "<host>:<port>" e.g.
"example.com:8085" (default host is localhost) or possibly (untested)
an SSL socket.

or

=item my $frame=$gui->getFrame || $gui;

Returns reference to the frame for both abstracted and backend
specific functions.

For more details visit The GUIDeFATE wiki at its Github pages

=back

=head1 AUTHOR

Saif Ahmed, SAIFTYNET { at } gmail.com

=head1 SEE ALSO

L<Wx>, L<Tk>, L<Image::Magick>, L<Wx::Perl::Imagick>,
L<Imager>,L<Win32>,
L<GLib>, L<Gtk3>, L<Win32>, L<QtCore4>,
L<Net::WebSocket::Server>

=cut
