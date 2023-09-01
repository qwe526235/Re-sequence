Data=$(dirname $PWD)
[ ! -d $Data/8_breakdancer ] && mkdir $Data/8_breakdancer
for i in $Data/4_duped_bam/*.duped.bam
do
id=`basename $i .duped.bam`
echo $id
perl /home/Metagenome/biosoft/miniconda3/envs/gatk4/bin/bam2cfg.pl  $i > $Data/8_breakdancer/$id.cfg
breakdancer-max $Data/8_breakdancer/$id.cfg > $Data/8_breakdancer/$id.xls
done
