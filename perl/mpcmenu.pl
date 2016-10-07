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

sub getCurrentPlaylist
{
    my @playlist = grep { scalar keys %$_; } mpc()->playlist_info();
    if (!scalar @playlist)
    {
        MenuSuite::promptMenu("Info: ", "Playlist is Empty");
        return;
    }

    return \@{playlist};
}

sub getCurrentSong
{
    if (!mpc()->playlist_length)
    {
        MenuSuite::promptMenu("Info: ", "Playlist is Empty");
        return;
    }

    if (isPlaying())
    {
        return \%{mpc()->current_song()};
    }

    return \%{mpc()->playlist_info(0)};
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
        $songInfo->{'Track'} . ": " . $songInfo->{'Title'},
        $songInfo->{'Artist'},
        $songInfo->{'Album'},
        # secondsToString(mpc()->elapsed),
        secondsToString($songInfo->{'Time'})
        );

    return @data;
}

sub showDetailedSongInfo
{
    my $songInfo = getCurrentSong() || return;

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

sub seek
{
    if (!isPlaying())
    {
        return;
    }

    my $seekValue = MenuSuite::promptMenu("Seek: ") || exit 0;

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
}

sub songPushLoop
{
    my ($songList) = @_;

    my @uriList = map { $_->{'uri'} } @$songList;
    my $songListStr = join("\n", @uriList);

    while (1)
    {
        my $uri = MenuSuite::promptMenu("Push: ", $songListStr) || exit 0;
        mpc()->add($uri);
    }
}

my %mainOptions = (
    Push => sub {
        my @songList = mpc()->list_all();
        songPushLoop(\@songList);
    },
    PushFilter => sub {
        my @filterTypes = ("any",
                           "artist",
                           "album",
                           "title",
                           "track",
                           "name",
                           "genre",
                           "date",
                           "composer",
                           "performer",
                           "comment",
                           "disc",
                           "filename");

        my $filterType = MenuSuite::selectMenu("Filter Type: ", \@filterTypes) || exit 0;
        my $filter = MenuSuite::promptMenu("Filter Type: ") || exit 0;

        my @songList = mpc()->search($filterType, $filter);
        songPushLoop(\@songList);
    },
    Remove => sub {
        while (1)
        {
            my $playlist = getCurrentPlaylist() || exit 0;
            my @options = map { $_->{Id} . "  " . briefSongInfo($_); } @$playlist;

            my $song = MenuSuite::selectMenu("Remove: ", \@options) || exit 0;

            if ($song =~ /^(\d+)/)
            {
                mpc()->delete_id($1);
            }
        }
    },
    List => sub {
        my $playlist = getCurrentPlaylist() || exit 0;
        listPlaylist($playlist);
    },
    Play => \&playOrPause,
    PlayById => sub {
        my $playlist = getCurrentPlaylist() || exit 0;
        my @options = map { $_->{Id} . "  " . briefSongInfo($_); } @$playlist;

        my $song = MenuSuite::selectMenu("Play: ", \@options) || exit 0;

        if ($song =~ /^(\d+)/)
        {
            mpc()->play_id($1);
        }
    },
    Next => sub { mpc()->next(); },
    Prev => sub { mpc()->previous(); },
    Pause => sub { mpc()->pause(); },
    Stop => sub { mpc()->stop(); },
    Current => \&showDetailedSongInfo,
    Seek => \&seek,
    Playlist => sub
    {
        my @playlistList = map { $_->{playlist} } mpc()->list_playlists();

        my %playlistMenuOptions = (
            Save => sub
            {
                my $name = MenuSuite::promptMenu("Save: ") || exit 0;
                mpc()->save($name);
            },
            List => sub
            {
                my $name = MenuSuite::selectMenu("List: ", \@playlistList) || exit 0;

                my @playlist = grep { scalar keys %$_; } mpc()->list_playlist_info($name);
                listPlaylist(\@playlist);
            },
            Load => sub
            {
                my $name = MenuSuite::selectMenu("Load: ", \@playlistList) || exit 0;
                mpc()->load($name);
            },
            Rename => sub
            {
                my $oldname = MenuSuite::selectMenu("Old Name: ", \@playlistList) || exit 0;
                my $newname = MenuSuite::promptMenu("New Name: ") || exit 0;
                mpc()->rename($oldname, $newname);
            },
            Delete => sub
            {
                my $name = MenuSuite::selectMenu("Delete: ", \@playlistList) || exit 0;
                mpc()->rm($name);
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
    Lyrics => sub {
        my $songInfo = getCurrentSong() || exit 0;

        my $lyricsFile = sprintf
            "%s/.lyrics/%s - %s.txt",
            $ENV{'HOME'},
            $songInfo->{'Artist'},
            $songInfo->{'Title'};

        binmode(STDOUT, ":utf8");

        if (! -f "$lyricsFile")
        {
            MenuSuite::promptMenu("Info: ", "Lyrics file not found\n$lyricsFile");
            return;
        }
        system("xdg-open '$lyricsFile'") == 0 or die "Call to xdg-open failed: $?";
    },
    );

MenuSuite::runMenu("Mpd: ", \%mainOptions);
