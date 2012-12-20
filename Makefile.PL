use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME           => 'Test::Facile',
	AUTHOR         => 'Belden Lyman <belden@cpan.org>',
	VERSION_FROM   => 'lib/Test/Facile.pm',
	ABSTRACT_FROM  => 'lib/Test/Facile.pm',
	PL_FILES => {},
	PREREQ_PM => {
		'Test::More' => 0,
		'Functional::Utility' => 0,
	},
	META_MERGE => {
		resources => {
			bugtracker => 'https://github.com/belden/perl-test-facile/issues',
		},
	},
	dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean => { FILES => 'Test-Facile-*' },
);
