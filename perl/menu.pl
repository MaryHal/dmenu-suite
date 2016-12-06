#!/usr/bin/env perl

use warnings;
use strict;

use File::Basename;
use File::Glob ':bsd_glob';

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $this_dir = "$FindBin::Bin";

my @filenames = map { basename($_) } bsd_glob("$this_dir/*.pl");
my %menuOptions = map
{
    my $filename = $_;
    $_ => sub {
        exec "perl $this_dir/$filename @ARGV"
    }
} @filenames;

$menuOptions{'# Screenshot #'} = sub { exec 'maim -s'; };

MenuSuite::runMenu('Run: ', \%menuOptions) || exit 0;
