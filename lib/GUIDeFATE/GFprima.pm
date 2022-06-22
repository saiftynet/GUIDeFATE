package GFprima;
   use strict;
   use warnings;
   
   our $VERSION = '0.14';
      
   use Prima qw(Application Buttons Label InputLine );;
   
   use Exporter 'import';   
   our @EXPORT  = qw<addWidget addVar addTimer setScale $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $winScale=6.5; 
 
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @widgets=();
   my %iVars=();     #vars for interface operation (e.g. 
   my %oVars=();      #vars for interface creation (e.g. list of options)
   my %styles;
   my %timers;
   
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift;    
    my $self = Prima::MainWindow->new(text=>$winTitle,
                                      size=> [$winWidth,$winHeight]);  # call the superclass' constructor
      $self->{frame}={};
      setupContent($self,$self->frame);  #then add content
      run Prima;
      return $self;
   };

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
		   elsif ($wtype eq "chkbox")       {aKB($self, $canvas, @params);}
		   elsif ($wtype eq "sp")           {aSP($self, $canvas, @params);}
		   elsif ($wtype eq "mb")
		                   {
							   if (! $self->{"menubar"}){
							       $self->configure(-menu => $self ->{"menubar"} = $self->Menu);
		                          }
	                          $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	       }
	       else {
			   print "Widget type $wtype withh parameters ".join(", ",@params). "cannot be created\n";
		   }
	   }
	   #setup timers
	   foreach my $timerID (keys %timers){
		  #$timers{$timerID}{timer} = AnyEvent->timer (after => 0, interval => $timers{$timerID}{interval}/1000, cb => $timers{$timerID}{function});
		  $canvas->repeat($timers{$timerID}{interval}, $timers{$timerID}{function}); #docstore.mik.ua/orelly/perl3/tk/ch13_22.htm
		   #$timers{$timerID}{timer} = AE::timer 1, $timers{$timerID}{interval}/1000, $timers{$timerID}{function};
		   #if ($timers{$timerID}{interval}>0){
			   #$timers{$timerID}{timer}->start($timers{$timerID}{interval});
		   #}
	   }

	   sub aBt{
	    my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
	    $canvas->{"btn$id"}=Prima::Button->new(text => $label,
	                         width  => ${$size}[0]/6.68-4,
	                         height => ${$size}[1]/16,
	                         owner  => $self);
        }
       sub aTC{
		my ($self,$canvas, $id, $text, $location, $size, $action)=@_;
		$canvas->{"textctrl$id"}=Prima::InputLine->new(
                             bg => 'white',
                             text => $text,
	                         width  => (${$size}[0]+32)/8,
	                         owner  =>$self);
        }
       sub aST{
		my ($self,$canvas, $id, $text, $location)=@_;
		$canvas->{"stattext$id"}=Prima::Label->new(text => $text,
	                         owner  =>$self);
        }
        sub aCB{  #adapted from http://www.perlmonks.org/?node_id=799673
		   my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
		   if (defined $oVars{$label}){
	        my @strings2 = split(",",$oVars{$label});
	        $iVars{"combo$id"}=$strings2[0];
	        $canvas->{"combo$id"}=$canvas->BrowseEntry(
	             -variable    => \($iVars{"combo$id"}),
				 -listheight => scalar @strings2, 
				 -listwidth  => (${$size}[0]-20)/2,
				 -browsecmd => $action);
		    foreach (@strings2){ $canvas->{"combo$id"}->insert("end",$_);}
			$canvas->{"cont$id"}=$canvas->{"combo$id"}->Subwidget('slistbox')->Subwidget('scrolled');#??
			
			$canvas->createWindow(${$location}[0] ,${$location}[1],
	             -width  => (${$size}[0]-20)*1.5,
	             -height => ${$size}[1], 
	                         -anchor => "nw",
	                         -window =>$canvas->{"combo$id"});
			}
		 
		 else {print "Combo options not defined for 'combo$id' with label $label\n"}
	        
	   }
	   sub aKB{
		   my ($self,$canvas, $id, $label, $location, $size,$action)=@_;
		   $canvas->{"chkbox$id"}=$canvas->Checkbutton(-text => $label,
	                         -command => $action);
	       	$canvas->createWindow(${$location}[0] ,${$location}[1],
	                         -anchor => "nw",
	                         -window => $canvas->{"chkbox$id"});                  
		   
	   }
        sub aMB{
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	    
	     
	       if ($type eq "menuhead"){
			   $currentMenu="menu".$id;
			   $self ->{$currentMenu} =  $self ->{"menubar"}->cascade(-label => "~$label")
		   }
		   elsif ($type eq "radio"){
			   $self ->{$currentMenu}->radiobutton(-label => $label);
		   }
		   elsif ($type eq "check"){
			   $self ->{$currentMenu}->checkbutton(-label => $label);
		   }
		   elsif ($type eq "separator"){
			   $self ->{$currentMenu}->separator;
		   }
		   else{
			   if($currentMenu!~m/$label/){
			     $self ->{$currentMenu}->command(-label => $label, -command =>$action);
			 }
		   }
		   # logging menu generator print "$currentMenu---$id----$label---$type\n";
		   return $currentMenu;
	   }
	   sub aSP{
			 my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  
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
   sub addTimer{
	   my ($timerID,$interval,$function,$start)=@_;
	   $timers{$timerID}{interval}=$interval;
	   $timers{$timerID}{function}=$function;
	   $timers{$timerID}{start}=$start;
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
	   return 1
   };

#  The functions for GUI Interactions
#Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;
	   my $location=$widgets[getItem($self,$id)][3];
	   $frame->delete($frame->{"$id"});
	   $frame->{"$id"}=$frame->createText(${$location}[0] ,${$location}[1], 
		                     -anchor => "nw",
                             -text => $text,
                             -font =>'medium'
                 );
   }

#Image functions
   sub setImage{
	   my ($self,$id,$file)=@_;
	   my $location=getLocation($self,$id,\@widgets);
	   my $size=getSize($self,$id,\@widgets);
	   if ($size){
	       my $image = Image::Magick->new;
		   my $r = $image->Read("$file");
		   if ($image){
			  my $bmp;    # used to hold the bitmap.
			  my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Scale(geometry => $geom);
			      $bmp = ( $image->ImageToBlob(magick=>'jpg') )[0];
			      $frame->{"$id"}=$frame->createImage(${$location}[0],${$location}[1],
			                             -anchor=>"nw",
			                             -image => $frame->Photo(#"img$id",
			                                     -format=>'jpeg',
			                                     -data=>encode_base64($bmp) ));
			      #  $frame->update();  # force refresh...does not work?   
			      undef $bmp;                          
                    }
				 else {"print failed to load image $file \n";}
			 }
		  else {print "Panel not found"}
			 
	   
   }

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   if ($id =~/TextCtrl/){return $frame->{$id}->get('1.0','end-1c'); }
	   else {
	      if (exists $iVars{$id}){
			  return $iVars{$id}
		  }
	      else{ return   $frame->{$id}->get(); }
	  }
	   
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
	   $frame->{"$id"}->delete('0.0','end');
	   $frame->{"$id"}->insert("end",$text);	   
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
	   $frame->{$id}->insert('end',$text);
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load) = @_;
     my $filename;
     if ($load){
		 $filename = $self->getOpenFile( -title => $message,
		 -defaultextension => '.txt', -initialdir => '.' );
		 warn "Opened $filename\n";
		 }
	 else{
		 $filename = $self->getSaveFile( -title => $message,
         -defaultextension => '.txt', -initialdir => '.' );
         warn "Saved $filename\n";
		 
	 }
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
	   my $answer=  $self->messageBox(
	      -icon => $icon, -message => $message, -title => $title, -type => $response);
       return (($answer eq "Ok")||($answer eq "Yes"))
   };
   
# Quit
   sub quit{
	   my ($self) = @_;
	   $self ->destroy;
   }
1;
