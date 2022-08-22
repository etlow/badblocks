# badblocks utilities

This is a collection of JavaScript and Bash scripts I needed to work with hard disks with bad sectors in addition to ddrescue and badblocks.

The general workflow goes:
- Run ddrescue on entire partition to get mapfile
- Input mapfile in ddrescue to badblocks converter, save to blocks.txt
- Run `findbb.sh` to check if other blocks are also bad
- Run `mkfs.sh` to get the required badblocks list format for a specific partition
- Pass this list when using mkfs

The scripts can be modified to streamline the workflow, but the current collection of scripts works for me. All scripts were tested on an Ubuntu 22.04 VM.

## ddrescue to badblocks block format converter

This program takes in a ddrescue mapfile and outputs a list of bad blocks compatible with the Linux badblocks program.

### Running the code

View on [Github Pages](https://etlow.github.io/badblocks).

## badblocks batching

This shell script takes in the existing bad blocks list in the format for badblocks, and runs badblocks on portions of the disk. This script is necessary if badblocks takes very long to run and enables resuming of the bad block finding process from the last successful batch.

Note: if the hard disk disappears halfway through finding of bad blocks, the script may emit the error message below but return successfully for the current batch. If this happens the text file for the current batch should be deleted before resuming the current batch.
```
badblocks: Invalid argument during seek
```

### Running the code

Warning: this script is likely to erase all the data on the target drive.

Change the relevant parameters in `config.sh` and `findbb.sh`, and run `bash findbb.sh`.

## badblocks list creation for particular partition

This script takes in the existing bad blocks list and combines it with the new bad blocks found by `findbb.sh`, and outputs the list of bad blocks for a particular partition. After the list for the entire block device has been created, the relevant bad blocks for each partition must be extracted and translated to be relative to the partition before it can be used.

### Running the code

Change the relevant parameters in `config.sh` and `mkfs.sh`, and run `bash mkfs.sh`.
