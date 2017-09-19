#! /bin/sh
# This script is for PARROT BEBOP and BEBOP 2 Dones.
# Forcing GPS cold start
# v1.4a by PeteTum 12/08/2017
#
# Written by PeteTum.
# http://youtube.com/c/PeteTum
# To download full installer go to https://goo.gl/Hbpgu1
#
# Special thanks for the Unofficial Bebop Hacking Guide (UBHG)
# https://github.com/nicknack70/bebop

# debug
echo "------------------------ DEBUG ------------------------"
echo "Script version: v1.4a"
grep Hardware /proc/cpuinfo
echo "Firmware version "$(cat /version.txt)
echo
echo "Contents of /data/ftp"
ls -x /data/ftp
echo
echo "List of devices starting with /dev/sd"
ls -x /dev/sd*
echo "-------------------------------------------------------"
echo

# detect hardware
BBDIR=$( if grep -q Mykonos3 /proc/cpuinfo; then echo Bebop_Drone; elif grep -q Milos /proc/cpuinfo; then echo Bebop_2; fi )

# set user feedback
LIGHT_R() { BLDC_Test_Bench -G 1 0 0 >/dev/null; }
LIGHT_O() { BLDC_Test_Bench -G 1 1 0 >/dev/null; }
LIGHT_G() { BLDC_Test_Bench -G 0 1 0 >/dev/null; }
LIGHT_LIT() { sprop "system.shutdown" "0" >/dev/null; }
LIGHT_FLA() { sprop "system.shutdown" "1" >/dev/null; }

if [ ! $BBDIR ]; then
echo "Hardware NOT compatible."
else
echo "Hardware compatible."
(if [ $BBDIR == "Bebop_2" ];
	then LIGHT_FLA; usleep 50000; LIGHT_LIT; usleep 50000; LIGHT_FLA; usleep 50000; LIGHT_LIT; LIGHT_FLA; usleep 50000; LIGHT_LIT; usleep 50000; LIGHT_FLA; usleep 50000; LIGHT_LIT; LIGHT_FLA; usleep 50000; LIGHT_LIT; usleep 50000; LIGHT_FLA; usleep 50000; LIGHT_LIT; usleep 800000; LIGHT_LIT;
	else LIGHT_G; usleep 50000; LIGHT_O; usleep 50000; LIGHT_G; usleep 50000; LIGHT_O; usleep 800000; LIGHT_G; usleep 50000; LIGHT_O; usleep 50000; LIGHT_G; usleep 50000; LIGHT_O; usleep 800000; LIGHT_G; usleep 50000; LIGHT_O; usleep 50000; LIGHT_G; usleep 50000; LIGHT_O; usleep 800000; LIGHT_G;
fi) &

echo “Cold Resetting GPS”
echo “Cold Resetting GPS” | logger -s -t “LongPress” -p user.info
echo -e "$PERDAPI,STOP*6F" > /dev/ttyPA1
echo -e "$PERDAPI,START,COLD*1F" > /dev/ttyPA1
fi
