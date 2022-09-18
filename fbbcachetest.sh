#!/bin/bash
. config.sh

# How to use this script:
# 1. Change knownbad to a bad block that is known to be bad.
# 2. Try to run the script.
# 3. If there are no bad blocks found, uncomment/modify the custom command
#    and return to step 2.
# 4. Put the command in findbb.sh where it says 'custom command'.

# Known bad block in terms of block size $bbbs
knownbad=123456

# Write zeros to the bad block
sudo dd if=/dev/zero of=$dev bs=$bbbs seek=$knownbad count=1

# # custom command to clear hard disk cache
# sudo dd if=$dev of=/dev/null bs=$bbbs count=$((2**21/bbbs)) status=none

echo
echo The command to read a bad block below should indicate that the block is bad.
echo

# Immediately try to read it
sudo badblocks -svb $bbbs -t 0 $dev $knownbad $knownbad

# If there are no bad blocks found, the results from findbb.sh may be unreliable.
