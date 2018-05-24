#!/usr/bin/env perl 
# A test script that search through the Plants List Database and uses 
# GUIDeFATE (which in turn depends on other graphical toolkits)
# This file designed to be called by Executioner for backend testing
# The main purpose is to test the various backends specially Websockets

use strict;
use warnings;
use GUIDeFATE;

use LWP::Simple;

my $dataFolder="./plants";          # Path to data store
my $imageFolder="./plants/images";   # path to images
mkdir $dataFolder unless -d $dataFolder;
mkdir $imageFolder unless -d $imageFolder;	

my @genera=();               # List of all genera found
my @results=();              # indexes filtered species or genenera list
my @genusList=();            # list off genera after filters (if filters applied)
my @speciesList=();          # list of indexes of Species
my $currentContext="No items in list";
my $oldContext;
my $currentItem=0;
my $currentGenus;
my $currentGroup;
my $currentSpecies;
my $currentSearch="";

my $dateString;
my($day, $month, $year)=(localtime)[3,4,5];
$month++;
$year-=100;

my %groups=( A  =>  { name=> "Angiosperm",   filtered =>0, total=>0, widget=>'stattext6'  },
	         B  =>  { name=> "Bryophytes",   filtered =>0, total=>0, widget=>'stattext11'  },
	         G  =>  { name=> "Gymnosperms",  filtered =>0, total=>0, widget=>'stattext7' },
	         P  =>  { name=> "Pteridophytes",filtered =>0, total=>0, widget=>'stattext10' },
	         );

my $window=<<END;
+-------------------------------------------+
|T The Plants List App                      |
+M------------------------------------------+
|  {Refresh Data} dd/mm/yy                  |
|  [                         ] {Search}     |
|  {Angiosperms  } 000   {Gymnosperms} 000  |
|  {Pteridophytes} 000   {Bryophytes } 000  |
|      No item on list                      |
|  +T-----------------+  +I--------------+  |    
|  |                  |  |               |  |
|  |                  |  |               |  |
|  |                  |  |               |  |
|  |                  |  |               |  |
|  |                  |  |               |  |
|  +------------------+  +---------------+  |
|  {<} {  Explore } {>}  { Upload Photo  }  |
|      0000 of 0000                         |
|  www.theplantlist.org     wikipedia.org   |
+-------------------------------------------+
END

my $backend=$ARGV[0]?$ARGV[0]:"web";
my $assist=$ARGV[1]?$ARGV[1]:"q";
my $gui=GUIDeFATE->new($window,$backend,$assist);
my $frame=$gui->getFrame()||$gui;

loadGenera();
searchGenera();

$frame->setLabel("stattext1",$dateString);

$gui->MainLoop();

sub btn0 {#called using button with label Refresh Data 
  createGeneraList();
  updateCounts();
   };
   
sub btn2 {#called using button with label Search 
   $currentSearch=$frame->getValue("textctrl3");
   searchGenera();
   };

sub textctrl3 {#called using Text Control with default text '
   };

sub btn4 {#called using button with label Angiosperms 
   searchGenera("A");
   };

sub btn5 {#called using button with label Gymnosperms 
  searchGenera("G");
   };

sub btn8 {#called using button with label Pteridophytes
  searchGenera("P");
   };

sub btn9 {#called using button with label Bryophytes
  searchGenera("B");
   };
 
sub btn18 {#called using button with label < 
  prevItem();
   };

sub btn19 {#called using button with label Explore  
     if ($currentContext!~/Species/){
       createSpeciesList();
     }
     else {
		 @results=@genusList;
		 $currentItem=$currentGenus;
		 $currentContext=$oldContext;
		 updateView();
	 }
   };

sub btn20 {#called using button with label > 
  nextItem();
   };

sub btn21 {#called using button with label Wikipedia 
  
   };

sub createGeneraList{
	my $url='http://www.theplantlist.org/1.1/browse/-/-/';
	my $content = get $url;
	$dateString="Data from: $day/$month/$year";
	my @lines=split(/\n/, $content);
	@genera=();
	foreach my $line (@lines){
		if ($line=~/<a href="\/1.1\/browse\/(A|G|B|P)\/([A-z]+)\/([A-z]+)\/"><i class="(A|U)/){
		  my $line="$1,$2,$3,$4,";
		  $line=~s/\n\r//g;
		  if (length $line >3){ push @genera, $line;}
	    }
	}
	open  my $fh, '>', "$dataFolder/genera.csv";
	print $fh $dateString."\n";
    print $fh join("\n",@genera);
    close $fh;
}

sub loadGenera{
	if (! -e "$dataFolder/genera.csv"){
	   createGeneraList();
     }
	else {
      @genera=();
	  open my $fh, "$dataFolder/genera.csv" or die "Couldn't open file: $!";
	  $dateString = <$fh>;
	  while (<$fh>){
		  push @genera,$_;
		  $groups{substr($_, 0, 1)}{filtered}++;
	  }
	  close $fh;
	  chomp $dateString;
    }
}

sub createSpeciesList{
	my ($group,$family,$genus,$accepted)=split(',', $genera[$results[$currentItem]]);
	my $url="http://www.theplantlist.org/1.1/browse/$group/$family/$genus/";
	
	@genusList=@results;
	$currentGenus=$currentItem;  
	
	@results=();
	@speciesList=();
	my $content = get $url;
	my @lines=split(/<td class="name /, $content);
	shift @lines;
	for (my $c=0;$c<=$#lines;$c++){
		my $tmp=$lines[$c];
		$tmp=(split(/<\/a>/,$tmp))[0];    # remove rubbish
		if ( $tmp=~/.*record\/([a-z\-\d]*)/	){
			my $record=$1;
			my $status=substr($tmp, 0, 1);
			$tmp=~/"species">([^<]*)</; my $species=$1;
			$tmp=~/"authorship">([^<]*)</; my $authorship=$1;
			push @speciesList, join(',', ($group,$family,$genus,$species,$authorship,$record,$status))
		}	
	}
	$currentContext="Species in genus $genus";
	$currentItem=0;
	@results=(0..$#speciesList);
	updateView();
}

sub nextItem{
	my $items=scalar @results;
	if ($currentItem<($items-1) ){
		$currentItem++;
		updateView();
	}
}

sub prevItem{
	my $items=scalar @results;
	if ($currentItem>(0) ){
		$currentItem--;
		updateView();
	}
}

sub searchGenera{
	my $grpFilter=shift;            #search string

	$currentContext=((!$currentSearch ||($currentSearch eq ""))?"Unfiltered Search":"Filtered Search").
	                ($grpFilter?" (".$groups{$grpFilter}{name}.")":'');
	$oldContext=$currentContext;                
	@results=();               
	foreach (qw/A B G P/){    # clear old counters
		      $groups{$_}{filtered}=0;
	}
	for (my $c=0;$c<=$#genera;$c++){
		  my ($group,$family,$genus,$accepted)=split(',', $genera[$c]);
		  if ((!$currentSearch ||($currentSearch eq "")) || (($family =~/\Q$currentSearch\E/i)||($genus =~/\Q$currentSearch\E/i))){
			  $groups{$group}{filtered}+=1;
			  if (!$grpFilter  || (($grpFilter)&&($group eq $grpFilter))){
			    push @results,$c;
			  }
		  }
		}
	if (! scalar @results){
		@results=(0..$#genera);
	}
	$currentGenus=$results[0];
	$currentItem=0;
	updateCounts();
	updateView();
}

sub updateCounts{
	foreach (qw/A B G P/){
		$frame->setLabel($groups{$_}{widget},$groups{$_}{filtered});
	}
}

sub updateView{
	my ($view,$image);
	$frame->setLabel("stattext12",$currentContext);
	if ($currentContext =~/Species/){
		my ($group,$family,$genus,$species,$authorship,$record,$status)=split(',', $speciesList[$currentItem]);
		$view=   "Group: -	".$groups{$group}{name} ."\n".
				 "Family: -	".$family."\n".
				 "Genus: -	".$genus."\n".
				 "Species: -	".$species."\n".
				 "Authorship:-	".$authorship."\n".
				 "Record: -	".$record."\n".
				 "Status: -	".(($status eq "A")?"Accepted":"Unresolved");
		$image=searchImage($status,$genus,$species)
		
	}
	else {
		my ($group,$family,$genus,$accepted)=split(',', $genera[$results[$currentItem]]) ;
		$view=	"Group: -	".$groups{$group}{name} ."\n".
				"Family: -	".$family."\n".
				"Genus: -	".$genus."\n".
				"Status: -	".(($accepted eq "A")?"Accepted":"Unresolved");
		$image= searchImage($accepted,$genus,undef);
	}
	
	$frame->setImage("Image15",$image);
	$frame->setValue("TextCtrl14",$view);
	$frame->setLabel('stattext22',($currentItem+1) ." of ".($#results+1) );
}

sub searchImage{   # looks for an image for the particular viewed item
	my ($status,$genus,$species)=@_;
	my @files; my $image;
	if ($status eq "A"){  # if the iitem is accepted bother to look for picture
		if ($species){
			@files = glob( $imageFolder . "/$genus".'_'."$species.*" );
			$image= (scalar @files) ? $files[0] : downloadImageFromWiki($genus.'_'.$species);
		}
		else         {
			@files = glob( $imageFolder . "/$genus.*" );                }
		    $image= (scalar @files) ? $files[0] : downloadImageFromWiki($genus);
		}
	else {
		$image=$imageFolder . '/unresolved.png'; # otherwise show an unresolved picuture
	}
	
	return $image;
	
	sub downloadImageFromWiki{
		my $pageName=shift;
		my $imagePath=$imageFolder."/noImage.png";
		my $url="https://en.wikipedia.org/wiki/$pageName";
	    my $content = get $url;
	    if ((defined $content)&&($content =~/<table class="infobox biota"/)){
			my $infoTable=( split /<table class="infobox biota"[^>]*>/, $content)[1];
			   $infoTable=( split /<\/table/, $infoTable )[0];
			if ($infoTable=~/class="image">(<img[^>]*>)/){
			    my $imgSrc=$1;
			    $imgSrc=~/src="([^"]*\.(png|jpg|gif|bmp))"/;
			    $imgSrc='http:'.$1;
			    $imagePath=$imageFolder."/".$pageName.".$2";
			    getstore($imgSrc, $imagePath);
			}
		}
		return $imagePath;

	}
}
