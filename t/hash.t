#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;
use lib grep { -d $_ } qw(./lib ../lib);
use Test::Easy::DataDriven qw(run_where);

my %hash = (1..10);
is_deeply( \%hash, {1..10}, 'sanity' );

run_where(
	[\%hash => {'a'..'f'}],
	sub {
		is_deeply( \%hash, {'a'..'f'}, 'local' );
	}
);
is_deeply( \%hash, {1..10}, 'restore' );
