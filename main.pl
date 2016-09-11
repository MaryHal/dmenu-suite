#!/usr/bin/perl

use strict;

use MenuSuite;

use Net::MPD;
my $mpd = Net::MPD->connect();

sub playOrPause
{
    if ($mpd->state eq 'stop')
    {
        $mpd->play();
    }
    elsif ($mpd->state eq 'pause')
    {
        $mpd->pause(0);
    }
    elsif ($mpd->state eq 'play')
    {
        $mpd->pause(1);
    }
}

sub secondsToString
{
    my $sec = $_[0];
    return sprintf("%02d:%02d", ($sec/60)%60, $sec%60);
}

my %options = (
    Play  => \&playOrPause,
    Stop  => sub { $mpd->stop(); },
    State => sub {
        my %songInfo = %{$mpd->current_song()};
        my @data = (
            $songInfo{'Title'},
            $songInfo{'Artist'},
            $songInfo{'Album'},
            $songInfo{'Track'},
            secondsToString($songInfo{'Time'})
            );

        &MenuSuite::dmenu(join("\n", @data));
    }
    );

my $selection = &MenuSuite::dmenu(join("\n", sort keys %options));

if (length $selection)
{
    $options{$selection}->();
}
