#!/bin/sh

# ./file-update.sh rpi2 _ips.txt |& tee _log
# /usr/bin/sshpass -p libreelec ssh -oStrictHostKeyChecking=no root@172.28.10.144 "uptime"
# /usr/bin/sshpass -p libreelec scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./storage-rpi2/watchdog.sh root@172.28.10.144:/storage/

print_help() {
  echo "Syntax: [script].sh [rpi1|rpi2] [ips].txt"
  echo
}

if test $# -lt 2; then
  print_help
  exit
fi

# =======================
RPI_VERSION=$1
IPS_FILE=$2

RPI_PASS=libreelec
KODI_TYPE=kodi
FILES_DIR=storage-rpi2

if [ "$RPI_VERSION" == "rpi1" ]; then
  RPI_PASS=openelec
  KODI_TYPE=xbmc
  FILES_DIR=storage-rpi1
fi

RED='\e[31;1m'
GREEN='\e[92m'
NC='\e[0m'

echo "Updating RPi files from '$FILES_DIR/'"
sudo rm -f /home/rhudz/.ssh/known_hosts

step_id=0
total_lines=`wc -l < $IPS_FILE`

for i in $(cat $IPS_FILE); do
  echo
  let step_id=step_id+1
  echo "[$step_id/$total_lines] IP: '$i'"
  
  ping -c 1 $i > /dev/null
  host_avail=$?
  if [ "$host_avail" != 0 ]; then
    printf "${RED} - No Ping '$i' ${NC}\n"
  else
    # ====== MAIN
    /usr/bin/sshpass -p $RPI_PASS scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./$FILES_DIR/.$KODI_TYPE/addons/ver.txt root@$i:/storage/.$KODI_TYPE/addons/
    
    printf "${GREEN} - Files copied ${NC}\n"
  fi
done

printf "Finish\n"
