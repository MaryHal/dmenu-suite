#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $entriesFile = "/tmp/pwentries";

sub DumpPasswordEntries
{
    my $ret = system("termite --class \"fzf-menu\" --geometry 560x80 -e \"pwsafe --list -o ${entriesFile}\"");

    if ($ret != 0)
    {
        system("rm ${entriesFile}");
        die "pwsafe command busted or cancelled";
    }
}

sub ReadPasswordEntries
{
    open(my $fh, '<', $entriesFile);
    chomp(my @entries = <$fh>);
    close($fh);

    return @entries;
}

sub GetUsernamePassword
{
    my ($entry) = @_;
    exec("termite --class \"fzf-menu\" --geometry 560x80 -e \"pwsafe -up '${entry}'\"");
}

sub GetAddEntry
{
    exec("termite --class \"fzf-menu\" --geometry 560x80 -e \"pwsafe -add\"");
}

## Build our menu

my %entries = (
    '[Reload]' => \&DumpPasswordEntries,
    '[Add]' => \&GetAddEntry
    );

foreach my $entry (ReadPasswordEntries())
{
    $entries{$entry} = sub {
        GetUsernamePassword($entry);
    };
}

MenuSuite::runMenu("Entry: ", \%entries) || exit 0;
