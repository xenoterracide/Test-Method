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
		return 'True';
	}
}

my $obj = Test->new;

my $ret;
check_test(
	sub {
		$ret = method_is( \&like, $obj, 'method', undef, qr/^[Tt]{1}/ );
	},
	{
		ok   => 1,
		name => q[Test->method( undef )],
		diag => '',
	},
	'method ok'
);

ok $ret, 'method_is';
