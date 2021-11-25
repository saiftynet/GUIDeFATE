use Test;
use Carp;

BEGIN {
	plan tests => 1;
}

# 1/ Test use
eval {
	use GUIDeFATE;
	return 1;
};
ok($@,'') or croak("Couldn't use GUIDeFATE.pm");
