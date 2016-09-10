#!/usr/bin/perl

package MenuSuite;

use warnings;
use strict;

use POSIX ":sys_wait_h";
use IPC::Open2;

sub dmenu
{
    my $input = $_[0];

    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, 'dmenu -i') or die "open2() failed $!";

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

1;
