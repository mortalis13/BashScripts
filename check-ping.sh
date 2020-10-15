#!/bin/sh

# ./check-ping.sh _ips.txt |& tee _log-ping

print_help() {
  echo "Syntax: [script].sh [ips].txt"
  echo
}

if test $# -lt 1; then
  print_help
  exit
fi


# =======================
IPS_FILE=$1

RED='\e[31;1m'
GREEN='\e[92m'
NC='\e[0m'

step_id=0
total_lines=`wc -l < $IPS_FILE`

for i in $(cat $IPS_FILE); do
  let step_id=step_id+1
  
  ping -c 1 $i > /dev/null
  host_avail=$?
  if [ "$host_avail" != 0 ]; then
    printf "[$step_id/$total_lines]${RED} - No Ping '$i' ${NC}\n"
  else
    printf "[$step_id/$total_lines]${GREEN} - Ping OK '$i' ${NC}\n"
  fi
done

printf "Finish\n"
