#!/bin/bash
# compute stats from TS tags

VCF="truthset.vcf"
ALLA=`grep -E "_A$" ${VCF} | wc -l`
ALLB=`grep -E "_B$" ${VCF} | wc -l`
EGQ=`grep -E "EQUAL_GQ" ${VCF} | wc -l`
EGQZ=`grep -E "EQUAL_GQ_zyg" ${VCF} | wc -l`
VDOTA=`grep "VALIDvsDOT_A" ${VCF} | wc -l`
VDOTB=`grep "VALIDvsDOT_B" ${VCF} | wc -l`
HGQA=`grep "HIGHER_GQ_A" ${VCF} | wc -l`
HGQB=`grep "HIGHER_GQ_B" ${VCF} | wc -l`
HGQZA=`grep "HIGHER_GQ_zyg_A" ${VCF} | wc -l`
HGQZB=`grep "HIGHER_GQ_zyg_B" ${VCF} | wc -l`

echo "Total in A"
echo $((${EGQ}+$EGQZ+$VDOTA+$HGQA+$HGQB+$HGQZA+$HGQZB))

echo "Total in B"
echo $((${EGQ}+$EGQZ+$VDOTB+$HGQA+$HGQB+$HGQZA+$HGQZB))

echo "Variants included from A"
echo $(($EGQ+$EGQZ+$VDOTA+$HGQA+$HGQZA))

echo "Variants included from B"
echo $(($EGQ+$EGQZ+$VDOTB+$HGQB+$HGQZB))
