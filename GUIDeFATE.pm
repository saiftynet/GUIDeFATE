   package MyFrame;
   use Wx;
   use Wx qw( wxTE_PASSWORD wxTE_PROCESS_ENTER );
   use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI );
   
   use base qw/Wx::Frame/; # Inherit from Wx::Frame
   
   my @buttons=();
   my @textctrls=();
   my @stattexts=();
   
   sub new
   {
    my $class = shift;    
    my $self = $class->SUPER::new(@_);  # call the superclass' constructor
   
       # Then define a Panel to put the content on
    my $panel = Wx::Panel->new( $self,  # parent
                                -1      # id
                              );
    setupContent($self,$panel);  #then add content
    return $self;
   }
   
   sub setupContent{
	   my ($self,$panel)=@_;
	   
       foreach $button  (@buttons){
		   aBt($self, $panel, @$button)
	   }
	   foreach $textctrl (@textctrls){
		   aTC($self,$panel,@$textctrl)
	   }
	   foreach $stattxt (@stattexts){
		   aST($self,$panel,@$stattxt)
	   }
	   
	   
       sub aBt{
	    my ($self,$panel, $id, $label, $location, $size, $action)=@_;
	    $self->{"btn".$id} = Wx::Button->new(     $panel,      # parent
                                        $id,             # ButtonID
                                        $label,          # label
                                        $location,       # position
                                        $size            # size
                                       );
        EVT_BUTTON( $self, $id, $action );  #object to bind to, buton id, and subroutine to call
        }
         
        sub aTC{
			 my ($self,$panel, $id, $text, $location, $size, $action)=@_;
			 $self->{"txtctrl".$id} = Wx::TextCtrl->new(
                                        $panel,
                                        $id,
                                        $text,
                                        $location,
                                        $size,
                                        wxTE_PROCESS_ENTER
                                        );
            EVT_TEXT_ENTER( $self, $id, $action );
		 }
         
         sub aST{
			  my ($self,$panel, $id, $text, $location)=@_;
			 $self->{"stattext".$id} = Wx::StaticText->new( $panel,             # parent
                                        $id,                  # id
                                        $text,                # label
                                        $location,            # position
                                      );			 
		 }

   }
   
   sub addButton{
	   push (@buttons,shift );
   }
   sub addTextCtrl{
	   push (@textctrls,shift );
   }
   sub addStatText{
	   push (@stattexts,shift );
   }
 
   package GUIDeFATE;
   use base qw(Wx::App);   # Inherit from Wx::App
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $frame;
   our @EXPORT_OK      = qw<$frame>;
   use parent qw<Exporter>;
   
   sub OnInit
   {
       my $self = shift;
       $frame =  MyFrame->new(   undef,         # Parent window
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
	foreach $line (@lines){
		while ($line =~m/(\{([^}]*)\})/g){
			$ps=length($`);
			print "Button with label '". $2."' calls function &btn$bid\n";
			MyFrame::addButton([$bid, $2,[$ps*16-8,$l*32],[length($2)*16+24,32], \&{"Main::btn".$bid++}]);
		}
		while ($line=~m/(\[([^\]]+)\])/g){
			$ps=length($`); $all=$1;$content=$2;
			$content=~s/_/ /g;
			print "Text Control with default text '". $content."' calls function &textctrl$bid\n";
			MyFrame::addTextCtrl([$bid, $content,[$ps*16-8,$l*32],[length($content)*16+24,32], \&{"Main::textctrl".$bid++}]);
		}
		if ($line !~ m/\+/){
		  my $tmp=$line;
		  $tmp=~s/^\|\s+|(\[([^\]]+)\])|(\{([^}]*)\})|\s+\|$//g;
		  if (length $tmp){
			  print "Static text '".$tmp."'\n";
		      $line=~m/$tmp/;$ps=length($`);
		      MyFrame::addStatText([$bid, $tmp,[$ps*16-8,$l*32]]);
		  }
	     }
		$l++;
	}
	
}

   
1;
