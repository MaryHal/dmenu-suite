#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

use Net::MPD;
my $mpd_;

sub mpc
{
    if (!defined $mpd_)
    {
        $mpd_ = Net::MPD->connect();
    }

    return $mpd_;
}

sub isPlaying
{
    return mpc()->state eq 'stop';
}

sub playOrPause
{
    if (mpc()->state eq 'stop')
    {
        mpc()->play();
    }
    elsif (mpc()->state eq 'pause')
    {
        mpc()->pause(0);
    }
    elsif (mpc()->state eq 'play')
    {
        mpc()->pause(1);
    }
}

sub secondsToString
{
    my ($seconds) = @_;
    return sprintf("%02d:%02d", ($seconds / 60) % 60, $seconds % 60);
}

sub listPlaylist
{
    my ($songList) = @_;

    if (!scalar @$songList)
    {
        MenuSuite::promptMenu("Info: ", "Playlist is Empty");
        return;
    }

    my $i = 1;
    my %optionHash;
    foreach my $song (@$songList)
    {
        my $key = sprintf "%3i  %s", $i,  briefSongInfo($song);
        $optionHash{$key} = sub
        {
            my @data = detailedSongInfo($song);
            MenuSuite::selectMenu("Info: ", \@data);
        };

        $i++;
    }

    MenuSuite::runMenu("List: ", \%optionHash);
}

sub briefSongInfo
{
    my ($song) = @_;

    if (scalar keys %$song)
    {
        return sprintf("%s - %s - %s",
                       $song->{'Title'},
                       $song->{'Artist'},
                       $song->{'Album'});
    }
}

sub detailedSongInfo
{
    my ($songInfo) = @_;

    my @data = (
        $songInfo->{'Title'},
        $songInfo->{'Artist'},
        $songInfo->{'Album'},
        $songInfo->{'Track'},
        secondsToString(mpc()->elapsed),
        secondsToString($songInfo->{'Time'})
        );

    return @data;
}

sub showDetailedSongInfo
{
    if (!mpc()->playlist_length)
    {
        MenuSuite::promptMenu("Info: ", "Playlist is Empty");
        return;
    }

    my $songInfo;
    if (mpc()->state ne 'stop')
    {
        $songInfo = \%{mpc()->current_song()};
    }
    else
    {
        $songInfo = \%{mpc()->playlist_info(0)};
    }

    print Dumper($songInfo);

    my @data = detailedSongInfo($songInfo);
    MenuSuite::selectMenu("Info: ", \@data);
}

sub showToggleMenu
{
    my $boolToString = sub
    {
        return shift ? 'true' : 'false';
    };
    my $randomState  = $boolToString->(mpc()->random);
    my $repeatState  = $boolToString->(mpc()->repeat);
    my $consumeState = $boolToString->(mpc()->consume);
    my $singleState  = $boolToString->(mpc()->single);

    # Proof of concept
    my %toggleOptions = (
        "Random: $randomState"   => sub { mpc()->random(mpc()->random   ? 0 : 1); showToggleMenu(); },
        "Repeat: $repeatState"   => sub { mpc()->repeat(mpc()->repeat   ? 0 : 1); showToggleMenu(); },
        "Consume: $consumeState" => sub { mpc()->consume(mpc()->consume ? 0 : 1); showToggleMenu(); },
        "Single: $singleState"   => sub { mpc()->single(mpc()->single   ? 0 : 1); showToggleMenu(); },
        );

    MenuSuite::runMenu("Toggle: ", \%toggleOptions);
}

my %mainOptions = (
    Push => sub {
        # my @songList = mpc()->search("any", "");

        my @uriList = map { $_->{'uri'} } mpc()->list_all();
        my $songListStr = join("\n", @uriList);

        while (1)
        {
            my $uri = MenuSuite::promptMenu("Push: ", $songListStr);
            last if (!length $uri);

            mpc()->add($uri);
        }
    },
    List => sub {
        my @playlist = grep { scalar keys %$_; } mpc()->playlist_info();
        listPlaylist(\@playlist);
    },
    Play => \&playOrPause,
    Next => sub { mpc()->next(); },
    Prev => sub { mpc()->previous(); },
    Pause => sub { mpc()->pause(); },
    Stop => sub { mpc()->stop(); },
    Current => \&showDetailedSongInfo,
    Seek => sub
    {
        if (mpc()->state eq 'stop')
        {
            return;
        }

        my $seekValue = MenuSuite::promptMenu("Seek: ");

        if (!length $seekValue)
        {
            return;
        }

        if ($seekValue =~ /(\d+)%/)
        {
            $seekValue = $1;

            my $songInfo = mpc()->current_song();
            mpc()->seek_cur($songInfo->{Time} * $seekValue / 100.0);
        }
        elsif ($seekValue =~ /(?:(\d+):)?(\d+)/)
        {
            my $minutes = $1 || 0;
            my $seconds = $2;

            mpc()->seek_cur($minutes * 60.0 + $seconds);
        }
    },
    Playlist => sub
    {
        my %playlistMenuOptions = (
            Save => sub
            {
                my $name = MenuSuite::promptMenu("Save: ");

                chomp($name);
                if (length $name)
                {
                    mpc()->save($name);
                }
            },
            List => sub
            {
                my @playlistList = map { $_->{playlist} } mpc()->list_playlists();
                my $name = MenuSuite::selectMenu("List: ", \@playlistList);

                if (!length $name)
                {
                    return;
                }

                my @playlist = grep { scalar keys %$_; } mpc()->list_playlist_info($name);
                listPlaylist(\@playlist);
            },
            Load => sub
            {
                my @playlistList = map { $_->{playlist} } mpc()->list_playlists();
                my $name = MenuSuite::selectMenu("Load: ", \@playlistList);

                chomp($name);
                if (length $name)
                {
                    mpc()->load($name);
                }
            },
            Delete => sub
            {
                my @playlistList = map { $_->{playlist} } mpc()->list_playlists();
                my $name = MenuSuite::selectMenu("Delete: ", \@playlistList);

                chomp($name);
                if (length $name)
                {
                    mpc()->rm($name);
                }
            },
            Clear => sub { mpc()->clear(); },
            );
        MenuSuite::runMenu("Playlist: ", \%playlistMenuOptions);
    },
    Toggle => \&showToggleMenu,
    Update => sub { mpc()->update(); },
    Stats => sub {
        my $stats = mpc()->stats();
        my @data;
        foreach my $key (sort keys %$stats)
        {
            push(@data, "$key: $stats->{$key}");
        }

        MenuSuite::selectMenu("Stats: ", \@data);
    },
    );

MenuSuite::runMenu("Mpd: ", \%mainOptions);
