#!/usr/bin/perl

use strict;
use warnings;

# Calculate metrics for the experiment tables

#change the below files accordingly, $sample is the name of the sample you are analyzing based on its ID in the #CHROM header line
my $sample = $ARGV[0];
my $truthset = "truthset.dp10.GQ40.dedup.vcf";
my $sampleVCF = "augustCalls.truthsetdp10GQ40dedup.vcf";
my $qualCut = "40"; # GQ quality score filter

#metric var setup
my @medianArr;  #use to sort later
my @median; # push depth of variants here;
my $medianOut; #for printing
my $gtTotal; # number of total genotypes made in sample (including over duplicate positions *see README)
my $gtQ; # number of genotypes in sample meeting the $qualCut filter
my $tp; # number of variant gts matching the truth set
my $fn; # number of reference gts where truth set had variant
my $tn; # number of equal reference calls
my $hetRef; # number of het variants against truth hom ref
my $hetHomVar; # number of het variants against truth hom var of same allele
my $homVarHet; # number of hom variants agaisnt truth het var of same alleles
my $homVarRef; # number of hom variants against truth hom reference
my $multiallelic; # number of variants where more than two alleles represeneted between truth set and experiment
my $sens; # sensitivity (TP/(TP+FP))
my $prec; # precision Tp/(TP+FP)
my $missed; # number of genotypes in truth that had no emit in sample
my $fpTotal; # a sum of the fp types


#feed the truth set in
my @truth;
open(TRUTH, $truthset);
while(<TRUTH>) {
    if ($_!~/^#/) {
      my $hold = $_;
      chomp $hold;
      my @liner = split("\t",$hold);
      push @truth, $liner[-1];
    }
}
close TRUTH;





# go through the exp VCF
my $col;
my $place = 0;
open(VCF, $sampleVCF);
while(<VCF>) {
  if ($_=~/^##/) {
    print $_;
    next;
  }
  #grab the column sample corresponding to the sample
  if ($_=~/^#CHROM/) {
      my @temp = split("\t",$_);
      my $lenTemp = @temp;
      for (my $i = 0 ; $i < $lenTemp ; $i++) {
          if ($temp[$i] eq $sample) {
            $col = $i; # assign column number
            last;
          }
      }
      next;
  }
  chomp $_;
  my @lineArr = split("\t",$_);

  #collect!
  my @truthArr = split(":",$truth[$place]); #breakdown truthset info
  $place++; # add 1 to the placeholder for truth set position
  my @sampleArr = split(":",$lineArr[$col]); #breakdown sample gt info

  #no emit in sample vs gt in truth
  if ($sampleArr[0] =~/\./ && $truthArr[0] !~/\./) {
    $missed++;
    next;
  }

  #add depth to median calculator
  push @median, $sampleArr[2];

  $gtTotal++; #add total
  if ($sampleArr[3] >= $qualCut) {
    $gtQ++; #if at qaulity test, add to above qual var
  }

  #true negatives
  if ($sampleArr[0] eq $truthArr[0] && $sampleArr[0] eq "0\/0") {
    tn++;
    next;
  }

  #true positives
  if ($sampleArr[0] eq $truthArr[0] && $sampleArr[0] ne "0\/0") {
    tp++;
    next;
  }

  #false negatives
  if ($sampleArr[0] eq "0\/0" && $truthArr[0] !~/\./) {
      fn++;
      next;
  }

  #multiallelic test
  my $multi = $sampleArr[0]."\/",$truthArr[0];
  my @multiTest = split("\/",$multi);
  my @multiSort = sort { $a <=> $b } @multiTest;
  my @multiUniq = uniq @multiSort;
  my $lenUniq = @multiUniq;
  if ($lenUniq > 2) {
    $multiallelic++;
    next;
  }

  #hetRef
  if ($truthArr[0] eq "0\/0" && $sampleArr[0] =~ /0\//) {
    $hetRef++;
    next;
  }

  #homVarRef
  if ($truthArr[0] eq "0\/0" && $sampleArr[0] !~ /0\//) {
    $homVarRef++;
    next;
  }

  #track zygosity now, at this point only variants are left
  my @homTruth = split("\/",$truthArr[0]);
  my @homTruthTest = uniq @homTruth;
  my $lenHomTruthTest = @homTruthTest;
  if ($lenHomTruthTest == 1) {
    my $homTruthTracker = 1; # mark as homozygous truth set
  }
  elsif ($lenHomTruthTest > 1) {
    my $homTruthTracker =0; #mark as not homozygous truth set
  }
  my $homSampleTracker;
  my @homSample = split("\/",$sampleArr[0]);
  my @homSampleTest = uniq @homSample;
  my $lenHomSampleTest = @homSampleTest;
  if ($lenHomSampleTest ==1) {
    $homSampleTracker =1; # mark sample as hom
  }
  elsif ($lenHomSampleTest > 1) {
    $homSampleTracker =0; #mark sample as het
  }


  #hetHomVar
  if($homSampleTracker == 0 && $homTruthTracker == 1) {
    $hetHomVar++;
    next;
  }

  #homVarHet
  if($homSampleTracker == 1 && $homTruthTracker == 0) {
    $homVarHet++;
    next;
  }
}

close VCF;



## finding medians

@medianArr = sort { $a <=> $b } @median;

#test to see if there are an even number of data points
if( @medianArr  % 2 == 0){
#if even then:
  my $sum = $medianArr[(@medianArr/2)-1] + $medianArr[(@medianArr/2)];
  my $med = $sum/2;
  my $medianOut = $med;
}
else{
#if odd then:
  my $medianOut =  $medianArr[@medianArr/2];
}

#fp sum
$fpTotal = $hetRef + $hetHomVar + $homVarHet + $homVarRef + $multiallelic;

#sensitivity
$sens = $tp / ($tp + $fn );

#precision

$prec = $tp / ($tp + $fpTotal);


print $medianOut."\t".($gtQ/$gtTotal)."\t".$tp."\t".$fn."\t".$fpTotal."\t".$hetRef."\t".$hetHomVar."\t".$homVarHet."\t".$homVarRef."\t".$multiallelic."\t".$sens."\t".$prec."\n"
