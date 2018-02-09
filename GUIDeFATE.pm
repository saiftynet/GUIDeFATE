 GUIDeFATE;

   use strict;
   use warnings;

   use parent qw(Wx::App);              # Inherit from Wx::App
   use Exporter 'import';
   use GFrame qw<addButton addStatText addTextCtrl>;
   
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $frame;
   our @EXPORT_OK      = qw<$frame>;  # allows manipulation of frame from 
   
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
	if ($lines[0] =~ /\-(\d+)x(\d+)-/){
		$winWidth=$1;
	    $winHeight=$2;
	}
	else{
	    $winWidth=16*(length $lines[0])-16;
	    $winHeight=24*(scalar @lines);
	}
	shift @lines;
	if ($lines[0]=~/\|T\s*(\S.*\S)\s*\|/){
		$winTitle=$1;
		print "Title=".$winTitle."\n";
		shift @lines;
	}
	my $l=0;my $bid=0;
	foreach my $line (@lines){
		while ($line =~m/(\{([^}]*)\})/g){
			my $ps=length($`);
			print "Button with label '". $2."' calls function &btn$bid\n";
			addButton([$bid, $2,[$ps*16-8,$l*32],[length($2)*16+24,32], \&{"main::btn".$bid++}]);
		}
		while ($line=~m/(\[([^\]]+)\])/g){
			my ($ps,$all,$content)=(length($`),$1,$2);
			$content=~s/_/ /g;
			print "Text Control with default text '". $content."' calls function &textctrl$bid\n";
			addTextCtrl([$bid, $content,[$ps*16-8,$l*32],[length($content)*16+24,32], \&{"main::textctrl".$bid++}]);
		}
		if ($line !~ m/\+/){
		  my $tmp=$line;
		  $tmp=~s/^\|\s+|(\[([^\]]+)\])|(\{([^}]*)\})|\s+\|$//g;
		  if (length $tmp){
			  print "Static text '".$tmp."'  with id stattext$bid\n";
		      $line=~m/$tmp/;my $ps=length($`);
		      addStatText([$bid, $tmp,[$ps*16-8,$l*32]]);
		  }
	     }
		$l++;
	}
	
}

   
1;
