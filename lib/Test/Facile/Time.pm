package Test::Facile::Time;
use base qw(Exporter);

use strict;
use warnings;

our @EXPORT = qw(time_nearly);

sub time_nearly {
	my ($got, $expected, $epsilon) = @_;

	my $guess;
	foreach my $try ($expected - $epsilon .. $expected + $epsilon) {
		if (scalar(localtime($try)) eq $got) {
			$guess = $try;
      last;
    }
	}
	return 0 unless defined $guess;
	return abs($guess - $expected) <= $epsilon;
}

1;
