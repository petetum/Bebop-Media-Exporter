#! /bin/sh
# This script is for PARROT BEBOP and BEBOP 2 Dones.
# Moving media files from internal memory to USB OTG Drive.
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

REMOVE_TMP_FILES () {
    for filetoremove in $1 $2 $3 $4 $5 $6; do
        if [ $filetoremove ] && [ -f $filetoremove ]; then
            echo $filetoremove" exists. Removing.."
            rm -f $filetoremove
        fi
    done
}

MD5CHECK () {
    sync
    echo 3 > /proc/sys/vm/drop_caches
    source_md5=$(md5sum $1 | awk '{print $1}')
    echo "MD5 hash of the source file:      "$source_md5
    dest_md5=$(md5sum $2 | awk '{print $1}')
    echo "MD5 hash of the destenation file: "$dest_md5
    if [ $source_md5 ] && [ $dest_md5 ] && [ "$source_md5" = "$dest_md5" ];
    then
        return 0
    else
        return 1
    fi
}

FIXENCAPS () {
    echo ""
    echo "Begin to scan USB drive for broken encaps files."
    if [ ! "$(find $USBPATH/media/ -type f -name '*.mp4-encaps.tmp')" ] ; 
    then
        echo "NO broken files found."
        echo ""
    else
        for ENCAPSFILE in $(find $USBPATH/media/ -type f -name '*.mp4-encaps.tmp'); do
            ENCAPSFILE=$(echo $ENCAPSFILE | awk -F / '{print $NF}' )
            DATFILE=$(echo $ENCAPSFILE | awk -F .mp4-encaps.tmp '{print $(1)}' ).mp4-encaps.dat
            THUMBFILE=$(echo $ENCAPSFILE | awk -F .mp4-encaps.tmp '{print $(1)}' ).mp4.jpg
            echo "";
            echo "------------------------------------------------------------------"
            echo "Processing: "$ENCAPSFILE
# checking free space
            echo "";
            echo "Begin to check available space for the .mp4-encaps.tmp and .mp4-encaps.dat files."
            ENCAPSFILESIZE=$(($(ls -l $USBPATH/media/$ENCAPSFILE | awk '{print $(5)}')/1024))
            DATFILESIZE=$(($(ls -l $USBPATH/media/$DATFILE | awk '{print $(5)}')/1024))
            THUMBFILESIZE=$(($(ls -l $USBPATH/thumb/$THUMBFILE | awk '{print $(5)}')/1024))
            INTMEMFREESPACE=$(df | grep $INTPATH | awk '{print $(NF-2)}')
            if [ $(($ENCAPSFILESIZE+$DATFILESIZE+$THUMBFILESIZE)) -gt $INTMEMFREESPACE ];
            then
# NOT ENOUGH SPACE
                echo "There is NOT enough space on internal memory."
            else
# THERE IS ENOUGH SPACE
                echo "There is enough space. ( "$ENCAPSFILESIZE" + "$DATFILESIZE" + "$THUMBFILESIZE" vs "$INTMEMFREESPACE" )"
                echo "";
# copy ENCAPSFILE to INTPATH
                echo "Copy the .mp4-encaps.tmp file to internal memory as a .temp file."
                cp -f $USBPATH/media/$ENCAPSFILE $INTPATH/$BBDIR/media/$ENCAPSFILE.temp
                if [ $? -ne 0 ];
                then
                    echo "Copy Failed!"
                    echo ""
                    REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
                echo "The file copied successfully.";
                echo ""
# MD5 check ENCAPSFILE
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "Checking MD5.."
                    MD5CHECK $USBPATH/media/$ENCAPSFILE $INTPATH/$BBDIR/media/$ENCAPSFILE.temp
                    if [ $? -ne 0 ];
                    then
                        echo "MD5 doesn't match."
                        echo ""
                        REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
# copy DATFILE to INTPATH
                echo "Copy the .mp4-encaps.dat file to internal memory as a .temp file."
                cp -f $USBPATH/media/$DATFILE $INTPATH/$BBDIR/media/$DATFILE.temp
                if [ $? -ne 0 ];
                then
                    echo "copy of DATFILE file failed. begin to remove .temp file"
                    REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
                echo "The file copied successfully.";
# MD5 check DATFILE
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "Checking MD5.."
                    MD5CHECK $USBPATH/media/$DATFILE $INTPATH/$BBDIR/media/$DATFILE.temp
                    if [ $? -ne 0 ];
                    then
                        echo "MD5 doesn't match."
                        echo ""
                    REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
# copy THUMBFILE to INTPATH
                echo "Copy the thumb file to internal memory as a .temp file."
                cp -f $USBPATH/thumb/$THUMBFILE $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                if [ $? -ne 0 ];
                then
                    echo "copy of THUMBFILE file failed. begin to remove .temp file"
                    REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
                echo "The file copied successfully.";
# MD5 check THUMBFILE
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "Checking MD5.."
                    MD5CHECK $USBPATH/thumb/$THUMBFILE $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                    if [ $? -ne 0 ];
                    then
                        echo "MD5 doesn't match."
                        echo ""
                    REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
# renaming .temp files
            echo "Renameing .temp files."
            mv -f $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$ENCAPSFILE
            if [ $? -ne 0 ];
            then
                echo Error when renaming .temp file.
                REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                ERROR=1
                echo "Braking the file processing loop."
                break
            fi
            mv -f $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/media/$DATFILE
            if [ $? -ne 0 ];
            then
                echo Error when renaming .temp file.
                REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                ERROR=1
                echo "Braking the file processing loop."
                break
            fi
            mv -f $INTPATH/$BBDIR/thumb/$THUMBFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE
            if [ $? -ne 0 ];
            then
                echo Error when renaming .temp file.
                REMOVE_TMP_FILES $INTPATH/$BBDIR/media/$ENCAPSFILE.temp $INTPATH/$BBDIR/media/$DATFILE.temp $INTPATH/$BBDIR/thumb/$THUMBFILE.temp
                ERROR=1
                echo "Braking the file processing loop."
                break
            fi
            echo "";
# removing original files from usb drive
            echo "begin to remove original media and thumb files from internal memory"
            if [ -f $USBPATH/media/$ENCAPSFILE ];
            then
                rm -f $USBPATH/media/$ENCAPSFILE
            fi
            if [ -f $USBPATH/media/$DATFILE ];
            then
                rm -f $USBPATH/media/$DATFILE
            fi
            if [ -f $USBPATH/thumb/$THUMBFILE ];
            then
                rm -f $USBPATH/thumb/$THUMBFILE
            fi
            echo "remove complete (in theory). no check has been done if remove was successful"
            echo "";
        fi
        sync
    done
fi
}

MOVEMEDIA () {
echo ""
echo "Begin to scan internal memory for $1 files."
if [ ! "$(find $INTPATH/$BBDIR/media/ -type f -name '*.'$1)" ] ; 
then
    echo "NO $1 files found."
else
    for MEDIA in $(find $INTPATH/$BBDIR/media/ -type f -name '*.'$1); do
        MEDIA=$(echo $MEDIA | awk -F / '{print $NF}' )
        THUMB=$(echo $MEDIA | awk -F .dng '{print $(1)}' | awk -F .jpg '{print $(1)}' ).jpg
        PUD=$( find $INTPATH/$BBDIR/navdata/ -type f -name *$( echo $MEDIA | awk -F . '{print $(NF-1)}' | awk -F $BBDIR '{print $(NF)}').pud | awk -F / '{print $NF}' )
        DNGPLUS=$(echo $MEDIA | awk -F .dng '{print $(NF-1)}').jpg
        echo "";
        echo "------------------------------------------------------------------"
        echo "processing: "$MEDIA
# checking free space
        echo "";
        echo "will begin to check available space for the THUMB AND MEDIA (and jpg that comes with dng) files"
        MEDIASIZE=$(($(ls -l $INTPATH/$BBDIR/media/$MEDIA | awk '{print $(5)}')/1024))
        USBFREESPACE=$(df | grep $USBPATH | awk '{print $(NF-2)}')
        if [ $PUD ] && [ -f $INTPATH/$BBDIR/navdata/$PUD ];
        then
            PUDSIZE=$(($(ls -l $INTPATH/$BBDIR/navdata/$PUD | awk '{print $(5)}')/1024))
        else
            PUDSIZE=0
        fi
        if [ $DNGPLUS ] && [ -f $INTPATH/$BBDIR/media/$DNGPLUS ];
        then
            DNGPLUSSIZE=$(($(ls -l $INTPATH/$BBDIR/media/$DNGPLUS | awk '{print $(5)}')/1024))
        else
            DNGPLUSSIZE=0
        fi
        if [ -f $INTPATH/$BBDIR/thumb/$THUMB ];
        then
            THUMBSIZE=$(($(ls -la $INTPATH/$BBDIR/thumb/$THUMB | awk '{print $(5)}')/1024))
        else
            THUMBSIZE=0
        fi
        if [ $(($PUDSIZE+$THUMBSIZE+$MEDIASIZE+$DNGPLUSSIZE)) -gt $USBFREESPACE ];
        then
# NOT ENOUGH SPACE
            echo "not enough room on USB drive"
            echo "making note of the error. set ERROR varialbe to 1"
            ERROR=1
        else
# THERE IS ENOUGH SPACE
        echo "there is enough space PUDSIZE + THUMBSIZE + MEDIASIZE + DNGPLUSSIZE = TOTAL"
        echo "                      "$PUDSIZE"+"$THUMBSIZE"+"$MEDIASIZE"+"$DNGPLUSSIZE"="$(($PUDSIZE+$THUMBSIZE+$MEDIASIZE+$DNGPLUSSIZE))
        echo "                      AVAILABLE FREE SPACE: "$USBFREESPACE
        echo "";
# copy PUD to USBPATH
            if [ -f $INTPATH/$BBDIR/navdata/$PUD ]; 
            then
                echo "pud exists. now begin to copy pud file to USB drive as a .tmp file"
                cp -f $INTPATH/$BBDIR/navdata/$PUD $USBPATH/navdata/$PUD.tmp
                if [ $? -ne 0 ];
                then
                    echo "copy of pud file to USB failed. begin to remove .tmp file"
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
                echo "pud copied successfully";
# MD5 check PUD
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "begin to check MD5"
                    MD5CHECK $INTPATH/$BBDIR/navdata/$PUD $USBPATH/navdata/$PUD.tmp
                    if [ $? -eq 1 ];
                    then
                        echo "MD5 doesn't match"
                        REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                        echo "making note of the error. set ERROR varialbe to 1"
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
            fi
# copy thumb to USBPATH
            if [ -f $INTPATH/$BBDIR/thumb/$THUMB ]; 
            then
                echo "thumb exists. now begin to copy thumb file to USB drive as a .tmp file"
                cp -f $INTPATH/$BBDIR/thumb/$THUMB $USBPATH/thumb/$THUMB.tmp
                if [ $? -ne 0 ];
                then
                    echo "copy of thumb file to USB failed. begin to remove .tmp file"
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
                echo "thumb copied successfully";
# MD5 check thumb
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "begin to check MD5"
                    MD5CHECK $INTPATH/$BBDIR/thumb/$THUMB $USBPATH/thumb/$THUMB.tmp
                    if [ $? -eq 1 ];
                    then
                        echo "MD5 doesn't match"
                        REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                        echo "making note of the error. set ERROR varialbe to 1"
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
            fi
            
            
# copy media to USBPATH
            echo "will begin to copy media file to usb dive as a .tmp file"
            cp -f $INTPATH/$BBDIR/media/$MEDIA $USBPATH/media/$MEDIA.tmp
            if [ $? -ne 0 ];
            then
                echo "copy of media file to USB failed. begin to remove .tmp file"
                REMOVE_TMP_FILES $THUMB $MEDIA
                echo "making note of the error. set ERROR varialbe to 1"
                ERROR=1
                echo "Braking the file processing loop."
                break
            fi
# MD5 check media
            if [ -f /data/ftp/md5check_on ];
            then
                echo "begin to check MD5"
                MD5CHECK $INTPATH/$BBDIR/media/$MEDIA $USBPATH/media/$MEDIA.tmp
                if [ $? -eq 1 ];
                then
                    echo "MD5 doesn't match"
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                else
                    echo "MD5 hash match."
                    echo "";
                fi
            fi
# copy DNGPLUS to USBPATH
            if [ -f $DNGPLUS ];
            then
                echo "will begin to copy DNGPLUS file to usb dive as a .tmp file"
                cp -f $INTPATH/$BBDIR/media/$DNGPLUS $USBPATH/media/$DNGPLUS.tmp
                if [ $? -ne 0 ];
                then
                    echo "copy of dngplus file to USB failed. begin to remove .tmp file"
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
# MD5 check DNGPLUS
                if [ -f /data/ftp/md5check_on ];
                then
                    echo "begin to check MD5"
                    MD5CHECK $INTPATH/$BBDIR/media/$DNGPLUS $USBPATH/media/$DNGPLUS.tmp
                    if [ $? -eq 1 ];
                    then
                        echo "MD5 doesn't match"
                        REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                        echo "making note of the error. set ERROR varialbe to 1"
                        ERROR=1
                        echo "Braking the file processing loop."
                        break
                    else
                        echo "MD5 hash match."
                        echo "";
                    fi
                fi
            fi
# renaming .tmp files
            echo "rename media .tmp file on the USB drive"
            mv -f $USBPATH/media/$MEDIA.tmp $USBPATH/media/$MEDIA
            if [ $? -ne 0 ];
            then
                echo Error when renaming media .tmp file on USB drive.
                REMOVE_TMP_FILES $THUMB $MEDIA
                echo "making note of the error. set ERROR varialbe to 1"
                ERROR=1
                echo "Braking the file processing loop."
                break
            fi
            if [ -f $USBPATH/thumb/$THUMB.tmp ]; 
            then
                echo "rename thumb .tmp on USB drive"
                mv -f $USBPATH/thumb/$THUMB.tmp $USBPATH/thumb/$THUMB
                if [ $? -ne 0 ];
                then
                    echo Error when renaming thumb .tmp file on USB drive.
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
            fi
            if [ -f $USBPATH/media/$DNGPLUS.tmp ]; 
            then
                echo "rename DNGPLUS .tmp on USB drive"
                mv -f $USBPATH/media/$DNGPLUS.tmp $USBPATH/media/$DNGPLUS
                if [ $? -ne 0 ];
                then
                    echo Error when renaming DNGPLUS .tmp file on USB drive.
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
            fi
            if [ -f $USBPATH/navdata/$PUD.tmp ]; 
            then
                echo "rename pud .tmp on USB drive"
                mv -f $USBPATH/navdata/$PUD.tmp $USBPATH/navdata/$PUD
                if [ $? -ne 0 ];
                then
                    echo Error when renaming pud .tmp file on USB drive.
                    REMOVE_TMP_FILES $USBPATH/media/$MEDIA.tmp $USBPATH/thumb/$THUMB.tmp $USBPATH/navdata/$PUD.tmp $USBPATH/media/$DNGPLUS.tmp
                    echo "making note of the error. set ERROR varialbe to 1"
                    ERROR=1
                    echo "Braking the file processing loop."
                    break
                fi
            fi
            echo "";
# removing original files from internal memory
            echo "begin to remove original media and thumb files from internal memory"
            if [ -f $INTPATH/$BBDIR/thumb/$THUMB ];
            then
                rm -f $INTPATH/$BBDIR/thumb/$THUMB
            fi
            if [ -f $INTPATH/$BBDIR/navdata/$PUD ];
            then
                rm -f $INTPATH/$BBDIR/navdata/$PUD
            fi
            if [ -f $INTPATH/$BBDIR/media/$MEDIA ]; 
            then
                rm -f $INTPATH/$BBDIR/media/$MEDIA
            fi
            if [ -f $INTPATH/$BBDIR/media/$DNGPLUS ];
            then
                rm -f $INTPATH/$BBDIR/media/$DNGPLUS
            fi
            echo "remove complete (in theory). no check has been done if remove was successful"
            echo "";
        fi
    sync
    done
fi
}

# internal memory location
INTPATH=/data/ftp/internal_000

# detect hardware and set BBDIR
BBDIR=$( if grep -q Mykonos3 /proc/cpuinfo; then echo Bebop_Drone; elif grep -q Milos /proc/cpuinfo; then echo Bebop_2; fi )

# user feedback
FB_START &

if [ -e /dev/sda ]; then
# USB OTG drive path
    USBPATH=$( mount | grep '/dev/sda' | awk '{print $3}' )
# USB OTG drive hardware
    USBDEV=$( mount | grep '/dev/sda' | awk '{print $1}' )
elif [ -e /dev/sdb ]; then
# USB OTG drive path
    USBPATH=$( mount | grep '/dev/sdb' | awk '{print $3}' )
# USB OTG drive hardware
    USBDEV=$( mount | grep '/dev/sdb' | awk '{print $1}' )
fi

# make USB drive writeable if it is not
if [ $USBPATH ] && [ ! $(mount | grep $USBPATH | awk '{ print $6 }' | awk -F '(' '{ print $2 }' | awk -F ',' '{ print $1 }') = "rw" ]; then
    mount -o remount,rw $USBPATH
fi

# Checks...
if [ ! $BBDIR ]; then
    ERROR=1; echo "Hardware NOT compatible."
elif [ $( lsusb | wc -l ) -lt 4 ] || [ ! $USBPATH ]; then
    ERROR=1; echo "USB drive not mounted"
elif [ ! $( echo $USBPATH | grep -v $INTPATH ) ]; then
    ERROR=1; echo "USB device mounted INSIDE internal memory. ( $USBPATH )"
elif [ "$( mount | grep /data/ftp/internal_000/$BBDIR )" ]; then
    ERROR=1; echo "A device is mounted to internal memory."; echo "If enabled direct recording earlier Did you disable it?"
elif [ ! -d $INTPATH/$BBDIR/media/ ]; then
    ERROR=1; echo "Media folder doesn't exist in internal memory! Try rebooting the Bebop!"
else
    ERROR=0; echo "All tests O.K."
fi

if [ $ERROR -ne 1 ]; then
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

if [ $ERROR -eq 0 ]; then
# user feedback
    FB_WORKING &
# moving media files from internal memory to USB drive
    MOVEMEDIA dng
    MOVEMEDIA jpg
    MOVEMEDIA mp4
# move broken encaps files from USB drive to internal memory
    FIXENCAPS
fi

# user feedback
if [ $ERROR -eq 1 ]; then
    FB_ERROR
else
    FB_DONE
fi
