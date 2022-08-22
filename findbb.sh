#!/bin/bash
. config.sh
findbatch=1000
currnum=$(ls -v extrablocks/bb* | tail -1 | sed 's/[^0-9*]//g')
if [ -z $currnum ]; then
    echo No last bad blocks file found, starting from 0
    currnum=-1
fi
mkdir -p extrablocks
while read block; do
    badblockarr[block]=1
done < $baseblocks

# One block of size $bbbs
rundd () {
    printf "%.0s\x$1" $(seq 1 $bbbs) \
        | sudo dd of=$dev bs=$bbbs seek=$2 count=1 iflag=fullblock oflag=direct status=none
    # Can remove code below if dd exits on write errors
    local exitcode=$?
    if [ $exitcode -ne 0 ]; then
        echo dd pipeline exited with $exitcode
        return $exitcode
    fi
}

# One pattern, first dd and then badblocks read-only
# Why replicate the rw behaviour of badblocks? Because it takes too long to
# touch bad sectors, this code avoids touching them
testpattern () {
    local bbin=()
    for ((block=currnum*findbatch; block<(currnum+1)*findbatch; block++)); do
        echo -ne "dd $1 $block \r"
        if [ -n "${badblockarr[block]}" ]; then
            bbin+=($block) # block is bad
        else
            if ! rundd $1 $block; then # block is unknown/good
                return 1
            fi
        fi
    done
    printf "%s\n" "${bbin[@]}" > tempfindbbi.txt
    if [ -z "$countinitial" ]; then
        countinitial=${#bbin[@]}
    fi

    sudo badblocks -svb $bbbs -t $(printf %lu 0x$1$1$1$1) \
        -i tempfindbbi.txt -o tempfindbbo.txt \
        $dev $(((currnum+1)*findbatch-1)) $((currnum*findbatch))
    local bbexit=$?
    while read block; do
        badblockarr[block]=2
    done < tempfindbbo.txt
    rm -f tempfindbb*.txt
    if [ $bbexit -ne 0 ]; then
        echo badblocks exited with $bbexit
        return 1
    fi
}

# One round of loop: test 4 patterns and output file
runbatch () {
    countinitial=
    for pattern in aa 55 ff 00; do
        if ! testpattern $pattern; then
            return 1
        fi
    done
    bbout=()
    for ((block=currnum*findbatch; block<(currnum+1)*findbatch; block++)); do
        if [ "${badblockarr[block]}" == "2" ]; then
            bbout+=($block)
        fi
    done
    countfound=${#bbout[@]}
    if [ $countfound -gt 0 ]; then
        printf "%s\n" "${bbout[@]}" > extrablocks/bb$currnum.txt
    else
        touch extrablocks/bb$currnum.txt # prevent file only containing newline
    fi
}

# Mostly timing code, actual loop logic in runbatch
while true; do
    ((currnum++))
    echo Starting batch $currnum at $(date).
    startsec=$SECONDS
    if ! runbatch; then
        exit 1
    fi
    ((totalsec=SECONDS - startsec))
    speedtext=
    if [ $totalsec -gt 0 ]; then
        speedtext=" at $(($bbbs * $findbatch / ($totalsec * 2**10))) kB/s"
    fi
    echo Batch $currnum, $countinitial initial, $countfound found, \
        done in $totalsec seconds$speedtext.
done
