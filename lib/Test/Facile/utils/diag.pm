package Test::Facile::utils::diag;
use base qw(Exporter);

use strict;
use warnings;

our @EXPORT = qw(diag);

sub diag {
	# a default diag that just warns a message back out
	my $diag = sub {
		my ($message) = @_;
		chomp $message;
		require Carp;
		Carp::carp "# $message";
	};

	# if an actual diag is available, use that
	$diag = \&Test::More::diag if exists $INC{'Test/More.pm'};

	# set up an actual diag now that we've chosen one
	no strict 'refs';
	*diag = $diag;

	# actually issue the diag that triggered this whole bootstrap-a-diag logic
	goto &diag;
}

1;
