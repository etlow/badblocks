dev=/dev/sdb # target device
bbbs=65536 # intermediate block size used to call badblocks
baseblocks=blocks65536.txt # existing bad blocks
findbatch=1000 # findbb batch size
partnum=6 # mkfs target partition number e.g. 6 for /dev/sdb6
outbs=1024 # mkfs output block size, read man page for corresponding mkfs command which accepts badblocks list format
