#!/bin/bash
tar_path=$1	#get tar path as first argument
tar -tf $tar_path | grep .txt >> tar_txt_files.txt
if [ ! -d "./tar_txts" ];then
mkdir ./tar_txts
fi
while IFS= read -r line; #extract only the txt files
do
if [[ "$line" == *"/"* ]];then
tar -xf $tar_path -C ./tar_txts "$line"  --strip-components=1
else
tar -xf $tar_path -C ./tar_txts "$line" 
fi

done < "tar_txt_files.txt"

if [ 'ls | assignments' == "" ];then
mkdir ./assignments
fi

for txt_file in $(ls ./tar_txts); do
	while IFS= read -r txt;
	do
	if ! [[ "$txt" == "#"* ]];then
		if [[ "$txt" == "https"*"github.com"*".git" ]];then
			clone_path=${txt%.*}
			clone_path=${clone_path##*/}
			git clone --progress "$txt" ./assignments/"$clone_path" &> /dev/null
			if [ $? -eq 0 ];then
				echo $txt ":   Cloning OK"
				echo "./assignments/$clone_path" >> cloned_paths.txt
			else
				echo $txt ":   Cloning FAILED"
			fi
		fi
	fi
	done < "./tar_txts/$txt_file"
done
ls -l | grep -q cloned_paths.txt
if [ $? -eq 1 ];then
rm -f tar_txt_files.txt
rm -rf tar_txts
exit 2
fi

while IFS= read -r directory;
do
txt_number=$(find $directory \( ! -regex '.*/\..*' \) -type f  | xargs | grep -o .txt | wc -l)
dir_number=$(ls -l $directory | grep -c ^d)
file_number=$(find $directory \( ! -regex '.*/\..*' \) -type f | wc -l)
other_number=$(( file_number - txt_number ))
echo "${directory##*/} :"
echo "Number of directories : $dir_number"
echo "Number of txt files : $txt_number"
echo "Number of other files : $other_number"
find $directory \( ! -regex '.*/\..*' \) -type f  | xargs | grep  -E  'dataA.txt' | grep -E 'more/dataB.txt' |grep  -E 'more/dataC.txt' 
if [[ $? -eq 0 ]];then
echo "Directory structure is OK."
else
echo "Directory structure is NOT OK."
fi
done < "cloned_paths.txt"
rm -f cloned_paths.txt
rm -f tar_txt_files.txt
rm -rf tar_txts
