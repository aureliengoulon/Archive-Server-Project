#!/bin/bash

# Written by Aurelien Goulon

# -browse mode

archive=Archives/$1

touch dirlist.txt
awk '/^directory/ {printf"%s\n",$2}' $archive > dirlist.txt

touch dirindex.txt
awk '/^directory/ {printf"%s\n",NR}' $archive > dirindex.txt

touch endindex.txt
awk '/^@/ {printf"%s\n",NR}' $archive > endindex.txt

defaultdir=$(awk 'NR==1 {print $1}' dirlist.txt)
currentdir=$defaultdir

defaultlength=${#defaultdir}

debh=$(awk -F: 'NR==1 {print $1}' $archive)

finh=$(awk -F: 'NR==1 {print $2}' $archive)
finh=$((finh-1))

cat dirlist.txt

echo -n "vsh:> "

while read userinput
do
	# Reset command and options
	bcmd=""
	bopt=""

	previousdir=$currentdir
	set -- $(echo $userinput)
	userinput=""

	if [[ $# == 1 ]]
		then
		bcmd=$1
		bopt="0"
	fi

	if [[ $# == 2 ]]
		then
		bcmd=$1
		bopt=$2
	fi
	
	if [[ "$bcmd" == "clear" || "$bcmd" == "exit" || "$bcmd" == "pwd" || "$bcmd" == "ls" || "$bcmd" == "cat" || "$bcmd" == "cd" && -n "$bopt" || "$bcmd" == "rm" ]]
		then

		if [[ "$bcmd" == "clear" ]]
			then
			clear
		elif [[ "$bcmd" == "exit" ]]
			then
			rm dirlist.txt
			rm dirindex.txt
			rm endindex.txt
			rm trololo
			rm tmpfile
			rm listdirectory.txt
			rm request.txt
		
			userinput=""
			bcmd=""
			bopt=""

			exit

		elif [[ "$bcmd" == "pwd" ]]
			then
			# Display current directory root
			# ${parameter:offset}
			# ${parameter:offset:length}
			echo ${currentdir:$defaultlength-1}

		else
		# First step consistes in checking if browser option is relative or absolute
			
			# if [[ "$bcmd" != "cd" && -z "$bopt" ]]
			if [[ "$bcmd" != "cd" ]]
				then
				bopt=$(echo $bopt | sed -e 's/\//\ /g')
				set -- $(echo $bopt)
				bopt=$(echo $bopt | sed -e 's/\ /\//g')
				if [[ $# -eq 1 ]]
					then
					# case where $bopt is relative					
					
					if [[ "$currentdir" == "$defaultdir" ]]
						then
						l=${#currentdir}
						currentdir=${currentdir:0:$l-1}
					fi
				fi
			fi

			if [[ "$bcmd" == "cat" || "$bcmd" == "rm" ]]
				then
				number=$(echo $bopt | sed -e 's/\// /g')
				set $(echo $number)
				
				if [[ $# -gt 1 ]]
					then
					previousdir=$currentdir
					bopt=$(echo $bopt | sed -e 's/\//\\\//g')
					filetouse=$(echo $bopt| awk -F"/" '{print $NF}')
					bopt=$(echo $bopt | sed -e 's/\\\//\//g')
					currentdir=$(echo $bopt | sed -e 's/[/][A-Za-z0-9]*$//g')
						
					bopt=$filetouse
				fi					
			fi
			# We have to check if destination directory exists
			# If not, do nothing
			present="0"
			present=$(grep -n -m 1 $bopt dirlist.txt | awk -F":" '{printf "1"}')

			if [[ "$bcmd" == "cd" && "$bopt" != ".." || "$bcmd" == "cd" && "$bopt" != "/" ]]
				then
				present="0"
				present=$(grep -n -m 1 $bopt dirlist.txt | awk -F: '{printf "1"}')
			#elif [[ "$bcmd" == "cd" && "$bopt" == ".." || "$bopt" == "/" ]]
			#	then
			else
					present="1"
			fi

			
			if [[ "$present" == "1" ]]
				then
				if [[ "$bcmd" == "ls" ]]
					then
					# Here, we try to list directory files with $bopt which contains current directory path, thanks to the cd command 

					# First, get the archive line to use, that is the line where the directory is located
					# We can find this index in dirindex.txt
										
					# grep command below gets the line number as linenumber:linecontent
					
					 if [[ "$bopt" == "0" ]]
						then
						bopt=$(echo $currentdir)
					fi


					bopt=$(echo $bopt | sed -e 's/\//\\\//g')

					gotdirindex=$(grep -n -m 1 $bopt dirlist.txt | awk -F":" '{print $1}')

					wheredirectorybegins=$(awk 'NR=='$gotdirindex' {print $0}' dirindex.txt)
					wheredirectorybegins=$((wheredirectorybegins+1))

					wheredirectoryends=$(awk 'NR=='$gotdirindex' {print $0}' endindex.txt)
					wheredirectoryends=$((wheredirectoryends-1))

					bopt=$(echo $bopt | sed -e 's/\\\//\//g')




					fichier=$(awk -v b=$wheredirectorybegins -v e=$wheredirectoryends '
						NR>=b && NR<=e {
						if(match($2,/-..x.*$/)!=0 && match($2,/^drwxr-xr-x$/)==0)
							{
							printf ("%s* \n",$1);
							}
						else if(match($2,/^drwxr-xr-x$/)!=0 && match($2,/^-..x.*$/)==0)
							{
								printf ("%s/ \n",$1);
							}
						else if(match($2,/^drwxr-xr-x$/)==0 && match($2,/^-..x.*$/)==0)
							{
								printf ("%s \n",$1);
							}
					}' $archive)


					echo -n $fichier" "
					echo""
			

				elif [[ "$bcmd" == "cat" ]]
					then
					# Search the file in the current directory, then in the other ones.
					# Once file is found, put it in the variable filename and read its content as in -extract mode.

					#recherche de la ligne sur lequel se trouve la fichier
					
					filename=$(grep -n -m 1 $bopt $archive | awk -F":" '{print $2}' | awk '{print $1}')

				
					# Test if file name exists
					# Read file content
					body=$(awk -F":" 'NR==1 {print $2}' $archive)
					
					# Do the following opeartion for each filename in the archive
					fline=$(grep -n -m 1 $bopt $archive | awk -F":" '{print $2}' | awk '{print $4}')
					lline=$(grep -n -m 1 $bopt $archive | awk -F":" '{print $2}' | awk '{print $5}')
					fline=$(($fline+$body-1))
					lline=$(($lline+$fline-1))

					isonelinelong=$((lline-fline))
					if [ $isonelinelong -eq 1 ]
						then
						fline=$((fline+1))
					fi

					awk -v f="$fline" -v l="$lline" '{if(NR>=f && NR<=l) print $0}' $archive

					# Go back to the initial directory if bopt command was absolute
					currentdir=$previousdir



				elif [[ "$bcmd" == "cd" ]]
					then
					case $bopt in
						".." )			
						if [[ $currentdir != $defaultdir ]]
							then
							currentdir=$(echo $currentdir | sed -e 's/\/[A-Za-z0-9]*$//g')
						fi
						space=${defaultdir:0:((defaultlength-1))}
						if [[ $currentdir == $space ]]
							then
							currentdir=$(echo $currentdir"/")
						fi
						;;

						"/" )
						currentdir=$defaultdir
						;;

						* )
						if [[ "$bopt" != "$currentdir" ]]
							then
							# Début de l'indexation du changement de currentdir
							gotdirindex=$(grep -n -m 1 $bopt dirlist.txt | awk -F: '{print $1}')
							# Une fois l'index récupéré, on va rechercher dans la liste des répertoires celui qui correspond
							currentdir=$(awk -v g=$gotdirindex 'NR==g {print $0}' dirlist.txt)
						else
							echo "You are already be in the directory you are asking for"
						fi
						;;
					esac
					

				elif [[ "$bcmd" == "rm" ]]
					then
					deletline=$(grep -n -m 1 $bopt $archive | awk -F":" '{print $1}') #voir la condition
					isfile="0"
					isfile=$(awk 'NR=='$deletline' {if(match($2,/^-.*/)!=0) print "1" }' $archive)
					
					# Create temporary files
					touch listdirectory.txt 
					touch tmpfile

					# test if it is a directory
					if [[ "$isfile" != "1" ]]
					
						then
						
						# find  childs directory
						awk -F "$currentdir" '/'"$bopt"'/ {print NR}' dirlist.txt > listdirectory.txt

						# tac: read backwards in order to delete childs directory first
						set -- $(tac listdirectory.txt)

						numdir=0
						# count number of files
						for i in $*
						do
							numdir=$(($numdir+1))
						done
						
						
						numdir=$(($numdir+1))
						num=$(($numdir-1))

						for((a=1;a<numdir;a++)) 
						do
							touch listfile.txt
						
							dirfile=$(awk 'NR =='${!a}' {print $0}' dirindex.txt)
							endfile=$(awk 'NR =='${!a}' {print $0}' endindex.txt)
							testdiff=$(($endfile-$dirfile))

							filename=55
							
							# test if the directory is emppty
							if [[ $testdiff -ne 1 ]]
								then
								endfile=$(($endfile-1))
								dirfile=$(($dirfile+1))
								#list files to delete
								awk 'NR =='$dirfile', NR =='$endfile' {print $1}' $archive > listfile.txt
												
								# if we are in the current directory, we add the directory to delete in order to be deleted
								if [[ $a -eq $num ]]
									then
									echo $bopt >> listfile.txt
								fi
								
							
								# here we delete files in listfile one by one
								while read ligne 
								do
									filename=$ligne
									
									body=$(awk -F: 'NR==1 {print$2}' $archive)
						 									
									# fline corresponds to line index where the body begins
									# fline corresponds to line index where the body ends
									fline=$(grep -n -m 1 $filename $archive | awk -F":" '{print $2}' | awk '{print $4}')
									lline=$(grep -n -m 1 $filename $archive | awk -F":" '{print $2}' | awk '{print $5}')

									fline=$(($fline+$body-1))
									lline=$(($lline+$fline-1))
									currentline=$(grep -n -m 1 $filename $archive | awk -F":" '{print $1}')


									# diff is the difference beteween the begin and the end of the file content, that is its length
									diff=$(grep -n -m 1 $filename $archive | awk -F":" '{print $2}' | awk '{print $5}')

									awk -v f="$fline" -v l="$lline" '!(NR>=f && NR<=l)' $archive > tmpfile && mv tmpfile $archive
									 
									
									awk '!/^'$filename'.*$/' $archive > tmpfile && mv tmpfile $archive
													
									body=$(($body-1))
													
									awk -F: '{if(NR==1) printf "%s:%s\n",$1,'$body'};{if(NR!=1) print $0}' $archive > tmpfile && mv tmpfile $archive


									dh=$(awk -F: 'NR==1 {print $1}' $archive)
									fh=$(awk -F: 'NR==1 {print $2}' $archive)
									fh=$(($fh-1))


									# This part is not executed if the file is a directory
									awk -v blop="$diff" -v a="$currentline" -v b="$fh" '
									{
										if(NR >= a && NR <= b && $1 !~ "directory" && $1 !~ "@" && $2 ~ /^\-/)
											$4=$4-blop;
											print $1,$2,$3,$4,$5;
									}' $archive > tmpfile && mv tmpfile $archive
								
								done < listfile.txt
							
							fi
							# Reset default values (dirfile -2 because directory is deleted)
							if [[ "$filename" != "$bopt" ]]
								then	
								dirfile=$(($dirfile-1))
								else
								dirfile=$(($dirfile-2))
							fi

							# Delete directory line
							
							sed ''"$dirfile"'d' $archive > tmpfile && mv tmpfile $archive
							
							sed ''"$dirfile"'d' $archive > tmpfile && mv tmpfile $archive

							# Reset the value
							# Line number to delete
							bigstring=2
							# Body beginning is located two lines up because of the directory line and the @ line
							body=$(awk -F: 'NR==1 {print$2}' $archive)
							body=$(($body-2)) #19-1=18 ou 17
							
							awk -F: '{if(NR==1) printf "%s:%s\n",$1,'$body'};{if(NR!=1) print $0}' $archive > tmpfile && mv tmpfile $archive
						
							rm listfile.txt		
						done
						rm listdirectory.txt

						# Update the files
						touch dirlist.txt
						awk '/^directory/ {printf"%s\n",$2}' $archive > dirlist.txt 
								
						touch dirindex.txt
						awk '/^directory/ {printf"%s\n",NR}' $archive > dirindex.txt
								
						touch endindex.txt
						awk '/^@/ {printf"%s\n",NR}' $archive > endindex.txt
						
					else 
						
						deletline=$(grep -n -m 1 $bopt $archive | awk -F":" '{print $1}')
						
						filename=$(awk 'NR=='$deletline' { print $1 }' $archive)
						
						# test if file name exists or not
						if [[ "$filename" == "" ]]
							then
							echo "The file you are asking is neither a file or a directory in this archive. error: unexisting or missing files"
						else
							body=$(awk -F: 'NR==1 {print$2}' $archive)
							
							# do the following opeartion for each filename in the archive
							bigstring=$(awk -v nom="$filename" '$1 ~ nom {print $(NF-1),$NF,$NR}' $archive)
							set -- $(echo $bigstring)
							fline=$(($1+$body-1))
							lline=$(($2+$fline-1))
							currentline=$(grep -n -m 1 $filename $archive | awk -F":" '{print $1}')
							

							awk -v f="$fline" -v l="$lline" '!(NR>=f && NR<=l)' $archive > tmpfile && mv tmpfile $archive
							#

							awk '!/^'$filename'.*$/' $archive > tmpfile && mv tmpfile $archive

							body=$(($body-1))
							awk -F: '{if(NR==1) printf "%s:%s\n",$1,'$body'};{if(NR!=1) print $0}' $archive > tmpfile && mv tmpfile $archive


							# Updating variables for the files located under the removed one
							dh=$(awk -F: 'NR==1 {print $1}' $archive)
							fh=$(awk -F: 'NR==1 {print $2}' $archive)
							fh=$(($fh-1))

							diff=$2
							
							
							awk -v blop="$diff" -v a="$currentline" -v b="$fh" '
							{
								if(NR > a && NR <= b && $1 !~ "directory" && $1 !~ "@" && $2 ~ /^\-/)
									print $1,$2,$3,$4-blop,$5;
							}
							{
								if (NR <= a || NR > b || $1 ~ "directory" || $1 ~ "@" || $2 !~ /^\-/)
									print $0;
							}' $archive > tmpfile && mv tmpfile $archive

							# Go back to the initial directory if bopt command was absolute
							currentdir=$previousdir
							# Update the files
							touch dirlist.txt
							awk '/^directory/ {printf"%s\n",$2}' $archive > dirlist.txt 
										
							touch dirindex.txt
							awk '/^directory/ {printf"%s\n",NR}' $archive > dirindex.txt
										
							touch endindex.txt
							awk '/^@/ {printf"%s\n",NR}' $archive > endindex.txt
													
						fi
					fi
				
				fi
			else
				echo "You can't reach this destination from where you are or it doesn't exist"
				currentdir=$previousdir
			fi
		fi
	else
		echo "unknown command"
	fi

	userinput=""
	bcmd=""
	bopt=""

	echo -n "vsh:> "
done
