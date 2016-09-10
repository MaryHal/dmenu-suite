#!/usr/bin/perl

use strict;

use MenuSuite;

use Net::MPD;
my $mpd = Net::MPD->connect();

my %options = (
    'Play'  => sub { $mpd->play(); },
    'Stop'  => sub { $mpd->stop(); },
    'Pause' => sub { $mpd->pause(); },
    'State' => sub { print $mpd->state; },
    );

my $selection = &MenuSuite::dmenu(join("\n", sort keys %options));

if (length $selection)
{
    $options{$selection}->();
}
