package GFweb;
   use strict;
   use warnings;
   
   our $VERSION = '0.11';

   use Exporter 'import';   
   our @EXPORT      = qw<addWidget addVar setScale MainLoop $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   
   use Net::WebSocket::Server;
   use IO::Socket::PortState qw(check_ports);  # requiredso that multiple listeners are not attempted
   our $connection;
   our $clientFileName; 
   our $webApp;
   our $host;
   our $port;  
   our $serverRunning=0; 
   our @msgQueue=();
     
   our $winX=30;
   our $winY=30;
   our $winWidth;
   our $winHeight;
   our $winTitle="title";
   our $winScale=6.5;
 
   # these arrays will contain the widgets each as an arrayref of the parameters
   my @widgets=();
   my %iVars=();      #vars for interface operation (e.g. state of interface)
   my %oVars=();      #vars for interface creation (e.g. list of options)
   my %styles;

   our $debug;
   my %msgFlags;
   my %dialogDispatch;   # dispatch table for dialog actions
   my $uploadFileName;

   
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift; 
    
    # Allow the host and the port for the server to be defined by main::
    # for web app creation this is an extra parameter added in the GUIDeFATE::new
    # Allows
    # my $gui=GUIDeFATE->new($window,"web","q", 8085);
    # my $gui=GUIDeFATE->new($window,"web","q", "localhost:8085");
    
    $port=shift || 8085;
    $debug=shift;
    $debug=$debug ? 1:0;
    if ($port =~/:/) {
		($host,$port)=split(":",$port)
	}
	else {$host="localhost"};
	
	
	# applications attemting to run with a used port will cause a
	# "Failed to listen error.This just finds the next available port.
	my $portAvailable = 0;        	                              
	 while(!$portAvailable){      
		   my %ports = (          # required for check_hosts from IO::Socket::PortState
	        tcp => {
	          $port => {}, 
	        }
	      );
	      my $timeout=10;
	      my $host_hr = check_ports($host, $timeout, \%ports);       # check the ports
	      $portAvailable = $host_hr->{tcp}{$port}{open} ? 0:1;       # if already open
	      $port++;
	 }     
	 $port--;
    	
    my $self={};   
    bless( $self, $class );
    $self->{html}=$self->header();
    
    $self->{html}.="<title>$winTitle $0 </title>\n";
    $self->{html}.= "  <head>\n<style>\n".css()."</style>\n";
    $self->{html}.= "  <script>\n".js()."</script>\n";
    if (-e "$0.js"){  $self->{html}.= "  <script type=\"text/javascript\" src=\"$0.js\"></script>\n";}
    $self->{html}.= "  </head>\n<body>\n<div style=\"width:$winWidth"."px;height:$winHeight"."px\">\n";
    $self->{content}="<div id=window style=\"position:relative;width:$winWidth"."px;height:$winHeight"."px\">\n";
    setupContent($self,$self->{content});
    $self->{html}.=$self->{content};
    $self->{html}.=dialogBoxDiv();
    
    $self->{html}.= "\n</div>\n</body>\n</html>";

    $clientFileName = "$0$port.html";
      open(my $fh, '>', $clientFileName) or die "Could not open file '$clientFileName' $!";
      print $fh $self->{html};
      close $fh; 
           
    return $self;
   };
   
  sub MainLoop{ #activate UI
	  my $self=shift;

	 # create new server 
	 $webApp= Net::WebSocket::Server->new(  
        listen => $port,
        on_connect => sub {
            (my $serv, $connection) = @_;
            
            $connection->on(
                utf8 => sub {
					parseMessage(@_);
				},
				binary => sub {
                    parseBinary(@_);
                },
             );
          },
      );
	  
	  
	  if ($^O =~/linux/){ system("xdg-open ./".$clientFileName."  2> /dev/null &\n"); }  # for Linux
	  elsif ($^O =~/Win/){ system("start .\\".$clientFileName."\n"); }      # for windows?
	  else{ system("open ./".$clientFileName." &\n"); }                     # for Macs?
	  
	  

		  $webApp->start(); 
  }
  
   sub parseMessage{
	my($conn, $message)=@_;
	$conn->send_utf8( "Message received by server: - $message\n");
	
    if ($message=~/Client is ready/){
		
		foreach (@msgQueue){ # send messages that were quede until client ready
				$conn->send_utf8($_);
				select(undef, undef, undef, 0.05);
			}
		if (exists &{'main::init'}){ # after client loaded application actions
			my $s = \&{'main::init'};
            $s->();
		}
	}
    elsif ($message=~/^[A-z]*=/){
	  my %hash = map{split /\=/, $_,2}(split /\&/, $message,3);
	  if($hash{Function}) {
		  if ($hash{Function} eq "Dialog"){  # function from Dialog buttons
			  &{$dialogDispatch{$hash{Label}}}; 
		  }
		  elsif ($hash{Function} eq "FileLoaded"){  # function from file selector
			  
		  }
		  else {                           # function triggered by widgets
			  mapAction($hash{Function});
		  }
	  }
	  elsif ($hash{ID}) {
		$msgFlags{$hash{ID}}=1;
		my $tmp=$hash{Value};
		$tmp=~s/^'|'$//g;
		$iVars{$hash{ID}}=$tmp;
		#$conn->send_utf8( "Server stores ".$hash{ID}. " the value ".$hash{Value});
	  }
    }
    elsif ($message=~/^File follows:(.*)\n/){       # Get ready to receive file
		$uploadFileName=$1;
		if (! -d "dataFiles") {mkdir "dataFiles";}  # ensure upload directory exists
		unlink "dataFiles/$uploadFileName";         # delete file if already exists
		$conn->send_utf8( "Binary data expected: Ready to receive $uploadFileName \n"); # Announce ready to receive binary Data
	}
	elsif ($message=~/^File ends:(.*)\n/){
		$conn->send_utf8( "Message Binary data upload complete:\n");
		if (defined $dialogDispatch{File}){ #Funtion to run after file has been downloaded
			 &{$dialogDispatch{File}}($1);  
			 }  
		$uploadFileName=undef;
	}
  }
  
  sub parseBinary{
	  my($conn, $binary)=@_;
	  open(my $fh, '>>', "dataFiles/$uploadFileName") or die "Could not open file 'dataFiles/$uploadFileName' $!";
	  print $fh $binary;
	  close $fh;
	  $conn->send_utf8( "Binary data received: -(". (length $binary). " bytes inserted into $uploadFileName)\n");
  }
  
  sub mapAction{   # maps id of widget with action on change
	my $item=shift;
	my $widgetIndex=getItem(undef,$item);
	my @widget=@{$widgets[$widgetIndex]};
	my $wType=shift @widget;
	if ($widgetIndex !=-1){
		if     ($wType eq "mb")   { &{$widget[3]};}  
		elsif  ($wType eq "btn")  { &{$widget[4]};}
		elsif  ($wType eq "combo")  { &{$widget[4]};}
	}	
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
					$self ->{"menubar"} = " <div style=\"width:$winWidth"."px;height:16px;\">\n  <ul class=menubar>\n";
		            }
	            $currentMenu=aMB($self,$canvas,$currentMenu,@params)
	         }
	   } 
	   if ($self->{"menubar"}) { $self->{"menubar"}.="       </div>\n   </li>\n  </ul>\n </div>"; }
	   if ($self->{menubar}){ $self->{content}.= $self->{menubar} . "\n<br>\n";}
	   $self->{content}.="\n</div>\n";
	   
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
	                  "width:".${$size}[0]."px;height:".${$size}[1]."px;\" value=\"".$strings2[0]."\" onchange=\'act(\"combo$id\",this.value)\'>\n";
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
			   if (defined $currentMenu){$canvas.="      </div>\n    </li>";}
			   $currentMenu="menu".$id;
			   $self ->{"menubar"}.="    <li class=\"menuhead dropdown\">\n     <a  id=menu$id class=\"dropbtn\">$label</a>\n       <div class=\"dropdown-content\">\n";
		   }
		   elsif ($type eq "radio"){
			   
		   }
		   elsif ($type eq "check"){
			   
		   }
		   elsif ($type eq "separator"){
			   
		   }
		   else{
			   if($currentMenu!~m/$label/){
				$self ->{"menubar"}.="         <a href=# id=menu$id class=menuitem  onclick=\'act(\"menu$id\",\"$label\")\'>$label</a>\n"  			     
			 }
		   }
		   return $currentMenu;
	   }
	   sub aSP{
			my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  # Image panels start with I
				$self->{content}.="<img id=Image$id src=\"$content\" style=\"position:absolute;left:".${$location}[0]."px;top:".${$location}[1]."px;".
	                  "width:".${$size}[0]."px;height:".${$size}[1]."px;\"  onclick=\"this.src=(this.src+\'?\'+Math.random)\">\n";
			 }
			if ($panelType eq "T"){  
				$id++;
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
  
   sub dialogAction{
	   my ($self,$name,$action)=@_;
	   $dialogDispatch{$name}=$action;
	   
   }
   sub setScale{
	   $winScale=shift;	   
   };

   sub getFrame{
	   my $self=shift;
	   return $self;
	   
   };

#  The functions for GUI Interactions
# Static Text functions
# GUI interactions are over the connection...but if connection not yet 
# active, these are queued   

   sub sendIfConnected{
	   my $msg=shift;
	   if ($connection){
		    $connection->send_utf8($msg);
		    select(undef, undef, undef, 0.25);
	   }
	   else{
		   push @msgQueue, $msg;
	   }
   }

   sub setLabel{
	   my ($self,$id,$text)=@_;
	  sendIfConnected("action=setLabel&id=$id&value=$text");
	   
   }

#Image functions
   sub setImage{
	 my ($self,$id,$file)=@_;
	 sendIfConnected("action=setImage&id=$id&value=$file");

   }

#Text input functions
  sub getValue{
	   my ($self,$id)=@_;
	   $msgFlags{$id}=0;
	   sendIfConnected("action=getValue&id=$id");
	   foreach (0..4){
		  last if $msgFlags{$id};
		  select(undef, undef, undef, 0.1);
	   }
	   $msgFlags{$id}=0;
       return $iVars{$id};
   }
   
   sub setValue{
	   my ($self,$id,$text)=@_;
	   sendIfConnected("action=setValue&id=$id&value=$text");
	   $iVars{$id}=$text;
   }   
   sub appendValue{
	   my ($self,$id,$text)=@_;
	   sendIfConnected("action=appendValue&id=$id&value=$text");
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
     my ($self, $message,$load,$file) = @_;
     $connection->send_utf8("action=showFileSelector&id=fileSelector&value=$load#$message#$file");
   };
   sub showDialog{
	   my ($self, $title, $message,$response,$icon) = @_;
	   $connection->send_utf8("action=showDialog&id=dialog&value=$icon#$response#$title#$message");
   };
   
# Quit
   sub quit{
	  $webApp->shutdown();
   }
   
   sub DESTROY {
	   unlink $clientFileName
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

.dialogBox{
   width:$winWidth;
   height:$winHeight;
   background-color:grey;
   opacity: 0.5;
}

.buttonBox{	
	width: 400px;
    height: 100px;
	background-color:lightgrey;
	position:relative;
    left:0; right:0;
    top:20%; bottom:0;
	margin:auto;
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
	  
var ws;
var start=new Date();
var binaryBuffer;
var logWin=$debug;
var blurred=0;

function WebSocketStart()
  {  
   if (logWin==1){
      logWin=window.open('','Logs', target='_blank', 'toolbar=0,scrollbars=1,statusbar=0,menubar=0,resizable=0,height=500,width=433');
   }
   if (logWin){ logWin.document.write("<h1>GUIDeFATE Websocket Log opened</h1><br>\\n");
         logWin.blur();
          window.focus();
   }
 
     
      
    if ("WebSocket" in window) {
      ws = new WebSocket("ws://$host:$port");
      
      ws.binaryType = "blob";
      
      ws.onopen = function(){
         log("red","Web App Started");
         send("Client is ready");
         };
				
      ws.onmessage = function (evt)  { 
		var received_msg = evt.data;
		log("blue",received_msg);
        parseMessage(received_msg);
      };
      
	  ws.onclose = function(){  log("red","Connection is closed...");  };
	}
    else { log("blue","WebSocket NOT supported by your Browser!"); }  };
   
    function send(msg){
        log("red",msg); 
		ws.send(msg);
		return false;
	}
	
	function sendBinary(msg){
        log("red","sending binary data"); 
		ws.send(msg);
		return false;
	}
	
	
// The handful of commands are parsed here and results reported back to server
function parseMessage(msg){
   if  (msg.indexOf("Mess")==0){return;}  //do nothing with informational messages
   else if(msg.indexOf("Binary")==0){
      binaryBuffer.sendNext();
   return;
   }
   var actionRE=/^action=([^&]*)&/;
   var IDRE=/&id=([^&]*)&?/;
   var valueRE=/&value=([\\s\\S]*)\$/;
   var action=actionRE.exec(msg);
   var id=IDRE.exec(msg);
   var value=valueRE.exec(msg);
   log("brown",action+"<br>"+id + "<br>"+value);



   if (!id || !id[1]) {
      
        log("green","NO ID or no item with ID '"+id[1] +"'");
      //send ("Error:NO ID or no item with ID '"+id[1] +"'")
   }
   else{ 
    switch (action[1]){
     case "getValue":
          log("green", "client replies to getValue  " + id[1]+ " with result :" +document.getElementById(id[1]).value);
          send ("ID="+id[1]+"&Value='"+document.getElementById(id[1]).value+"'");
     break;
     case "setValue":
          document.getElementById(id[1]).value=value[1];
          log("green", "Success:"+id[1]+" now has value "+document.getElementById(id[1]).value);
          send ("ID="+id[1]+"&Value="+document.getElementById(id[1]).value);
     break;
     case "appendValue":
          document.getElementById(id[1]).value+=value[1];
          log("green", "Success:"+id[1]+" now has value "+document.getElementById(id[1]).value);
          send ("ID="+id[1]+"&Value="+document.getElementById(id[1]).value);
     break;
     case "setLabel":
          document.getElementById(id[1]).innerHTML=value[1];
          log("green", "Success:"+id[1]+" now has text.. "+document.getElementById(id[1]).innerHTML);
     break;
     case "setImage":
          document.getElementById(id[1]).src=value[1];
          log("green", "Success:"+id[1]+" now has src.. "+value[1]);
     
     break;
     case "showFileSelector":
       var dlg=(value[1]).split("#")
       log("green","showing File Selector, Load/Save "+dlg[0] + ", Message "+dlg[1] + ", File "+dlg[2]) 
       document.getElementById("dialogTitle").innerHTML="<strong>File Operation</strong>";
       document.getElementById("dialogMessage").innerHTML=dlg[1]+"<br>";
       document.getElementById("dialogButtons").innerHTML="";
       if (dlg[0]=="1") {addFileButton();}
       else  {
          document.getElementById("dialogMessage").innerHTML+="<em>Right click to Download and save-as desired</em><br>";
          document.getElementById("dialogMessage").innerHTML+="<a href='dataFiles/"+dlg[2] +"' download>DOWNLOAD "+dlg[2]+" </a>"
       }
       addDialogButton("Dialog","Cancel");
       hideDiv("window");
       showDiv("dialogBox");
     break;
     case "showDialog":
        var dlg=(value[1]).split("#")
        log("green","showing Dialog with Icon "+dlg[0] + ", Response "+dlg[1] + ", Title "+dlg[2] + ", Message "+dlg[3]);
        document.getElementById("dialogTitle").innerHTML=dlg[2];
        document.getElementById("dialogMessage").innerHTML=dlg[3]+"<br>";
        document.getElementById("dialogButtons").innerHTML="";
        if (dlg[1].indexOf("O")!=-1) addDialogButton("Dialog","OK");
        if (dlg[1].indexOf("Y")!=-1) addDialogButton("Dialog","Yes");
        if (dlg[1].indexOf("N")!=-1) addDialogButton("Dialog","No");
        if (dlg[1].indexOf("C")!=-1) addDialogButton("Dialog","Cancel");
        hideDiv("window");
        showDiv("dialogBox");
     break;
     default:
       log ("teal","unrecognised command "+action[1])
      }   
    }
};


//object that stores a binary file data and send is 64000 bytes at a time
function BinaryBuffer(blob){
   this.data=blob;
   this.name=blob.name;
   this.size=blob.size;
   this.sendIndex=0;
   
   this.sendNext=function(){
      var endIndex=this.sendIndex+64000;
      if (endIndex>this.size)
          { endIndex=this.size };
      if (this.sendIndex<this.size)
          {sendBinary(this.data.slice(this.sendIndex,endIndex) );
           this.sendIndex+=64000}
      else 
           { send("File ends:"+this.name+"\\n")      }   
   }
}

function log(colour, message){
   if(logWin) logWin.document.write("<p style='margin:0;color:"+colour+"'>"+message+"</p>\\n");
   else { console.log(message) }
}


function act(command,label){
  if (typeof window[command] === "function") {  //these are functions internal to the javascript engine or in the external javascrpt file
    window[strOfFunction](label);
   }
   else if (command=="UploadFile"){  //label contains a blob the file
     binaryBuffer=new BinaryBuffer(label);
     send("Sending File with size "+binaryBuffer.size+"\\n");
     send("File follows:"+binaryBuffer.name+"\\n");
   }
   else{
     if (command.match(/textctrl|combo/i)){   // for text ctrls and combos send ID and value/content
        var content=(document.getElementById(command).value!="")?document.getElementById(command).value:"EmptyString"
        send("ID="+ command + "&Value='"+content + "'")
      }
    send("Function="+ command + "&Label="+encodeURIComponent(label)) //for buttons and menu items send ID and label
   }
}

 function addFileButton(){
    var btn=document.createElement("input");
    btn.type="file";
    btn.onchange=function(){
        act("UploadFile",this.files[0]);
        hideDiv("dialogBox");
        showDiv("window");
       }
    document.getElementById("dialogButtons").appendChild(btn);
 }
 function addDialogButton(command,label){
    var btn=document.createElement("input");
    btn.type="button";
    btn.value=label;
    btn.command=command;
    btn.onclick=function(){
        hideDiv("dialogBox");
        showDiv("window");
        act(this.command,this.value);
       }
    document.getElementById("dialogButtons").appendChild(btn);
 }
 
 //functions to hide and show divs by ID
 function hideDiv(id){
   document.getElementById(id).style.visibility="hidden";
   document.getElementById(id).style.display="none";
 }
 function showDiv(id){
   document.getElementById(id).style.visibility="visible";
   document.getElementById(id).style.display="block";
 }
 
 
 window.onbeforeunload = function() {
    websocket.onclose = function () {}; // disable onclose handler first
    websocket.close()
    }	
    
 window.onload=function(){
   window.resizeTo($winWidth,$winHeight);
   hideDiv("dialogBox");
   WebSocketStart();
 
 }  
 
 // this allows the websocket to restart incase focus was lost by starting another listener
  window.onblur=function(){
    blurred=1;
  
  }
  window.onfocus=function(){
   if (blurred){
      blurred=0;
      WebSocketStart();
  }
 }  
 
END

}


sub dialogBoxDiv{
	  return <<END
   <!-Container for Dialog Box-->
   <div id=dialogBox class=dialogBox>
      <div id=dialogButtonBox class=buttonBox>
       <center>
          <div id=dialogTitle></div>
          <div id=dialogMessage></div>
          <div id=dialogButtons></div>
        </center>
      </div>
   
   </div>	  	  
END

}

1;

