package GFtemplate;
   use strict;
   use warnings;
   
   our $VERSION = '0.12';

   use Exporter 'import';   
   our @EXPORT      = qw<addWidget addVar setScale MainLoop $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle="title";
   our $winScale=6.5; 
 
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @widgets=();
   my %iVars=();      #vars for interface operation (e.g. 
   my %oVars=();      #vars for interface creation (e.g. list of options)
   my %styles;        #reserved for future module creation
   
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift; 
    my $self={};   
    bless( $self, $class );



    return $self;
   };
   
  sub MainLoop{ #activate UI
	  
  }

# setupContent  sets up the initial content before Mainloop can be run.
   sub setupContent{
	   my ($self, $canvas)=@_;      # pass both object as well as the frame element
	   $self ->{"menubar"}=undef;   # menu not yet defined
	   my $currentMenu;             # undefined menu
	   foreach my $widget (@widgets){  # read each widget data and call gnerator
		   my @params=@$widget;
		   my $wtype=shift @params;
		   if ($wtype eq "btn")             {aBt($self, $canvas, @params);}
		   elsif ($wtype eq "textctrl")     {aTC($self, $canvas, @params);}
		   elsif ($wtype eq "stattext")     {aST($self, $canvas, @params);}
		   elsif ($wtype eq "sp")           {aSP($self, $canvas, @params);}
		   elsif ($wtype eq "combo")        {aCB($self, $canvas, @params);}
		   elsif ($wtype eq "sp")           {aSP($self, $canvas, @params);}
		   elsif ($wtype eq "mb")
		      {
				if (! $self->{"menubar"}){
					$self ->{"menubar"} = Gtk3::MenuBar->new;
		            $canvas->put($self ->{"menubar"},0,0);
		            }
	            $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	         }
	   }
	   
	   sub aBt{      
	    my ($self,$canvas, $id, $label, $location, $size, $action)=@_;# Button generator
        }
       sub aTC{
		my ($self,$canvas, $id, $text, $location, $size, $action)=@_;0# Single line input generator
        }
       sub aST{
		my ($self,$canvas, $id, $text, $location)=@_;  #Static text element generator
        }
       sub aCB{  
		my ($self,$canvas, $id, $label, $location, $size, $action)=@_; #gnerator for comoboxes
	        
	   }
       sub aMB{
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	     if ($type eq "menuhead"){
			   $currentMenu="menu".$id;
		   }
		   elsif ($type eq "radio"){
			   
		   }
		   elsif ($type eq "check"){
			   
		   }
		   elsif ($type eq "separator"){
			   
		   }
		   else{
			   if($currentMenu!~m/$label/){
				   			     
			 }
		   }
		   return $currentMenu;
	   }
	   sub aSP{
			my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  # Image panels start with I
				
			 }
			elsif ($panelType eq "T"){  
				
			 }
		 }
        
	   
   }

      
#functions for GUIDeFATE to load the widgets into the backend
   sub addWidget{
	   push (@widgets,shift );
   }
   sub addStyle{
	   my ($name,$style)=@_;
	   $styles{$name}=$style;
   }
   sub addVar{
	   my ($varName,$value)=@_;
	   $oVars{$varName}=$value;
   }

# Functions for internal use 
   sub getSize{
	   my ($self,$id)=@_;
	   my $found=getItem($self,$id);
	   return ( $found!=-1) ? $widgets[$found][5]:0;
	   
   }
   sub getLocation{
	   my ($self,$id)=@_;
	   my $found=getItem($self,$id);
	   return ( $found!=-1) ? $widgets[$found][4]:0;
	   
   }   
   sub getItem{
	   my ($self,$id)=@_;
	   $id=~s/[^\d]//g;
	   my $i=0; my $found=-1;
	   while ($i<@widgets){
		   if ($widgets[$i][1]==$id) {
			   $found=$i;
			   }
		   $i++;
	   }
	   return $found;
   }

   sub setScale{
	   $winScale=shift;	   
   };

   sub getFrame{
	   
   };

#  The functions for GUI Interactions
#Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;
	   
   }

#Image functions
   sub setImage{
	 my ($self,$id,$file)=@_;

   }

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   if ($id =~/TextCtrl/){
	   }
	   else {
	      if (exists $iVars{$id}){
			  return $iVars{$id}
		  }
	  }
	   
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
  
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
 
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load,$filter) = @_;
     my $filename;

     return $filename;
   };
   sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;

   };
   
# Quit
   sub quit{

   }
1;
