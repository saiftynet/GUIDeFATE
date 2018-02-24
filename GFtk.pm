package GFtk;

   use parent qw(Tk::MainWindow);
   
   use Tk::JPEG;
   use Image::Magick;
   use MIME::Base64;
   
   use Exporter 'import';   
   our @EXPORT_OK      = qw<addButton addStatText addTextCtrl addMenuBits addPanel setScale $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle;
   our $winScale=6.5;  

   my @buttons=();
   my @textctrls=();
   my @stattexts=();
   my @menu=();
   my @subpanels=();
   my %styles;
   


   sub new
   {
    my $class = shift;    
    my $self = $class->SUPER::new(@_);  # call the superclass' constructor 
      $frame = $self->Canvas(
         -bg => 'lightgray',
         -relief => 'sunken',
         -width => $winWidth,
         -height => $winHeight*1.2)->pack(-expand => 1, -fill => 'both');
      
      $frame ->fontCreate('medium',
             -family=>'arial',
             -weight=>'normal',
             -size=>int(-18*18/14));
      setupContent($self,$frame);  #then add content
      return $self;
   };
   
   sub setupContent{
	   my ($self, $canvas)=@_;
	   
	   foreach my $button  (@buttons){
		   aBt($self, $canvas, @$button)
	   }
	   foreach my $textctrl (@textctrls){
		   aTC($self,$canvas,@$textctrl)
	   }
	   foreach my $stattxt (@stattexts){
		   aST($self,$canvas,@$stattxt)
	   }
	   if (scalar @menu){   #menu exists
		  $self->configure(-menu => my $self ->{"menubar"} = $self->Menu);
		  my $currentMenu;
		  foreach my $menuBits (@menu){ 
			  $currentMenu=aMB($self,$frame,$currentMenu,@$menuBits)
	       }
	       # a bug seems to make a menuhead to be also ia menuitem---

	   }
	   foreach my $sp (@subpanels){
		   aSP($self,$canvas,@$sp);
	   }
	   
	   sub aBt{
	    my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
	    $canvas->{"btn$id"}=$canvas->Button(-text => $label,
	                         -width  => (${$size}[0]-20)/7.5,
	                         -height => ${$size}[1]/16,
	                         -command => $action);
	    $canvas->createWindow(${$location}[0] ,${$location}[1],
	                         -anchor => "nw",
	                         -window => $canvas->{"btn$id"});
        }
       sub aTC{
		my ($self,$canvas, $id, $text, $location, $size, $action)=@_;
		$canvas->{"txtctrl$id"}=$canvas->Entry(
	                         -width  => ${$size}[0]/7);
	    $canvas->createWindow(${$location}[0] ,${$location}[1],
	                         -anchor => "nw",
	                         -window => $canvas->{"txtctrl$id"} );
        }
       sub aST{
		my ($self,$canvas, $id, $text, $location)=@_;
		$canvas->{"stattext$id"}=$canvas->createText(${$location}[0] ,${$location}[1], 
		                     -anchor => "nw",
                             -text => $text,
                             -font =>'medium'
                 );
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
			
			if ($panelType eq "I"){  # Image panels start with I
				$content=~s/^\s+|\s+$//g;
				if (! -e $content){ return; }
				no warnings;   # sorry about that...suppresses a "Useless string used in void context"
			    my $image = Image::Magick->new;
			    my $r = $image->Read("$content");
			    if ($image){
			      my $bmp;    # used to hold the bitmap.
			      my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Scale(geometry => $geom);
			      $bmp = ( $image->ImageToBlob(magick=>'jpg') )[0];
			      $canvas->{"image".($id+1)}=$canvas->createImage(${$location}[0],${$location}[1],
			                             -anchor=>"nw",
			                             -image => $canvas->Photo(#"img$id",
			                                     -format=>'jpeg',
			                                     -data=>encode_base64($bmp) ));
                    }
				 else {"print failed to load image $content \n";}
			 }
			if ($panelType eq "T"){  
				$content=~s/^\s+|\s+$//g;
				$id++;
				$canvas->{"TextCtrl$id"}=$canvas->Text(
	                         -width  => (${$size}[0])/7,
	                         -height => (${$size}[1]+12)/15);
	            $canvas->{"TextCtrl$id"}->insert('end',$content);
	             $canvas->createWindow(${$location}[0] ,${$location}[1],
	                         -anchor => "nw",
	                         -window => $canvas->{"TextCtrl$id"});
			 }
		 }
        
	   
   }
   
   sub setLabel{
	   my ($self,$text,$id)=@_;
	   my $location=$stattexts[getItem($self,$id,\@stattexts)][2];
	   $frame->delete($frame->{"stattext$id"});
	   $frame->{"stattext$id"}=$frame->createText(${$location}[0] ,${$location}[1], 
		                     -anchor => "nw",
                             -text => $text,
                             -font =>'medium'
                 );
   }
   
   sub setImage{
	   my ($self,$file,$id)=@_;
	   my $location=getLocation($self,$id,\@subpanels);
	   my $size=getSize($self,$id,\@subpanels);
	   if ($size){
	       my $image = Image::Magick->new;
		   my $r = $image->Read("$file");
		   if ($image){
			  my $bmp;    # used to hold the bitmap.
			  my $geom=${$size}[0]."x".${$size}[1]."!";
			      $image->Scale(geometry => $geom);
			      $bmp = ( $image->ImageToBlob(magick=>'jpg') )[0];
			      $frame->{"image$id"}=$frame->createImage(${$location}[0],${$location}[1],
			                             -anchor=>"nw",
			                             -image => $frame->Photo(#"img$id",
			                                     -format=>'jpeg',
			                                     -data=>encode_base64($bmp) ));
                    }
				 else {"print failed to load image $file \n";}
			 }
		  else {print "Panel not found"}
			 
	   
   }
   sub getValue{
	   my ($self,$id)=@_;
	   $frame->{"$id"}->get('1.0','end-1c');
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
	   my $i=0; my $found=-1;
	   while ($i<@$arrayRef){
		   if ($$arrayRef[$i][0]==$id) {
			   $found=$i;
			   }
		   $i++;
	   }
	   return $found;
   }
   
      
   sub showFileSelectorDialog{
	 
     my ($self, $message,$load) = @_;
     if ($load){
		 my $filename = $self->getOpenFile( -title => $message,
		 -defaultextension => '.txt', -initialdir => '.' );
		 warn "Opened $filename\n";
		 }
	 else{
		 my $filename = $self->getSaveFile( -title => $message,
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
   
   sub setScale{
	   $winScale=shift;	   
   };
   
   sub getFrame{
	   my $self=shift;
	return $self;
   };


1;
