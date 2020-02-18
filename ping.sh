#!/bin/bash
# author:ShallowAi
# Set ips.txt split part by how many lines. (Default: false)
count=1000000
# Separate output csv. (Default: 1, Set 0 to enable)
sepa=1
echo INFO: IP Pages have been Separated to $count parts. Output csv separate is $sepa.
echo WARN: Please not decrease Count value too low!
echo WARN: It will cost more performance and network traffic.
echo WARN: 
split -$count ips.txt ip_
for file in `ls ip_*`;
do
	fping -A -e -r 5 -f $file > pingdata_$file.tmp &
done;
echo INFO: ALL fping process create completed. Please wait until ping complete.
wait
echo INFO: ALL fping ping completed. Ready to export csv file.
for file in `ls pingdata_*.tmp`;
do
	sed -i 's/ is alive (/,/g; s/ ms)/,/g' $file.tmp
	if [sepa=1]
	then
		cat $file.tmp >> output.csv
		rm -rf $file.tmp
	fi
done;