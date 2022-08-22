#!/bin/bash
. config.sh
partnum=6
outbs=1024
arr=( $(sudo fdisk -l $dev | awk -v dev=$dev$partnum -F '[ *]*' 'NR==1{print $5}$1=="Units:"{print $7}$1==dev{print $2 "\n" $3}') )
echo ${arr[*]}
disksec=${arr[1]}
firstblk=$((${arr[2]}*$disksec/$outbs))
lastblk=$((${arr[3]}*$disksec/$outbs))
cat $baseblocks extrablocks/bb*.txt | awk -v scale=$(($bbbs/$outbs)) -v first=$firstblk -v last=$lastblk \
    '{end = ($1+1)*scale; for (i = $1*scale; i < end; i++) if (i >= first && i <= last) print i - first}' \
    > partblocks.txt
