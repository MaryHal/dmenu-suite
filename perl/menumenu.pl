#!/usr/bin/perl

use warnings;
use strict;

use File::Basename;
use File::Glob ':bsd_glob';

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $thisDir = "$FindBin::Bin";

my @files = map { basename($_) } bsd_glob("$thisDir/*.pl");

my $selection = MenuSuite::selectMenu("Run: ", \@files) || exit 0;

system("perl", "$thisDir/$selection");
