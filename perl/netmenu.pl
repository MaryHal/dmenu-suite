#!/usr/bin/perl

# This script assumes you can run "netctl" as a user through sudo without
# entering a password. This can be done by editing /etc/sudoers via visudo.

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub loadNetProfile
{
    my ($profileName) = @_;

    system('sudo', 'netctl', 'switch-to', "$profileName");
}

my @rawList = `netctl list`;

my %profileOptions;
foreach my $profile (@rawList)
{
    chomp($profile);

    $profileOptions{$profile} = sub
    {
        loadNetProfile($profile);
    };
}

$profileOptions{'Wifi-Menu'} = sub {
    exec('termite', '-e', 'sudo wifi-menu');
};

MenuSuite::runMenu("Profile: ", \%profileOptions) || exit 0;
