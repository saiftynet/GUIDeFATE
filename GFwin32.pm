package GFwin32;
   use strict;
   use warnings;
   
   our $VERSION = '0.07';
   
   use Win32::GUI;

   use Image::Magick;                  ##other modules that need to be loaded
   
   use Exporter 'import';     ##somefunctions are always passed back to GUIDeFATE.pm
   our @EXPORT_OK      = qw<addButton addStatText addTextCtrl addMenuBits addPanel setScale $frame $winScale $winWidth $winHeight $winTitle>;

   our $frame;                #  The frame which is the parent of all the widgets
                              #  ever widget is referenced by an id and is accessible by $frame -> {id}
   
   our $winX=30;              #  These are the window dimensions and are modified by GUIDeFATE
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $winScale=6.5;         #  This allows the window to be scaled
 
   # these arrays will contain the widgets each as an arrayref of the parameters
   # It may be logical to group them as one array conatining eveything and this
   # may be the way to go when ready to push out v1.0
   my @buttons=();
   my @textctrls=();
   my @stattexts=();
   my @menu=();
   my @subpanels=();
   my @combos=();
   my %styles;   # styles is a future mod that allows widgets to be styled
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {  
	  my $class = shift;    
      my $self = Win32::GUI::Window->new(-name   => 'Main',
                -width  => $winWidth,
                -height => $winHeight,
                -title  => $winTitle
        );  # call the superclass' constructor
        $styles{"mediumFont"} = Win32::GUI::Font->new(
                -name => "Comic Sans MS", 
                -size => 18,
        );
        setupContent($self,undef);
	    $self->Show();
	    return $self;

   };
   
     sub MainLoop{ # substitutes MainLoop with the equivalent in Win32
		 Win32::GUI::Dialog();
	 }
	 
# setupContent  sets up the initial content before Mainloop can be run.
   sub setupContent{
	   my ($self, $frame)=@_;
	   foreach my $button  (@buttons){
		   aBt($self, $frame, @$button)
	   }
	   foreach my $textctrl (@textctrls){
		   aTC($self,$frame,@$textctrl)
	   }
	   foreach my $stattxt (@stattexts){
		   aST($self,$frame,@$stattxt)
	   }
	   if (scalar @menu){   #menu exists
		  $self ->{"menubar"} = Win32::GUI::Menu->new();
		  my $currentMenu;
		  foreach my $menuBits (@menu){ 
			  $currentMenu=aMB($self,$frame,$currentMenu,@$menuBits)
	       }
	   }
	   foreach my $sp (@subpanels){
		   aSP($self,$frame,@$sp);
	   }
	   
	   
	   # these functions convert the parameters of the widget into actual widgets
	   sub aBt{  # creates buttons
	    my ($self,$frame, $id, $label, $location, $size, $action)=@_;
	       $self->{"btn".$id}=$self->AddButton(-name     => "btn".$id,
	                                           -text     =>$label,
	                                           -position =>$location,
	                                           -size     =>$size);
	   }
       sub aTC{ # single line text entry
		my ($self,$frame, $id, $text, $location, $size, $action)=@_;
		      $self->{"textctrl".$id}=$self->AddTextfield(
		               -text => $text,
		               -width => ${$size}[0],
		               -height => ${$size}[1],
		               -pos => $location,
		               -name => "textctrl".$id);
        }
       sub aST{  #static texts
		my ($self,$frame, $id, $text, $location)=@_; 
		      $self->{"stattext".$id}=$self->AddLabel( -text => "Hello, world",
		               -text => $text,
		               -font =>$styles{"mediumFont"},
		               -pos => $location,
		               -name=>"stattext".$id)
        }
        sub aMB{  #parses the menu items into a menu.   menus may need to be a child of main window
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_; 
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	    
	     
	       if ($type eq "menuhead"){  #the label of the menu
			   $currentMenu="menu".$id;
			   $self ->{$currentMenu} = $self->AddMenuButton( -text    => $label,
			                                      -id      => $id
			                                      );
		   }
		   elsif ($type eq "radio"){   #menu items which are radio buttons in tk there is no function called
			    
		   }
		   elsif ($type eq "check"){  #menu items which are check boxes in tk there is no function called
			    
		   }
		   elsif ($type eq "separator"){ #separators
			    
		   }
		   else{
			   if($currentMenu!~m/$label/){  #simple menu items
			     $self ->{$currentMenu}->AddMenuItem(
                             -text    => $label,
                             -id      => $id,
                             -onClick => $action);
			 }
		   }
		   return $currentMenu;
	   }
	   sub aSP{
			 my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;  ##image Id must endup $id+1
			
			if ($panelType eq "I"){  # Image panels start with I
				$content=~s/^\s+|\s+$//g;
				if (! -e $content){ return; }
				no warnings;   # sorry about that...suppresses a "Useless string used in void context"
			    my $image = Image::Magick->new;
			    my $r = $image->Read("$content");
			    if ($image){
			      my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Scale(geometry => $geom);
			      my $bmp = ( $image->ImageToBlob(magick=>'bmp') )[0];
			      $self->{"Image".($id+1)}=$self.AddLabel( -bitmap => $bmp,
			           -name=>"Image".($id+1),
		               -pos => $location,
		               -size=> $size )
			      
                }
				else {"print failed to load image $content \n";}
			 }
			 
			if ($panelType eq "T"){  # text entry panels start with T
				$content=~s/^\s+|\s+$//g;
			    $self->{"TextCtrl".($id+1)}=$self->AddTextfield(
		               -text => $content,
		               -multiline=>1,
		               -autovscroll   => 1,
		               -autohscroll   => 1,
		               -width => ${$size}[0],
		               -height => ${$size}[1],
		               -pos => $location,
		               -name => "TextCtrl".($id+1)); 			  
			 }
		 }
   }

      
#functions for GUIDeFATE to load the widgets into the backend...leave alone
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
   sub addStyle{
	   my ($name,$style)=@_;
	   $styles{$name}=$style;
   }
   sub addCombo{
	   push (@combos, shift);
   }


# Functions for internal use uses the arrays to get the parameters for the widgets...leave alone
   sub getSize{
	   my ($self,$id,$arrayRef)=@_;
	   my $found=getItem($self,$id,$arrayRef);
	   return ( $found!=-1) ? $$arrayRef[$found][4]:0;
	   
   }
   sub getLocation{
	   my ($self,$id,$arrayRef)=@_;
	   my $found=getItem($self,$id,$arrayRef);
	   return ( $found!=-1) ? $$arrayRef[$found][3]:0;
	   
   }   
   sub getItem{
	   my ($self,$id,$arrayRef)=@_;
	   $id=~s/[^\d]//g;
	   my $i=0; my $found=-1;
	   while ($i<@$arrayRef){
		   if ($$arrayRef[$i][0]==$id) {
			   $found=$i;
			   }
		   $i++;
	   }
	   return $found;
   }

   sub setScale{  # supposed to be a function that allows scaling of all objects
	              # this actually happen in GUIDeFATE.pm, but font scaling is very
	              # much back end dependent, so happens here too
	  $winScale=shift;	   
   };

   sub getFrame{ # get frame returns the object that can be used o access all the widgets
	   my $self=shift;
	return $self;
   };

#  The functions for GUI Interactions
#  Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;
	   my $location=$stattexts[getItem($self,$id,\@stattexts)][2];
	   # routine to change the contents of static text
   }

#Image functions
   sub setImage{
	   my ($self,$id,$file)=@_;
	   my $location=getLocation($self,$id,\@subpanels);
	   my $size=getSize($self,$id,\@subpanels);
	   if ($size){
	       my $image = Image::Magick->new;
		   my $r = $image->Read("$file");
		   if ($image){
			  # function to place image at ${$location}[0],${$location}[1] of size ${$size}[0],${$size}[1]
			  # Image id is "Image".($id+1)...notice capital I and also $id is incremented (sometimes useful to put 
			  # image in a container and if the container needs an ID then the containers ID is suffexed $id
		   }
		   else {"print failed to load image $file \n";}
			 }
		else {print "Panel not found"}
			 
	   
   }

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   # function to get value of an input box
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
	    # function to set value of an input box	   
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
	    # function to append value into an input box
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load) = @_;  # Message is the title of the fileselector
                                       # Load is 1 if loading or 0 if saving
     my $filename = Win32::GUI::GetOpenFileName ( 
       -filter =>  [ 'All Files - *', '*' ],
                   -directory => "c:\\program files",
                   -title => $message
                   );
	 return $filename;

   };
      sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   my %responses=( YNC=>0x00000003,
	                   YN =>0x00000004,
	                   OK =>0x00000000,
	                   OKC=>'OkCancel' );
	                   
	   my %icons= (  "!"=>0x00000030,
	                 "?"=>0x00000020,
	                 "E"=>0x00000010,
	                 "H"=>0x00000010,
	                 "I"=>0x00000040 );
	   $response=$response?$responses{$response}:0x00000000;
	   $icon=$icon?$icons{$icon}:0x00000040;
	   my $answer= Win32::MsgBox($message,$response|$icon,$title);
       return (($answer == 1)||($answer==6));
   };
   
# Quit
   sub quit{
	   my ($self) = @_;
	   $self ->Close(-1);
   }
1;
