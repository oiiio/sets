#!/usr/bin/perl

# use first 8 columns of truth set (from file "matcher" by grep -vE "^#" truthset.dp10.GQ40.dedup.vcf | cut -f1-8) to grab exact matching lines from exp calls

use strict;
use warnings;


my @matcher;
open(FILE,"matcher");
while(<FILE>) {
  chomp;
  push @matcher, $_;
}
close FILE;
my $lenMatcher = @matcher;
my $place =0;
my $callFile = "augustCalls.vcf";
open(VCF,$callFile);
while(<VCF>) {
    if ($_=~/^#/) {
        print $_;
        next;
    }
    my $hold = $_;
    for (my $i = $place ; $i < $lenMatcher ; $i++ ) {
      if ($hold =~ /$matcher[$i]/) {
        print $hold;
        $place = $i;
        last;
      }
    }
}
close VCF;
