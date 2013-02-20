package Test::Method;
use 5.006;
use strict;
use warnings;

# VERSION

use parent 'Exporter';
use Scalar::Util 'blessed';
use Carp;
use Test::Builder;
use Test::Deep::NoTest qw(
	cmp_details
	methods
	deep_diag
);
use Test::More;

our @EXPORT ## no critic ( AutomaticExportation )
	= ( qw( method_ok ) );

sub method_ok { ## no critic ( ArgUnpacking )
	# first 2 args
	my ( $obj, $method, $args, $want, $name ) = @_;

	my $params = [ $method ];

	if ( defined $args && ref $args eq 'ARRAY' ) {
		push @{ $params }, @{ $args };
	}

	$name ||= blessed( $obj )
		. '->' . $method . '( '
		. _get_printable_value( $args )
		. ' ) is "'
		. _get_printable_value( $want )
		. '"'
		;

	my ( $ok, $stack ) = cmp_details( $obj, methods( $params, $want ) );

	my $test = Test::Builder->new;
	unless ( $test->ok( $ok, $name ) ) {
		my $diag = deep_diag( $stack );
		$test->diag( $diag );
	}
	return;
}

sub _get_printable_value {
	my $args = shift;

	return 'undef' unless defined $args;
	if ( ref $args && ref $args eq 'ARRAY' ) {
		if ( scalar @{ $args } > 1 ) {
			return '...';
		}
		return &_get_printable_value( @{$args}[0] );
	}
	return ref $args if ref $args;

	return $args;
}

1;

# ABSTRACT: test sugar for methods

=head1 SYNOPSIS

	use Test::Method;

	my $obj = Class->new; # blessed reference

	method_ok( $obj, 'method', [] 'value' ); # Class->method()

	method_ok( $obj, 'method', ['arg1', 'arg2'], 'expected', 'testname' );

=func method_is

	my $bool = method_is( [ \&cmp ], $obj, $method, \@args, $want, [ $name ] );

C<method_is> allows you to check the return value of an object method using an
optional comparator. C<is> is the default comparator.
