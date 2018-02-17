#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

sub getServiceList
{
    my $serviceListString = `systemctl list-unit-files --type=service --no-legend`;
    my @lines = split("\n", $serviceListString);
    
    my %services;
    
    foreach my $line (@lines)
    {
        my @components = split(/\s+/, $line);
        my $serviceName = shift(@components);
        my $serviceStatus = shift(@components);
        
        my $serviceKey = "$serviceName ($serviceStatus)";
    
        $services{$serviceKey} = sub
        {
            my @serviceActions = ('Enable', 'Disable', 'Start', 'Stop', 'Restart', 'Reload');

            my $action = MenuSuite::selectMenu($serviceKey, \@serviceActions);
            
            if (grep /^$action$/, @serviceActions)
            {
                exec 'sudo', 'systemctl', lc($action), $serviceName;
            }
        };
    }
    
    return %services;
}

my %services = getServiceList();

MenuSuite::runMenu('Service: ', \%services);
