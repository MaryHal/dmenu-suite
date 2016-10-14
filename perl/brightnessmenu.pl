#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my @brightnessSteps = qw (100 80 60 40 20);
my $brightness = MenuSuite::selectMenu("Brightness: ", \@brightnessSteps) || exit 0;

system('xbacklight', '=', "$brightness");
