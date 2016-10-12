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

my $pid = (split /\W+/, $selection)[1];

if (looks_like_number($pid))
{
    system("kill $pid");
}


