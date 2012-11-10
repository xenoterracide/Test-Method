package Test::Subroutine;
use 5.006;
use strict;
use warnings;

# VERSION

use parent 'Exporter';
use Scalar::Util 'blessed';
use Test::Builder;
use Test::More;

our @EXPORT ## no critic ( AutomaticExportation )
	= ( qw( method_is func_is ) );

my $test = Test::Builder->new;

sub method_is { ## no critic ( ArgUnpacking )
	unshift @_, \&is unless defined $_[0] && ref $_[0] && ref $_[0] eq 'CODE';
	my ( $cmp, $obj, $method, $args, $want, $name ) = @_;

	local $Test::Builder::Level      ## no critic ( PackageVars )
		= $Test::Builder::Level + 1; ## no critic ( PackageVars )

	my $arg_val_name
		= ! defined $args          ? 'undef'
		: ref $args # put value of scalar
			&& ref $args eq 'ARRAY'
			&& scalar @$args == 1
			&& ! ref @{ $args }[0] ? @{ $args }[0]
		:                            '...'
		;

	$name ||= blessed( $obj ) . '->' . $method . '( ' . $arg_val_name . ' )';

	my $ret = $cmp->( $obj->$method( @$args ), $want, $name );

	return $ret;
}

1;

# ABSTRACT: test sugar for methods and functions

=head1 SYNOPSIS

	use Test::Subroutine;

	my $obj = Class->new; # blessed reference

	method_is( $obj, 'method', undef, 'value' ); # Class->method( undef )

=func method_is

	my $bool = method_is( [ $cmp ], $obj, $method, $args, $want, [ $name ] );

C<method_is> allows you to check the return value of an object method using an
optional comparator. C<is> is the default comparator.
