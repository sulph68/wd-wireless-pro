echo
/bin/cat /etc/banner
echo
# get power status
POWER=$(cat /tmp/battery | awk '{ print "Power : "$1",Batt: "$2"%" }')
CPU=$(uptime| awk '{ gsub(/\s+/," ",$0);print $0 }')
UPTIME=$(echo "${CPU}" | awk -F, '{ print $1 }' | awk '{print $3}')
LOAD=$(echo "${CPU}" | awk -F, '{ print $3 }' | awk '{print $3}')
LOGGEDIN=$(echo "${CPU}" | awk -F, '{ print $2 }' | awk '{print $1}')
MEMUSED=$(free | head -n2 | tail -n1 | awk '{print ($2-$7)/$2*100"%"}')
CPUSTATUS="Uptime: ${UPTIME},Load: ${LOAD},MemUse: ${MEMUSED},Logins :${LOGGEDIN}"

# get network status
JOINAP=$(iwconfig wlan1 | grep ESSID | awk '{gsub(/\s+/," ",$0);print $0;}' | awk '{gsub(/"/,"",$4); print $4}' | awk -F: '{print "SSID: "$2}')
LOCALIP=$(/sbin/ifconfig br0 | grep "inet addr" | awk -F":" '{print $2}' | awk '{ print "LAN IP: "$1}')
WANIP=$(/sbin/ifconfig wlan1 | grep "inet addr" | awk -F":" '{print $2}' | awk '{ print "WAN IP: "$1}')
APCLIENTS=$(/usr/local/sbin/get_wifi_ap_clients.sh | wc -l)
if [ "$APCLIENTS" = "" ]; then
	APCLIENTS="0"
fi
NETWORK="$LOCALIP,$JOINAP,$WANIP,Clients: $APCLIENTS"

# get storage status
ROOTFS=$(/bin/df /dev/root | tail -n1 | awk '{print "RootFS: "$2/1024"MB,Free: "$4/1024"MB,Used  : "$3/1024"MB,Percent: "$5}')
STORAGEFS=$(/bin/df /dev/sda1 | tail -n1 | awk '{print "DiskFS: "$2/1048576"GB,Free: "$4/1048576"GB,Used  : "$3/1048576"GB,Percent: "$5}')
SMART=$(/usr/local/sbin/getSmartStatus.sh)
STORAGE="Root Used: $ROOTFS,Disk Used: $STORAGEFS,SMART: $SMART"

# get CPU status
eval CPUSTATE=$(/usr/sbin/getcpu-freq | head -n 1 | awk -F"mode:" '{ print $2 }')
TEMP=$(/bin/cat /tmp/mcuTemperature | awk '{ print int(($1+$2+$3+$4)/4) }')
CPU="CPUGov: $CPUSTATE,MCUTemp: ${TEMP} deg"

# get AP config
AP=$(/usr/bin/jq -r -M '."2.4"."ssid",."5"."ssid",."2.4"."security_key"' /tmp/apconfig | tr '\n' ',')
APINFO="SSID 2.4GHz,SSID 5GHz,Security Key,"


# output information
# echo -e "\033[1mSystem Information:\033[0m"
echo "System Information:"
echo -e "$POWER,$CPU\n$CPUSTATUS\n$ROOTFS\n$STORAGEFS\n$NETWORK" | column -s, -o" | " -t
echo

# echo -e "\033[1mDevice Hotspot Information:\033[0m"
echo "Device Hotspot Information:"
echo -e "$APINFO\n$AP" | column -s, -o" | " -t
echo

# echo -e "\033[1mCurrent time is:\033[0m $(/bin/date), Welcome!"
echo -e "Current time is: $(/bin/date), Welcome!"
echo
