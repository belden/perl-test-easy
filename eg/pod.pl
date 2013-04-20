#!/usr/bin/env perl

use strict;
use warnings;

# examples from the pod.
# $0 --make: spit out something that can be stuck in the pod

if (@ARGV && $ARGV[0] eq '--make') {
	while (<DATA>) {
		next if /^[{}]$/;
		s{#__END__}{__END__};
		s{^## (.*)}{\n$1\n};
		s/\t/    /g;
		print;
	}
} else {
	require Test::More; END { done_testing() if main->can('done_testing') }
	Test::More->import;
	my $code = do { local $/; <DATA> };
	eval $code;
	die $@ if $@;
}

__DATA__
## Easy "x is within an expected range" testing:
{
	# prove that $got is within $epsilon of $expected
	use Test::Easy qw(nearly_ok);

	my $got = 1;
	my $expected = 1.25;
	my $offset = .7;
	nearly_ok( $got, $expected, $offset, "$got is within $offset of $expected" );

	# build your own close-approximation tests:
	use Test::Easy qw(nearly);
	ok( nearly(1, 1.25, .7), '1 is within .7 of 1.25' );
}

## Easy tests-in-a-loop:
{
	use Test::Easy qw(each_ok);

	# If your BLOCK returns a single value, it is tested for truthiness
	each_ok { nearly($_, 1.25, .7) } (1, 1.1, .9);

	# If your BLOCK returns a pair of values, they are treated as a 'got' and 'expected' value.
	# This behaves as you'd expect if the 'expected' value is a regular expression.
	# If the 'expected' is not a regular expression, the two values are checked for string equality.
	each_ok { $_, qr/^[aeiou]/i } qw(alpha echo India Oscar uniform);

	# If your BLOCK returns a pair of data structures, deep_ok() is used to compare them
	each_ok { {foo => $_}, +{foo => qr/hi/i} } qw(hi Hilo hilt);
}

## C<deep_ok()> uses L<Data::Difflet> to provide easy understanding of test failures when checking data structures:
{
	use Test::Easy qw(deep_ok);
	deep_ok(
		[1, {2 => 4}, 3],
		['a', {b => '4'}, 'c', 3],
		'this test fails meaningfully'
	);

	#__END__
	#   Failed test 'this test fails meaningfully'
	#   at eg/pod.pl line 48.
	# $GOT
	# @
	#     1
	#     %
	#         2 => 4
	#     3
	# $EXPECTED
	# @
	#     a
	#     %
	#         b => 4
	#     c
	#     3
	# $DIFFLET
	# [
	#   1,   # != a
	#     {
	#       '2' => 4,
	#       'b' => '4',
	#     }
	#   3,   # != c
	#   3,
	# ]
}

## deep_ok() makes it easy to do equivalence testing; here's an example of checking that a given B<date string> ('Wed Apr 17 19:28:55 2013') is "close enough" to a given B<epoch time> (1366241335). Spoiler alert: it's just two different representations of the exact same time.
{
	use Test::Easy qw(around_about);

	sub Production::Code::do_something_expensive {
		my $got = localtime(time);
		sleep 2;
		return (some_datetime => $got);
	}

	my $now = time;
	deep_ok(
		+{Production::Code->do_something_expensive}, # eg: Wed Apr 17 19:28:55 2013
		+{some_datetime => around_about($now, 3)},   # eg: 1366241335-plus-or-minus-3-seconds
		"within 2 seconds of now!"
	);
}

## Easy monkey patching:
{
	use Test::Easy qw(resub);

	# Within this block, 'Production::Code::do_something_expensive' will sleep 2 seconds
	# and return some static data.
	{
		my $rs = resub 'Production::Code::do_something_expensive', sub {
			sleep 2;
			return (some_datetime => 'Wed Apr 17 19:28:55 2013');
		};

		like( {Production::Code->do_something_expensive}->{some_datetime}, qr/wed apr 17/i );
	}

	# Scope ends, the resub goes away, and your original code is restored.
	unlike( {Production::Code->do_something_expensive}->{some_datetime}, qr/wed apr 17/i );
}

{
    my @files = qw(photo1 video10 photo2 video3 photo12);
    my @temp1 = map { my ($word, $number) = /^(\D+)(\d+)$/; [$1, $2, $_] } @files;
    my @temp2 = sort { $a->[0] cmp $b->[0] || $a->[1] <=> $b->[1] } @temp1;
    my @final = map { $_->[2] } @temp2;
		deep_ok( \@final, [qw(photo1 photo2 photo12 video3 video10)], 'xform ok' );
}



    is_deeply( [1, 2, 3], [4, 5, 3], 'lists are the same' );



    deep_ok( [1, 2, 3], [4, 5, 3], 'lists are the same' );


