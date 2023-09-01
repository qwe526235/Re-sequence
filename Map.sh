Data=$(dirname $PWD)

#[ ! -d $Data/map_result ] && mkdir $Data/map_result
#for i in $Data/4_duped_bam/*.duped.bam
#do
#id=`basename $i .duped.bam`
#samtools view $i > $Data/map_result/${id}.txt
#done



for i in $Data/map_result/*.txt
do
id=`basename $i .txt`
cat $i |awk -F '\t' '{print $4,$5}' > $Data/map_result/${id}_pos.txt
done
