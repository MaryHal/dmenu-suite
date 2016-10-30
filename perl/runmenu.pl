#!/usr/bin/perl

# If using rofi, try using 'rofi -modi "run,drun" -show run'.

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $dirs = $ENV{'PATH'};
$dirs =~ s/:/ /g;

my $cache = "$ENV{'HOME'}/.cache/dmenu_run";

my $doUpdate = !system("stest -dqr -n '$cache' $dirs");

my @progs;

if ($doUpdate)
{
    @progs = `stest -flx $dirs | sort -u | tee "$cache"`;
}
else
{
    my $content;
    open(my $fh, '<', $cache) or die "cannot open file $cache";
    {
        @progs = <$fh>;
    }
    close($fh);
}

my $cmd = MenuSuite::selectMenu("Run: ", \@progs);
exec 'setsid', "$cmd";
