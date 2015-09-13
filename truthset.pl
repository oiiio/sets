#!/usr/bin/perl

use strict;
use warnings;


#merge the reference calls with priority heuristics based on the analysis plan


open(FILE,"augustCalls.vcf");
while(<FILE>) {
    my $hold = $_;
    if ($hold !~ /^#/) {
        chomp $hold;
        my @lineArr = split("\t",$hold);
        my @ra = split(":",$lineArr[-2]); #replicate A genotype info
        my @rb = split(":",$lineArr[-1]); # replicate B genotype info
        my $chr = $lineArr[0]; # chromosome
        my $pos = $lineArr[1]; # position
        my $ref = $lineArr[3]; # reference allele
        my @vars = split(",",$lineArr[4]); # array of alternate alleles

        #First, check for replicate genotype information existence, if there is a ./. in one replicate but a valid 10x genotype in the other, then that genotype will still be reported
        if ($ra[0] =~ /\./ && $rb[0] =~ /\./) {
            next;
        }

        elsif ($ra[0] eq $rb[0] && ($ra[0] !~/\./ && $rb[0] !~/\./)) {
            #check for which entry to use, with priority given to the highest GQ

            if ($ra[3] > $rb[3]) {
              print "@ra HIGHER GQ\n";
            }
            elsif ($ra[3] < $rb[3]) {
              print "@rb HIGHER GQ\n";
            }
            elsif ($ra[3] == $rb[3]) {
              print "@ra EQUAL GQ\n";
            }
        }
        #for a valid genotype vs. no genotype (different from an alt vs. reference case)
        elsif (($ra[0] =~ /\./ || $rb[0] =~ /\./) && ($ra[0]=~/[0-9]/ || $rb[0]=~/[0-9]/)) {
          if ($ra[0] =~ /[0-9]/) {
              print "@ra VALID VS DOT\n";
          }
          elsif ($rb[0] =~/[0-9]/) {
              print "@rb VALID VS DOT\n";
          }
        }

        #for a differing valid genotypes, if the zygosity does not match, take the higher GQ. If the variant alleles do not match, throw out variant.
        elsif ($ra[0] ne $rb[0] && $ra[0] =~ /0-9/ && $rb[0]=~/0-9/) {
            my @ragt = split("\/",$ra[0]); # genotype arrays
            my @rbgt = split("\/",$rb[0]);
            my @ragtSort = sort { $a <=> $b } @ragt;
            my @rbgtSort = sort { $a <=> $b } @rbgt;
            my $mark = 0; # marker for multiallelic
            for (my $i = 0; $i < @ragtSort; $i++) {
              #check for multiallelic
              if ($ragtSort[$i] != $rbgtSort[0] && $ragtSort[$i] != $rbgtSort[1]) {
                $mark = 1;
                next;
              }
              if ($rbgtSort[$i] != $ragtSort[0] && $rbgtSort[$i] != $ragtSort[1]) {
                $mark=1;
                next;
              }
            }
            #multiallelic throwout
            if ($mark ==1) {
                next;
            }

            #if its just a zygotic difference
            if ($mark ==0) {
              if ($ra[3] > $rb[3]) {
                print "@ra HIGHER GQ zygosity\n";
              }
              elsif ($ra[3] < $rb[3]) {
                print "@rb HIGHER GQ zygosity\n";
              }
              elsif ($ra[3] == $rb[3]) {
                print "@ra EQUAL GQ zygosity\n";
              }
            }
        }

    }
}
