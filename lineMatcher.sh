#!/bin/bash

#use the first 9 columns of the truth set vcf to pull out hte exact non duplicate intersection with the experiment calls

for i in $(grep -vE "^#" truthset.dp10.GQ40.dedup.vcf | cut -f1-8)
do
  grep "$i" augustCalls.vcf
done > augustCalls.truthsetdp10GQ40dedup.vcf
