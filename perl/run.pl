#!/usr/bin/perl

# If using rofi, try using 'rofi -modi "run,drun" -show run'.

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use File::Path qw(make_path);

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub getDirectoriesStringFromPath
{
    my $dirs = $ENV{'PATH'};
    $dirs =~ s/:/ /g;

    return $dirs;
}

sub shouldUpdateCache
{
    my ($cacheFile, $directories) = @_;
    return -z $cacheFile || !system("stest -dqr -n '$cacheFile' $directories");
}

sub createDirectory
{
    my ($directory) = @_;

    if ( ! -d $directory) {
        make_path $directory || die "Failed to create path: $directory";
    }

    return;
}

sub createFile
{
    my ($file) = @_;

    unless(-e $file)
    {
        open my $fc, ">", $file;
        close $fc;
    }

    return;
}

my $cacheDirectory = "$ENV{'HOME'}/.cache/dmenu/";
my $cacheFile = 'run_cache';

my $cachePath = "${cacheDirectory}/${cacheFile}";

createDirectory($cacheDirectory);
createFile($cachePath);

my @progs;
my $searchdirs = getDirectoriesStringFromPath();

if (shouldUpdateCache($cachePath, $searchdirs))
{
    @progs = `stest -flx $searchdirs | sort -u | tee "$cachePath"`;
}
else
{
    open(my $fh, '<', $cachePath) or die "cannot open file $cachePath";
    {
        @progs = <$fh>;
    }
    close($fh);
}

my $cmd = MenuSuite::selectMenu("Run", \@progs) || exit 0;
exec 'setsid', "$cmd";
