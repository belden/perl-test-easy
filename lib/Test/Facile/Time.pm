package Test::Facile::Time;
use base qw(Exporter);

use strict;
use warnings;

use Test::Facile::utils::diag;
use Test::Facile::utils::data_manip;

our @EXPORT = qw(time_nearly time_nearly_iterative);

sub time_nearly {
	my ($got, $expected, $epsilon) = @_;

	if (_looks_like_a_date($got)) {
		$got = guess_epoch($got, time);
	}

	return $got - $expected <= $epsilon;
}

sub guess_epoch {
	my ($got, $epoch) = @_;
	my $epoch_time = localtime($epoch);
	# diag "considering $got versus $epoch_time";

	# first try to match the year
	my ($epoch_year) = $epoch_time =~ /.* (\d+)$/;
	if ($got =~ $epoch_year) {
		# year is correct
		# diag "$got is in $epoch_year";
	} else {
		my ($got_year) = $got =~ /\b((?:19|20)\d\d)\b/;
		my $beyond_by = -1 * ($epoch_year - $got_year);
		# diag "$got is beyond $epoch_year by $beyond_by years";
		$epoch += ($beyond_by * 86400 * 365.25);
		return guess_epoch($got, $epoch);
	}

	my ($epoch_sec, $epoch_min, $epoch_hour, $epoch_mday, $epoch_month) =
		(localtime($epoch))[0..4];
	my @month_regexes = (
		qr/(jan)\w*/i,
		qr/(feb)\w*/i,
		qr/(mar)\w*/i,
		qr/(apr)\w*/i,
		qr/(may)/i,
		qr/(jun)\w*/i,
		qr/(jul)\w*/i,
		qr/(aug)\w*/i,
		qr/(sep)\w*/i,
		qr/(oct)\w*/i,
		qr/(nov)\w*/i,
		qr/(dec)\w*/i,
	);
	my ($have_month, $current_month);
	for (my $i = 0; $i < @month_regexes; $i++) {
		$have_month = $i if $got =~ $month_regexes[$i] && ! defined $have_month;
		$current_month = $i if $epoch_time =~ $month_regexes[$i] && ! defined $current_month;
	}

	if ($current_month == $have_month) {
		# diag "$got is in $month_regexes[$epoch_month]";
	} else {
		my $direction;
		if ($have_month > $current_month) {
			$direction = 1;
		} else {
			$direction = -1;
		}
		$epoch += $direction * 86400;
		# diag "moving " . ['', qw(forward backward)]->[$direction] . " a day";
		no warnings 'recursion'; # you know it's good code when you do this
		return guess_epoch($got, $epoch);
	}

	# try to extract time and day-of-month components
	my $copy = $got;
	$copy =~ s{$epoch_year}{};
	$copy =~ s{$_}{} foreach @month_regexes;
	$copy =~ s{[a-z]}{}gi;
	my ($guessed_time, $guessed_month_day) =
		partition { $_ =~ /^\d{1,2}:\d{1,2}:\d{1,2}$/ }
		grep { defined && length }
		split / /, $copy;
	diag "I should back out of this, either I misidentified time [@$guessed_time] or the month-day [@$guessed_month_day]"
		if grep { @$_ != 1 } $guessed_time, $guessed_month_day;
	($_) = @$_ foreach $guessed_time, $guessed_month_day;

	if ($guessed_month_day != $epoch_mday) {
		$epoch += ($guessed_month_day - $epoch_mday) * 86400;
		return guess_epoch($got, $epoch);
	}

	# rewind $epoch to midnight
	$epoch -= 1 until scalar localtime($epoch) =~ /00:00:00/;
	# fast-forward $epoch to match guessed time
	$epoch += 1 until scalar localtime($epoch) =~ /$guessed_time/;

	return $epoch;
}

sub _looks_like_a_date {
	my ($candidate) = @_;

	my @groups = ([
		qr/\b(?:19|20)\d\d\b/,           # ccyy
		qr/\b\d{1,2}:\d{1,2}:\d{1,2}\b/, # hh:mm:ss
		qr/\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*?\b/i, # text_month
		qr/\b(?:sun|mon|tue|wed|thu|fri|sat)\b/i, # week_day
	]);

	return defined first { my $g = $_; @$g == grep { $candidate =~ $_ } @$g } @groups;
}

sub time_nearly_iterative {
	my ($got, $expected, $epsilon) = @_;

	my $try;
	foreach $try ($expected - $epsilon .. $expected + $epsilon) {
		last if scalar(localtime($try)) eq $got;
	}
	return 0 unless defined $try;
	return $try - $expected <= $epsilon;
}

1;
