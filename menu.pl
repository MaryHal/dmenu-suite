#!/usr/bin/perl

use warnings;
use strict;

use POSIX ":sys_wait_h";
use IPC::Open2;

my %options = (
    'One'   => sub {print '1';},
    'Two'   => sub {print '2';},
    'Three' => sub {print '3';},
    'Four'  => sub {print '4';},
    );

sub dmenu
{
    my $input = $_[0];

    # my $output = `echo "$input" | dmenu`;
    # chomp $output;
    # return $output;

    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, 'dmenu') or die "open2() failed $!";

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

my $selection = &dmenu(join("\n", keys %options));
$options{$selection}->();
