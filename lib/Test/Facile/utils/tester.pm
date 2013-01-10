package Test::Facile::utils::tester;
use strict;
use warnings;

sub new {
	my ($class, %args) = @_;
	return bless {test => $args{test}}, $class;
}

sub check_value {
	my ($self, $got) = @_;
	return $self->{test}->($got);
}

1;
