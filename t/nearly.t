#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use lib grep { -d } qw(./lib ../lib);
use Test::Facile;

subtest basic => sub {
	diag "Answer the basic question of, 'Is this time within X seconds of this date?'";

	my $some_epoch = rand(CORE::time);
	my $some_localtime = localtime($some_epoch);
	ok( time_nearly($some_localtime, $some_epoch - 2, 5) );

	my $other_epoch = ($some_epoch - 100);
	my $other_localtime = localtime($other_epoch);
	ok( ! time_nearly($some_localtime, $other_epoch, 99) );
	ok( time_nearly($some_localtime, $other_epoch, 100) );
};

subtest pluggable => sub {
	diag 'Illustrate how to plug in support for other time formats';

	Test::Facile::Time->add_format(
		_description => 'CCYYMMDDhhmmss',
		format_epoch_seconds => sub {
			my ($sec, $min, $hour, $mday, $month, $year) = localtime($_);
			$month += 1;
			$year += 1900;
			return join '',
				map { length($_) == 1 ? sprintf '%02d', $_ : $_ }
				$year, $month, $mday, $hour, $min, $sec;
		},
	);

	my $random_midnight = 8957188800; # Fri Nov  4 00:00:00 2253 - it's a keyrattle date
	my $random_date = $random_midnight + 3;
	ok( time_nearly('22531104000003', $random_midnight, 5) );
};

# todo:
# * make this work with deep_ok
# * some notion about error messaging
