#!/bin/sh

# ./check-md5.sh _ips.txt |& tee _log-md5

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

RPI_PASS=libreelec
FILES_DIR=addons

RED='\e[31;1m'
GREEN='\e[92m'
NC='\e[0m'

step_id=0
total_lines=`wc -l < $IPS_FILE`

for i in $(cat $IPS_FILE); do
  echo
  let step_id=step_id+1
  echo "[$step_id/$total_lines] IP: '$i'"
  
  COPY_SUCCESS=true
  for f in $(find $FILES_DIR -type f); do
    echo "FILE: '$f'"
    
    MD5SUM_LOC=`md5sum $f`
    MD5SUM_LOC=`echo "${MD5SUM_LOC% *}"`
    echo "MD5SUM_LOC: $MD5SUM_LOC"
    
    MD5SUM_REM=`/usr/bin/sshpass -p $RPI_PASS ssh -oStrictHostKeyChecking=no root@$i "md5sum /storage/.kodi/$f"`
    MD5SUM_REM=`echo "${MD5SUM_REM% *}"`
    echo "MD5SUM_REM: $MD5SUM_REM"
    
    if [ $MD5SUM_LOC = $MD5SUM_REM ]; then
      printf "md5 --> ${GREEN}OK${NC}\n"
    else
      printf "md5 --> ${RED}FAIL${NC}\n"
      COPY_SUCCESS=false
    fi
    echo
  done
  
  if [ $COPY_SUCCESS = true ]; then
    printf "${GREEN}Files match${NC}\n"
  else
    printf "${RED}Files don't match${NC}\n"
  fi
  
  echo == $i$'\n'
done
