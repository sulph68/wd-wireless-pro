echo
/bin/cat /etc/banner
echo
# get power status
POWER=$(cat /tmp/battery | awk '{ print "Power : "$1",Batt: "$2"%" }')

# get network status
JOINAP=$(/bin/cat /tmp/uplinkAP | awk -F"[ =]" '{ gsub(/"/,"", $2); gsub(/"/,"",$24);print "SSID: "$2",WAN IP: "$24 }')
LOCALIP=$(/sbin/ifconfig br0 | grep "inet addr" | awk -F":" '{print $2}' | awk '{ print "LAN IP: "$1}')
APCLIENTS=$(/usr/local/sbin/get_wifi_ap_clients.sh)
if [ "$APCLIENTS" = "" ]; then
	APCLIENTS="0"
fi
NETWORK="$LOCALIP,$JOINAP,Clients: $APCLIENTS"

# get storage status
ROOTFS=$(/bin/df /dev/root | tail -n1 | awk '{print "RootFS: "$2/1024"MB,Free: "$4/1024"MB,Used  : "$3/1024"MB,Percent: "$5}')
STORAGEFS=$(/bin/df /dev/sda1 | tail -n1 | awk '{print "DiskFS: "$2/1048576"GB,Free: "$4/1048576"GB,Used  : "$3/1048576"GB,Percent: "$5}')
SMART=$(/usr/local/sbin/getSmartStatus.sh)
STORAGE="Root Used: $ROOTFS,Disk Used: $STORAGEFS,SMART: $SMART"

# get CPU status
eval CPUSTATE=$(/usr/sbin/getcpu-freq | head -n 1 | awk -F"mode:" '{ print $2 }')
TEMP=$(/bin/cat /tmp/mcuTemperature | awk '{ print $4 }')
CPU="CPUGov: $CPUSTATE,MCUTemp: ${TEMP} deg"

# get AP config
AP=$(/usr/bin/jq -r -M '."2.4"."ssid",."5"."ssid",."2.4"."security_key"' /tmp/apconfig | tr '\n' ',')
APINFO="SSID 2.4GHz,SSID 5GHz,Security Key,"


# output information
echo -e "\033[1mSystem Information:\033[0m"
echo -e "$POWER,$CPU\n$ROOTFS\n$STORAGEFS\n$NETWORK" | column -s, -o" | " -t
echo
echo -e "\033[1mDevice Hotspot Information:\033[0m"
echo -e "$APINFO\n$AP" | column -s, -o" | " -t
echo
echo -e "\033[1mCurrent time is:\033[0m $(/bin/date), Welcome!"
echo
