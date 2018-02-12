package GUIDeFATE;

   use strict;
   use warnings;
   
   our $VERSION = '0.0.1';

   use parent qw(Wx::App);              # Inherit from Wx::App
   use Exporter 'import';
   use GFrame qw<addButton addStatText addTextCtrl addMenuBits>;
   
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $frame;
   our @EXPORT_OK      = qw<$frame>;  # allows manipulation of frame from main.
   
   sub OnInit
   {
       my $self = shift;
       $frame =  GFrame->new(   undef,         # Parent window
                                   -1,            # Window id
                                   $winTitle, # Title
                                   [1,1],         # position X, Y
                                   [$winWidth, $winHeight]     # size X, Y
                                  );
       $self->SetTopWindow($frame);    # Define the toplevel window
       $frame->Show(1);                # Show the frame
   }

sub convert{
	
	my @lines=(split /\n/ ,shift) ;
	my $assist=shift;
	if ($lines[0] =~ /\-(\d+)x(\d+)-/){
		$winWidth=$1;
	    $winHeight=$2;
	}
	else{
	    $winWidth=16*(length $lines[0])-16;
	}
	shift @lines;
	if ($lines[0]=~/\|T\s*(\S.*\S)\s*\|/){
		$winTitle=$1;
		print "Title=".$winTitle."\n";
		shift @lines;
	}
	my $l=0;my $bid=0;
	foreach my $line (@lines){
		last if ($line eq "");
		while ($line =~m/(\{([^}]*)\})/g){
			my $ps=length($`);
			print "Button with label '". $2."' calls function &btn$bid\n";
			addButton([$bid, $2,[$ps*16-8,$l*32],[length($2)*16+24,32], \&{"main::btn".$bid++}]);
		}
		while ($line=~m/(\[([^\]]+)\])/g){
			my ($ps,$all,$content)=(length($`),$1,$2);
			$content=~s/_/ /g;
			print "Text Control with default text '". $content."', calls function &textctrl$bid \n";
			addTextCtrl([$bid, $content,[$ps*16-8,$l*32],[length($content)*16+24,32], \&{"main::textctrl".$bid++}]);
		}
		if ($line !~ m/\+/){
		  my $tmp=$line;
		  $tmp=~s/^\|\s+|(\[([^\]]+)\])|(\{([^}]*)\})|\s+\|$//g;
		  if (length $tmp){
			  print "Static text '".$tmp."'  with id stattext$bid\n";
		      $line=~m/$tmp/;my $ps=length($`);
		      addStatText([$bid++, $tmp,[$ps*16-8,$l*32],[length($tmp)*16+24,32]]);
		  }
	     }
		$l++;		
	}
	if(!$winHeight) {$winHeight=32*($l-1)};
	
	my $mode="";
	while ($l++<=scalar(@lines)){
		next if ((!$lines[$l]) || ($lines[$l] eq "")||($lines[$l]=~m/^#/));
		if ($lines[$l]=~/menu/i){
			print "Menu found\n";
			$mode="menu";
			next;};
		if($mode eq "menu"){
			if ($lines[$l]=~/^\-([A-z0-9].*)/i){
				print "Menu bar $1 found\n";
				addMenuBits([$bid++, $1, "menu", ""]);
				}
			elsif($lines[$l]=~/^\-{2}([A-z0-9].*)\;radio/i){
				print "Menu $1  as radio found, calls function &menu$bid \n";
				addMenuBits([$bid, $1, "radio", \&{"main::menu".$bid++}]);
				}
			elsif($lines[$l]=~/^\-{2}([A-z0-9].*)\;check/i){
				print "Menu $1 as check found, calls function &menu$bid \n";
				addMenuBits([$bid, $1, "check", \&{"main::menu".$bid++}]);
				}
			elsif($lines[$l]=~/^\-{6}/){
				print "Separator found,\n";
				addMenuBits([$bid++, "", "separator",""]);
				}
		    elsif($lines[$l]=~/^\-{2}([A-z0-9].*)/i){
				print "Menu $1 found, calls function &menu$bid \n";
				addMenuBits([$bid, $1, "normal", \&{"main::menu".$bid++}]);
				}
		    elsif($lines[$l]=~/^\-{3}([A-z0-9].*)/i){print "SubMenu $1 found\n";}
		}
		
		}
		
}

sub assist{}


1;
