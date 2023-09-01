Data=$(dirname $PWD)
for i in $Data/4_duped_bam/*.duped.bam
do
id=`basename $i .duped.bam`
gatk DepthOfCoverage \
    --input  $i  \
    -L  $Data/bin/HFF.bed \
    -O test.coverage.csv \
    --create-output-variant-index \
    -R $Data/refseq/HFF/HFF_refseq.fa \
    --output-format CSV \
    --print-base-counts 
done
