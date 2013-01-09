#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 3;

use lib grep { -d } qw(./lib ../lib);
use Test::Facile;

my $some_epoch = rand(CORE::time);
my $some_localtime = localtime($some_epoch);

ok( time_nearly($some_localtime, $some_epoch - 2, 5), "$some_localtime is within 5 seconds of itself minus 2" );

my $other_epoch = ($some_epoch - 100);
my $other_localtime = localtime($other_epoch);
ok( ! time_nearly($some_localtime, $other_epoch, 99), "$some_localtime is greater than 99 seconds away from $other_localtime" );
ok( time_nearly($some_localtime, $other_epoch, 100), "$some_localtime is within 100 seconds of $other_localtime" );

