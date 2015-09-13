#!/usr/bin/perl

use strict;
use warnings;

# Calculate metrics for the experiment tables

#change the below files accordingly, $sample is the name of the sample you are analyzing based on its ID in the #CHROM header line
my $sample = $ARGV[0];
my $truthset = "truthset.dp10.GQ40.vcf";
my $sampleVCF = "augustCalls.truthsetdp10GQ40.vcf";
my $qualCut = "40"; # GQ quality score filter

#metric var setup
my @medianArr;
my @median;
my $gtTotal; # number of total genotypes made in sample (including over duplicate positions *see README)
my $gtQ; # number of genotypes in sample meeting the $qualCut filter
my $tp; # number of variant gts matching the truth set
my $fn; # number of reference gts where truth set had variant
my $hetRef; # number of het variants against truth hom ref
my $hetHomVar; # number of het variants against truth hom var of same allele
my $homVarHet; # number of hom variants agaisnt truth het var of same alleles
my $homVarRef; # number of hom variants against truth hom reference
my $multiallelic; # number of variants where more than two alleles represeneted between truth set and experiment
my $sens; # sensitivity (TP/(TP+FP))
my $prec; # precision Tp/(TP+FP)



#feed the truth set in
open()
