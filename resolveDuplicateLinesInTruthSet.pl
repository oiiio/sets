#!/usr/bin/perl

use strict;
use warnings;
use List::Util qw( min max );

#Check the genotypes between lines of repeated coordinates in the truthset (only one sample genotype column expected).
#Choose the single highest GQ line, and emit that
# use the duplicate list given by (OS X Command):
# grep -Ev "^#" truthset.dp10.GQ40.vcf | cut -f2 | uniq -d

my $input = $ARGV[0];
my $dupList = "dupPosTruthSet";


#super ghetto file slurp into memory
my @vcf;
open(VCF, $input);
while(<VCF>) {
  my $hold = $_;
  if ($hold =~ /^#/) {
      print $hold;
  }
  else {
    push @vcf, $hold;
  }
}
close VCF;

#slurp in dup list of coordinates
my @duplist;
open(FILE, $dupList);
while(<FILE>) {
  chomp;
  push @duplist, $_;
}
close FILE;

#begin parsing
my @done; #stores coordinates already arbitrated
my @vcfCopy = @vcf; # copy of vcf array for calling within foreach
foreach(@vcf) {
  my @lineArr = split("\t", $_);
  #check to see if the coordinate has been done already
  my @doneCheck = grep (/^$lineArr[1]$/, @done);
  my $doneLen = @doneCheck;
  if ($doneLen > 0) {
    next;
  }
  # if it hasn't been done, check to see if it's on the duplicate list
  my @countArr = grep (/^$lineArr[1]$/, @duplist);
  my $countLen = @countArr;
  if ($countLen == 0) {
      push @done, $lineArr[1];
      print join("\t",@lineArr); # if not on dup list, emit and go to next
      next;
  }
  # if it's on the dup list, arbitrate
  my @gtArr; #genotype data for current position
  my @findArr = grep (/\t$lineArr[1]\t/, @vcfCopy);
  foreach(@findArr) {
      my @tempArr = split("\t",$_);
      my @holder = split(":",$tempArr[-1]);
      push @gtArr, $holder[-3];
  }
  my $findLen = @findArr;
  my $maxq = max @gtArr;
  for (my $i = 0 ; $i < $findLen ; $i++) {
      if ($gtArr[$i] == $maxq) {
          print $findArr[$i];
          push @done, $lineArr[1];
          last;
      }
  }
}

=begin
open(FILE, $dupList);
while(<FILE>) {
  chomp;
  @gtArr = [];
  my @holder = [];
  print $_."\n";
  my $pos = $_;
  my @findArr = grep(/\t$pos\t/,@vcf);
#  my $find = `grep -E "\t$_\t" $input`;
#  chomp $find;
#  my @findArr = split("\n",$find);
  my $len = @findArr;
  print "@findArr\n";
  die;
  foreach(@findArr) {
      @lineArr = split("\t",$_);
      @holder = split(":",$lineArr[-1]);
      push @gtArr, $holder[-2];
  }

  for (my $i = 0; $i < $len ; $i++) {
  }
}
=cut
