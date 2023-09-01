Data=$(dirname $PWD)
FLASH=/home/Metagenome/biosoft/flash/FLASH-1.2.11-Linux-x86_64
##qual control
#source  activate trim-galor
[ ! -d $Data/temp ] && mkdir $Data/temp
[ ! -d $Data/1_clean_data ] && mkdir $Data/1_clean_data
[ ! -d $Data/merge_fq ] && mkdir $Data/merge_fq
[ ! -d $Data/filter_fa ] && mkdir $Data/filter_fa

#for i in $Data/0_raw_data/*_1.fq.gz
#do
#id=`basename $i _1.fq.gz`
#echo $id
#trim_galore -q 20 --phred33 --length 10 --stringency 15 --paired -o $Data/temp $Data/0_raw_data/${id}_1.fq.gz $Data/0_raw_data/${id}_2.fq.gz  --gzip 
#done

#cat $Data/bin/list.txt | while read id
#do
#mv $Data/temp/${id}_1_val_1.fq.gz $Data/1_clean_data/${id}_1.fq.gz
#mv $Data/temp/${id}_2_val_2.fq.gz $Data/1_clean_data/${id}_2.fq.gz
#done

#merge
cat $Data/bin/list.txt | while read id
do
#$FLASH/flash -t 8  $Data/1_clean_data/${id}_1.fq.gz  $Data/1_clean_data/${id}_2.fq.gz  -o ../merge_fq/${id}
#pandaseq -f $Data/1_clean_data/${id}_1.fq.gz  -r $Data/1_clean_data/${id}_2.fq.gz  -w $Data/filter_fa/${id}.fa
seqtk seq -A $Data/merge_fq/${id}.extendedFrags.fastq > $Data/filter_fa/${id}.fa
done
rm -rf $Data/merge_fq/*.notCombined*
cp $Data/merge_fq/* $Data/filter_fa/

