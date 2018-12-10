#!/bin/bash
compare_content() {
#arg1 is url arg2 is md5
k=1
echo "compare start"
while IFS= read -r line
do
if [ "$1" == "$line" ];then
	k=$((k+1))
	if [ "$(sed "${k}q;d" script1_history)" == "$2" ];then #compare md5
		return 1					#same
	else						#different
		sed -i "${k}s/.*/$2/" script1_history	#changed md5
		echo "$1"				#print to console
	return 0
	fi
		
fi

k=$((k+1))
done < "script1_history"
}

touch "script1_history"
if ! [ -a 'urls_in.txt' ]; then #checks if url file exists
echo "file not found"
exit 1
fi
i=0
while IFS= read -r url
do
if ! [[ $url == "#"* ]]; then			#ignore all lines starting with #

if [ -z $(cat script1_history | grep "$url") ];then #read script history
echo "$url INIT" 				#check if url already exists
echo -e "$url\n0" >> script1_history		#if it doesn't add it
fi
urls[i]=$url 
wget $url -q -O  "site$i"
if  ! [ -s "site$i" ];then #testing if wget succeeded by checking if file exists
echo  "$url FAILED"
fi
md5=$(md5sum "site$i" | awk '{ print $1 }')
compare_content "$url" "$md5" & # running in parallel (not very effective) poor implementation
i=$((i+1))
fi
done < "urls_in.txt"
wait

