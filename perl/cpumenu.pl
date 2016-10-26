#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $scalingGovFile = '/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor';
my $availableGovFile = '/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors';

my $currentGov;
open(my $fh, '<', $scalingGovFile) or die "cannot open file $scalingGovFile";
{
    local $/;
    $currentGov = <$fh>;
}
chomp $currentGov;
close $fh;

my @availableGov;
open($fh, '<', $availableGovFile) or die "cannot open file $availableGovFile";
{
    my $govOptionString = <$fh>;
    @availableGov = split /\s/s, $govOptionString;
}
close $fh;

my $gov = MenuSuite::selectMenu("[${currentGov}]: ", \@availableGov) || exit 0;

exec 'sudo', 'cpupower', 'frequency-set', '-g', "$gov > /dev/null";
