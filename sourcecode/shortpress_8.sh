#! /bin/sh
# This script is for PARROT BEBOP and BEBOP 2 Dones.
# Mounting script for recording to USB OTG Drive.
# v1.4a by PeteTum 12/08/2017
#
# Written by PeteTum.
# http://youtube.com/c/PeteTum
# To download full installer go to https://goo.gl/Hbpgu1
#
# Special thanks for https://github.com/Daggers/
# https://github.com/Daggers/Bebop2CopyMoveRecord2USBDrive

# set user feedback
if [ $BBDIR == "Bebop_2" ]; then
	led=/sys/devices/platform/leds_pwm/leds/milos:super_led/brightness
	ob=$(cat $led)
fi
SOUND_STA() { BLDC_Test_Bench -M 1 >/dev/null 2>&1; usleep 1000000; }
SOUND_ERR() { BLDC_Test_Bench -M 2 >/dev/null 2>&1; usleep 800000; }
LIGHT_RED() { BLDC_Test_Bench -G 1 0 0 >/dev/null 2>&1; }
LIGHT_ORN() { BLDC_Test_Bench -G 1 1 0 >/dev/null 2>&1; }
LIGHT_GRN() { BLDC_Test_Bench -G 0 1 0 >/dev/null 2>&1; }
LIGHT_LIT() { echo 60 > $led; }
LIGHT_BLK() { echo 0 > $led; }
LIGHT_OLD() { echo ${ob} > $led; }
FB_START() { if [ $BBDIR == "Bebop_2" ]; then LIGHT_LIT; else LIGHT_RED; fi; }
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
if [ $BBDIR == "Bebop_2" ]
	then SOUND_STA; LIGHT_OLD
	else SOUND_STA; LIGHT_GRN
fi
}
FB_ERROR () { 
# stopping heartbeat
rm -f /tmp/heartbeat.tmp
if [ $BBDIR == "Bebop_2" ]; 
	then ( CS=0; while [ $CS -lt 5 ]; do SOUND_ERR; let CS=$CS+1; done ) & ( CL=0; while [ $CL -lt 20 ]; do LIGHT_LIT; usleep 50000; LIGHT_BLK; usleep 5000; let CL=$CL+1; done; LIGHT_OLD; )
	else ( CS=0; while [ $CS -lt 5 ]; do SOUND_ERR; let CS=$CS+1; done ) & ( CL=0; while [ $CL -lt 20 ]; do LIGHT_GRN; usleep 50000; LIGHT_RED; usleep 5000; let CL=$CL+1; done )
fi 
}


# internal memory location
INTPATH=/data/ftp/internal_000

# detect hardware and set BBDIR
BBDIR=$( if grep -q Mykonos3 /proc/cpuinfo; then echo Bebop_Drone; elif grep -q Milos /proc/cpuinfo; then echo Bebop_2; fi )

# user feedback
#FB_START
#sleep 1
FB_WORKING &

if [ "$( mount | grep '/dev/sda' )" ]; then
# USB OTG drive path
	USBPATH=$( mount | grep '/dev/sda' | awk '{print $3}' )
# USB OTG drive hardware
	USBDEV=$( mount | grep '/dev/sda' | awk '{print $1}' )
elif [ "$( mount | grep '/dev/sdb' )" ]; then
# USB OTG drive path
	USBPATH=$( mount | grep '/dev/sdb' | awk '{print $3}' )
# USB OTG drive hardware
	USBDEV=$( mount | grep '/dev/sdb' | awk '{print $1}' )
elif [ -e /dev/sda ] && [ "$( blkid /dev/sda | grep 'vfat' )" ]; then
	USBDEV=$( blkid /dev/sda | grep 'vfat' | awk -F ':' '{print $1}' )
elif [ -e /dev/sdb ] && [ "$( blkid /dev/sdb | grep 'vfat' )" ]; then
	USBDEV=$( blkid /dev/sdb | grep 'vfat' | awk -F ':' '{print $1}' )
fi




MOUNT () {
# Checks...
if [ ! $BBDIR ]; then
	ERROR=1; echo "Hardware NOT compatible."
elif [ ! $USBDEV ]; then
	ERROR=1; echo There is no usb device.
else
	echo "All tests O.K."
fi

# Unmounting USB Drive
if [ ! $ERROR ] && [ $USBPATH ] ;
then
	echo Unmounting USB Drive
	umount $USBPATH
	if [ $? -ne 0 ];
	then
		echo "Cannot unmount!"
		echo ""
		ERROR=1
	else
		echo Done
	fi
fi

# Re-mounting USB Drive to $INTMEM/$BBDIR
if [ ! $ERROR ] && [ $USBDEV ];
then
	echo Re-mounting USB Drive to $INTPATH/$BBDIR
	mount $USBDEV $INTPATH/$BBDIR
	if [ $? -ne 0 ];
	then
		echo "Cannot mount!"
		echo ""
		ERROR=1
	fi
fi

if [ ! $ERROR ] && [ -e /dev/sda ]; then
	OLDUSBPATH=$USBPATH 
	USBPATH=$( mount | grep '/dev/sda' | awk '{print $3}' )
elif [ ! $ERROR ] && [ -e /dev/sdb ]; then
	OLDUSBPATH=$USBPATH 
	USBPATH=$( mount | grep '/dev/sdb' | awk '{print $3}' )
fi

if [ ! $ERROR ] && [ ! $USBPATH ];
then
	echo "USB Drive unplugged"
	ERROR=1
elif [ ! $ERROR ] && [ ! $USBPATH == "$INTPATH/$BBDIR" ];
then
	echo "Failed to mount USB Drive for direct recordning."
	ERROR=1
elif [ ! $ERROR ];
then
	echo "USB Drive successfully mounted for direct recording."
if [ -d $OLDUSBPATH ] && [ ! "$(ls -A $OLDUSBPATH)" ]; then sleep 1; rm -rf $OLDUSBPATH; fi

# Creating folders on the USB drive.
	if [ ! -d $USBPATH/academy/ ]; then	mkdir $USBPATH/academy/; echo academy folder created; fi
	if [ ! -d $USBPATH/media/ ];   then mkdir $USBPATH/media/;   echo media folder created; fi
	if [ ! -d $USBPATH/navdata/ ]; then mkdir $USBPATH/navdata/; echo navdata folder created; fi
	if [ ! -d $USBPATH/thumb/ ];   then	mkdir $USBPATH/thumb/;   echo thumb folder created; fi
sync

fi
}

UNMOUNT () {
OLDUSBPATH=$( if [ -f /tmp/oldusbpath.tmp ]; then cat /tmp/oldusbpath.tmp ; fi )

# Checks...
if [ ! $BBDIR ]; then
	ERROR=1; echo "Hardware NOT compatible."
elif [ ! $USBPATH ]; then
	ERROR=1; echo "USB drive not mounted"
else
	echo "All tests O.K."
fi

# Unmounting USB Drive
if [ ! $ERROR ];
then
	echo Unmounting USB Drive
	umount $INTPATH/$BBDIR
	if [ $? -ne 0 ];
	then
		echo "Cannot unmount!"
		echo ""
		ERROR=1
	fi
fi

}

if [ ! $USBDEV ]; then
	echo USB device is not present.
	ERROR=1
elif [ $USBDEV ] && [ ! $( echo $USBPATH | grep "internal_000" ) ]; then
	echo usbpath is not in internal memory
	doing=mount
	MOUNT
elif [ $( echo $USBPATH | grep "internal_000" ) ]; then
	echo usb is already internal
	doing=unmount
	UNMOUNT
fi

# user feedback
if [ $ERROR ]; then
	FB_ERROR
elif [ $doing = "mount" ]; then
	FB_DONE
elif [ $doing = "unmount" ]; then
	FB_DONE
	FB_DONE
fi
