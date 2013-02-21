use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME           => 'Test::Easy',
	AUTHOR         => 'Belden Lyman <belden@cpan.org>',
	VERSION_FROM   => 'lib/Test/Easy.pm',
	ABSTRACT_FROM  => 'lib/Test/Easy.pm',
	PL_FILES => {},
	PREREQ_PM => {
		# you should have these
		'Test::More' => 0,

    'Test::Resub' => 0,
		'Functional::Utility' => 0,
		'Hash::MostUtils' => 0,

		# for deep_equal and deep_ok
		'Data::Denter' => 0,
		'Text::Diff' => 0,

		# core as of a long time ago
		'Scalar::Util' => 0,
	},
	META_MERGE => {
		resources => {
			bugtracker => 'https://github.com/belden/perl-test-easy/issues',
		},
	},
	dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES => 'Test-Easy-*' },
);
