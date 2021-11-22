package GFwin32;
   use strict;
   use warnings;
   
   our $VERSION = '0.13';
   
   use Win32::GUI;
   use Imager;

   use Exporter 'import';     ##somefunctions are always passed back to GUIDeFATE.pm
   our @EXPORT  = qw<addWidget addVar addTimer setScale MainLoop $frame $winScale $winWidth $winHeight $winTitle>;
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
   my @widgets=();
   my %iVars=();     #vars for interface operation (e.g. 
   my %oVars=();      #vars for interface creation (e.g. list of options)
   my %styles;   # styles is a future mod that allows widgets to be styled
   my %timers;

   my $lastMenuLabel;
   
   sub new
   {
       my $class=shift;
       my $self={};
       bless ($self,$class);
       $self->{Window}= new Win32::GUI::Window(
                 -name  =>  "GF",
                 -title =>  $winTitle,
                 -pos   =>  [ $winX,$winY ],
                 -size  =>  [ $winWidth+10, $winHeight+50 ],
               );
       $self->{Window}->Show();
       $self->{font} = Win32::GUI::Font->new(
                -name => "Arial", 
                -size => 16,
        );
       &setupContent($self, $self->{Window} );

       $self->{Window}->Show();
       return $self; 
   };

  sub MainLoop{
    Win32::GUI::Dialog();
  };
  
  sub GF_Terminate { return -1; }
  
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
							      $self ->{"menubar"} = Win32::GUI::Menu->new();;
		                          $canvas->SetMenu($self ->{"menubar"});
		                          }
	                          $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	       }
	   }
	    foreach my $timerID (keys %timers){
		   $timers{$timerID}{timer} = new Win32::GUI::Timer( $canvas, $timerID, $timers{$timerID}{interval} );
		   *{$timerID."_Timer")=$timers{$timerID}{function}
	   }
	   
	   # these functions convert the parameters of the widget into actual widgets
	   sub aBt{  # creates buttons
	    my ($self,$frame, $id, $label, $location, $size, $action)=@_;
	    $self->{"btn$id"}=$frame->AddButton(
                -name => "btn$id",
                -text => $label,
                -pos  => $location,
                -size => $size,
                -onClick => $action, 
        );
	    # button id are "btn".$id,  action is generally also a function called "btn".$id
	    # referenced by $frame->{"btn".$id}
        }
       sub aTC{ # single line text entry
		my ($self,$frame, $id, $text, $location, $size, $action)=@_;
		$self->{"textctrl$id"} = $frame->AddTextfield(
		-text   => $text,
        -pos    => $location,
        -size   => $size,
    );
        }
       sub aST{  #static texts
		my ($self,$frame, $id, $text, $location)=@_;
		$self->{"stattext$id"} = $frame->AddLabel(
                -text  => $text,
                -font  => $self->{font},
                -pos   => $location,
                -wrap  => 0,
                -truncate => 0,
                -foreground => [255, 0, 0],
           );
        }
       sub aCB{  
		   my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
		   $self->{"combo$id"}=$canvas->AddCombobox(     
              -name        => "combo_box1",
              -size        => $size,
              -pos         => $location,
              -dropdownlist=> 0,
              -onChange    =>$action,
              );
           my @strings2 = split(",",$oVars{$label});
	       $iVars{"combo$id"}=$strings2[0];
	       foreach (@strings2){ $self->{"combo$id"}->InsertItem($_);}

	   }
       sub aMB{  #parses the menu items into a menu.   menus may need to be a child of main window
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_; 
	       if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	       else {$lastMenuLabel=$label};	                                         # in menu generator
	    
	     
	       if ($type eq "menuhead"){  #the label of the menu
			   $currentMenu="menu".$id;
			   $self ->{$currentMenu} =  $self ->{"menubar"}->AddMenuButton( -text, $label);
		   }
		   elsif ($type eq "radio"){   #menu items which are radio buttons in tk there is no function called
			    
		   }
		   elsif ($type eq "check"){  #menu items which are check boxes in tk there is no function called
			    
		   }
		   elsif ($type eq "separator"){ #separators
			    
		   }
		   else{
			   if($currentMenu!~m/$label/){
				   $self ->{"menu$id"} =  $self ->{$currentMenu}->AddMenuItem(
				   -text => $label,
				   -id   =>$id,
				   -name => "menu$id",
				   -onClick => $action,
				   );
				    }
			   
		   }
		   $canvas->SetMenu($self ->{"menubar"});
		   return $currentMenu;
	   }
	   sub aSP{
			 my ($self,$frame, $id, $panelType, $content, $location, $size)=@_;  ##image Id must endup $id+1
			 if ($panelType eq "I"){  # Image panels start with I
				$content=~s/^\s+|\s+$//g; 
				$self->{"Image$id"} = $frame->AddLabel(
				-text  => "GFPic",
				-style => '14',
				-visible => '1',
				-background => [255,255,255],
				-foreground => [0,0,0],
                -pos   => $location,
                );
               # $self->{"Image$id"}->SetImage( new Win32::GUI::Bitmap("GFtmp.bmp") );
				if (-e $content){
			     my $image = Imager->new;
				 $image->read(file=>"$content"); 
			     my $newimg = $image->scale(xpixels=>${$size}[0], ypixels=>${$size}[1],type=>'nonprop');
			     $newimg->write(file=>"GFtmp.bmp");
			     $self->{"Image$id"}->SetImage( new Win32::GUI::Bitmap("GFtmp.bmp") );
			   }
		     }
			 
			elsif ($panelType eq "T"){    # text entry panels start with T
				$content=~s/^\s+|\s+$//g;
				$id++;
			    $self->{"TextCtrl$id"} = $frame->AddTextfield(
		            -text   => $content,
		            -multiline => 1,
		            -autohscroll => 1,
		            -autovscroll => 1,
                    -pos    => $location,
                    -size   => $size,
                 );
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
	   return ( $found!=-1) ? $widgets[$found][3]:0;
	   
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
#  Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;
	   $self->{$id}->Text("");
	   # label persists...but not contains empty string? how to delete?
	   my $location=getLocation($self,$id,\@widgets);
	   $self->{$id} = $self->{Window}->AddLabel(
                -text  => $text,
                -font  => $self->{font},
                -pos   => $location,
           )
   }

#Image functions
   sub setImage{
	   my ($self,$id,$file)=@_;
	   my $size=getSize($self,$id,\@widgets);
	   my $location=getLocation($self,$id,\@widgets);
       my $image = Imager->new;
       $image->read(file=>"$file");
       my $newimg = $image->scale(xpixels=>${$size}[0], ypixels=>${$size}[1],type=>'nonprop');
       $newimg->write(file=>"GFtmp.bmp");
	   $self->{"$id"}->SetImage( new Win32::GUI::Bitmap("GFtmp.bmp") );;
   };

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   return $self->{$id}->Text();
	   # function to get value of an input box
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
	   $self->{$id}->Text( $text );  
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
	   $self->{$id}->Append( $text ); 
   }   

#Message box, Fileselector and Dialog Boxes
  sub showFileSelectorDialog{
	 
     my ($self, $message,$load) = @_;
     my $filename;
     if ($load){
		 $filename  = Win32::GUI::GetOpenFileName (
		    -owner => $self->{Window},
		    -title =>$message,
		    -directory => ".",
		    ) ;
		 warn "Opened $filename\n";
		 }
	 else{
		 $filename = Win32::GUI::GetSaveFileName (
		    -title=>$message,
		    );
         warn "Saved $filename\n";
	 }
	 return $filename;
   };
      sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   #http://search.cpan.org/~robertmay/Win32-GUI-1.06/docs/GUI/UserGuide/FAQ.pod#What_are_the_icon,_button_and_modality_values_for_MessageBox?
	   my %responses=( YNC=>3,
	                   YN =>4,
	                   OK =>0,
	                   OKC=>1 );
	                   
	   my %icons= (  "!"=>16,
	                 "?"=>32,
	                 "E"=>48,
	                 "H"=>48,
	                 "I"=>64);
	   $response=$response?$responses{$response}:0;
	   $icon=$icon?$icons{$icon}:64;
	   my $answer= $self-> Win32::GUI::MessageBox(
            $message,
            $title,
            $icon+$response,
       );
       return (($answer == 1)||($answer == 6))
   };
   
# Quit
   sub quit{
	   my ($self) = @_;
	   $self ->GF_Terminate;
   }
1;
