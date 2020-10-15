# Resize .img file removing the unmounted disk space

IMG_FILE=$1
echo "=== Resizing image: '$IMG_FILE' ==="

sudo losetup -d /dev/loop0
sudo modprobe loop
sudo losetup -f
sudo losetup /dev/loop0 $IMG_FILE
sudo partprobe /dev/loop0
sudo gparted /dev/loop0
sudo losetup -d /dev/loop0

# sudo fdisk -l $IMG_FILE
END_SECTOR=`sudo fdisk -l $IMG_FILE | grep .img2 | cut --delimiter=' ' --fields='8'`
NEW_SIZE=$[$END_SECTOR * 512 + 512]

echo "END_SECTOR: $END_SECTOR"
echo "NEW_SIZE: $NEW_SIZE"

echo "-- Calling: 'truncate --size=$NEW_SIZE $IMG_FILE'"
truncate --size=$NEW_SIZE $IMG_FILE
