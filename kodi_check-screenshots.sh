#!/bin/sh

IMG_1=/storage/screenshots/t1.png
IMG_2=/storage/screenshots/t2.png

kodi-send --action="TakeScreenshot($IMG_1)"
sleep 5
kodi-send --action="TakeScreenshot($IMG_2)"
sleep 5

IMG_1_SIZE=`ls -l "$IMG_1" | awk '{print $5; exit}'`
IMG_2_SIZE=`ls -l "$IMG_2" | awk '{print $5; exit}'`

echo $IMG_1_SIZE
echo $IMG_2_SIZE

if [ $IMG_1_SIZE = $IMG_2_SIZE ]; then
  echo "!!! Images Equal"
fi
