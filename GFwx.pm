package GFwx;	   
   
   use strict;
   use warnings;
   
   our $VERSION = '0.08';

   use parent qw(Wx::App);              # Inherit from Wx::App
   use Exporter 'import';
   use GFwxFrame qw<addWidget addVar setScale>;
   
   our @EXPORT_OK      = qw<addWidget addVar setScale $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $winScale=6.5;   
   
   sub OnInit
   {
       my $self=shift;
       $frame =  GFwxFrame->new(   undef,         # Parent window
                                   -1,            # Window id
                                   $winTitle, # Title
                                   [$winX,$winY],         # position [X, Y]
                                   [$winWidth,$winHeight]     # size [$winWidth, $winHeight]
                                  );
       $self->SetTopWindow($frame);    # Define the toplevel window
       $frame->Show(1);                # Show the frame
   }
   
   
sub getFrame{
	return $frame;
	
}
   
   1;


