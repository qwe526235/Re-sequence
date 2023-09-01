Data=$(dirname $PWD)

[ ! -d $Data/8_con_seq ] && mkdir $Data/8_con_seq
[ ! -d $Data/blast_seq ] && mkdir $Data/blast_seq
[ ! -d $Data/consensus_seq ] && mkdir $Data/consensus_seq
[ ! -d $Data/blast_seq/gene ] && mkdir $Data/blast_seq/gene
[ ! -d $Data/blast_seq/up ] && mkdir $Data/blast_seq/up
[ ! -d $Data/blast_seq/down ] && mkdir $Data/blast_seq/down
[ ! -d $Data/consensus_seq/gene ] && mkdir $Data/consensus_seq/gene
[ ! -d $Data/consensus_seq/up ] && mkdir $Data/consensus_seq/up
[ ! -d $Data/consensus_seq/down ] && mkdir $Data/consensus_seq/down

cat $Data/bin/list.txt | while read id
do
	vcf-sort $Data/7_filter_snp/${id}.snp.vcf | bgzip > $Data/8_con_seq/${id}.sort.vcf.gz
	tabix $Data/8_con_seq/${id}.sort.vcf.gz
	bcftools consensus -f $Data/refseq/$id/${id}_refseq.fa $Data/8_con_seq/${id}.sort.vcf.gz > $Data/8_con_seq/${id}.snp.geonme.fa
done

cat $Data/bin/list.txt | while read id
do
for i in $Data/bed/${id}*.bed
do
t=`basename $i .bed`
seqkit subseq $Data/refseq/${id}/${id}_refseq.fa --bed $i -o $Data/blast_seq/gene/${t}.fa
seqkit subseq $Data/refseq/${id}/${id}_refseq.fa --bed $i -u 1000 -f -o $Data/blast_seq/up/${t}_up.fa
seqkit subseq $Data/refseq/${id}/${id}_refseq.fa --bed $i -d 1000 -f -o $Data/blast_seq/down/${t}_down.fa
seqkit subseq $Data/8_con_seq/${id}.snp.geonme.fa --bed $i -o $Data/consensus_seq/gene/${t}.fa
seqkit subseq $Data/8_con_seq/${id}.snp.geonme.fa --bed $i -u 1000 -f -o $Data/consensus_seq/up/${t}_up.fa
seqkit subseq $Data/8_con_seq/${id}.snp.geonme.fa --bed $i -d 1000  -f -o $Data/consensus_seq/down/${t}_down.fa
done
done
