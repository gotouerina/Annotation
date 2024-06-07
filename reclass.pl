#! /usr/bin/perl
use strict;
use warnings;
my $input = shift;

open I, "<$input" or die "";
while (<I>)
{
        if(/>/)
        {
                chomp;
                s/Unknown__//g;
                s/ClassI_//g;
                s/ClassII_//g;
                s/ClassI_nLTR_//g;
                m/#(\w+_\w+)/;
                s/#(\w+)_(\w+)/#$1\/$2/g;
                print "$_\n";
        }
        else { 
                print;
        }
}
