#!/usr/bin/env perl

# Read from a pwsafe database.

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $entriesFile = "/tmp/pwentries";

if (! -f "$entriesFile")
{
    MenuSuite::promptMenu("pwsafe entries file not found.");
    my $ret = system("termite --class \"fzf-menu\" --geometry 480x80 -e \"pwsafe --list -o $entriesFile\"");

    if ($ret != 0)
    {
        system("rm $entriesFile");
        die "pwsafe command busted or cancelled";
    }
}

open(my $fh, '<', $entriesFile) || die "entries file still does not exist.";
chomp(my @entries = <$fh>);
close($fh);

my $entry = MenuSuite::selectMenu("Entry: ", \@entries) || exit 0;

exec("termite --class \"fzf-menu\" --geometry 480x80 -e \"pwsafe -up ${entry}\"");
