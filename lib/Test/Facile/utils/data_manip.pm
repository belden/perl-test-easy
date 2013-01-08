package Test::Facile::utils::data_manip;
use base qw(Exporter);

use strict;
use warnings;

our @EXPORT = qw(partition first);

sub partition (&@) {
	my $partitioner = shift;
	my (@match, @fail);
	foreach (@_) {
		my $ar = $partitioner->() ? \@match : \@fail;
		push @$ar, $_;
	}
	return (\@match, \@fail);
}

sub first (&@) {
	my $code = shift;
	foreach (@_) {
		return $_ if $code->();
	}
	return;
}

1;

__END__

=head1 NAME

Test::Facile::utils::data_manip - simple data manipulators for interal use within Test::Facile's classes

=head1 DESCRIPTION

One of the goals of Test::Facile is to have a full-fledged suite of testing tools which do not add CPAN dependencies upon the project in question.

=head1 SEE ALSO

L<Test::Facile>

=head1 AUTHOR

(c) 2013 Belden Lyman <belden@cpan.org>

=head1 LICENSE

This is free software. You may use, modify, and redistribute it under the same terms as Perl itself.

