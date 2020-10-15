#!/bin/bash

# Listens for remote buttons via CEC on Raspbian

# sudo apt install cec-utils
# sudo apt-get install xosd-bin xdotool

# Run in Raspbian graphical mode
# Navigate with Up, Right, Down, Left, OK, Back

# List of xdotool keys: https://gitlab.com/cunidev/gestures/-/wikis/xdotool-list-of-key-codes


VERBOSE=0
# VERBOSE=1

type cec-client &>/dev/null || { echo "cec-client is requiered"; exit; }
type xdotool    &>/dev/null || NOXDOTOOL=#
 
function      echov(){ [[ "$VERBOSE" == "1" ]] && echo $@                              ; }
function filter_key(){ grep -q "key pressed: $1 .* duration" <( echo "$2" )            ; }


while :; do 
  cec-client | while read l; do
    echov $l
    
    if filter_key "select" "$l"; then
      echo "== [SELECT]"
      xdotool key Return
    fi
    if filter_key "exit" "$l"; then
      echo "== [EXIT]"
      xdotool key BackSpace
    fi
    
    if filter_key "up" "$l"; then
      echo "== [UP]"
      xdotool key Up
    fi
    if filter_key "right" "$l"; then
      echo "== [RIGHT]"
      xdotool key Right
    fi
    if filter_key "down" "$l"; then
      echo "== [DOWN]"
      xdotool key Down
    fi
    if filter_key "left" "$l"; then
      echo "== [LEFT]"
      xdotool key Left
    fi
  done
done
