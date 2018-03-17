package GFtemplate;
   use strict;
   use warnings;
   
   our $VERSION = '0.08';
   
   use parent qw(Backend::MainWindow); ##

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
   my %styles;   # styles is a future mod that allows widgets to be styled
   
   sub new
   {
	    # This creates a new Window which runs the mainloop and contains
	    # the frame (which may be the window itself) that contains all widgets
	    # calls function setupConetnt with $self and $frame object

   };

# setupContent  sets up the initial content before Mainloop can be run.
   sub setupContent{
	   my ($self, $frame)=@_;
	   
	   #  These just work over the 4 arrays of widgets and calls the contructor 
	   # with the pramaters extracted by GUIDEeFATE.pm
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
		  $self->configure(-menu => my $self ->{"menubar"} = $self->Menu);
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
	    # button id are "btn".$id,  action is generally also a function called "btn".$id
	    # referenced by $frame->{"btn".$id}
	    

        }
       sub aTC{ # single line text entry
		my ($self,$frame, $id, $text, $location, $size, $action)=@_;
		# id are "textctrl".$id, if action specified, return triggers $action (not all backend support this)
        # referenced by $frame->{"textctrl".$id}
        }
       sub aST{  #static texts
		my ($self,$frame, $id, $text, $location)=@_;
		# id are "stattext".$id, 
        # referenced by $frame->{"stattext".$id}
        }
        sub aMB{  #parses the menu items into a menu.   menus may need to be a child of main window
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_; 
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	    
	     
	       if ($type eq "menuhead"){  #the label of the menu
			   
		   }
		   elsif ($type eq "radio"){   #menu items which are radio buttons in tk there is no function called
			    
		   }
		   elsif ($type eq "check"){  #menu items which are check boxes in tk there is no function called
			    
		   }
		   elsif ($type eq "separator"){ #separators
			    
		   }
		   else{
			   if($currentMenu!~m/$label/){  #simple menu items
			     $self ->{$currentMenu}->command(-label => $label, -command =>$action);
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
			      # function to place image at ${$location}[0],${$location}[1] of size ${$size}[0],${$size}[1]
			      # Image id is "Image".($id+1)...notice capital I and also $id is incremented (sometimes useful to put 
			      # image in a container and if the container needs an ID then the containers ID is suffexed $id
                }
				else {"print failed to load image $content \n";}
			 }
			 
			if ($panelType eq "T"){  # text entry panels start with T
				$content=~s/^\s+|\s+$//g;
			      # function to place multiline text entry widget at ${$location}[0],${$location}[1] of size ${$size}[0],${$size}[1]
			      # Object id is "TextCtrl".($id+1)...notice capital T and also $id is incremented (sometimes useful to put 
			      # this  in a container and if that container needs an ID then the container's ID is suffexed $id				  
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
     my $filename;
     ##  fileselector routine  
	 return $filename;

   };
      sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   my %responses=( YNC=>'YesNoCancel',
	                   YN =>'YesNo',
	                   OK => 'Ok',
	                   OKC=>'OkCancel' );
	                   
	   my %icons= (  "!"=>"warning",
	                 "?"=>"question",
	                 "E"=>"error",
	                 "H"=>"warning",
	                 "I"=>"info" );
	   $response=$response?$responses{$response}:"ok";
	   $icon=$icon?$icons{$icon}:"info";
	   my $answer=  # messagebox creationn  statement here
       return (($answer eq "Ok")||($answer eq "Yes"))
   };
   
# Quit
   sub quit{
	   my ($self) = @_;
	   $self ->Close(1);
   }
1;
