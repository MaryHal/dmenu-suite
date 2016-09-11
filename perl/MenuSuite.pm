#!/usr/bin/perl

package MenuSuite;

use warnings;
use strict;

use Data::Dumper;

use POSIX ":sys_wait_h";
use IPC::Open2;

my ($menuProg) = @ARGV;
$menuProg //= "dmenu";

sub launchMenu($\$)
{
    my $prompt = shift;
    my $input  = shift || "";

    my $menuCommand;
    if ($menuProg eq 'dmenu')
    {
        $menuCommand = "dmenu -i -l 12 -x 403 -y 200 -w 560 -s 0 -p '$prompt'";
    }
    elsif ($menuProg eq 'fzf')
    {
        $menuCommand = "fzf $ENV{'FZF_DEFAULT_OPTS'} --print-query --prompt '$prompt'";
    }
    else
    {
        die "Invalid MenuProg $menuProg";
    }

    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, "${menuCommand}") or die "open2() failed $!";

    binmode CHILD_OUT, ':utf8';
    binmode CHILD_IN, ':utf8';

    print CHILD_IN $input;
    close CHILD_IN;

    waitpid($pid, 0);

    my $line;
    while (<CHILD_OUT>)
    {
        chomp;
        if (/\S/)
        {
            $line = $_;
        }
    }

    close CHILD_OUT;

    if ($line eq '~kill')
    {
        die "Kill switch activated";
    }

    return $line;
}

sub promptMenu($\$)
{
    my $prompt = shift;
    my $info   = shift || "";
    return &MenuSuite::launchMenu($prompt, $info);
}

sub selectMenu($\@)
{
    my $prompt  = shift;
    my $options = shift;
    return &launchMenu($prompt, join("\n", @$options));
}

sub runMenu($\%)
{
    my $prompt  = shift;
    my $dispatchTable = shift;

    my @menuOptions = sort keys %$dispatchTable;
    my $selection = &launchMenu($prompt, join("\n", @menuOptions));

    # TODO: Make a subroutine to select an option in a dispatch table
    my $defaultAction = sub {};
    ((length $selection && $dispatchTable->{$selection}) || $defaultAction)->();

    return $selection;
}

1;
