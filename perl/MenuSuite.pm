#!/usr/bin/perl

package MenuSuite;

use warnings;
use strict;

use Data::Dumper;

use POSIX ":sys_wait_h";
use IPC::Open2;

my ($menuProg) = @ARGV;
$menuProg //= "rofi";

sub setMenuHandler
{
    my ($prompt) = @_;

    if ($menuProg eq 'dmenu')
    {
        return "dmenu -i -l 12 -x 403 -y 200 -w 560 -s 0 -p '$prompt'";
    }
    elsif ($menuProg eq 'fzf')
    {
        return "fzf $ENV{'FZF_DEFAULT_OPTS'} --print-query --prompt '$prompt'";
    }
    elsif ($menuProg eq 'rofi')
    {
        return "rofi -dmenu -i -p '$prompt'";
    }
    else
    {
        die "Invalid MenuProg $menuProg";
    }
}

sub launchMenu
{
    my ($prompt, $input) = @_;

    my $menuCommand = setMenuHandler($prompt);
    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, ${menuCommand}) or die "open2() failed $!";

    binmode CHILD_OUT, ':utf8';
    binmode CHILD_IN, ':utf8';

    print CHILD_IN $input;
    close CHILD_IN;

    waitpid($pid, 0);

    # Get the last line of output
    my $line = "";
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

sub promptMenu
{
    my ($prompt, $info) = @_;
    $info //= "";

    return MenuSuite::launchMenu($prompt, $info);
}

sub selectMenu
{
    my ($prompt, $options) = @_;
    return launchMenu($prompt, join("\n", @$options));
}

sub runMenu
{
    my ($prompt, $dispatchTable) = @_;

    my @menuOptions = sort keys %$dispatchTable;
    my $selection = launchMenu($prompt, join("\n", @menuOptions));

    my $defaultAction = sub {};
    ((length $selection && $dispatchTable->{$selection}) || $defaultAction)->();

    return $selection;
}

1;
