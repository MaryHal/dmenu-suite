#!/usr/bin/env perl

package MenuSuite;

use warnings;
use strict;

use Data::Dumper;

use POSIX ':sys_wait_h';
use IPC::Open2;

my ($menuProg) = @ARGV; $menuProg //= 'rofi';

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
        die "Invalid MenuProg $menuProg $!";
    }
}

sub buildInputStringFromArray
{
    my ($options) = @_;

    # Chomp every line in options, then join. Don't wanna double up on newlines!
    return join("\n", map { s/\s+\z//srx } @{$options});
}

sub launchMenu
{
    my ($prompt, $input) = @_;
    $input //= '';

    my $menuCommand = setMenuHandler($prompt);
    my $pid = open2(\*CHILD_OUT, \*CHILD_IN, ${menuCommand}) || die "open2() failed $!";

    binmode CHILD_OUT, ':encoding(UTF-8)';
    binmode CHILD_IN, ':encoding(UTF-8)';

    print CHILD_IN $input;
    close CHILD_IN;

    waitpid($pid, 0);

    # Get the last line of output, sadly this doesn't support multiple
    # selection.
    my $line = '';
    while (<CHILD_OUT>)
    {
        chomp;
        if (/\S/s)
        {
            $line = $_;
        }
    }

    close CHILD_OUT;

    if ($line eq '~kill')
    {
        die 'Kill switch activated';
    }

    return $line;
}

sub promptMenu
{
    my ($prompt, $info) = @_;
    return MenuSuite::launchMenu($prompt, $info // '');
}

sub selectMenu
{
    my ($prompt, $options) = @_;
    return launchMenu($prompt, buildInputStringFromArray($options // ()));
}

sub runMenu
{
    my ($prompt, $dispatchTable) = @_;
    $dispatchTable //= ();

    my @menuOptions = sort keys %{$dispatchTable};
    my $selection = launchMenu($prompt, buildInputStringFromArray(\@menuOptions));

    my $defaultAction = sub {};
    ((length $selection && $dispatchTable->{$selection}) || $defaultAction)->();

    return $selection;
}

1;
