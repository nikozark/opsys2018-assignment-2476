#!/bin/bash
tar_path=$1	#get tar path as first argument
tar -tf $tar_path | grep .txt > tar_txt_files.txt
if [ 'ls | grep tar_txts' == "" ];then
mkdir ./tar_txts
fi
while IFS= read -r line; #extract only the txt files
do
echo $line
if [[ "$line" == *"/"* ]];then
echo hey
tar -xvf $tar_path -C ./tar_txts "$line"  --strip-components=1
else
tar -xvf $tar_path -C ./tar_txts "$line" 
fi

done < "tar_txt_files.txt"

if [ 'ls | assignments' == "" ];then
echo heya
mkdir ./assignments
fi

for txt_file in $(ls ./tar_txts); do
echo $txt_file
	while IFS= read -r txt;
	do
	echo $txt
	if ! [[ "$txt" == "#"* ]];then
		if [[ "$txt" == "https"*"github.com"*".git" ]];then
			git clone "$txt" ./assignments
		fi
	fi
	done < "./tar_txts/$txt_file"
done
