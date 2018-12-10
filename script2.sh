#!/bin/bash
tar_path=$1	#get tar path as first argument
tar -tf $tar_path | grep .txt >> tar_txt_files.txt #get only the paths to the .txt files
if [ ! -d "./tar_txts" ];then			  #create a directory to exctract them to
mkdir ./tar_txts
fi
while IFS= read -r line; #extract only the txt files
do
if [[ "$line" == *"/"* ]];then #check if the .txt was in the main directory or in a subdirectory
tar -xf $tar_path -C ./tar_txts "$line"  --strip-components=1 #ignore the path if it was
else
tar -xf $tar_path -C ./tar_txts "$line" 
fi

done < "tar_txt_files.txt"

if [ 'ls | assignments' == "" ];then #create folder assignments if it doesn't exist
mkdir ./assignments
fi

for txt_file in $(ls ./tar_txts); do  # for each txt file in folder
	while IFS= read -r txt;	 	#for each line in each .txt
	do
	if ! [[ "$txt" == "#"* ]];then	#ignore lines that start with #
		if [[ "$txt" == "https"*"github.com"*".git" ]];then #if url is in correct format
			clone_path=${txt%.*}		#get the name for the directory
			clone_path=${clone_path##*/}
			git clone --progress "$txt" ./assignments/"$clone_path" &> /dev/null
			if [ $? -eq 0 ];then	#check if cloning succeeded
				echo $txt ":   Cloning OK"
				echo "./assignments/$clone_path" >> cloned_paths.txt
			else
				echo $txt ":   Cloning FAILED"
			fi
		fi
	fi
	done < "./tar_txts/$txt_file"
done
ls -l | grep -q cloned_paths.txt #in case that there were no valid git urls
if [ $? -eq 1 ];then		#cleanup
rm -f tar_txt_files.txt
rm -rf tar_txts
exit 2
fi
#checking if structure is correct
while IFS= read -r directory;   #for every cloned directory
do
#counting number of .txt files in cloned directory
txt_number=$(find $directory \( ! -regex '.*/\..*' \) -type f  | xargs | grep -o .txt | wc -l)
#counting number of directories
dir_number=$(ls -l $directory | grep -c ^d)
#counting number of all files
file_number=$(find $directory \( ! -regex '.*/\..*' \) -type f | wc -l)
#substraction to find number of non .txt files
other_number=$(( file_number - txt_number ))
echo "${directory##*/} :"	#print directory in correct format
#printing in requested format
echo "Number of directories : $dir_number"
echo "Number of txt files : $txt_number"
echo "Number of other files : $other_number"
#checking if the structure is the correct 
#find ignores all hidden files , xargs to have everything in a line in order for grep -E to work properly, by piping the result of the first grep to the second and the the third it function as an AND operator 
find $directory \( ! -regex '.*/\..*' \) -type f  | xargs | grep  -E  'dataA.txt' | grep -E 'more/dataB.txt' |grep  -E 'more/dataC.txt' 
if [[ $? -eq 0 ]];then
echo "Directory structure is OK."
else
echo "Directory structure is NOT OK."
fi
done < "cloned_paths.txt"
#cleanup
rm -f cloned_paths.txt
rm -f tar_txt_files.txt
rm -rf tar_txts
