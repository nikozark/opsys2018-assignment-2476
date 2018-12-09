#!/bin/bash
compare_content() {
#arg1 is url arg2 is md5
k=1
while IFS= read -r line
do
echo "line read = $line"
if [ "$1" == "$line" ];then
	k=$((k+1))
	if [ "$(sed "${k}q;d" script1_history)" == "$2" ];then #compare md5
		return 1					#same
	else	echo "k=$k"					#different
		echo "hey yo $(sed "${k}q;d" script1_history)"
		sed -i "${k}s/.*/$2/" script1_history	#change md5
		echo "$1 changed"				#print to console
	return 0
	fi
		
fi
echo "im here xd"
k=$((k+1))
done < "script1_history"
}

touch "script1_history"

echo $(find -name 'urls_in.txt')
#file -E "urls_in.txt"
if ! [ -a 'urls_in.txt' ]; then #checks if url file exists
echo "file not found"
exit 1
fi
i=0
while IFS= read -r url
do
if ! [[ $url == "#"* ]]; then

if [ -z $(cat script1_history | grep "$url") ];then
echo "$url INIT"
echo -e "$url\n0" >> script1_history
fi
urls[i]=$url
echo "${urls[i]}"
wget $url -q -O  "site$i"
if  ! [ -s "site$i" ];then
echo  "$url FAILED"
fi
md5=$(md5sum "site$i" | awk '{ print $1 }')
compare_content "$url" "$md5"
i=$((i+1))
fi
done < "urls_in.txt"





get_page(){
i=0
for $i in ${#urls[@]}  do
#wget "http://www.google.com/"
done
}

