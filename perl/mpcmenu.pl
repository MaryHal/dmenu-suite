#!/usr/bin/perl

use strict;

use FindBin;
use lib "$FindBin::Bin/";
use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

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

sub dumpMpdObject
{
    print Dumper($mpd);
}

sub secondsToString
{
    my $seconds = $_[0];
    return sprintf("%02d:%02d", ($seconds / 60) % 60, $seconds % 60);
}

my %options = (
    View  => sub {
        my @songList = $mpd->playlist_info();

        my $songToString = sub
        {
            my $song = $_;
            return sprintf("%s %s - %s",
                           $song->{'Track'},
                           $song->{'Title'},
                           $song->{'Album'});
        };

        my @formattedList = map(&$songToString, @songList);

        &MenuSuite::dmenu(join("\n", @formattedList));
    },
    Debug => \&dumpMpdObject,
    Play  => \&playOrPause,
    Stop  => sub { $mpd->stop(); },
    State => sub {
        my %songInfo = %{$mpd->current_song()};
        my @data = (
            $songInfo{'Title'},
            $songInfo{'Artist'},
            $songInfo{'Album'},
            $songInfo{'Track'},
            secondsToString($mpd->elapsed),
            secondsToString($songInfo{'Time'})
            );

        &MenuSuite::dmenu(join("\n", @data));
    }
    );

&MenuSuite::runMenu(\%options);
