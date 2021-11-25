use Test::More;

if (!$ENV{RELEASE_TESTING}) {
    plan skip_all => 'These tests are for only for release candidate testing. Enable with RELEASE_TESTING=1';
}

eval "use Test::Pod::Coverage";

if( $@ ) {
	plan skip_all => "Test::Pod::Coverage required for testing POD";
	}
else {
	plan tests => 1;
	pod_coverage_ok( "GUIDeFATE" );
	}
