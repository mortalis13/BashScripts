#!/bin/sh

# curl -s -X POST -H 'Content-type: application/json' --max-time 5 -d '{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels","params":{"labels":["System.CpuUsage"]},"id":1}' 127.0.0.1:8080/jsonrpc
# curl -s -X POST -H 'Content-type: application/json' -d '{"jsonrpc":"2.0","method":"Player.GetActivePlayers","id":1}' 127.0.0.1:8080/jsonrpc
# curl -s -X POST -H 'Content-type: application/json' --max-time 5 -d '{"jsonrpc":"2.0","method":"Player.GetProperties","params":{"properties":["time","position"],"playerid":1},"id":1}' 127.0.0.1:8080/jsonrpc

SCRIPT_VERSION=0.0.3

WD_LOCK_FILE="watchdog.lock"
LOG_PATH=/storage
LOG_NAME=log_antiblocking.log
LOG_DEBUG_NAME=log_debug_antiblocking.log

# ------------------------
log() {
  msg=$1
  echo $msg
  echo "`date`: $msg" >> $LOG_PATH/$LOG_NAME
  logd $msg
}

logd() {
  msg=$1
  echo $msg
  echo "`date`: $msg" >> $LOG_PATH/$LOG_DEBUG_NAME
}

get_kodi_info() {
  ip=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d / -f1)
  url="http://$ip:8080/jsonrpc"
  header="Content-type: application/json"
  timeout="--max-time 5"
  method=$1
  if [ $method = 'cpuinfo' ]; then
    info=$(curl -s -X POST -H $header $timeout -d '{"jsonrpc":"2.0","method":"XBMC.GetInfoLabels","params":{"labels":["System.CpuUsage"]},"id":1}' $url)
  fi
  if [ $method = 'activeplayers' ]; then
    info=$(curl -s -X POST -H $header $timeout -d '{"jsonrpc":"2.0","method":"Player.GetActivePlayers","id":1}' $url)
  fi
  if [ $method = 'playerprop' ]; then
    info=$(curl -s -X POST -H $header $timeout -d '{"jsonrpc":"2.0","method":"Player.GetProperties","params":{"properties":["time","position"],"playerid":1},"id":1}' $url)
  fi
  echo $info
}

get_channel_time_info() {
  channel_info=`get_kodi_info playerprop`
  
  channel_pos=$(echo $channel_info | sed -E 's/^.+"position":([0-9]+).+$/\1/')
  time_ms=$(echo $channel_info | sed -E 's/^.+"milliseconds":(-?[0-9]+).+$/\1/')
  time_s=$(echo $channel_info | sed -E 's/^.+"seconds":(-?[0-9]+).+$/\1/')
  time_m=$(echo $channel_info | sed -E 's/^.+"minutes":(-?[0-9]+).+$/\1/')
  time_h=$(echo $channel_info | sed -E 's/^.+"hours":(-?[0-9]+).+$/\1/')
  
  let aux=time_m+60*time_h
  let aux2=time_s+60*$aux
  let totaltimeinms=$time_ms+1000*$aux2
  
  echo "$channel_pos-$totaltimeinms"
}

check_blocking() {
  logd "check_blocking()"
  
  active_player=`get_kodi_info activeplayers`
  active_player_id=$(echo $active_player | sed -E 's/^.+"result":\[(\{"playerid":([0-9]+).*\})?\].+$/\2/')
  
  if [ "$active_player_id" = "1" ]; then
    ch1=`get_channel_time_info`
    sleep 1s
    ch2=`get_channel_time_info`
    
    logd "[1] ch1: $ch1"
    logd "[1] ch2: $ch2"
    
    if [ "$ch1" = "$ch2" ]; then
      sleep 4s
      ch1_2=`get_channel_time_info`
      sleep 1s
      ch2_2=`get_channel_time_info`
      
      logd "[2] ch1: $ch1_2"
      logd "[2] ch2: $ch2_2"
      
      broken_stream=$(echo $ch1 | sed -E 's/^.+-(500)$/1/')
      if [ "$ch1" = "$ch2_2" -a "$broken_stream" != "1" ]; then
        touch $WD_LOCK_FILE
        
        let last_restart_diff=`date +%s`-last_kodi_restart
        if [ $last_restart_diff -lt 60 ]; then
          log "KODI BLOCKED - REBOOT [$ch1]"
          reboot
          exit
        fi
        
        log "KODI BLOCKED - KILLALL [$ch1]"
        last_kodi_restart=`date +%s`
        killall -9 kodi.bin
        # systemctl restart kodi
      fi
    fi
  fi
  
  cpu_info=`get_kodi_info cpuinfo`
  cpu_info_data=$(echo $cpu_info | sed -E 's/^.+"CPU0: ?([0-9]+.?[0-9]+%).+$/\1/')
  
  if [ "$cpu_info_data" = "" ]; then
    logd "CPUINFO EMPTY: $no_cpu_count"
    let no_cpu_count=no_cpu_count+1
  else
    logd "CPUINFO: $cpu_info_data"
    no_cpu_count=0
  fi
  
  if [ $no_cpu_count -gt 10 ]; then
    log "NO CPUINFO - REBOOT"
    reboot
  fi
}

# -----------
check_blocking
