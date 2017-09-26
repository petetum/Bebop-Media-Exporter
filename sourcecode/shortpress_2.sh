#! /bin/sh
# This script is for PARROT BEBOP and BEBOP 2 Dones.
# Forcing GPS cold start
# v1.4.1 by PeteTum 26/09/2017
#
# Written by PeteTum.
# http://youtube.com/c/PeteTum
# To download full installer go to https://github.com/petetum/Bebop-Media-Exporter/

# debug
echo "Script version: v1.4.1"
echo "Bebop Hardware: "$(grep Hardware /proc/cpuinfo)
echo "Firmware version: "$(gprop ro.parrot.build.version)
echo
echo "Contents of /data/ftp"
ls -x /data/ftp
echo
echo "List of devices starting with /dev/sd"
ls -x /dev/sd*
echo "-------------------------------------------------------"
echo "-------------------------------------------------------"
echo

# detect hardware
BBDIR=$( if grep -q Mykonos3 /proc/cpuinfo; then echo Bebop_Drone; elif grep -q Milos /proc/cpuinfo; then echo Bebop_2; fi )

# set user feedback
if grep -q Milos /proc/cpuinfo; then
    super_led=/sys/class/leds/milos\:super_led
fi
SOUND_STA() { i2ctool -d /dev/i2c-cypress 0x8 0x82 0x1 >/dev/null 2>&1; usleep 1000000; }
SOUND_ERR() { i2ctool -d /dev/i2c-cypress 0x8 0x82 0x2 >/dev/null 2>&1; usleep 600000; }
LIGHT_RED() { BLDC_Test_Bench -G 1 0 0 >/dev/null 2>&1; }
LIGHT_ORN() { BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1; }
LIGHT_GRN() { BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1; }
LIGHT_LIT() { echo 60 > $super_led/brightness; }
LIGHT_BLK() { echo 0 > $super_led/brightness; }
LIGHT_ERR() { sprop "system.ready" "1"; sleep 1; sprop "system.ready" "0"; }
FB_START() { if [ $BBDIR == "Bebop_2" ]; then sprop "system.ready" "1"; LIGHT_LIT; else LIGHT_RED; fi; }
FB_WORKING() {
# starting heartbeat
    touch /tmp/heartbeat.tmp
    ( while [ -f /tmp/heartbeat.tmp ]; do
        if [ $BBDIR == "Bebop_2" ];
            then LIGHT_BLK; usleep 50000; LIGHT_LIT; usleep 50000; LIGHT_BLK; usleep 50000; LIGHT_LIT
            else LIGHT_GRN; usleep 50000; LIGHT_ORN; usleep 50000; LIGHT_GRN; usleep 50000; LIGHT_ORN
        fi
        usleep 800000;
    done )
}
FB_DONE () {
# stopping heartbeat
rm -f /tmp/heartbeat.tmp
sleep 1
if [ $BBDIR == "Bebop_2" ]
    then SOUND_STA; LIGHT_LIT
    else SOUND_STA; LIGHT_GRN
fi
}
FB_ERROR () { 
# stopping heartbeat
rm -f /tmp/heartbeat.tmp
sleep 1
if [ $BBDIR == "Bebop_2" ]; 
    then ( CS=0; while [ $CS -lt 5 ]; do SOUND_ERR; let CS=$CS+1; done ) & ( CL=0; while [ $CL -lt 20 ]; do LIGHT_LIT; usleep 50000; LIGHT_BLK; usleep 5000; let CL=$CL+1; done; sleep 1; LIGHT_LIT; sleep 1; LIGHT_ERR; )
    else ( CS=0; while [ $CS -lt 5 ]; do SOUND_ERR; let CS=$CS+1; done ) & ( CL=0; while [ $CL -lt 20 ]; do LIGHT_GRN; usleep 50000; LIGHT_RED; usleep 5000; let CL=$CL+1; done )
fi 
}

FB_START
sleep 1
FB_WORKING &

if [ ! $BBDIR ]; then
	echo "Hardware NOT compatible."
	ERROR=1;
else
	echo "Hardware compatible."
	echo
	echo “Cold Resetting GPS”
	echo “Cold Resetting GPS” | logger -s -t “LongPress” -p user.info
	echo -e "$PERDAPI,STOP*6F" > /dev/ttyPA1
	echo -e "$PERDAPI,START,COLD*1F" > /dev/ttyPA1
fi

# user feedback
if [ $ERROR -eq 1 ]; then
	FB_ERROR
else
	FB_DONE
fi
