package SIMPLE;

# This module is designed to allow progammable flow control,
# variables and simple arithmetic operations in user designed scripts

   use strict;
   use warnings;
   
   our $VERSION    = '0.01';
   
   my  $logs        = "Logs\n";
   my  @statements  = ();
   my  @code        = ();
   our %gV          = ();
   our $pi          = (atan2(1,1)*4);
   my  %labels      = ();
   our %extensions  = ();
   my  $ln          = 0;
   my  $errors      = "";
   my  $listing     = "";
   my  $limit       = 3000;
   my  $scriptPath  = "";
   my  $dataPath    = "";
   my  %commands    = (
        let => sub {
			my $rest=shift;
			$rest =~m/^\s*([a-z][a-z0-9]*)(\[[^\]]*\])?\s*\=\s*(\S.*)$/i;
			my $varName=$1;my $arrayIndex=$2 // ""; $rest=$3;
			logLine(" let $varName $arrayIndex = $rest");
			if ($arrayIndex ne ""){
				$arrayIndex=~s/^\[//;$arrayIndex=~s/\]$//;
				my $tmp=evaluate($rest);
				if ($tmp & ~$tmp) {$tmp="\"".$tmp."\"";}  # strings https://www.perlmonks.org/?node_id=791650
				$gV{$varName}[evaluate($arrayIndex)]=$tmp;
			}
			elsif ($rest=~m/^(\(\)|\(([^,]+)(,[^,]+)*\))/){
				logLine("\n...$varName is an array $rest ");	
				$rest=~s/^\(//;$rest=~s/\)\s*$//;
				my @tmp = split(",",$rest);
				if ($rest=~m/,/){
					my $c=0;
					foreach (@tmp){
						$tmp[$c]=evaluate($tmp[$c]);
						if (($tmp[$c] == 0) && ($tmp[$c] ne "0")) {$tmp[$c]="\"".$tmp[$c]."\"";}
						$c++;	
					}
				}
				$gV{$varName}=[@tmp];
				logLine("..which contains ".join(",",@{$gV{$varName}}));	
			}
			else{
				my $tmp=evaluate($rest);
				if ($tmp =~m/Array \((.*)\)$/){
					$gV{$varName}=[split(",",$1)];
					logLine("\n...$varName is now..".join(",",@{$gV{$varName}})."\n");	
					return;
				}
				elsif ($tmp & ~$tmp) {$tmp="\"".$tmp."\"";}  # handle strings
				$gV{$varName}=$tmp;
				logLine("\n...$varName is now..".$gV{$varName}."\n");	
			}	
	
		},
		print => sub {
			my $rest=shift;
			print evaluate($rest)."\n";
			logLine( "Command 'print' called with parameters $rest\n");
		},
		gosub => sub {
			my $rest=shift;
			$rest =~/^\s*([a-zA-Z][\w]*)\b/;
			my $label=$1;
			if (exists $labels{$label}){ execBlock(undef,$labels{$label}); }
			else {print "SubRoutine $label not found"};
			
		},
		refresh =>sub{
			
		},
		
	);
	
   our %functions  = (
       asin =>	sub { atan2($_[0], sqrt(1 - $_[0] * $_[0])) },
	   acos =>  sub { atan2( sqrt(1 - $_[0] * $_[0]), $_[0] ) },
	   tan  =>  sub { sin($_[0]) / cos($_[0])  },
	   atan =>  sub { atan2($_[0],1) },
	   deg  =>  sub { 180 * $_[0] / $pi },
	   rad  =>  sub { $pi * $_[0] / 180 },   
   );


   
   sub new{
    my ($class, %args) = @_;    
    my $script;
    my $self={};
    $scriptPath =  $args{scriptPath}   ||  "scripts/";
	$dataPath   =  $args{dataPath}     ||  "data/";	
	my $file    =  $args{file}         ||  "autoload.smp";
	$logs="";
	$errors="";
	if (-e $scriptPath.$file){
		logLine("Loading file $scriptPath.$file \n");
		$script=load($file );
	} 
	elsif (exists  $args{script}){
		logLine("Loading file passed as string \n");
		$script= $args{script};
	} 	
	 
    bless $self, $class;
    
    if ($script){
		runCode($self,$script)
	}	
    return $self;
   };
   
   sub runCode{
	    my ($self,$script)=@_;
	    @statements=();
		buildLines($script);
		indentLines();
		codify();
   }
   
   # extend allows extending simple with user defined extensions to the
   # programming language.  Extensions can be loaded from the scripts
   # by the `extension` command, or in an object orientated way
   # using eg. $refToSIMPLEObject->extend("scriptname");
   
   sub extend{
	   my ($self, $extName)=@_;
	   my $file="./$scriptPath".$extName.(($extName=~/\.ext$/)?"":".ext");
	   $extName=~s/.ext$//;
	   if (-e $file){
		   my %extension=do $file or die "Failed to load extension in $file $!";
		   foreach my $thingy (keys %extension){
			   $extensions{$extName}{$thingy}=$extension{$thingy};
		   } 
		   logLine("Module $extName version ".$extensions{$extName}{$extName."Vars"}{version}." loaded from $file \n"  ) ;
	   }
	   else {
		   logLine("extension not found ( $file )\n");
	   }
	   
   }
   
   # setRefresh allows a function called refresh inserted that may be useful
   # say to refresh a display, but passing a code ref 
   sub setRefresh{
	   my ($self,$subRef)=@_;
	   $commands{refresh}=$subRef;	   
   }
   
   #  this loads the scripts from an external file 
   sub load{
	   my $file=shift;
	   my $filepath=$scriptPath.$file;
	   my $script="";
	   local $/=undef;
       open FILE, $filepath or die "Couldn't open file $filepath: $!";
       $script = <FILE>;
       close FILE;
       return $script;
   }
   
   # this returns the $logs, containing the logs of course 
   sub logs{
	   my $self=shift;
	   return $logs;
   }
   
   # this generates a listing of the statements
   sub listing{
	   my $self=shift;
	   return "Listing:-\n".join("\n",@statements)."\n";
   }
   
   # codeBlocks outputs indented code, stripped of comments
   sub codeBlocks{
	   my ($self,$block,$level)=@_;
	   $block//= \@code;
	   $level //= 0;
	   foreach my $line (@$block){
		   if (ref ($line) eq 'ARRAY'){
			  codeBlocks($self,$line,$level+1); 
		   }
		   else {
			   print "  " x $level.$line."\n";
		   }
	   } 
   }
   
   #  main internal function that executes statements and blocks of statements
   # passed withot a parameter it executes the code in memory (stored in @code)
   sub execBlock{
	   my ($self,$block)=@_;
	   $block//= \@code;
	   my $bln=0;
	   #blocks which are single statements
	   if (ref $block ne 'ARRAY'){
		 my $cmd=command($block);
		 $block=~s/$cmd//;
		 $block=~s/^\s+|\s+$//g;
	     if (exists $commands{$cmd}){
			logLine("Command=$cmd, parameters= $block \n");
			&{$commands{$cmd}}($block)
		 }
		 elsif (exists $labels{$cmd}){
			  execBlock($self,$labels{$cmd})
		 }
		 else {
		   my $found=0;
		   foreach my $extName (keys %extensions){
			   if (exists $extensions{$extName}{commands}{$cmd}){
				   logLine("Command $cmd  found in $extName \n");
				   $found=1;
				   $extensions{$extName}{commands}{$cmd}->($block);
				   last;
			   }
		   }
		   if (!$found){logLine("Command $cmd not found \n");}
	     } 
	   }
	   # blocks with flow control heads
	   elsif (command($$block[0])=~/^(if|elsif|else|while|forever|repeat|for|unless|until|on|sub)$/){
		   blockHead($self, $block);
		   $bln++;	   
	   }
	   # other blocks (including the whole program itself and subroutine code)
	   else{
	     while ($bln<scalar @$block){
		   my $line=$$block[$bln];
		   execBlock($self,$line); 
		   $bln++;
		 } 
	  }
    }
	
	# flow control blocks are dealt with separately 
    sub blockHead{
		my ($self,$block)=@_;
		my $line=$$block[0];
		my $head=command($line);
		$line=~s/$head//;
		$line=~s/^\s+|\s+$//g;
		logLine($head . " Block found\n    Parameters : $line\n");
		if ($head eq 'while'){
			while (evaluate($line)){
				execBlock($self,$$block[1]);
			}
		}
		elsif ($head eq 'repeat'){
			my $times=evaluate($line);
			logLine( "Doing it $times times \n");
			for (my $t=0;$t<$times;$t++){
				execBlock($self,$$block[1]);
			}
		}
		elsif ($head eq 'if'){
			my $met=0;my $then=1;
			while(!$met){
			  if (evaluate($line)){
				execBlock($self,$$block[$then]);
				$met=1;
				last;
			  }
			  else{
				 $then+=2; 
			  }
			  if ($then <scalar @$block){
				  $line=$$block[$then-1];
				  $head=command($line);
				  $line=~s/$head//;
				  if ($head eq 'else'){$line=1}
			  }
			  else {last;}
		  }
		}
		elsif ($head eq "for"){
			my($start,$end,$stepMagnitude,$counterName)=split(",",$line);
				$start = evaluate($start);
				$end   = evaluate($end);
				my $dir=($start<$end)?1:-1;
				my $step=((defined $stepMagnitude)&&($stepMagnitude))?evaluate($stepMagnitude):1;
				$step=$dir*$step;
				my $named=(defined $counterName) ?1:0;
				while($dir*$start<$dir*$end){
					if ($named){ $gV{$counterName}=$start} ;
					execBlock($self,$$block[1]);
					$start+=$step;
				}
		}
		elsif ($head eq 'sub'){
			return;
		}
		
	}
   
   # blockMaker does the internal code folding of the blocks of code
   sub blockMaker{
	  my @block=();
	  while (($ln <scalar @statements)&&($statements[$ln]!~/^\s*\}/)){
		  my $line=$statements[$ln];
          if($line=~/^\s*\{/){
			$ln++;
			push @block, blockMaker();
		  }
		  else {
			push @block, $line;
		  }
		  $ln++;
	   }
      
      # second pass to get blockHeads
      # now all {} should be ArrayRefs
      # make an ArrayRef containing header and any subsequent line/arrayRef
      my $line=0;
      while($line<$#block){
		my $cmd=command($block[$line]);
		if($cmd=~/^(while|repeat|for|unless|until|on|sub)$/){
			logLine( "Head $cmd found\n");
			my $label=$block[$line];
			$label=~s/$cmd//;
			my @headBlock=($block[$line],$block[$line+1]);
			splice @block,$line,2,\@headBlock;
			if ($cmd eq 'sub'){    # remember which code blocks represent subroutines.
		        $label=~s/^\s+|\s+$//g;
		        $labels{$label}=$block[$line][1];
			}
		}
		elsif ($cmd eq 'if'){
			logLine( " if head found\n");
			my $endif=2;
			while ($block[$line+$endif]&&(command($block[$line+$endif]) eq 'elsif')){
				$endif+=2;
			}
			if ($block[$line+$endif]&&(command($block[$line+$endif]) eq 'else')){
				$endif+=2;
			}
			my @ifBlock=@block[$line..($line+$endif-1)];
			logLine( "If block contains \n".join ("\n..",@ifBlock)."\n");
			
			splice @block,$line,$endif,\@ifBlock;
		}
		$line++;
	  }
	  
	  return \@block;
   }

   # save the code
   sub save{
	   
   }
    
    # extract the command from a line or block
   	sub command{
		my $st=shift;		
		my $res="help";
		if (!$st){return  "Error no command\n";}
		if (ref($st) eq 'ARRAY') {$res= "Block ".command($$st[0])}
		elsif ($st=~/^\s*([a-z]\w*)\b/i){$res= $1}
		else {$res= "Error no command\n"};
		return $res;
	};
	
	#logging procedures
	sub logLine{
		$logs.=shift;
	}
	
	sub errorLine{
		my $error=shift;
		$logs.=$error;
		$errors.=$error;
	}
	
	#evaluating expressions
   sub evaluate{
	my $expression=shift;
	#if (! defined $expression){return ""; }
	logLine( "\n...Evaluating $expression\n" );
	my $preval="";
	while ($expression ne ""){
		my $buffer=$expression;
		if ($expression=~m/([a-z][a-z0-9]*)\s*\(([^\(\)]*)\)/i){
			my $res=FUNCTION($1,$2);
			if (defined $res){ 	$expression=~s/([a-z][a-z0-9]*)\s*\(([^\(\)]*)\)/$res/i;}
			else {die "Error $1...$2...\n"}
		}
		elsif ($expression=~m/^\s*(\"[^\"]*\")/){ $preval.=$1;logLine("\n...found a string $1");$expression=~s/^\s*(\"[^\"]*\")//}
		elsif ($expression=~m/^\s*([\+\-\(\)\*\/<>=\.\[\],])/){$preval.=$1;logLine("\n...found a $1"); $expression=~s/^\s*([\+\-\(\)\*\/<>=\.\[\],])//i; }
		elsif ($expression=~m/^\s*(eq|ne|lt|gt)(\s.*)+/){$preval.=" ".$1." ";logLine("\n...found a $1"); $expression=~s/^\s*$1//i; }
		elsif ($expression=~m/^\s*([a-z][a-z0-9]*)[^\(\[a-z0-9]/i){logLine("\n...found a $1");  $preval.="\$gV{".$1."}";$expression=~s/^\s*$1//}
		elsif ($expression=~m/^\s*([a-z][a-z0-9]*)\[([^\]]+)\]/i){logLine("\n...found a $1 [ $2 ]");  $preval.="\$gV{".$1."}[".evaluate($2)."]";$expression=~s/^\s*([a-z][a-z0-9]*)\[([^\]]+)\]//}		
		elsif ($expression=~m/^\s*(\d+)/){$preval.=$1;logLine("\n...found a $1"); $expression=~s/^\s*$1//;}	
		elsif ($expression=~m/\s*([a-z][a-z0-9]*)$/i){logLine("\n...found a $1");  $preval.="\$gV{".$1."}";$expression=~s/\s*$1$//}
		if ($buffer eq $expression) {$expression="";logLine("\n...END Eval at $preval..$buffer ")}
	}
	no warnings 'all';
	my $result=eval($preval);
	if ($@){ errorLine($@)  } 
	elsif  ( ref($result) eq 'ARRAY') {
		logLine("\n...Evaluating an array ");
		return "Array (".join(",",@{eval($preval)}).")";
	}
	else {
		logLine("\n...Evaluating ".$preval );
		return $result;
	}

  };
  
  # handles internal string and arithmetic and trigonometric procedures   
  sub FUNCTION{
		my ($command,$parameters)=@_;
		logLine("\n...Evaluating func $command on $parameters");
		if ($command =~m/^(sin|cos|tan|log|atan|acos|asin|rand|int|ceil|floor|sqrt|deg|rad)?$/){
			my $param=evaluate($parameters);
			if (exists $functions{$command}){
				return $functions{$command}->($param)
				}
			else { return eval("$command($param)") }
		}
		elsif ($command =~m/^(substring|left|right|mid|isEmpty|len)?$/){
			$parameters=~s/"/\\"/g;
			if (exists $functions{$command}){
				return eval ("$functions{$command}->($parameters)");
			}
			else{
			    return eval("$command(\"$parameters\")");
			}
		}
		else {
		   my $found=0;  # if function not found search extensions for functions
		   foreach my $extName (keys %extensions){
			   if (exists $extensions{$extName}{functions}{$command}){
				   logLine("Command $command  found in $extName \n");
				   $found=1;
				   $extensions{$extName}{functions}{$command}->($parameters);
				   last;
			   }
		   }
		   if(!$found){ return ""};
	   }
		
		sub substring {
			my ($string,$index,$len)=@_;
			$string=streval($string);
			return "\"".(substr $string,evaluate($index),evaluate($len))."\"";
		}
		sub len{
			return length(streval(shift));
		}
		sub left{
			my $params=shift;
			my ($string,$length)=split(/,/, $params);
			return substring($string,0,$length)
		}
		sub right{
			my $params=shift;
			my ($string,$length)=split(/,/, $params);
			$length=evaluate($length);
			return substring($string,len($string)-$length,$length);
		}
		sub mid{
			my ($string,$index,$index2)=@_;
			$index=evaluate($index);$index2=evaluate($index2);
			return substring($string,$index,$index-$index2-1)
		}
		sub streval{
			my $str=shift;
			if ($str=~m/^\s*\"([^\"]*)\"\s*$/) {$str = $1}
			else {$str = evaluate($str)};
			$str=~s/\"([^\"]*)\"/$1/g;
			return $str;
		}

	};

   # buildlines parses the scripts, removing comments and empty line and
   # separating out the statements creating and array of statements
   # handling any includes to bring in external scripts and loading 
   # extensions if instructed in the code
        
   sub buildLines{                               # function takes a script and builds an array of statements
	   	my $script=shift;
		$script=~s/\\\n//g;                      # remove line joiners
		$script=~s/\s*([\{\}])\s*/\n$1\n/g;      # block ends i.e. { and } in separate
		my @lines=split(/[;\n]+/,$script);       # find statement separators
		map { s/#.*$//g; } @lines;               # remove # comments; REM statements remain;
		map { s/^\s+|\s+$//g; } @lines;          # trim lines
		map { s/^([a-z]\w*)\s*=\s*([\S]*)/let $1 = $2/; } @lines;
		map { s/^else\s+if/elsif/; } @lines;
		@lines = grep { $_ !~ /^\s*$/ } @lines;  # remove empty lines
		foreach my $line (@lines){
			if ($line =~/^include[ \t]+(.*)$/i){ # include code from other scripts 
				buildLines(load($1));
			}
			elsif( $line=~/^extension[ \t]+(.*)$/i){  # extend using external extension 
				extend(undef,$1);
			}
			else {
				push @statements, $line;
			}
		}
		logLine ("Built ".scalar @statements ." statement lines \n");
   }
   
   # indentLines works out the level of each statement or block of statements
   # in doing so it also picks up bracket errors.
   
   sub indentLines{
	   my $indent=0; my %loops;  my $ssl=0; my $bc;my @errors;
		foreach my $ln (0..$#statements){
			if ($statements[$ln]=~/^\}/){
				if ($indent<=0){
					errorLine("Error: Bracket closed without corresponding open bracket at line $ln \n".
					          "\t near ".$statements[$ln-1]."\n");
				}
				else {
					$indent--;
					$statements[$ln]="  "x$indent . $statements[$ln];
					$indent--;
				}
			}
			elsif ($statements[$ln]=~/^\{/){
				$indent++; 
				$statements[$ln]="  "x$indent . $statements[$ln];
				$indent++;
				$loops{$indent}=$ln;
			}
			elsif (command($statements[$ln-1])=~/^(if|elsif|else|while|times|for|unless|until|on|sub)$/){
				$statements[$ln]="  "x($indent+1) . $statements[$ln];
			}
			else {
				$statements[$ln]="  "x$indent . $statements[$ln];
			}
			
		}
		if ($indent){
			errorLine("Error: Bracket unclosed in program\n");
		}
   }
   
   # calls blockmaker to fold the code
   sub codify{
	   if ($errors ne ""){
		   errorLine("Error: Block Errors exist...can not codify\n");
		   return;
	   }
	   $ln=0;
	   @code=@{blockMaker()};
   }
   
	
	1;
	

	
