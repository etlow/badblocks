# badblocks utilities

This is a collection of JavaScript and Bash scripts I needed to work with hard disks with bad sectors in addition to ddrescue and badblocks.

The general workflow goes:
- Run ddrescue on entire partition to get mapfile
- Input mapfile in ddrescue to badblocks converter, save to blocks.txt
- Run `findbb.sh` to check if other blocks are also bad
- Run `mkfs.sh` to get the required badblocks list format for a specific partition
- Pass this list when using mkfs

The scripts can be modified to streamline the workflow, but the current collection of scripts works for me. All scripts were tested on Ubuntu 22.04.

## ddrescue to badblocks block format converter

This program takes in a ddrescue mapfile and outputs a list of bad blocks compatible with the Linux badblocks program.

### Running the code

View on [Github Pages](https://etlow.github.io/badblocks).

## badblocks batching

This shell script takes in the existing bad blocks list in the format for badblocks, and runs badblocks on portions of the disk. This script is necessary if badblocks takes very long to run and enables resuming of the bad block finding process from the last successful batch.

### Interruption of script

The script can be interrupted manually or for a variety of other reasons. To ensure proper results when the script is interrupted, the script output should be checked. If badblocks completes successfully when the script is interrupted, the current batch is likely to be incorrect and so the text file for the current batch should be deleted before resuming the current batch.

One scenario is when the hard disk disappears halfway through finding of bad blocks. The script may emit the error message below but return successfully for the current batch.
```
badblocks: Invalid argument during seek
```
As badblocks returns successfully marking everything else as bad, the current batch is incorrect.

Another scenario is when dd is interrupted but badblocks still runs. The blocks are not written with the correct pattern and badblocks thinks there are corruption errors.

As long as badblocks completes successfully when it is not supposed to, the text file for the current batch should be deleted before resuming the current batch.

### Running the code

Warning: this script is likely to erase all the data on the target drive.

Change the relevant parameters in `config.sh` and `findbb.sh`, and run `bash findbb.sh`.

### Test hard disk cache

In certain hard disk configurations or if the hard disk cache cannot be disabled, the cache may interfere with bad block finding.

If a bad block is known, it can be added to `fbbcachetest.sh`, and the script run to find a suitable command which removes this cache effect.

## badblocks list creation for particular partition

This script takes in the existing bad blocks list and combines it with the new bad blocks found by `findbb.sh`, and outputs the list of bad blocks for a particular partition. After the list for the entire block device has been created, the relevant bad blocks for each partition must be extracted and translated to be relative to the partition before it can be used.

### Running the code

Change the relevant parameters in `config.sh` and `mkfs.sh`, and run `bash mkfs.sh`.

## Useful tools

I found the following commands/files useful when working with this project.

- `/dev/disk/by-id`
- `hdparm -AW`
