package GFhtml;
   use strict;
   use warnings;
   
   our $VERSION = '0.13';

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
   my %timers;
   
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift; 
    my $self={};   
    bless( $self, $class );
    $self->{header}=header();
    $self->{header}.="<title>$winTitle $0 </title>\n";
    $self->{content}="<div id=window style=\"position:relative;width:$winWidth"."px;height:$winHeight"."px\">\n";
    setupContent($self,$self->{content});
    
    $self->{html}=$self->{header};
    $self->{html}.="<head>\n<style>\n".css()."</style>\n<script>\n".js()."</script>\n".
                   "<script type=\"text/javascript\" src=\"$0.js\"></script>\n".
                   "</head>\n<body>\n";
    $self->{html}.=$self->{content};
    if ($self->{menubar}){ $self->{html}.= $self->{menubar} . "\n<br>\n";}
    $self->{html}.= "</div>\n</body>\n</html>";
    
    my $filename = $0.".html";
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh $self->{html};
    close $fh;
    return $self;
   };
   
  sub MainLoop{ #activate UI
	  my $self=shift;
	  my $htmlFile=$0.".html";
	  if ($^O =~/linux/){ system("xdg-open ./".$htmlFile."\n"); }
	  elsif ($^O =~/Win/){ system("start .\\".$htmlFile."\n"); }
	  else{ system("open ./".$htmlFile."\n"); }
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
					$self ->{"menubar"} = "<div style=\"width:$winWidth"."px;height:16px;\">\n<ul class=menubar>";
		            }
	            $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	         }
	   } 
	   if ($self->{"menubar"}) { $self->{"menubar"}.="</div>\n</li>\n</ul></div>"; }
	   foreach my $timerID (keys %timers){  ## nnot sure if this needs to be implemented yet
		   if ($timers{$timerID}{start} eq '1'){start($self,$timerID)};
	   }
	   
	   
	   sub aBt{      
	    my ($self,$canvas, $id, $label, $location, $size, $action)=@_;# Button generator
	    $self->{content}.="<input id=btn$id type=button style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	             "width:".${$size}[0]."px;height:".${$size}[1]."px;\" value=\"$label\" onclick=\'act(\"btn$id\",\"$label\")\'>\n";
        }
       sub aTC{
		my ($self,$canvas, $id, $text, $location, $size, $action)=@_;# Single line input generator
		$self->{content}.="<input id=textctrl$id  style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	             "width:".${$size}[0]."px;height:".${$size}[1]."px;\" value=\"$text\" onchange=\'act(\"textctrl$id\",this.value)\'>\n";
		}
       sub aST{
		my ($self,$canvas, $id, $text, $location)=@_;  #Static text element generator
		$self->{content}.="<div id=stattext$id style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px\">".$text."</div>\n";
        }
       sub aCB{  
		my ($self,$canvas, $id, $label, $location, $size, $action)=@_; #gnerator for comoboxes
		if (defined $oVars{$label}){
			 my @strings2 = split(",",$oVars{$label}); # extract the defined options
	         $self->{content}.="<select id=combo$id style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	                  "width:".${$size}[0]."px;height:".${$size}[1]."px;\" value=\"".$strings2[0]."\" onchange=\'act(\"textctrl$id\",this.value)\'>\n";
		     foreach (@strings2){
				 $self->{content}.="  <option>$_</option>\n";
			 }
			 $self->{content}.="</select>\n";
	      }
		 else {print "Combo options not defined for 'combo$id' with label $label\n"};
	   }          
	   
       sub aMB{
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	     if ($type eq "menuhead"){
			   if (defined $currentMenu){$canvas.="</div></li>";}
			   $currentMenu="menu".$id;
			   $self ->{"menubar"}.="<li class=\"menuhead dropdown\">\n<a  id=menu$id class=\"dropbtn\">$label</a>\n<div class=\"dropdown-content\">\n";
		   }
		   elsif ($type eq "radio"){
			   
		   }
		   elsif ($type eq "check"){
			   
		   }
		   elsif ($type eq "separator"){
			   
		   }
		   else{
			   if($currentMenu!~m/$label/){
				$self ->{"menubar"}.="<a href=# id=menu$id class=menuitem  onclick=\'act(\"menu$id\",\"$label\")\'>$label</a>\n"  			     
			 }
		   }
		   return $currentMenu;
	   }
	   sub aSP{
			my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  # Image panels start with I
				$self->{content}.="<img id=Image$id src=\"$content\" style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	                  "width:".${$size}[0]."px;height:".${$size}[1]."px;\">\n";
			 }
			elsif ($panelType eq "T"){  
				$self->{content}.="<textarea id=TextCtrl$id  style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	                  "width:".${$size}[0]."px;height:".${$size}[1]."px;\">$content</textArea>\n";
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
 
 # Timer functions
  sub start{
	  my ($self,$timerID)=@_;
	  $timers{$timerID}{timer} = AnyEvent->timer (after => 0, interval => $timers{$timerID}{interval}/1000, cb => $timers{$timerID}{function});
  };
  sub stop{
	  my ($self,$timerID)=@_;
	  $timers{$timerID}{timer} = undef;
  };
  sub interval{
	  my ($self,$timerID,$interval)=@_;
	  stop($self,$timerID);
	  $timers{$timerID}{interval}=$interval;
	  start($self,$timerID);
  };
  sub callback{
	  my ($self,$timerID,$function)=@_;
	  stop($self,$timerID);
	  $timers{$timerID}{function}=$function;
	  start($self,$timerID);
  };
    
  
# Quit
   sub quit{

   }
   
   
  sub css{
	  return <<ENDCSS
ul.menubar {
    list-style-type: none;
    margin: 0;
    padding: 0;
    overflow: hidden;
    background-color: #333;
}

.menuhead {
    float: left;
}

.menuhead a, .dropbtn {
    display: inline-block;
    color: white;
    text-align: center;
    padding: 1px 3px;
    text-decoration: none;
}

li.menuhead a:hover, .dropdown:hover .dropbtn {
    background-color: red;
}

.menuhead .dropdown {
    display: inline-block;
}

.dropdown-content {
    display: none;
    position: absolute;
    background-color: #f9f9f9;
    min-width: 160px;
    box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
    z-index: 1;
}

.dropdown-content a {
    color: black;
    padding: 1px 3x;
    text-decoration: none;
    display: block;
    text-align: left;
}

.dropdown-content a:hover {background-color: #f1f1f1}

.dropdown:hover .dropdown-content {
    display: block;
}

ENDCSS

  }
  
  sub header{
	  return <<END
<html>	  
END

}

  sub js{
	  return <<END
function act(command,label){
  if (typeof window[command] === "function") {
    window[strOfFunction](label);
   }
  else{
     alert("Function "+ command + "\\nParameter "+label +"\\nNot yet defined")
  }
}
	  
END

}

1;

