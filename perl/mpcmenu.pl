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

sub secondsToString($)
{
    my $seconds = shift;
    return sprintf("%02d:%02d", ($seconds / 60) % 60, $seconds % 60);
}

sub briefSongInfo(\%)
{
    my $song = shift;

    if (scalar keys %$song)
    {
        return sprintf("%s - %s - %s",
                       $song->{'Title'},
                       $song->{'Artist'},
                       $song->{'Album'});
    }
}

sub detailedSongInfo(\%)
{
    my $songInfo = shift;
    my @data = (
        $songInfo->{'Title'},
        $songInfo->{'Artist'},
        $songInfo->{'Album'},
        $songInfo->{'Track'},
        secondsToString($mpd->elapsed),
        secondsToString($songInfo->{'Time'})
        );

    return @data;
}

sub showDetailedSongInfo()
{
    if (!$mpd->playlist_length)
    {
        &MenuSuite::dmenu("Info: ", "Playlist is Empty");
        return;
    }

    my $songInfo;
    if ($mpd->state ne 'stop')
    {
        $songInfo = \%{$mpd->current_song()};
    }
    else
    {
        $songInfo = \%{$mpd->playlist_info(0)};
    }

    my @data = detailedSongInfo(%$songInfo);
    &MenuSuite::selectMenu("Info: ", \@data);
}

my %mainOptions = (
    Push => sub {
        # my @songList = $mpd->search("any", "");

        my @urlList = map { $_->{'uri'} } $mpd->list_all_info();

        my $uri = "asdf";
        while (length $uri)
        {
            $uri = MenuSuite::selectMenu("Push: ", @urlList);

            if (length $uri)
            {
                $mpd->add($uri);
            }
        }
    },
    List => sub {
        my @songList = $mpd->playlist_info();

        my $i = 1;
        my %optionHash;
        foreach my $song (@songList)
        {
            my $key = "$i  " . &briefSongInfo($song);
            $optionHash{$key} = sub
            {
                my @data = detailedSongInfo(%$song);
                &MenuSuite::selectMenu("Info: ", \@data);
            };

            $i++;
        }

        &MenuSuite::runMenu("List: ", \%optionHash);
    },
    Play => \&playOrPause,
    Next => sub { $mpd->next(); },
    Prev => sub { $mpd->previous(); },
    # Replay => sub { $mpd->stop(); $mpd->play(); },
    Pause => sub { $mpd->pause(); },
    Stop => sub { $mpd->stop(); },
    Current => \&showDetailedSongInfo,
    Clear => sub { $mpd->clear(); },
    Seek => sub
    {
        my $seekValue = &MenuSuite::promptMenu("Seek: ");
        if ($seekValue =~ /\d+%/)
        {
            my $songInfo = $mpd->current_song();
            $mpd->seek_cur($songInfo->{Time} * $seekValue / 100.0);
        }
        elsif ($seekValue =~ /(?:(\d+):)?(\d+)/)
        {
            my $minutes = $1;
            my $seconds = $2;

            $mpd->seek_cur($minutes * 60.0 + $seconds);
        }
    },
    Playlist => sub
    {
        my %playlistMenuOptions = (
            Save => sub
            {
                my $name = &MenuSuite::promptMenu("Save: ");

                chomp($name);
                if (length $name)
                {
                    $mpd->save($name);
                }
            },
            List => sub
            {
                my @playlistList = map { $_->{playlist} } $mpd->list_playlists();
                &MenuSuite::selectMenu("List: ", \@playlistList);
            },
            Load => sub
            {
                my @playlistList = map { $_->{playlist} } $mpd->list_playlists();
                my $name = &MenuSuite::selectMenu("Load: ", \@playlistList);

                chomp($name);
                if (length $name)
                {
                    $mpd->load($name);
                }
            },
            Delete => sub
            {
                my @playlistList = map { $_->{playlist} } $mpd->list_playlists();
                my $name = &MenuSuite::selectMenu("Delete: ", \@playlistList);

                chomp($name);
                if (length $name)
                {
                    $mpd->rm($name);
                }
            },
            Clear => sub { $mpd->clear(); },
            );
        &MenuSuite::runMenu("Playlist: ", \%playlistMenuOptions);
    },
    Toggle => sub
    {
        my $boolToString = sub($)
        {
            return shift ? 'true' : 'false';
        };
        my $randomState  = &$boolToString($mpd->random);
        my $repeatState  = &$boolToString($mpd->repeat);
        my $consumeState = &$boolToString($mpd->consume);
        my $singleState  = &$boolToString($mpd->single);

        # Proof of concept
        my %toggleOptions = (
            "Random: $randomState"   => sub { $mpd->random($mpd->random   ? 0 : 1); },
            "Repeat: $repeatState"   => sub { $mpd->repeat($mpd->repeat   ? 0 : 1); },
            "Consume: $consumeState" => sub { $mpd->consume($mpd->consume ? 0 : 1); },
            "Single: $singleState"   => sub { $mpd->single($mpd->single   ? 0 : 1); },
            );

        &MenuSuite::runMenu("Toggle: ", \%toggleOptions);
    },
    Update => sub { $mpd->update(); },
    # Debug => \&dumpMpdObject,
    );

&MenuSuite::runMenu("Mpd:", \%mainOptions);
