1. Run augustCalls.vcf through truthset.pl to aquire truthset without depth filter

$ perl truthset.pl > truthset.vcf

2. Run depthFilter.pl on truthset to filter to depth, quality  and aquire median stats

$ perl depthFilter.pl truthset.vcf > truthset.dp10.vcf

3. Get stats on truthset using the TS info tag.

EQUAL_GQ = the GT and GQ were equal, so the replicate A info was used
EQUAL_GQ_zyg = the GQ were equal, but zygosities were different so the replicate A info was used (occured a small 159 times)
HIGHER_GQ_A = the GT were equal, so the info from A was used due to its higher EQ
HIGHER_GQ_B = the GT were equal, so the info from B was used due to its higher EQ
VALIDvsDOT_A = A had a valid GT versus no genotype in B
VALIDvsDOT_B = B had a valid GT versus no genotype in A
HIGHER_GQ_zyg_A = GT had different zygosity, but A was chosen to emit due to higher GQ
HIGHER_GQ_zyg_B = GT had different zygosity, but B was chosen to emit due to higher GQ

$ bash stats.sh
