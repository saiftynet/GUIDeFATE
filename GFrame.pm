   package GFrame;
   
   use strict;
   use warnings;

   our $VERSION = '0.0.1';
   
   use GFrame qw<$frame>;
   use Exporter 'import';
   our @EXPORT_OK      = qw<addButton addStatText addTextCtrl addMenuBits>;
   
   use Wx qw( wxTE_PASSWORD wxTE_PROCESS_ENTER wxDEFAULT wxNORMAL wxFONTENCODING_DEFAULT);
   use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI EVT_MENU);
   
   
   use base qw(Wx::Frame); # Inherit from Wx::Frame
   
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @buttons=();
   my @textctrls=();
   my @stattexts=();
   my @menu=();
   
    my $font = Wx::Font->new(     20,
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
	   if (scalar @menu){
		   $self ->{"menubar"} = Wx::MenuBar->new();
		   $self->SetMenuBar($self ->{"menubar"});
		   my $currentMenu;
		   foreach my $menuBits (@menu){
			  $currentMenu=aMB($self,$panel,$currentMenu,@$menuBits)
	       }
		   
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
			  my ($self,$panel, $id, $text, $location, $size)=@_;
			 $self->{"stattext".$id} = Wx::StaticText->new( $panel,             # parent
                                        $id,                  # id
                                        $text,                # label
                                        $location,            # position
                                        $size
                                      );	
             $self->{"stattext".$id}->SetFont($font);		 
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
 
  1;
