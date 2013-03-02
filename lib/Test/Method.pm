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
		. '->' . $method . '('
		. _get_printable_value( $args )
		. ') is '
		. _get_printable_value( $want )
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
	my ( $args ) = @_;

	return '' unless defined $args;
	if ( ref $args && ref $args eq 'ARRAY' ) {
		if ( scalar @{ $args } > 1 ) {
			return '...';
		}
		if ( scalar @{ $args } == 1 && ! defined @{ $args }[0] ) {
			return 'undef';
		}
		return &_get_printable_value( @{$args}[0] );
	}
	return ref $args if ref $args;

	return '"' . $args . '"';
}

1;

# ABSTRACT: test sugar for methods

=head1 SYNOPSIS

	use Test::Method;

	my $obj = Class->new; # blessed reference

	method_ok( $obj, 'method', [] 'value' ); # Class->method()

	method_ok( $obj, 'method', undef, 'value' ); # Class->method()

	method_ok( $obj, 'method', ['arg1', 'arg2'], 'expected', 'testname' );

=head1 DESCRIPTION

The purpose of L<Test::Method> is to provide an easy way of testing methods
without writing a testname which ultimately could equat to Object, method
name, arguments, expected return. Ultimately I found my test names suffered
from lack of appropriate details simply due to lack of desire for repetetive
typing. This should mostly help reduce this.
