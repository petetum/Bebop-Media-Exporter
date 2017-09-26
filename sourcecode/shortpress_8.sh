#! /bin/sh
# This script is for PARROT BEBOP and BEBOP 2 Dones.
# Mounting script for recording to USB OTG Drive.
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
	    echo $USBPATH > /tmp/oldusbpath.tmp
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
# make and/or remove the directories in root of USB drive
    if [ ! -d $USBPATH/academy/ ]; then mkdir $USBPATH/academy/; fi
    if [ ! -d $USBPATH/media/ ]; then mkdir $USBPATH/media/; fi
    if [ ! -d $USBPATH/navdata/ ]; then mkdir $USBPATH/navdata/; fi
    if [ ! -d $USBPATH/thumb/ ]; then mkdir $USBPATH/thumb/; fi
    if [ -d $USBPATH/$BBDIR/academy/ ] && [ ! "$(ls -A $USBPATH/$BBDIR/academy/)" ]; then rmdir $USBPATH/$BBDIR/academy/; fi
    if [ -d $USBPATH/$BBDIR/media/ ] && [ ! "$(ls -A $USBPATH/$BBDIR/media/)" ]; then rmdir $USBPATH/$BBDIR/media/; fi
    if [ -d $USBPATH/$BBDIR/navdata/ ] && [ ! "$(ls -A $USBPATH/$BBDIR/navdata/)" ]; then rmdir $USBPATH/$BBDIR/navdata/; fi
    if [ -d $USBPATH/$BBDIR/thumb/ ] && [ ! "$(ls -A $USBPATH/$BBDIR/thumb/)" ]; then rmdir $USBPATH/$BBDIR/thumb/; fi
    if [ -d $USBPATH/$BBDIR/ ] && [ ! "$(ls -A $USBPATH/$BBDIR/)" ]; then rmdir $USBPATH/$BBDIR/; fi
	sync
# Removing junk folders from /data/ftp/
    for directory in $(find /data/ftp/ -maxdepth 1 -type d -regex ".*_[0-9][0-9][0-9]") $(find /data/ftp/ -type d -name "sda" -o -name "sdb" -o -name "sda1" -o -name "sdb1"); do
    if ! (( mount | grep -q $directory )) && [ ! "$(ls -A $directory)" ]; then
        rm -rf $directory
        sync
    fi
    done
fi
}

UNMOUNT () {

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

# Re-mounting USB Drive to external
OLDUSBPATH=$( if [ -f /tmp/oldusbpath.tmp ]; then cat /tmp/oldusbpath.tmp ; fi )

if [ ! $ERROR ] && [ ! -e /dev/sda ] && [ ! -e /dev/sdb ]; then
    echo There is no usb device. Nothing to remount.
    if [ -f /tmp/oldusbpath.tmp ]; then rm -f /tmp/oldusbpath.tmp ;    fi
else
    if [ ! $ERROR ] && [ ! "$( mount | grep '/dev/sda' )" ] && [ ! "$( mount | grep '/dev/sdb' )" ]; then
        if [ ! $OLDUSBPATH ]; then
            OLDUSBPATH=/data/ftp/sda
		fi
        if [ -d $OLDUSBPATH ]; then
            echo Directory already exists $OLDUSBPATH
            echo ""
		else
			echo Creating directory $OLDUSBPATH
            mkdir $OLDUSBPATH
            if [ $? -ne 0 ]; then
                ERROR=1; echo "Cannot create directory!"
            fi

		fi
	fi
    if [ ! $ERROR ] && [ ! -d $OLDUSBPATH ]; then
        echo "Directory doesn't exist! "$OLDUSBPATH
        ERROR=1
    fi
        
    if [ ! $ERROR ] && [ $OLDUSBPATH ];
    then
        echo Re-mounting USB Drive to $OLDUSBPATH
        mount $USBDEV $OLDUSBPATH
        if [ $? -ne 0 ];
        then
            echo "Cannot mount!"
            echo ""
            ERROR=1
        else
            echo Done
        fi
    fi

    if [ ! $ERROR ] && [ -e /dev/sda ]; then
        USBPATH=$( mount | grep '/dev/sda' | awk '{print $3}' )
    elif [ ! $ERROR ] && [ -e /dev/sdb ]; then
        USBPATH=$( mount | grep '/dev/sdb' | awk '{print $3}' )
    fi

    if [ ! $ERROR ] && [ ! -e /dev/sda ] && [ ! -e /dev/sdb ]; then
        echo "USB Drive unplugged"
        ERROR=1
    elif [ ! $ERROR ] && [ ! $USBPATH ];
    then
        echo "USB Drive successfully unmounted but couldn't remounted. It will be available after reboot."
    elif [ ! $ERROR ] && [ $USBPATH == $OLDUSBPATH ];
    then
        echo "USB Drive successfully mounted for as an external drive. "$USBPATH
        if [ -f /tmp/oldusbpath.tmp ]; then rm -f /tmp/oldusbpath.tmp ;    fi
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
