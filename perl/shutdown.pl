#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my @timings = qw(now +60 +45 +30 +15 +10 +5 +3 +2 +1);

my %shutdownOptions = (
    Shutdown => sub {
        my $delay = MenuSuite::selectMenu('When', \@timings) || exit 0;
        exec 'sudo', 'shutdown', '-P', "$delay";
    },
    Reboot => sub {
        my $delay = MenuSuite::selectMenu('When', \@timings) || exit 0;
        exec 'sudo', 'shutdown', '-r', "$delay";
    },
    Sleep => sub {
        exec 'sudo', 'systemctl', 'suspend';
    },
    Lock => sub {
        my $lockscreenWallpaper = $ENV{'HOME'} . '/docs/wallpapers/old/SoftAndClean.png';
        exec 'i3lock',
             '--show-failed-attempts',
             '--color=EEEEEE',
             "--image=$lockscreenWallpaper",
             '--tiling';
    },
    Cancel => sub {
        exec 'sudo', 'shutdown', '-c';
    },
    );

MenuSuite::runMenu('Shutdown', \%shutdownOptions);
