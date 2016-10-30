#!/usr/bin/perl

# If using rofi, try using 'rofi -modi "run,drun" -show run'.

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub getDirectoriesStringFromPath()
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

my $dirs = getDirectoriesStringFromPath();
my $cacheFile = "$ENV{'HOME'}/.cache/dmenu/run_cache";

unless(-e $cacheFile)
{
    open my $fc, ">", $cacheFile;
    close $fc;
}

my @progs;

if (shouldUpdateCache($cacheFile, $dirs))
{
    @progs = `stest -flx $dirs | sort -u | tee "$cacheFile"`;
}
else
{
    my $content;
    open(my $fh, '<', $cacheFile) or die "cannot open file $cacheFile";
    {
        @progs = <$fh>;
    }
    close($fh);
}

my $cmd = MenuSuite::selectMenu("Run: ", \@progs) || exit 0;
exec 'setsid', "$cmd";
