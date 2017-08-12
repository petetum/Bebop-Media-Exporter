#!/bin/sh
# this is nearly identical to the one is already on the bebop except this one will leave the LED light green.

/usr/bin/BLDC_Test_Bench -G 1 1 1 >/dev/null 2>&1
/bin/ardrone3_stop.sh
/usr/bin/BLDC_Test_Bench -G 1 0 1 >/dev/null 2>&1

# Sleep for secure Broadcom reboot
echo "Sleep for broadcom reboot"  | ulogger -t "reboot" -p I
sleep 1

# Make the Cypress chip turn on the GPIO which keeps the P7 alive at reboot
# Also keep led GREEN while reebooting
/usr/bin/BLDC_Test_Bench -G 0 1 1 >/dev/null 2>&1

# Call the system reboot procedure
/sbin/reboot
