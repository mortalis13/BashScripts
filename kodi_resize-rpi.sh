# Reduce storage partition
# Used with LibreELEC 8.2.5

systemctl stop kodi.service
cd / && kill -9 $(fuser -m /storage) && umount /storage

resize2fs -f /dev/mmcblk0p2 100M
parted -s -m /dev/mmcblk0 unit MB p
parted -s -m /dev/mmcblk0 rm 2
parted -s -m /dev/mmcblk0 unit MB p
parted -s -m /dev/mmcblk0 unit MB mkpart primary 541MB 1100MB
parted -s -m /dev/mmcblk0 unit MB p

df -h
umount /dev/mmcblk0p2
e2fsck -f -p /dev/mmcblk0p2
resize2fs /dev/mmcblk0p2
mount /dev/mmcblk0p2 /storage
df -h
reboot
