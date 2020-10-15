#!/bin/sh

# ./run-cmd.sh rpi2 _ips.txt |& tee _log-cmd
# /usr/bin/sshpass -p libreelec ssh -oStrictHostKeyChecking=no root@172.28.10.144 "uptime"

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

if [ "$RPI_VERSION" == "rpi1" ]; then
  RPI_PASS=openelec
  KODI_TYPE=xbmc
fi

RED='\e[31;1m'
GREEN='\e[92m'
NC='\e[0m'

sudo rm -f /root/.ssh/known_hosts

step_id=0
total_lines=`wc -l < $IPS_FILE`

for i in $(cat $IPS_FILE); do
  echo
  let step_id=step_id+1
  echo "[$step_id/$total_lines] IP: '$i'"
  
  no_ping=`ping -c 1 $i > /dev/null;echo $?`
  if [ "$no_ping" != 0 ]; then
    printf "${RED} - No Ping '$i' ${NC}\n"
  else
    # CMD="chmod +x /storage/anti_blocking.sh"
    # CMD="ps aux | grep anti | grep .sh"
    # CMD=". /storage/.config/autostart.sh"
    
    # CMD="ls -la /storage/anti_blocking.sh"
    # CMD="ls -la /storage/log_antiblocking.txt"
    # CMD="ls -la /storage/.cache/cron/crontabs/"
    # CMD="ls -la /storage/watchdog.sh"
    
    CMD="cat /storage/.$KODI_TYPE/addons/ver.txt"
    # CMD="cat /storage/log_debug_antiblocking* | grep -B5 'KODI BLOCKED'"
    # CMD="cat /storage/log_antiblocking.txt"
    # CMD="cat /storage/log_antiblocking.txt && cat /storage/log_debug_watchdog.txt"
    # CMD="cat /storage/log_antiblocking.txt"
    # CMD="cat /storage/.$KODI_TYPE/temp/kodi.log | grep -i udp"
    # CMD="cat /flash/config.txt"
    
    # CMD="killall -9 kodi.bin"
    # CMD="mount -o remount,rw /storage & reboot"
    # CMD="mount"
    # CMD="chmod +x /storage/watchdog.sh"
    # CMD="grep \"rm -f\" /storage/watchdog.sh"
    # CMD="grep \"fvolumelevel\" /storage/.kodi/userdata/guisettings.xml"
    # CMD="grep \"<skin>\" /storage/.kodi/userdata/guisettings.xml"
    # CMD="grep -m 1 \"SERVICE.OCIO\" /storage/.kodi/temp/kodi.log"
    # CMD="df -h | grep /storage"
    # CMD="parted -s -m /dev/mmcblk0 unit MB p"
    # CMD="vcgencmd get_config disable_audio_dither && vcgencmd get_config enable_audio_dither && vcgencmd get_config audio_pwm_mode && vcgencmd get_config pwm_sample_bits"
    
    # CMD="sqlite3 /storage/.kodi/userdata/Database/MyVideos107.db \"UPDATE settings SET volumeamplification=0\""
    # CMD="sqlite3 -header -column /storage/.kodi/userdata/Database/MyVideos107.db \"SELECT idFile,VolumeAmplification FROM settings\""
    
    # CMD="sed -n 1p /storage/.$KODI_TYPE/addons/service.ocio/resources/lib/main_vars.py"
    # CMD="sed -n 3p /storage/watchdog.sh"
    
    # CMD="kodi-send --action=\"TakeScreenshot(/storage/screenshots/abc.png)\""
    
    /usr/bin/sshpass -p $RPI_PASS ssh -oStrictHostKeyChecking=no root@$i "$CMD"
    
    # sleep 10
    # /usr/bin/sshpass -p $RPI_PASS scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$i:/storage/screenshots/abc.png /home/rhudz/screens/$i'_abc.png'
  fi
done

printf "\nFinish\n"
