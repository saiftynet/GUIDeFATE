package GFgtk;
   use strict;
   use warnings;
   
   our $VERSION = '0.09';
   
   use Glib ':constants';   # load Glib and import useful constants
   use Gtk3 '-init';        # load Gtk3 module and initialize it
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
   my %iVars=();     #vars for interface operation (e.g. 
   my %oVars=();      #vars for interface creation (e.g. list of options)
   my %styles;
   
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift; 
    my $self={};   
    bless( $self, $class );
    $self->{window}= Gtk3::Window->new;  
    $self->{window}->signal_connect(destroy => sub { Gtk3::main_quit; });
    $self->{window}->resize($winWidth,$winHeight);
    $self->{window} -> set_title($winTitle);
    $self->{window}->signal_connect('delete-event' => sub { Gtk3->main_quit });
    
    $self->{panel}=Gtk3::Fixed->new();
    $self->{window}->add($self->{panel});
    
    setupContent($self,$self->{panel});  #then add content
    $self->{window} ->show_all();
      return $self;
   };
   
  sub MainLoop{
	  Gtk3->main;
  }

# setupContent  sets up the initial content before Mainloop can be run.
   sub setupContent{
	   my ($self, $canvas)=@_;
	   $self ->{"menubar"}=undef;
	   my $currentMenu;
	   foreach my $widget (@widgets){
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
	    my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
	    $canvas->{"btn$id"}=Gtk3::Button->new($label);
	    $canvas->{"btn$id"}->set_property("width-request", ${$size}[0]);
	    $canvas->{"btn$id"}->signal_connect( clicked => $action );
	    $canvas->put($canvas->{"btn$id"},${$location}[0] ,${$location}[1]);
        }
       sub aTC{
		my ($self,$canvas, $id, $text, $location, $size, $action)=@_;
		$canvas->{"textctrl$id"}=Gtk3::Entry->new();
		$canvas->{"textctrl$id"}->set_text($text);
	    $canvas->{"textctrl$id"}->set_property("width-request", ${$size}[0]);
	    $canvas->put($canvas->{"textctrl$id"},${$location}[0] ,${$location}[1]);
        }
       sub aST{
		my ($self,$canvas, $id, $text, $location)=@_;
		$canvas->{"stattext$id"}=Gtk3::Label->new();
	    $canvas->{"stattext$id"}->set_label($text);
	    $canvas->{"stattext$id"}->set_markup('<span size="xx-large" >'.$text.'</span>');
	    $canvas->put($canvas->{"stattext$id"},${$location}[0] ,${$location}[1]);
        }
        sub aCB{  #adapted from http://www.perlmonks.org/?node_id=799673
		   my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
		   if (defined $oVars{$label}){
			  my @strings2 = split(",",$oVars{$label});
	          $iVars{"combo$id"}=$strings2[0];
			  $canvas->{"combo$id"}=Gtk3::ComboBoxText->new();
			  foreach (@strings2){ $canvas->{"combo$id"}->append_text($_);}
			  $canvas->{"combo$id"}->set_active (0);
			  $canvas->{"combo$id"}->signal_connect(changed => sub{
				  $iVars{"combo$id"}=$canvas->{"combo$id"}->get_active_text;
				  &$action});
	          $canvas->put($canvas->{"combo$id"},${$location}[0] ,${$location}[1]);
	       }
	       else {print "Combo options not defined for 'combo$id' with label $label\n"}
	        
	   }
        sub aMB{
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	     if ($type eq "menuhead"){
			   $currentMenu="menu".$id;
			   $self ->{$currentMenu} = Gtk3::MenuItem->new_with_label($label);
			   $self ->{"sm$currentMenu"}=Gtk3::Menu->new();
			   $self ->{$currentMenu}->set_submenu( $self ->{"sm$currentMenu"} );
			   $self ->{"menubar"}->append($self ->{$currentMenu});
		   }
		   elsif ($type eq "radio"){
			   $self ->{"sm$currentMenu"}->append(Gtk3::RadioMenuItem->new($label));
		   }
		   elsif ($type eq "check"){
			   $self ->{"sm$currentMenu"}->append(Gtk3::CheckMenuItem->new($label));
		   }
		   elsif ($type eq "separator"){
			   $self ->{"sm$currentMenu"}->append(Gtk3::SeparatorMenuItem->new());
		   }
		   else{
			   if($currentMenu!~m/$label/){
				 $self ->{"mi$id"}=Gtk3::MenuItem->new($label);
				 $self ->{"sm$currentMenu"}->append($self ->{"mi$id"});
				 $self ->{"mi$id"}->signal_connect('activate' => $action);			     
			 }
		   }
		   # logging menu generator print "$currentMenu---$id----$label---$type\n";
		   return $currentMenu;
	   }
	   sub aSP{
			 my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  # Image panels start with I
				$canvas->{"Image".$id} = Gtk3::Image->new();
				$canvas->put($canvas->{"Image".$id},${$location}[0] ,${$location}[1]);
				if (! -e $content){ return; }
				my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($content);
				my $scaled = $pixbuf->scale_simple(${$size}[0],${$size}[1], 'GDK_INTERP_HYPER');
				$canvas->{"Image".$id}->set_from_pixbuf($scaled);
			 }
			if ($panelType eq "T"){  
				$canvas->{"sw$id"}= Gtk3::ScrolledWindow->new();
				$canvas->{"sw$id"}->set_hexpand(1);
				$canvas->{"sw$id"}->set_vexpand(1);
				$canvas->{"sw$id"}->set_size_request (${$size}[0],${$size}[1]);
				$canvas->{"TextCtrl".($id+1)}=Gtk3::TextView->new;
				$canvas->{"TextCtrl".($id+1)}->get_buffer()->set_text($content);
				$canvas->{"TextCtrl".($id+1)}->set_editable (1) ;
				$canvas->{"sw$id"}->add($canvas->{"TextCtrl".($id+1)});
	            $canvas->put($canvas->{"sw$id"},${$location}[0] ,${$location}[1]);
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
	 my $self=shift;
	return $self;
   };

#  The functions for GUI Interactions
#Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;
	   $self->{panel}->{$id}->set_label($text);
   }

#Image functions
   sub setImage{
	   my ($self,$id,$file)=@_;
	   my $canvas=$self->{panel};
	   my $location=getLocation($self,$id);
	   my $size=getSize($self,$id);
	   if ($size){
	       if (! -e $file){ print "$file not found\n"; return; }
				my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_file($file);
				my $scaled = $pixbuf->scale_simple(${$size}[0],${$size}[1], 'GDK_INTERP_HYPER');
				$canvas->{"$id"} ->clear; 
				$canvas->{"$id"}->set_from_pixbuf($scaled);
			 }
		  else {print "Panel not found"}
			 
	   
   }

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   if ($id =~/TextCtrl/){
		    my $tb=$self->{panel}->{$id}->get_buffer();
		   return $tb->get_text($tb->get_start_iter, $tb->get_end_iter, 1);
	   }
	   else {
	      if (exists $iVars{$id}){
			  return $iVars{$id}
		  }
	      else{ return  $self->{panel}->{"$id"}->get_text; }
	  }
	   
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
	   if ($id=~/^T/){
	      $self->{panel}->{"$id"}->get_buffer()->set_text($text); 
	   }
	   elsif ($id=~/^t/){
		   $self->{panel}->{"$id"}->set_text($text);
	   }  
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
	   if ($id=~/^T/){
	     my $textbuffer=$self->{panel}->{$id}->get_buffer();
	     my $textiter = $textbuffer->get_end_iter;
	     $textbuffer->insert($textiter,$text);
	     $self->{panel}->{$id}->set_buffer($textbuffer);
	 }
	 elsif ($id=~/^t/){
		 my $newText=$self->{panel}->{"$id"}->get_text . $text;
		   $self->{panel}->{"$id"}->set_text($newText);
	   } 
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load,$filter) = @_;
     my $filename;
     my $file_chooser =  Gtk3::FileChooserDialog->new ( 
                            $message,
                            undef,
                            $load?'open':'save',
                            'gtk-cancel' => 'cancel',
                            $load?'gtk-open':'gtk-save' => 'ok'
                        );
    (defined $filter)&&($file_chooser->add_filter($filter));
    if ('ok' eq $file_chooser->run){ $filename = $file_chooser->get_filename; }
    $file_chooser->destroy;
    return $filename;

   };
      sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   my %responses=( YNC=>'yes-no',
	                   YN =>'yes-no',
	                   OK => 'ok',
	                   OKC=>'ok-cancel' );
	                   
	   my %icons= (  "!"=>"warning",
	                 "?"=>"question",
	                 "E"=>"error",
	                 "H"=>"warning",
	                 "I"=>"info" );
	   $response=$response?$responses{$response}:"ok";
	   $icon=$icon?$icons{$icon}:"info";
	   my $dialog=Gtk3::MessageDialog->new (undef,
                                      [qw( modal destroy-with-parent )],
                                      $icon, # message type
                                      $response, # which set of buttons?
                                      $message);
	   my $answer= $dialog->run;
	   $dialog->destroy;
       return (($answer eq "ok")||($answer eq "yes"))
   };
   
# Quit
   sub quit{
	   my ($self) = @_;
	   $self->{window}->destroy();
   }
1;

