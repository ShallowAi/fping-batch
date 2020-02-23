#!/bin/bash
# author:ShallowAi

# Set ips.txt split part by how many line.
echo 'Please set ip list file split line count.(Default: 100000)'
echo 'WARN: Please not decrease Count value too low!'
echo 'WARN: It will cost more performance and network traffic. May cause inaccurate.'
read spl
while (($spl<=0))
do
	echo 'ERROR: invalid split count number. Set to Default'
	spl=100000
done

# Separate output csv.
echo 'Separate output csv file? (Default: false)'
read sepa
case $sepa in
	true) echo 'SET: true'
	;;
	false) echo 'SET: false'
	;;
	*) sepa=false
	;;
esac
echo 'INFO: IP Pages have been Separated by $spl line every parts. Output csv separate is $sepa.'

# Ping Method
echo 'Which ping method do you prefer? (fast/exact/custom)'
echo 'fast: Send 1 pings to target, output ping only.(Default)'
echo 'exact: Send 4 pings to target, output min/avg/max ping and packet loss.'
echo 'custom: Send custom numbers pings to target. output min/avg/max ping and packet loss.'
read method
case $method in
	fast) echo 'You choosed fast method.'
	count=1
	;;
	exact) echo 'You choosed exact method.'
	count=4
	;;
	custom) echo 'You choosed custom method. Please type your numbers.'
	read count
	;;
esac

# ip split part
split -$spl ips.txt ip_
# Ping execute part.
case $count in
	1)
	for file in `ls ip_*`;
	do
	fping -A -e -f $file > pingdata_$file.tmp &
	done;
	;;
	*)
	for file in `ls ip_*`;
	do
	fping -A -c $count -q -e -f $file &> pingdata_$file.tmp &
	done;
	;;
esac

echo 'INFO: ALL fping process create completed. Please wait until ping complete.'
wait

# Output process part
echo 'INFO: ALL fping ping completed. Ready to export csv file.'
case $count in
	1)
		for file in `ls pingdata_*.tmp`;
		do
		sed -i 's/ is alive (/,/g; s/ ms)/,/g; s/ is unreachable/,500,/g' $file
		if [sepa=false]
			then
			cat $file >> output.csv
			rm -rf $file
		fi
		done;
	;;
	*)
		for file in `ls pingdata_*.tmp`;
		do
		sed -i "s/' : xmt/rcv/%loss = 4/4/'/,/g; s/', min/avg/max = '/,/g; s/'/'/,/g" $file
		if [sepa=false]
			then
			cat $file >> output.csv
			rm -rf $file
		fi
		done;
	;;
esac