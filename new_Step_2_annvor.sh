Data=$(dirname $PWD)
Bin1=/home/Metagenome/biosoft
Bin2=/home/Metagenome/biosoft/annovar

[ ! -d $Data/9_annovar_snp ] && mkdir $Data/9_annovar_snp
[ ! -d $Data/9_annovar_indel ] && mkdir $Data/9_annovar_indel
cat $Data/bin/list.txt | while read id
do
gffread $Data/refseq/$id/${id}_refseq.gff -T -o $Data/refseq/$id/${id}_refseq.gtf
$Bin1/gtfToGenePred -genePredExt $Data/refseq/$id/*.gtf $Data/refseq/$id/${id}_refGene.txt
perl $Bin2/retrieve_seq_from_fasta.pl --format refGene --seqfile $Data/refseq/$id/${id}_refseq.fa $Data/refseq/$id/${id}_refGene.txt --outfile $Data/refseq/$id/${id}_refGeneMrna.fa

##snp
perl $Bin2/convert2annovar.pl -format vcf4old  $Data/7_filter_snp/${id}.snp.vcf  >  $Data/9_annovar_snp/${id}_snp.annovar
perl $Bin2/annotate_variation.pl -buildver HFF -outfile $Data/9_annovar_snp/${id}_snp.anno $Data/9_annovar_snp/${id}_snp.annovar $Data/refseq/$id
###indel
perl $Bin2/convert2annovar.pl -format vcf4old  $Data/7_filter_indel/${id}.indel.vcf  >  $Data/9_annovar_indel/${id}_indel.annovar
perl $Bin2/annotate_variation.pl -buildver HFF -outfile $Data/9_annovar_indel/${id}_indel.anno $Data/9_annovar_indel/${id}_indel.annovar $Data/refseq/$id

done

