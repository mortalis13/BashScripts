#!/bin/sh

LOG_ROTATE_LIMIT=10

get_next_name_abs() {
  FILE_PATH=$1
  COUNT=0
  
  files=`ls -1 "$FILE_PATH".[0-9]*`
  if [ "$files" != "" ]; then
    for f in $files; do
      n=`echo $f | grep -Eo "[0-9]+$"`
      if [ $n -gt $COUNT ]; then COUNT=$n; fi
    done
    COUNT=$((COUNT+1))
    if [ $COUNT -gt $LOG_ROTATE_LIMIT ]; then COUNT=0; fi
  fi
  
  echo $COUNT
}

get_next_name_simple() {
  FILE_PATH=$1
  COUNT=0
  
  while [ -f $FILE_PATH.$COUNT ]; do
    COUNT=$((COUNT+1))
  done
  if [ $COUNT -gt $LOG_ROTATE_LIMIT ]; then COUNT=0; fi
  
  echo $COUNT
}

# -----------
sleep 15s
mkdir /storage/log

FILE_PATH=/storage/log/log_debug_antiblocking.txt
next_count=$(get_next_name_simple `echo $FILE_PATH`)
remove_count=$((next_count+1))
rm -f $FILE_PATH.$remove_count
mv /storage/log_debug_antiblocking.txt $FILE_PATH.$next_count

FILE_PATH=/storage/log/kodi.old.log
next_count=$(get_next_name_simple `echo $FILE_PATH`)
remove_count=$((next_count+1))
rm -f $FILE_PATH.$remove_count
cp /storage/.kodi/temp/kodi.old.log $FILE_PATH.$next_count

no_cpu_count=0
last_kodi_restart=0

while :
do
  . /storage/anti_blocking_worker.sh
  echo "." >> /dev/watchdog
  # echo "V" >> /dev/watchdog
  sleep 4s
done
