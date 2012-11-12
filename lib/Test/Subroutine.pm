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

sub _get_args_name {
	my $args = shift;

	return ! defined $args          ? 'undef'
		: ref $args # put value of scalar
			&& ref $args eq 'ARRAY'
			&& scalar @$args == 1
			&& ! ref @{ $args }[0] ? @{ $args }[0]
		: ref $args # put value of ref
			&& ref $args eq 'ARRAY'
			&& scalar @$args == 1
			&& ref @{ $args }[0]   ? ref @{ $args }[0]
		:                            '...'
		;
}

sub method_is { ## no critic ( ArgUnpacking )
	unshift @_, \&is unless defined $_[0] && ref $_[0] && ref $_[0] eq 'CODE';
	my ( $cmp, $obj, $method, $args, $want, $name ) = @_;

	local $Test::Builder::Level      ## no critic ( PackageVars )
		= $Test::Builder::Level + 1; ## no critic ( PackageVars )

	_get_args_name( $args );

	$name ||= blessed( $obj )
		. '->' . $method . '( '
		. _get_args_name( $args )
		. ' )'
		;

	my $ret = $cmp->( $obj->$method( @$args ), $want, $name );

	return $ret;
}

sub func_is { ## no critic ( ArgUnpacking )
	unshift @_, \&is unless defined $_[0] && ref $_[0] && ref $_[0] eq 'CODE';
	my ( $cmp, $package, $func, $args, $want, $name ) = @_;

	local $Test::Builder::Level      ## no critic ( PackageVars )
		= $Test::Builder::Level + 1; ## no critic ( PackageVars )

	my $function = $package . '::' . $func;
	$name ||= $function . '( ' . _get_args_name( $args ) . ' )';

	my $ret;
	{
		no strict 'refs'; ## no critic ( NoStrict )
		$ret = $cmp->( &$function( @$args ), $want, $name );
	}

	return $ret;
}

1;

# ABSTRACT: test sugar for methods and functions

=head1 SYNOPSIS

	use Test::Subroutine;

	my $pkg = 'Foo::Bar';
	my $obj = Class->new; # blessed reference

	method_is( $obj, 'method', undef, 'value' ); # Class->method( undef )

	func_is( $pkg, 'func', undef, 'value' ); # Foo::Bar::func( undef )

=func method_is

	my $bool = method_is( [ \&cmp ], $obj, $method, \@args, $want, [ $name ] );

C<method_is> allows you to check the return value of an object method using an
optional comparator. C<is> is the default comparator.

=func func_is

	my $bool = func_is( [ \&cmp ], $pkg, $func, \@$args, $want, [ $name ] );

C<func_is> allows you to check the return value of a function using an
optional comparator. C<is> is the default comparator.
