#!/bin/sh

TEMPPATH="/storage/screenshots"
TEMPFILENAME="screen_check"
TEMPFILEEXT=".png"
LASTREBOOTFILE="lastreboot.info"
WD_LOCK_FILE="screen_check.lock"
LOG_PATH=/storage
LOG_NAME=log_debug_watchdog.log

# ------------------------
log() {
  msg=$1
  echo $msg
  echo "`date`: $msg" >> $LOG_PATH/$LOG_NAME
}

get_tv_status() {
  cec_status=`echo 'scan' | cec-client -s -d 1`
  tv_status=`echo $cec_status | sed -E 's/^.+power status: ([^[:space:]]+).+power status.+$/\1/'`
  echo $tv_status
}

check_blocking() {
  TIMESTAMP=`date +"%Y%m%d%H%M%S"`
  
  TEMPFILEPATH="$TEMPPATH/$TEMPFILENAME$TIMESTAMP$TEMPFILEEXT"
  kodi-send --action="TakeScreenshot($TEMPFILEPATH)"
  sleep 10
  
  if [ -f $TEMPFILEPATH ]; then
    echo "Not blocked"
  else
    if [ ! -f $WD_LOCK_FILE ]; then
      tv_status=`get_tv_status`
      if [ "$tv_status" != "on" ]; then
        log "[screen_check] Kodi blocked, TV_STATUS OFF [$tv_status], Exit"
        exit
      fi
    
      if [ -f $LASTREBOOTFILE ]; then
        log "[screen_check] Kodi blocked, reboot"
        rm $LASTREBOOTFILE
        reboot
      else
        log "[screen_check] Kodi blocked, killall"
        touch $LASTREBOOTFILE
        killall -9 kodi.bin
        # systemctl restart kodi
      fi
    fi
  fi
}

# ---------------
rm -f $TEMPPATH/$TEMPFILENAME*
find . -type f -mmin 30 -name $LASTREBOOTFILE -exec rm {} \;

if [ ! -f $WD_LOCK_FILE ]; then
  check_blocking
fi
find . -type f -mmin 1 -name $WD_LOCK_FILE -exec rm {} \;
