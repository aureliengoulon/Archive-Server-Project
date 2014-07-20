#!/bin/bash

# Written by Aurelien Goulon

# server side

# cleaning server disk
checkpoint ()
{
	nbarg=$(($#+1))
	for((i=1;i<$nbarg;i++))
	do
		if [[ -f $i ]]
			then
			rm $i
		fi
	done
}
if [[ ! -f trololo ]]
	then
	mkfifo trololo
fi
if [[ ! -f requestlog.txt ]]
		then
		touch requestlog.txt
fi
when=$(date --)

echo -n ":: server started service :-: "$when 
echo -n ":: server started service :-: "$when >> requestlog.txt
echo "" >> requestlog.txt


while true
do
	
	nc -ld -p 8765 > request.txt
	request=$(cat request.txt)

	when=$(date --)
	echo "on @ "$when"#"
	echo "on @ "$when"#" >> requestlog.txt
	echo $request >> requestlog.txt

	set -- $(echo $request)

	# $1  specified mode
	# $2  client listening port
	# $3  archive requested
	# $4  client ip address (-extract) 
	echo $*
	
	
	if [[ $# -gt 0 ]]
		then

		case $1 in
			"-list" )
			mkfifo trololo
			chmod u+x vshlist.sh
			nc -l -p $2 < trololo | ./vshlist.sh > trololo
			rm trololo
			;;

			"-browse" )
			mkfifo trololo
			chmod u+x vshbrowse.sh
			nc -l -p $2 < trololo | ./vshbrowse.sh $3 > trololo
			rm trololo
			;;

			"-extract" )
			sleep 6s
			nc -w 3 $4 $2 < Archives/$3
			;;
			
			*) echo "unknown mode" ;;
		esac
		echo "CONNECTION ENDED"
	fi
	checkpoint dirlist.txt dirindex.txt endindex.txt trololo tmpfile istdirectory.txt request.txt

done
