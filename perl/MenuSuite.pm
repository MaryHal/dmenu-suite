#!/usr/bin/perl

package MenuSuite;

use warnings;
use strict;

use POSIX ":sys_wait_h";
use IPC::Open2;

sub dmenu(\$)
{
    my $input = $_[0];

    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, 'dmenu -i -l 12') or die "open2() failed $!";

    binmode CHILD_OUT, ':utf8';
    binmode CHILD_IN, ':utf8';

    print CHILD_IN $input;
    close CHILD_IN;

    waitpid($pid, 0);

    my $line;
    while ($line = <CHILD_OUT>)
    {
        chomp $line;
        last if (length $line);
    }

    close CHILD_OUT;

    return $line;
}

sub runMenu(\%)
{
    my $dispatchTable = shift;

    my @menuOptions = sort keys %$dispatchTable;
    my $selection = &dmenu(join("\n", @menuOptions));

    # TODO: Make a subroutine to select an option in a dispatch table
    my $defaultAction = sub {};
    ((length $selection && $dispatchTable->{$selection}) || $defaultAction)->();
}

1;
