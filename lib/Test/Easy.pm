package Test::Easy;
use base qw(Exporter);

use strict;
use warnings;

# used as helper modules within this module
require Test::More;
use Carp qw(confess);

# non-core modules
use Data::Denter ();
use Text::Diff ();

# this module re-exports functions from these modules
use Test::Resub;
use Test::Easy::Time;
use Test::Easy::DataDriven;
use Test::Easy::DeepEqual qw(deep_equal);

our $VERSION = 1.04;

## spend a little time moving things around into @EXPORT, @EXPORT_OK
our @EXPORT = qw(nearly_ok each_ok deep_ok around_about);
our @EXPORT_OK = qw(nearly test_sub match);
foreach my $supplier (qw(Test::Resub Test::Easy::DataDriven Test::Easy::Time Test::Easy::DeepEqual)) {
	no strict 'refs';
	push @EXPORT, @{"$supplier\::EXPORT"};
	push @EXPORT_OK, @{"$supplier\::EXPORT_TAGS"};
}

# Set up %EXPORT_TAGS based on whatever we've shoved into @EXPORT, @EXPORT_OK
our %EXPORT_TAGS = (
	helpers => [@EXPORT_OK],
	all => [@EXPORT, @EXPORT_OK],
);
foreach my $supplier (qw(Test::Resub Test::Easy::DataDriven)) {
	no strict 'refs';
	%EXPORT_TAGS = _merge(%EXPORT_TAGS, %{"$supplier\::EXPORT_TAGS"});
}

sub _merge {
	my %out;
	while (my ($k, $v) = splice @_, 0, 2) {
		push @{$out{$k}}, @$v;
	}
	return %out;
}

sub nearly_ok {
  my ($got, $expected, $epsilon, $message) = @_;
  local $Test::Builder::Level = $Test::Builder::Level + 1;
  Test::More::ok( nearly($got, $expected, $epsilon), $message )
		 or warn "wanted epsilon $epsilon, got " . abs($expected - $got) . "\n";
}

sub nearly {
	my ($got, $expected, $epsilon) = @_;
  my $close = abs($expected - $got) <= $epsilon;
	return !!$close;
}

sub around_about {
	my ($now, $epsilon) = @_;

	$epsilon ||= 0;

	return Test::Easy::utils::tester->new(
		raw  => [$now, $epsilon],
		explain => sub {
			my ($got, $raw) = @_;
			return sprintf '%s within %s seconds of %s', $got, reverse @$raw;
		},
		test => sub {
			my ($got) = @_;
			return time_nearly($got, $now, $epsilon);
		},
	);
}

sub test_sub (&) {
  my $test = shift;
  return sub {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    goto &$test; # It's a goto because when debugging a test you probably don't care to see this wrapper.
  };
}

sub deep_ok ($$;$) {
  my ($got, $exp, $message) = @_;

  local $Test::Builder::Level = $Test::Builder::Level + 1;
  Test::More::ok( deep_equal($got, $exp), $message ) || do {
		$_ = clone_and_mutate_for_diag($_) foreach $got, $exp;
		my $dump_got = Data::Denter::Denter($got);
		my $dump_exp = Data::Denter::Denter($exp);

    Test::More::diag '$GOT';
    Test::More::diag $dump_got;
    Test::More::diag '$EXPECTED';
    Test::More::diag $dump_exp;

    my $diff = Text::Diff::diff(\$dump_exp, \$dump_got, {CONTEXT => 2**31});
    $diff =~ s/^\@\@.*\@\@\n//;
    Test::More::diag "\n\nDIFF\n+ \$GOT\n- \$EXPECTED\n";
    Test::More::diag $diff;
  };
}

# lame placeholder
sub clone_and_mutate_for_diag { shift }

sub each_ok (&@) {
	my $code = shift;

	local $_;

	my $index = 0;

	my @bad;
	foreach (@_) {
		my $orig = $_;
		my (@got) = $code->();

		my $ok = 1;
		my $expected;

		if (@got == 1) {
			$ok = !! $got[0];
			$expected = 'something true';
		} elsif (! _match($got[0], $got[1])) {
			$ok = 0;
			$expected = $got[1];
		}

		push @bad, {
			raw => $_,
			index => $index,
			got => $got[0],
			expected => $expected,
		} if ! $ok;

		$index++;
	}

	local $Test::Builder::Level = $Test::Builder::Level + 1;
	return deep_ok( \@bad, [] );
}

sub _match {
	my ($got, $expected) = @_;
	if (ref($expected) eq 'Regexp') {
		return $got =~ $expected;
	} elsif (! scalar grep { ref } ($got, $expected)) {
		return $got eq $expected;
	} elsif (ref($got) eq ref($expected)) {
		return deep_equal($got, $expected);
	} else {
		confess "I don't know how to compare a '${\ref($got)}' to a '${\ref($expected)}'";
	}
}

1;

__END__

=head1 NAME

Test::Easy - facilitates easy testing patterns

=head1 SYNOPSIS

    use Test::Easy qw(nearly_ok nearly each_ok);

    # prove that $got is within $epsilon of $expected
    nearly_ok( 1, 1.25, .7, '1 is within .7 of 1.25' );

    # build your own close-approximation tests:
    ok( nearly(1, 1.25, .7), '1 is within .7 of 1.25' );

Simplify tests-in-a-loop:

    # Rather than having a test in a loop like this:
    my @values = (1, 1.1, .9);
    foreach (@values) {
      nearly_ok( $_, 1.25, .7, "$_ is within .7 of 1.25" );
    }

    # You can write it as a single test of the entire set, like this:
    my @values = (1, 1.1, .9);
    my @bad;
    foreach (@values) {
      push @bad, $_ unless nearly($_, 1.25, .7);
    }
    is_deeply( \@bad, [], 'all @values are within .7 of 1.25' );

    # You can write the above test more simply still by simply expressing the
    # test you wish to conduct within the foreach loop:
    each_ok { nearly($_, 1.25, .7, "$_ is within .7 of 1.25") } (1, 1.1, .9);

=head1 AUTHOR AND COPYRIGHT

(c) 2012 Belden Lyman <belden@cpan.org>

=head1 LICENSE

You may use this under the same terms as Perl itself.
