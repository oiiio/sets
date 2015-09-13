#!/usr/bin/perl

use strict;
use warnings;

my @medianArr;
my @median;
open(FILE,$ARGV[0]);
while(<FILE>) {
  my $hold = $_;
  if ($hold =~ /^#/) {
    print $hold;
    next;
  }
  elsif ($hold !~/^#/) {
    chomp $hold;
    my @lineArr = split("\t",$hold);
    my @gtArr = split(":",$lineArr[-1]);
    #print STDERR "@gtArr\n";
#    if ($gtArr[3] >= 40) {
      push @median, $gtArr[2];
#      print $hold."\n";
#    }
  }
}
close FILE;


## finding medians

@medianArr = sort { $a <=> $b } @median;

#test to see if there are an even number of data points
if( @medianArr  % 2 == 0){
#if even then:
  my $sum = $medianArr[(@medianArr/2)-1] + $medianArr[(@medianArr/2)];
  my $med = $sum/2;
  print STDERR "The median value is $med\n";
}
else{
#if odd then:
  print STDERR "The median value is $medianArr[@medianArr/2]\n";
}
