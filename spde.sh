Data=$(dirname $PWD)
[ ! -d $Data/SPAdes_result ] && mkdir $Data/SPAdes_result
cat $Data/bin/test_sample.txt | while read id
do
	spades.py -o $Data/SPAdes_result/$id --isolate -1 $Data/1_clean_data/${id}-1/${id}-1_1.clean.fq.gz  -2 $Data/1_clean_data/${id}-1/${id}-1_2.clean.fq.gz  --phred-offset 33
done

