ip_prefix=192.168.2
for i in $(seq 1 254); do
  # echo $ip_prefix.$i
  # ping -c 1 $ip_prefix.$i > /dev/null; a=$?; echo "$a: $ip_prefix.$i"
  # timeout 0.4 ping -c 1 $ip_prefix.$i > /dev/null; a=$?; echo "$a: $ip_prefix.$i"
  timeout 0.4 ping -c 1 $ip_prefix.$i > /dev/null; a=$?; if [ $a == 0 ]; then echo "$a: $ip_prefix.$i"; fi
done
