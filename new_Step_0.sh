Data=$(dirname $PWD)
##qual control
#source  activate trim-galor
[ ! -d $Data/temp ] && mkdir $Data/temp
[ ! -d $Data/1_clean_data ] && mkdir $Data/1_clean_data
[ ! -d $Data/merge_fq ] && mkdir $Data/merge_fq
[ ! -d $Data/filter_fa ] && mkdir $Data/filter_fa


#source  activate gatk4

#[ ! -d $Data/QC_Raw ] && mkdir $Data/QC_Raw;
#for i in $(ls $Data/0_raw_data/*.fq.gz); 
#do
 #       fastqc -o $Data/QC_Raw -t 10 $i --extract 
#done
#perl $Data/bin/step_1_fastqc.pl  $Data'/1_clean_data/*.fq.gz' $Data'/QC_Raw/*_fastqc/fastqc_data.txt' $Data/QC_Raw
#rm -r $Data/QC_Raw/*.zip

#Rscript $Data/bin/qc_plot1.r  $Data"/QC_Raw/Result_Table_Info_Raw.txt" 

#[ ! -d $Data/QC_Merge ] && mkdir $Data/QC_Merge;
#for i in $(ls $Data/merge_fq/*.fastq); 
#do
 #       fastqc -o $Data/QC_Merge -t 4 $i --extract ## 
#done
#perl $Data/bin/step_2_merge.pl $Data'/merge_fq/*.fastq' $Data'/QC_Merge/*_fastqc/fastqc_data.txt' $Data/QC_Merge
#rm -r $Data/QC_Merge/*.zip



#[ ! -d $Data/QC_End ] && mkdir $Data/QC_End;
#perl $Data/bin/step_3_end.pl   $Data/filter_fq/"*.fa" $Data/QC_End 


#Rscript $Data/bin/qc_plot2.r $Data"/QC_Raw/*LengthCount.txt" $Data"/QC_Raw/Result_Table_Info_Raw.txt" $Data"/QC_Merge/Result_Table_Info_Merge.txt" $Data/QC_End/Result_Length_End.txt $Data/QC_End/Result_Table_Info_End.txt  $Data/QC_End 



##GATK 
#conda activate gatk4
cat $Data/bin/list.txt | while read id
do
bwa index $Data/refseq/${id}/${id}_refseq.fa
samtools faidx $Data/refseq/${id}/${id}_refseq.fa
gatk CreateSequenceDictionary -R $Data/refseq/${id}/${id}_refseq.fa -O $Data/refseq/${id}/${id}_refseq.dict
done

[ ! -d $Data/2_bwa_bam ] && mkdir $Data/2_bwa_bam
cat $Data/bin/list.txt | while read id
do
bwa mem -t 4 -R '@RG\tID:$id\tPL:illumina\tLB:library\tSM:$id'  $Data/refseq/${id}/${id}_refseq.fa  $Data/1_clean_data/${id}_1.fq $Data/1_clean_data/${id}_2.fq | samtools view -S -bF 12 > $Data/2_bwa_bam/${id}.bam
done


[ ! -d $Data/3_sort_bam ] && mkdir $Data/3_sort_bam
for i in $Data/2_bwa_bam/*.bam
do
id=`basename $i .bam`
samtools sort $i > $Data/3_sort_bam/${id}.sort.bam
done
[ ! -d $Data/4_duped_bam ] && mkdir $Data/4_duped_bam
for i in $Data/3_sort_bam/*.sort.bam
do
id=`basename $i .sort.bam`
picard MarkDuplicates I=$i O=$Data/4_duped_bam/${id}.duped.bam M=$Data/4_duped_bam/${id}.metrics
done

[ ! -d $Data/samtools_stat ] && mkdir $Data/samtools_stat

for i in $Data/4_duped_bam/*.bam
do
id=`basename $i .bam`
samtools index $i
/usr/local/bin/samtools stats $i > $Data/samtools_stat/${id}.stat.txt
done

[ ! -d $Data/5_gatk_vcf ] && mkdir $Data/5_gatk_vcf
cat $Data/bin/list.txt | while read id
do
gatk HaplotypeCaller -R $Data/refseq/${id}/${id}_refseq.fa -I $Data/4_duped_bam/${id}.duped.bam -O $Data/5_gatk_vcf/${id}.vcf
done


[ ! -d $Data/6_snp_indel ] && mkdir $Data/6_snp_indel
for i in $Data/5_gatk_vcf/*.vcf
do
id=`basename $i .vcf`
gatk SelectVariants  -V $i  -O $Data/6_snp_indel/${id}.snp.vcf --select-type-to-include SNP
gatk SelectVariants  -V $i  -O $Data/6_snp_indel/${id}.indel.vcf --select-type-to-include INDEL
done

[ ! -d $Data/7_filter_snp ] && mkdir $Data/7_filter_snp
[ ! -d $Data/7_filter_indel ] && mkdir $Data/7_filter_indel

for i in $Data/6_snp_indel/*.snp.vcf
do 
id=`basename $i .snp.vcf` 
gatk VariantFiltration  -V $i -O $Data/temp/${id}.temp.snp.vcf --filter-expression 'QUAL < 30.0 || QD < 2.0 || FS > 60.0 ||  SOR > 4.0' --filter-name lowqual --cluster-window-size 10  --cluster-size 3 --missing-values-evaluate-as-failing
done

for i in $Data/temp/*.temp.snp.vcf
do
id=`basename $i .temp.snp.vcf`
grep -v 'lowqual' $i >  $Data/7_filter_snp/${id}.snp.vcf
done


for i in $Data/6_snp_indel/*.indel.vcf
do
id=`basename $i .indel.vcf`  
gatk VariantFiltration  -V $i -O $Data/temp/${id}.temp.indel.vcf --filter-expression 'QUAL < 30.0 || QD < 2.0 || FS > 60.0 ||  SOR > 4.0' --filter-name lowqual --cluster-window-size 10  --cluster-size 3 --missing-values-evaluate-as-failing
done

for i in $Data/temp/*.temp.indel.vcf
do
id=`basename $i .temp.indel.vcf`
grep -v 'lowqual' $i >  $Data/7_filter_indel/${id}.indel.vcf
done


rm -rf temp





