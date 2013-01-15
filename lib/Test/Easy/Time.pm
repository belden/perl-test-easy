package Test::Easy::Time;
use base qw(Exporter);

use strict;
use warnings;

require Test::Easy;

our @EXPORT = qw(time_nearly);

my @_formatters = ({
	_description => 'output of localtime',
	format_epoch_seconds => sub {
		return scalar(localtime($_));
	},
});

sub add_format { shift; push @_formatters, +{@_} }

sub time_nearly {
	my ($got, $expected, $epsilon) = @_;

	my ($low, $high) = ($expected - $epsilon, $expected + $epsilon);
	my $guess;
	local $_;
	SAMPLE: foreach ($low .. $high) {
		foreach my $formatter (@_formatters) {
			if ($formatter->{format_epoch_seconds}->() eq $got) {
				$guess = $_;
				last SAMPLE;
			}
		}
	}

	return 0 unless defined $guess;
	return Test::Easy::nearly($guess, $expected, $epsilon);
}

1;
