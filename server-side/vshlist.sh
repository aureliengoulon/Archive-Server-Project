#!/bin/bash

# Written by Aurelien Goulon

# -list mode

cd Archives
for i in *
do
	echo "$i"
done
rm tempfifo
rm request.txt
