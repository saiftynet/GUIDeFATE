#!/usr/bin/env perl 
#A test script that calls the test files in scripts folder
#uses GUIDeFATE (which in turn depends on Wx or Tk)

use strict;
use warnings;
use GUIDeFATE;

my @workingModules;

	eval {
            eval "use GUIDeFATE" or die; 
        };
     if ($@ && $@ =~ /GUIDeFATE/) {
            # print " GUIDeFATE not installed\n";
            exit;
        }
    # contains list of modules reuired for each backend
    # in order of preference
    foreach my $module ( qw/ GFwin32 GFwx GFtk  GFqt GFhtml GFweb/ ) {
        eval {
            eval "use $module" or die; 
        };
        if ($@ && $@ =~ /$module/) {
            # print " $module not installed\n";
        }
        else {
			# print " $module found\n";
			my $m=$module;
			$m=~s/^GF//;
			push (@workingModules, ucfirst $m);
			}
    }
    if (! $workingModules[0]){ # at least one module works
		# print "no working GFxx modules intalled\n";
		exit;
		};

my $backends=join(",",@workingModules);
print $backends;
