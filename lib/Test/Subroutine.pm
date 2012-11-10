package Test::Subroutine;
use 5.006;
use strict;
use warnings;

# VERSION

use parent 'Exporter';
use Scalar::Util 'blessed';
use Test::Builder;
use Test::More;

our @EXPORT = ( qw( method_is func_is ) );

my $test = Test::Builder->new;

sub method_is {
	unshift @_, \&is unless ref $_[0] eq 'CODE';
	my ( $cmp, $obj, $method, $args, $want, $name ) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

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

sub func_is {
	unshift @_, \&is unless ref $_[0] eq 'CODE';
}

1;

# ABSTRACT: test sugar for methods and functions

=head1 SYNOPSIS

	use Test::SubRoutine;

	my $obj = Class->new; # blessed reference

	method_is( $obj, 'method', undef, 'value' ); # Class->method( undef )
