package GFqt;
   use strict;
   use warnings;
   
   our $VERSION = '0.13';

use QtCore4;
use QtGui4;
use QtCore4::isa qw( Qt::MainWindow );
use QtCore4::slots
    mapAction=>['QString'],
    timedaction  =>[];##attempt ot get timer functionality  currently only single timeout slot

   
   use Exporter 'import';   
   our @EXPORT   = qw<addWidget addTimer addVar setScale getFrame $frame $winScale $winWidth $winHeight $winTitle>;
   our $frame;
   our $app;
   
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
  # my @menus;
   my $lastMenuLabel;  #bug workaround in menu generator may be needed for submenus
   
   sub new
   {
    my $class = shift; 
    $app = Qt::Application(\@ARGV);    
    my $self = $class->SUPER::new();  # call the superclass' constructor
    $self->{canvas}=Qt::Widget;
    $frame= $self->{canvas};
    $self->setWindowTitle ( $winTitle );
    $self->{canvas}->setGeometry(0, 0, $winWidth, $winHeight);
    $self->{canvas}->setParent($self);
    $app->setMainWidget($self->{canvas});
    
    $self->{SigMan} = Qt::SignalMapper($self);
    $self->connect($self->{SigMan}, SIGNAL 'mapped(QString)', $self, SLOT 'mapAction(QString)');#
    
    setupContent($self,$self->{canvas});
    $self->resize($winWidth, $winHeight);
    
    $self->show;
    return $self;

   };
   
  sub MainLoop{
	  my $self=shift;
	  $app->exec();
  }
  
  sub timedaction{
	  $timers{(keys %timers)[0]}{function}->();   #currently only one timeout slot
  };



sub mapAction{
	my $item=shift;
	my $widgetIndex=getItem($item);
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
	   my ($self, $canvas)=@_;
	   my $currentMenu;	   
	   foreach my $widget (@widgets){
		   my @params=@$widget; my $menuStarted=0;
		   my $wtype=shift @params;
		   if ($wtype eq "btn")             {aBt($self, $canvas, @params);}
		   elsif ($wtype eq "textctrl")     {aTC($self, $canvas, @params);}
		   elsif ($wtype eq "stattext")     {aST($self, $canvas, @params);}
		   elsif ($wtype eq "sp")           {aSP($self, $canvas, @params);}
		   elsif ($wtype eq "combo")        {aCB($self, $canvas, @params);}
		   elsif ($wtype eq "sp")           {aSP($self, $canvas, @params);}
		   elsif ($wtype eq "mb")           {$currentMenu=aMB($self,$canvas,$currentMenu,@params) }	       
	   }
	    if (defined $currentMenu){ $self->menuBar()->addMenu($self->{$currentMenu}) }

        #setup timers
	    foreach my $timerID (keys %timers){
		   $timers{$timerID}{timer} = Qt::Timer($self);  # create internal timer
		   $self->connect($timers{$timerID}{timer}, SIGNAL('timeout()'), SLOT('timedaction()'));
		   if ($timers{$timerID}{interval}>0){
			   $timers{$timerID}{timer}->start($timers{$timerID}{interval});
		   }
		}

	   sub aBt{
		   my ($self,$canvas, $id, $label, $location, $size, $action)=@_;
		   $canvas->{"btn$id"}=Qt::PushButton($label);
		   $canvas->{"btn$id"}->setParent($canvas);
		   $canvas->{"btn$id"}->setGeometry(${$location}[0],${$location}[1],${$size}[0],${$size}[1]);
		   $self->connect($canvas->{"btn".$id}, SIGNAL 'clicked()', $self->{SigMan}, SLOT 'map()');
		   $self->{SigMan}->setMapping($canvas->{"btn".$id}, "btn".$id);
        }
       sub aTC{
		   my ($self,$canvas, $id, $text, $location, $size, $action)=@_;
		   $canvas->{"textctrl$id"}=Qt::LineEdit($text);
		   $canvas->{"textctrl$id"}->setParent($canvas);
		   $canvas->{"textctrl$id"}->setGeometry(${$location}[0],${$location}[1],${$size}[0],${$size}[1]);
        }
       sub aST{
		   my ($self,$canvas, $id, $text, $location)=@_;
		   $canvas->{"stattext$id"}=Qt::Label($text);
		   $canvas->{"stattext$id"}->setStyleSheet("font-size:18px");
		   $canvas->{"stattext$id"}->setParent($canvas);
		   $canvas->{"stattext$id"}->setGeometry(${$location}[0],${$location}[1],32*length $text,24);
        }
       sub aCB{  
		   my ($self,$canvas, $id, $label, $location,$size,$action)=@_;
		   $canvas->{"combo$id"}=Qt::ComboBox;
		   if (defined $oVars{$label}){
	         my @strings2 = split(",",$oVars{$label});
		     foreach (@strings2){
				 $canvas->{"combo$id"}->addItem($_);
			 }
			 $canvas->{"combo$id"}->setParent($canvas);
		     $canvas->{"combo$id"}->setGeometry(${$location}[0],${$location}[1],${$size}[0],${$size}[1]);
		     $self->connect($canvas->{"combo".$id}, SIGNAL 'currentIndexChanged(int)', $self->{SigMan}, SLOT 'map()');
		     $self->{SigMan}->setMapping($canvas->{"combo".$id}, "combo".$id);

			}
		 else {print "Combo options not defined for 'combo$id' with label $label\n"}

		}
		 
      sub aMB{
	     my ($self,$canvas,$currentMenu, $id, $label, $type, $action)=@_;
	     if (($lastMenuLabel) &&($label eq $lastMenuLabel)){return $currentMenu} # bug workaround 
	     else {$lastMenuLabel=$label};	                                         # in menu generator
	       if ($type eq "menuhead"){
			   if (defined $currentMenu){ $self->menuBar()->addMenu($self->{$currentMenu}) }
			   $currentMenu="menu".$id;
			   $self->{$currentMenu} = Qt::Menu($self->tr($label),$self);
			   
			  # push (@menus, $currentMenu)
		   }
		   elsif ($type eq "radio"){
		   }
		   elsif ($type eq "check"){
		   }
		   elsif ($type eq "separator"){
			   $canvas->{$currentMenu}->addSeparator();
		   }
		   else{
			   #print "MenuItem $label \n";
			   $self->{"menu".$id."Act"}=Qt::Action($self->tr($label), $self);
			   $self->connect($self->{"menu".$id."Act"}, SIGNAL 'triggered()', $self->{SigMan}, SLOT 'map()');
			   $self->{SigMan}->setMapping($self->{"menu".$id."Act"}, "menu".$id);
			   $self->{$currentMenu}->addAction($self->{"menu".$id."Act"});
			 }
		   
		   # logging menu generator print "$currentMenu---$id----$label---$type\n";
		   return $currentMenu;
	   }
	   sub aSP{
			 my ($self,$canvas, $id, $panelType, $content, $location, $size)=@_;
			
			if ($panelType eq "I"){  # Image panels start with I
				    $canvas->{"Image$id"}=Qt::Label();
				    $canvas->{"Image$id"}->setParent($canvas);
		            $canvas->{"Image$id"}->setGeometry(${$location}[0],${$location}[1],${$size}[0],${$size}[1]);
				if (! -e $content){ return; }
					my $image = Qt::Image(Qt::String($content));
		            $canvas->{"Image$id"}->setPixmap(Qt::Pixmap::fromImage( $image )->scaled(${$size}[0],${$size}[1]) );
		            
			}
			elsif ($panelType eq "T"){ 
				    $canvas->{"TextCtrl".($id+1)}=Qt::PlainTextEdit;
		            $canvas->{"TextCtrl".($id+1)}->setPlainText($content);
		            $canvas->{"TextCtrl".($id+1)}->setParent($canvas);
		            $canvas->{"TextCtrl".($id+1)}->setGeometry(${$location}[0],${$location}[1],${$size}[0],${$size}[1]);				
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
	   my ($id)=@_;
	   my $found=getItem($id);
	   return ( $found!=-1) ? $widgets[$found][5]:0;
	   
   }
   sub getLocation{
	   my ($id)=@_;
	   my $found=getItem($id);
	   return ( $found!=-1) ? $widgets[$found][4]:0;
	   
   }   
   sub getItem{
	   my ($id)=@_;
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


# doesnt work for GFqt
   sub getFrame{  
	   my $self=shift;
	   return $self;
   };

#  The functions for GUI Interactions
#Static Text functions
   sub setLabel{
	   my ($id,$text)=@_;
	   $frame->{$id}->setText($text);
   }
   

#Image functions
   sub setImage{
	   my ($id,$imageFile)=@_;
	   my @widget=@{$widgets[getItem($id)]};
	   my $size= $widget[5];
	   my $image = Qt::Image(Qt::String($imageFile)) or die "could not load Image $!";
	   $frame->{$id}->setPixmap(Qt::Pixmap::fromImage( $image )->scaled(${$size}[0],${$size}[1]) );
	   # $frame=>{$id}->repaint();  ## force update doesnt work
	   
   }

#Text input functions
  sub getValue{
	   my ($id)=@_;
	   if ($id=~/TextCtrl/){ return $frame->{$id}->toPlainText() }
	   elsif ($id=~/textctrl/){ return $frame->{$id}->text();}
	   elsif ($id=~/combo/){ return $frame->{$id}->currentText();}
	   
   }
   sub setValue{
	   my ($id,$text)=@_;	
	   if ($id=~/TextCtrl/){ $frame->{$id}->setPlainText($text) }
	   elsif ($id=~/textctrl/){ return $frame->{$id}->setText($text)}   
   }   
   sub appendValue{
	   my ($id,$text)=@_;
	   if ($id=~/TextCtrl/){ $frame->{$id}->appendPlainText($text) }
	   elsif ($id=~/textctrl/){ return $frame->{$id}->insert($text)}  
   }   

#Message box, Fileselector and Dialog Boxes
   sub showFileSelectorDialog{
	   my ($message,$load,$filter) = @_;
	   my $dialog=Qt::Dialog; my $fileName;
	   if ($load){
           $fileName = Qt::FileDialog::getOpenFileName($dialog,
                                $dialog->tr("Open file"),
                                $message,
                                $dialog->tr('All Files (*)') );
							}
							
	  else{
           $fileName = Qt::FileDialog::getSaveFileName($dialog,
                                $dialog->tr("Save file"),
                                $message,
                                $dialog->tr('All Files (*)') );
							}	
	  return $fileName;						
   };
   
   sub showDialog{   #unblessed so $self not passed
	   my ( $title, $message, $response, $icon) = @_;
	   my $dialog=Qt::Dialog; my $reply;
	   
	   my %responses=( YNC  => Qt::MessageBox::Yes() | Qt::MessageBox::No() | Qt::MessageBox::Cancel(), 
	                   YN   => Qt::MessageBox::Yes() | Qt::MessageBox::No(),
	                   OK   => Qt::MessageBox::Ok(),
	                   OKC  => Qt::MessageBox::Ok() | Qt::MessageBox::Cancel() );
	                   
	   $response=$response?$responses{$response}:Qt::MessageBox::Ok();
	   if ($icon =~ /W|E|H/){
	     $reply = Qt::MessageBox::critical($dialog, $dialog->tr($title),
                                    $message,
                                   $response);
								}
	   elsif ($icon =~ /Q/){
	     $reply = Qt::MessageBox::question($dialog, $dialog->tr($title),
                                    $message,
                                    $response);
								}
	   else{
	     $reply = Qt::MessageBox::information($dialog, $dialog->tr($title),
                                    $message,
                                    $response);
								}
	   return (($reply==Qt::MessageBox::Yes() )||($reply==Qt::MessageBox::Ok()));
   };
   
# Quit
   sub quit{
	  $app ->quit();
   }


 1;
