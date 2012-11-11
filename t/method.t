use strict;
use warnings;
use Test::Tester tests => 8;
use Test::More;
use Test::Subroutine 'method_is';

{
	package Test;

	sub new {
		my $class = shift;
		return bless {}, $class;
	}

	sub method {
		return 'true';
	}
}

my $obj = Test->new;

my $ret;
check_test(
	sub {
		$ret = method_is( $obj, 'method', undef, 'true' );
	},
	{
		ok   => 1,
		name => q[Test->method( undef )],
		diag => '',
	},
	'method ok'
);

ok $ret, 'method_is';
