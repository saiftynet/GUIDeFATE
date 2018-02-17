package GFrame;
   
   use strict;
   use warnings;

   our $VERSION = '0.0.3';
   
   use GFrame qw<$frame>;
   use Exporter 'import';
   our @EXPORT_OK      = qw<addButton addStatText addTextCtrl addMenuBits addPanel>;
   
   use Wx qw( wxTE_PASSWORD wxTE_PROCESS_ENTER wxDEFAULT wxNORMAL wxFONTENCODING_DEFAULT);
   use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI EVT_MENU);
   use Wx::Perl::Imagick;                 #for image panels
   
   use base qw(Wx::Frame); # Inherit from Wx::Frame
   
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @buttons=();
   my @textctrls=();
   my @stattexts=();
   my @menu=();
   my @subpanels=();
   
   my $font = Wx::Font->new(     24,
                                wxDEFAULT,
                                wxNORMAL,
                                wxNORMAL,
                                0,
                                "",
                                wxFONTENCODING_DEFAULT);
   
   sub new
   {
    my $class = shift;    
    my $self = $class->SUPER::new(@_);  # call the superclass' constructor
    # Then define a Panel to put the content on
    my $panel = Wx::Panel->new( $self,-1); # parent, id
    setupContent($self,$panel);  #then add content
    return $self;
   }
   
   sub setupContent{
	   my ($self,$panel)=@_;
	   
       foreach my $button  (@buttons){
		   aBt($self, $panel, @$button)
	   }
	   foreach my $textctrl (@textctrls){
		   aTC($self,$panel,@$textctrl)
	   }
	   foreach my $stattxt (@stattexts){
		   aST($self,$panel,@$stattxt)
	   }
	   if (scalar @menu){   #menu exists
		   $self ->{"menubar"} = Wx::MenuBar->new();
		   $self->SetMenuBar($self ->{"menubar"});
		   my $currentMenu; my $lastMenuItem;
		   foreach my $menuBits (@menu){ 
			  $currentMenu=aMB($self,$panel,$currentMenu,@$menuBits)
	       }
	   }
	   foreach my $sp (@subpanels){
		   aSP($self,$panel,@$sp);
	   }
	   
	   sub aMB{
	     my ($self,$panel,$currentMenu, $id, $label, $type, $action)=@_;
	       if ($type eq "menu"){
			   $currentMenu="menu".$id;
			   $self ->{$currentMenu} =  Wx::Menu->new();
		       $self ->{"menubar"}->Append($self ->{$currentMenu}, $label);
		   }
		   elsif ($type eq "radio"){
			   $self ->{$currentMenu}->AppendRadioItem($id, $label);
			   EVT_MENU( $self, $id, $action )
		   }
		   elsif ($type eq "check"){
			   $self ->{$currentMenu}->AppendCheckItem($id, $label);
			   EVT_MENU( $self, $id, $action )
		   }
		   elsif ($type eq "separator"){
			   $self ->{$currentMenu}->AppendSeparator();
		   }
		   else{
			   $self ->{$currentMenu}->Append($id, $label);
			   EVT_MENU( $self, $id, $action )
		   }
		   return $currentMenu;
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
                                        $location            # position
                                      );	
             $self->{"stattext".$id}->SetFont($font);		 
		 }
		 sub aSP{
			 my ($self,$panel, $id, $panelType, $content, $location, $size)=@_;
			 $self->{"subpanel".$id}= Wx::Panel->new( $panel,# parent
			                                         $id,# id
			                                         $location,
			                                         $size			                                         
			                                         ); 
			
			if ($panelType eq "I"){  # handle
				#my $handler = Wx::JPEGHandler->new();
				$content=~s/^\s+|\s+$//g;
			    my $image = Wx::Perl::Imagick->new($content);
			    if ($image){
			      my $bmp;    # used to hold the bitmap.
			      my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Resize(geometry => $geom);
			      $bmp = $image->ConvertToBitmap();
			        if( $bmp->Ok() ) {
                     $self->{"Image".$id}= Wx::StaticBitmap->new($self->{"subpanel".$id}, -1, $bmp);
                    }
				 }
				 else {"print failed to load image $content \n";}
			 }

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
   sub addMenuBits{
	   push (@menu, shift);
   }
    sub addPanel{
	   push (@subpanels, shift);
   }
   
   sub setImage{
	   my ($self,$file,$id,$size)=@_;
	    my $image = Wx::Perl::Imagick->new($file);
			    if ($image){
			      my $bmp;    # used to hold the bitmap.
			      my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Resize(geometry => $geom);
			      $bmp = $image->ConvertToBitmap();
			        if( $bmp->Ok() ) {
                     $self->{"Image".$id}= Wx::StaticBitmap->new($self->{"subpanel".$id}, -1, $bmp);
                    }
				 }
				 else {"print failed to load image $file \n";}
	   
   }
  1;
