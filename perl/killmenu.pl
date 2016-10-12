#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/";

use Scalar::Util qw(looks_like_number);

use MenuSuite;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;

my $data = `ps aux`; # Already returns newline-delimited output
my $selection = MenuSuite::promptMenu("Process List: ", $data) || exit 0;

my @tokens = split /\s+/, $selection;

my $user = $tokens[0];
my $pid = $tokens[1];

if (looks_like_number($pid))
{
    # if ($user eq 'root')

    my $check = MenuSuite::promptMenu("Are you sure? (yes/no) ", $selection) || exit 0;
    exit 0 if uc($check) ne 'YES';

    system('kill', "$pid");
}
