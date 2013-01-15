#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

use lib grep { -d } qw(./lib ../lib);
use Test::Easy;

subtest basic => sub {
	diag "Answer the basic question of, 'Is this time within X seconds of this date?'";

	my $some_epoch = int rand(time);
	my $some_localtime = localtime($some_epoch);
	ok( time_nearly($some_localtime, $some_epoch - 2, 5) );

	my $other_epoch = ($some_epoch - 100);
	my $other_localtime = localtime($other_epoch);
	ok( ! time_nearly($some_localtime, $other_epoch, 99) );
	ok( time_nearly($some_localtime, $other_epoch, 100) );
};

subtest pluggable => sub {
	diag 'Illustrate how to plug in support for other time formats';

	Test::Easy::Time->add_format(
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

subtest deep_ok => sub {
  diag 'Show how time_nearly() plays with deep_ok()';

	my $some_epoch = int rand(time);
	my $some_date  = localtime $some_epoch;
	my $future_now = $some_epoch + 10;
	my $epsilon    = 15;

	my %got = (
		create_time => $some_date,
		name => 'maternal-Edam',
	);

	my %exp = (
		create_time => around_about($future_now, $epsilon),
		name => 'maternal-Edam',
	);

	isnt( $got{create_time}, $exp{create_time}, "'$got{create_time}' is not the same as '$future_now'..." );
	deep_ok( \%got, \%exp, "...yet we can treat them as equivalent, and within $epsilon seconds of each other!" );

	my $now = localtime;
	my $time = time;
	deep_ok( [$now], [around_about($time, 0)], "'$now' is within 0 seconds of epoch time '$time'" );
};

# todo:
# * some notion about error messaging
