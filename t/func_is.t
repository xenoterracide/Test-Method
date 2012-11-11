use strict;
use warnings;
use Test::Tester tests => 8;
use Test::More;
use Test::Subroutine;

package My {
	sub func { return 'true' }
}

my $ret;
check_test(
	sub {
		$ret = func_is( 'My', 'func', undef, 'true' );
	},
	{
		ok   => 1,
		name => q[My::func( undef )],
		diag => '',
	},
	'func_is'
);

ok $ret, 'func_is return';
