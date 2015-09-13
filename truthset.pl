#!/usr/bin/perl

use strict;
use warnings;
use List::MoreUtils qw(uniq);

#merge the reference calls with priority heuristics based on the analysis plan
#Usage: Change the FILE pointer to the desired VCF, where there are two replicates in the final two columns of genotypes
#Rules implemented for the merging of replicates:
# 1. If both replicates do not have a genotype (show a ./.), then skip
# 2. If both replicates have the same genotype, emit the one with a higher GQ. If equal GQ, emit replicate A
# 3. If one replicate is ./., while the other is genotyped, then emit the genotype
# 4. If there are more than two alleles represented between replicates, throw out line
# 5. If the replicates differ in zygosity only, emit the genotype from the higher GQ


my $out;
open(FILE,"augustCalls.vcf");
while(<FILE>) {
    $out ="";
    my $hold = $_;
    if ($hold =~ /^#/) {
        print $hold;
    }
    if ($hold !~ /^#/) {
        chomp $hold;
        my @lineArr = split("\t",$hold);
        my @ra = split(":",$lineArr[-2]); #replicate A genotype info
        my @rb = split(":",$lineArr[-1]); # replicate B genotype info
        my $chr = $lineArr[0]; # chromosome
        my $pos = $lineArr[1]; # position
        my $ref = $lineArr[3]; # reference allele
        my @vars = split(",",$lineArr[4]); # array of alternate alleles
        $lineArr[8] = "GT:AD:DP:GQ:PL:TS";
        $out = $lineArr[0]."\t".$lineArr[1]."\t".$lineArr[2]."\t".$lineArr[3]."\t".$lineArr[4]."\t".$lineArr[5]."\t".$lineArr[6]."\t".$lineArr[7]."\t".$lineArr[8];
        #First, check for replicate genotype information existence, if there is a ./. in one replicate but a valid 10x genotype in the other, then that genotype will still be reported
        if ($ra[0] =~ /\./ && $rb[0] =~ /\./) {
            next;
        }

        elsif ($ra[0] eq $rb[0] && ($ra[0] !~/\./ && $rb[0] !~/\./)) {
            #check for which entry to use, with priority given to the highest GQ

            if ($ra[3] > $rb[3]) {
              $out .= "\t".join(":",@ra).":HIGHER_GQ_A\n";
              print $out;
            }
            elsif ($ra[3] < $rb[3]) {
              $out .= "\t".join(":",@rb).":HIGHER_GQ_B\n";
              print $out;
            }
            elsif ($ra[3] == $rb[3]) {
              $out .= "\t".join(":",@ra).":EQUAL_GQ\n";
              print $out;
            }
        }
        #for a valid genotype vs. no genotype (different from an alt vs. reference case)
        elsif (($ra[0] =~ /\./ || $rb[0] =~ /\./) && ($ra[0]=~/[0-9]/ || $rb[0]=~/[0-9]/)) {
          if ($ra[0] =~ /[0-9]/) {
            $out .= "\t".join(":",@ra).":VALIDvsDOT_A\n";
            print $out;
          }
          elsif ($rb[0] =~/[0-9]/) {
            $out .= "\t".join(":",@rb).":VALIDvsDOT_B\n";
            print $out;
          }
        }

        #for a differing valid genotypes, if the zygosity does not match, take the higher GQ. If the variant alleles do not match, throw out variant.
        elsif ($ra[0] ne $rb[0] && $ra[0] =~ /[0-9]/ && $rb[0]=~/[0-9]/) {

            my @ragt = split("\/",$ra[0]); # genotype arrays
            my @rbgt = split("\/",$rb[0]);
            my @ragtSort = sort { $a <=> $b } @ragt;
            my @rbgtSort = sort { $a <=> $b } @rbgt;
            my $mark = 0; # marker for multiallelic

            #check for number of alleles represented between replicates
            my @tester = (@ragt, @rbgt);
            my @testSort = sort { $a <=> $b } @tester;
            my @uniSort = uniq(@testSort);
            my $len = @uniSort;
            if ($len > 2) {
              $mark =1;
            }


            #multiallelic throwout
            if ($mark ==1) {
                next;
            }

            #if its just a zygotic difference
            if ($mark ==0) {
              if ($ra[3] > $rb[3]) {
                $out .= "\t".join(":",@ra).":HIGHER_GQ_zyg_A\n";
                print $out;
              }
              elsif ($ra[3] < $rb[3]) {
                $out .= "\t".join(":",@rb).":HIGHER_GQ_zyg_B\n";
                print $out;
              }
              elsif ($ra[3] == $rb[3]) {
                $out .= "\t".join(":",@ra).":EQUAL_GQ_zyg\n";
                print $out;
              }
            }
        }

    }
}
close FILE;
