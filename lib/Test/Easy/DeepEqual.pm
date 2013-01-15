package Test::Easy::DeepEqual;
use base qw(Exporter);

use strict;
use warnings;

use Carp ();
use Scalar::Util ();
use Test::Easy::utils::tester;

our @EXPORT_OK = qw(deep_equal);

sub deep_equal {
	Carp::confess "must have only two things to deep_equal" if @_ != 2;

	return 1 if _undefs(@_);
	return 0 unless _same_type(@_);
	return 1 if _hashrefs(@_) && _same_hashrefs(@_);
	return 1 if _arrayrefs(@_) && _same_arrayrefs(@_);
	return 1 if _same_values(@_); # note, not 'if _scalars(@_) && _same_values(@_)'
	return 0;
}

sub _undefs    { return 2 == grep { ! defined } @_ }
sub _hashrefs  { return 2 == grep { ref($_) eq 'HASH' } @_ }
sub _arrayrefs { return 2 == grep { ref($_) eq 'ARRAY' } @_ }

# check the refs of $got and $exp; they must match, or $got must be a simple scalar and $exp must be a checker object.
sub _same_type {
	my ($got, $exp) = @_;

	return 1 if _undefs(@_);
	return 1 if ref($got) eq ref($exp);
	return 1 if ! ref($got) && _is_a_checker($exp);
	Carp::cluck "a ${\ref($got)} is not a ${\ref($exp)}!\n";
	return 0;
}

sub _same_hashrefs {
	my ($got, $exp) = @_;

	# if their keys aren't the same there's no point checking further
	# ...but really we should run the checker objects as mutators on $exp
	# so the real failure is apparent
	return 0 unless scalar keys %$got == scalar keys %$exp;

	# not 'each': it would reset the hash's iterator on a potentially weird caller
	foreach my $k (keys %$exp) {
		return 0 unless exists $exp->{$k};
		return 0 unless deep_equal($got->{$k}, $exp->{$k});
	}

	# make sure there's nothing extra in $got that we didn't $exp'ect to see.
	return 0 == grep { ! exists $exp->{$_} } keys %$got;
}

sub _same_arrayrefs {
	my ($got, $exp) = @_;

	return 0 unless $#$got == $#$exp;

	for (my $i = 0; $i < @$exp; $i++) {
		# return 0 unless _same_sparseness($got, $exp, $i);
		return 0 unless deep_equal($got->[$i], $exp->[$i]);
	}

	return 1;
}

# I suspect I need this but haven't written a test to prove it yet; it's an edge case
# which would be pretty frustrating to debug (at least it was when I had to debug it).
# sub _same_sparseness {
# 	my ($got, $exp, $i) = @_;
# 	return exists $exp->[$i]
# 		? exists $got->[$i]
# 		: ! exists $got->[$i];
# }

sub _is_a_checker {
	my ($exp) = @_;
	my $ref = ref($exp);
	return $ref && Scalar::Util::blessed($exp) && UNIVERSAL::can($exp, 'check_value');
}

sub _same_values {
	my ($got, $exp) = @_;
	my ($ref_got, $ref_exp) = map { ref } $got, $exp;
	my $checker = _is_a_checker($exp)
		? $exp
		: Test::Easy::utils::tester->new(
			test => sub {
				my ($got) = @_;
				return "$got" eq "$exp";
			},
	  );
	return $checker->check_value($got);
}

1;
