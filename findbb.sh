#!/bin/bash
. config.sh
currnum=$(ls -v extrablocks/bb* | tail -1 | sed 's/[^0-9*]//g')
if [ -z $currnum ]; then
    echo No last bad blocks file found, starting from 0
    currnum=-1
fi
mkdir -p extrablocks
bbexit=0
while [ $bbexit -eq 0 ]; do
    ((currnum++))
    sudo badblocks -svwb $bbbs -i $baseblocks -o tempfindbb.txt \
        $dev $((currnum*1000+999)) $((currnum*1000))
    bbexit=$?
    if [ $bbexit -ne 0 ]; then
        echo badblocks exited with $bbexit
    else
        sudo chown $(id -u):$(id -g) tempfindbb.txt
        mv tempfindbb.txt extrablocks/bb$currnum.txt
    fi
done
