#!/bin/bash

# Written by Aurelien Goulon

# client side

#  Do not use port 8765 (reserved for server use)

if [[ $# -ge 3 && $# -le 4 ]]
	then
	if [[ $# -gt 0 ]]
		then
		# $1  specified mode
		# $2  server ip address
		# $3  client listening port
		# $4  archive requested
		# $5  client ip address (-extract) 


		touch request.txt
		# mode archive port
		echo "$1 $3 $4" > request.txt

		if [ "$2" == "127.0.0.1" ]
			then
			ipaddress=$(echo "127.0.0.1")
		else
			ipaddress=$(dig +short myip.opendns.com @resolver1.opendns.com)
			# test portion for local network below
			# ipaddress=$(ifconfig en1 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
		fi

		echo " $ipaddress" >> request.txt
				
		case "$1" in
			
			"-list" )
			
			nc -w 3 $2 8765 < request.txt
			rm request.txt
			echo -n "Processing your request, please wait "
			echo -n "."
			for((i=3;i>0;i--))
			do
				sleep 1s
				echo -n "."
			done
			echo ""
			clear
			nc $2 $3
			;;

			"-browse" )
			nc -w 3 $2 8765 < request.txt
			rm request.txt
			echo -n "Processing your request, please wait "
			echo -n "."
			for((i=3;i>0;i--))
			do
				sleep 1s
				echo -n "."
			done
			echo ""
			clear
			nc $2 $3
			;;

			"-extract" )

			server=$2
			port=$3
			archive=$4

			
			nc -w 3 $server 8765 < request.txt
			rm request.txt
			echo -n "Processing your request, please wait "
			echo -n "."
			for((i=2;i>0;i--))
			do
				sleep 1s
				echo -n "."
			done
			echo ""

			echo -n "Downloading the archive, please wait "
			echo -n "."
			for((i=2;i>0;i--))
			do
				sleep 1s
				echo -n "."
			done
			echo ""
			# Receive the archive
			touch $archive
			nc -ld -p $port > $archive

			touch dirlist.txt
			awk '/^directory/ {printf"%s\n",$2}' $archive > dirlist.txt

			touch dirindex.txt
			awk '/^directory/ {printf"%s\n",NR}' $archive > dirindex.txt

			touch endindex.txt
			awk '/^@/ {printf"%s\n",NR}' $archive > endindex.txt
			
			touch drec.txt


			whocandowhat () {

				permissions=$(awk 'NR=='$k' { print $2 }' $archive)

				ur=$(echo ${permissions:1:1} | sed -e 's/-//g')
				uw=$(echo ${permissions:2:1} | sed -e 's/-//g')
				ux=$(echo ${permissions:3:1} | sed -e 's/-//g')
				urights=$(echo $ur$uw$ux)
				chmod u+$urights $filename

				gr=$(echo ${permissions:4:1} | sed -e 's/-//g')
				gw=$(echo ${permissions:5:1} | sed -e 's/-//g')
				gx=$(echo ${permissions:6:1} | sed -e 's/-//g')
				grights=$(echo $gr$gw$gx)
				chmod g+$grights $filename

				or=$(echo ${permissions:7:1} | sed -e 's/-//g')
				ow=$(echo ${permissions:8:1} | sed -e 's/-//g')
				ox=$(echo ${permissions:9:1} | sed -e 's/-//g')
				orights=$(echo $or$ow$ox)
				chmod o+$orights $filename

			}

			createfiles () {
				
				wheredirectorybegins=$(awk 'NR=='$i' {print $0}' dirindex.txt)
				wheredirectoryends=$(awk 'NR=='$i' {print $0}' endindex.txt)

				hasoneline=$((wheredirectoryends-wheredirectorybegins))
				if [ $hasoneline -eq 1 ]
					then
					wheredirectorybegins=$((wheredirectorybegins+1))
				fi

				k=$wheredirectorybegins
				while [[ k -lt $wheredirectoryends ]]
				do
					filename=$(awk 'NR=='$k' { print $1 }' $archive)
					
					isfile="0"
					isfile=$(awk 'NR=='$k' {if(match($1,/^directory$/)==0 && match($1,/^@$/)==0 && match($2,/^drwxr-xr-x$/)==0) printf "1"; else printf "0"}' $archive)

					if [[ "$isfile" == "1" ]]
						then
						if [[ "$currentdir" == "$defaultdir" ]]
							then
							filename=$(echo $currentdir$filename)
						else
							filename=$(echo $currentdir"/"$filename)
						fi
						touch $filename

						echo $filename" " >> drec.txt
						fline=$(awk 'NR=='$k' { print $(NF-1) }' $archive)
						fline=$(($fline+$body-1))

						lline=$(awk 'NR=='$k' { print $NF }' $archive)
						lline=$(($lline+$fline-1))

						isonelinelong=$((lline-fline))
						if [ $isonelinelong -eq 1 ]
							then
							fline=$((fline+1))
						fi
						awk -v f="$fline" -v l="$lline" '{if(NR>=f && NR<=l) print $0}' $archive > $filename

						whocandowhat
					fi
					k=$((k+1))
				done
			}

			debh=$(awk -F: 'NR==1 {print $1}' $archive)
			finh=$(awk -F: 'NR==1 {print $2}' $archive)
			body=$finh
			finh=$(($finh-1))
			defaultdir=$(awk 'NR==1 {print $1}' dirlist.txt)

			nbdir=$(awk -F”\n” 'BEGIN{cmp=0}{cmp++}END{print cmp}' dirlist.txt)
			echo $nbdir" directories to create"


			for((i=1;i<$nbdir+1;i++))
			do
				if [[ $i -eq 1 ]]
					then
					# Gets content begin and end with dirlist
					# Permits to create archvie root, and following directories
					racine=$(awk -F"/" 'BEGIN{i=0;} NF>0 && NR==1 {for(i=NF;i>0;i--)printf("%s ", $i);}' dirlist.txt | sed -e 's/\// /g')
					set -- $racine
					rsize=$(($#))
					j=$rsize
					while [[ $j -gt 0 ]]
					do
						if [[ $j -eq $rsize ]]
							then
							echo "creating "${!j} in $PWD
						fi
						mkdir ${!j}
						echo ${!j}" " >> drec.txt
						
						if [[ $j -lt $rsize ]]
							then				
							dadindex=$((j+1))
							echo "creating "${!j} "in" ${!dadindex}
							mv ${!j} ${!dadindex}
							lastroot=${!j}
						fi
						
					
						j=$((j-1))
					done
					currentdir=$(awk 'NR==1 {print $0}' dirlist.txt)

					createfiles
				else
					dirtocreate=$(awk 'NR=='$i' {print $0}' dirlist.txt)
					dirinfo=$(awk -F"/" 'NR=='$i' {print $NF}' dirlist.txt)
					dadinfo=$(awk -F"/" 'NR=='$i' {print $(NF-1)}' dirlist.txt)
					echo "creating "$dirinfo "in" $dadinfo
					mkdir $dirtocreate

					echo $dirtocreate" " >> drec.txt
					currentdir=$dirtocreate

					createfiles
				fi
			done

			echo "Here are the files that have been created: "
			cat drec.txt
			echo ""

			rm dirlist.txt
			rm dirindex.txt
			rm endindex.txt
			rm $archive
			rm drec.txt
			;;

			* )
			echo ""
			echo "This option doesn't exist. Try again with a valid one."
			echo "Error at >> $1 << "
			echo ""
			;;
		esac
	fi
else
	echo ""
	echo "Wrong number of arguments, follow this pattern: vsh [mode] [address] [port] [archive]"
	echo ""
fi
