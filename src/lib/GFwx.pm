package GFwxFrame;
   
   use strict;
   use warnings;

   our $VERSION = '0.11';
   
   use Exporter 'import';
   our @EXPORT = qw<addWidget addVar setScale>;
   
   use Wx qw(wxMODERN wxTE_PASSWORD wxTE_PROCESS_ENTER wxDEFAULT wxNORMAL
          wxFONTENCODING_DEFAULT wxTE_MULTILINE wxHSCROLL wxDefaultPosition wxFD_SAVE
          wxYES wxFD_OPEN wxFD_FILE_MUST_EXIST wxFD_CHANGE_DIR wxID_CANCEL
          wxYES_NO wxCANCEL wxOK  wxCENTRE  wxICON_EXCLAMATION  wxICON_HAND 
          wxICON_ERROR  wxICON_QUESTION  wxICON_INFORMATION wxCB_DROPDOWN);
          
   use Wx::Event qw( EVT_BUTTON EVT_TEXT_ENTER EVT_UPDATE_UI EVT_MENU EVT_COMBOBOX);
   use Wx::Perl::Imagick;                 #for image panels
   
   use base qw(Wx::Frame); # Inherit from Wx::Frame
   
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @widgets=();
   my %iVars=();     #vars for interface operation (e.g. 
   my %oVars=();                #vars for interface
   my %styles;
   
   my $lastMenuLabel;  #bug workaround in menu generator
   
   our $winScale=6.5;
   my $font = Wx::Font->new(     3*$winScale,
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

# setupContent  sets up the initial content before Mainloop can be run.
   
   sub setupContent{
	   my ($self,$canvas)=@_;
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
							       $self ->{"menubar"} = Wx::MenuBar->new();
		                           $self->SetMenuBar($self ->{"menubar"});
		                          }
	                          $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	       }
	   }
	   
	   sub aCB{
		   my ($self,$panel, $id, $label, $location, $size, $action)=@_;
		   if (defined $oVars{$label}){
	         my @strings2 = split(",",$oVars{$label});
	         $self->{"combo".$id}= Wx::ComboBox->new($panel, $id, $strings2[0],$location, Wx::Size->new($$size[0], $$size[1]),\@strings2,wxCB_DROPDOWN);
	         EVT_COMBOBOX( $self, $id, $action);
		 }
		 else {print "Combo options not defined for 'combo$id' with label $label\n"}
	   }
	   	   
	   sub aMB{
	     my ($self,$panel,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	    
	     
	       if ($type eq "menuhead"){
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
			   if($currentMenu!~m/$label/){
			     $self ->{$currentMenu}->Append($id, $label);
			     EVT_MENU( $self, $id, $action )
			 }
		   }
		   # logging menu generator print "$currentMenu---$id----$label---$type\n";
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
			 $self->{"textctrl".$id} = Wx::TextCtrl->new(
                                        $panel,
                                        $id,
                                        $text,
                                        $location,
                                        $size,
                                        wxTE_PROCESS_ENTER
                                        );
            EVT_TEXT_ENTER( $self, $id, $action);
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
			
			if ($panelType eq "I"){  # Image panels start with I
				if (! -e $content){ return; }
				no warnings;   # sorry about that...suppresses a "Useless string used in void context"
			    my $image = Wx::Perl::Imagick->new($content);
			    if ($image){
			      my $bmp;    # used to hold the bitmap.
			      my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Resize(geometry => $geom);
			      $bmp = $image->ConvertToBitmap();
			        if( $bmp->Ok() ) {
                     $self->{"Image".($id+1)}= Wx::StaticBitmap->new($self->{"subpanel".$id}, $id+1, $bmp);
                    }
				 }
				 else {"print failed to load image $content \n";}
			 }
			if ($panelType eq "T"){  # handle
				
				$self->{"TextCtrl".($id+1)} = Wx::TextCtrl->new(
                   $self->{"subpanel".$id}, 
                   $id+1,
                   $content, 
                   wxDefaultPosition, 
                   $size, 
                   wxTE_MULTILINE|wxHSCROLL 
                  );
                $self->{"TextCtrl".($id+1)}->SetFont(Wx::Font->new(10, wxMODERN, wxNORMAL, wxNORMAL ));
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
	   my ($self,$id,$arrayRef)=@_;
	   my $found=getItem($self,$id,$arrayRef);
	   return ( $found!=-1) ? $$arrayRef[$found][5]:0;
	   
   }
   sub getLocation{
	   my ($self,$id,$arrayRef)=@_;
	   my $found=getItem($self,$id,$arrayRef);
	   return ( $found!=-1) ? $$arrayRef[$found][4]:0;
	   
   }   
   sub getItem{
	   my ($self,$id,$arrayRef)=@_;
	   my $i=0; my $found=-1;
	   while ($i<@$arrayRef){
		   if ($$arrayRef[$i][1]==$id) {
			   $found=$i;
			   }
		   $i++;
	   }
	   return $found;
   }
   sub setScale{
	   $winScale=shift;
	   $font = Wx::Font->new(     3*$winScale,
                                wxDEFAULT,
                                wxNORMAL,
                                wxNORMAL,
                                0,
                                "",
                                wxFONTENCODING_DEFAULT);	   
   }
   sub reSize{
	   my ($self,$id,$newSize)=@_;
   }   
#  The functions for GUI Interactions
#Static Text functions
   sub setLabel{
	   my ($self,$id,$text)=@_;	   
	   $self->{$id}->SetLabel($text);
   }
   

#Image functions
   sub setImage{
	   my ($self,$id,$file)=@_;
	   $id=~s/[^\d]//g;
	   my $size=getSize($self,$id,\@widgets);
	   if ($size){
	       my $image = Wx::Perl::Imagick->new($file);
		   if ($image){
			  my $bmp;    # used to hold the bitmap.
			  my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Resize(geometry => $geom);
			      $bmp = $image->ConvertToBitmap();
			        if( $bmp->Ok() ) {
                     $self->{"Image".($id+1)}= Wx::StaticBitmap->new($self->{"subpanel".$id}, $id+1, $bmp);
                    }
				 }
				 else {"print failed to load image $file \n";}
			 }
		  else {print "Panel not found"}
			 
	   
   }

#Text input functions
   sub getValue{
	   my ($self,$id)=@_;
	   if (!$self->{$id}) {print "can not get  Value for widget ". $id.": Widget not found\n";}
	   else { $self->{$id}->GetValue();}
   }
   sub setValue{
	   my ($self,$id,$text)=@_;
	   if (!$self->{$id}) {print "can not set  Value for widget ". $id.": Widget not found\n";}
	   else {  $self->{$id}->SetValue($text);}
   }
   sub appendValue{
	   my ($self,$id,$text)=@_;
	   if (!$self->{$id}) {print "can not Append  Value to widget ". $id.": Widget not found\n";}
	    else { $self->{$id}->AppendText($text);}
   }

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load) = @_;
     my $loadOptions=wxFD_OPEN|wxFD_FILE_MUST_EXIST|wxFD_CHANGE_DIR;
     my $saveOptions=wxFD_SAVE|wxFD_CHANGE_DIR;
     my $fd = Wx::FileDialog->new( $self, $message, ".", q{},
				"All files|*|Data (*.dat)|*.dat",
				$load?$loadOptions:$saveOptions,
				wxDefaultPosition);
    if ($fd->ShowModal == wxID_CANCEL) {
      print "Data import cancelled\n";
      return;
    };
    return $fd->GetPath;

   };
   
   sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   my %responses=( YNC=>wxYES_NO|wxCANCEL|wxCENTRE,
	                   YN =>wxYES_NO|wxCENTRE,
	                   OK =>wxOK|wxCENTRE,
	                   OKC=>wxOK|wxCANCEL|wxCENTRE );
	                   
	   my %icons= (  "!"=>wxICON_EXCLAMATION,
	                 "?"=>wxICON_QUESTION,
	                 "E"=>wxICON_ERROR,
	                 "H"=>wxICON_HAND,
	                 "I"=>wxICON_INFORMATION );
	   $response=$response?$responses{$response}:wxOK|wxCENTRE;
	   $icon=$icon?$icons{$icon}:wxICON_INFORMATION;
	   my $answer= Wx::MessageBox( $message, 
                       $title, 
                       $response|$icon, 
                       $self);
       return (($answer==wxOK)||($answer==wxYES))
	   
   };
   
# quit
   sub quit{
	   my ($self) = @_;
	   $self ->Close(1);
   }


package GFwx;	   
   
   use strict;
   use warnings;
   
   our $VERSION = '0.09';

   use parent qw(Wx::App);              # Inherit from Wx::App
   use Exporter 'import';
   GFwxFrame->import(qw<addWidget addVar setScale>);
   
   our @EXPORT  = qw<addWidget addVar setScale $frame $winScale $winWidth $winHeight $winTitle>;
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


