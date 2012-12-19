#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 11;
use Test::Facile::DataDriven qw(run_where);

{
	my ($foo, $bar, $baz) = (1, sub { 2 }, [3]);

	# sanity tests
	is( $foo, 1, '$foo is sane' );
	is( $bar->(), 2, '$bar is sane' );
	is_deeply( $baz, [3], '$baz is sane' );

	# we can specify new values for variables for a testing sub and
	# expect the testing sub to see those values
	run_where(
		[\$foo => 'foo'],
		[\$bar => sub { 'bar' }],
		[\$baz => [8,9]],
		sub {
			is( $foo, 'foo', '$foo has temp value' );
			is( $bar->(), 'bar', '$bar has temp value' );
			is_deeply( $baz, [8,9], '$baz has temp value' );
		}
	 );

	# rollback the variables to their original values
	is( $foo, 1, '$foo restored' );
	is( $bar->(), 2, '$bar restored' );
	is_deeply( $baz, [3], '$baz restored' );
}

# the return value of run_where is the same as your testing sub's return value,
# with context awareness etc.
{
	my $context_sensitive = sub { wantarray ? 'array' : 'scalar or void' };

	my $out = run_where($context_sensitive);
	is( $out, 'scalar or void', 'detected scalar/void context properly' );

	($out) = run_where($context_sensitive);
	is( $out, 'array', 'detected array context properly' );
}
