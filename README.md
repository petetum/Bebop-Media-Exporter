# Bebop_Export_Media_to_USB
For exporting media files from your Bebop Drone / Bebop 2 to external USB drive. 

                  !!!!!! CAUTION !!!!!!
  As per confirmed by PARROT CUSTOMER SERVICE AND SUPPORT
  Any modifications on Telnet voids the warranty.
  BY USING THIS UTILITY YOU WILL VOID YOUR DRONE'S WARRANTY!
  
This script is for PARROT BEBOP and BEBOP 2 Dones.
v1.4 alpha - 10/08/2017

Find me on youtube.
https://www.youtube.com/c/PeteTum

The author shall not be held responsible for any damages that may occur to your device or your media files.
Proceed at your own risk.


Tested on Bebop Drone - firmware version ?.?.?
Tested on Bebop 2 - firmware version ?.?.?

How to install the scripts:
  - Download file
	BEBOP_EXPORT_TO_USB_v1.4a.EXE
	https://xxxxxx.xxxx
  - Run the utility
  - Follow on screen instructions
  - Do You like my work?
    If you do then why not buy me a coffee. I like it with cinnamon on top :)
    It won't brake the bank..  Go to the link below to donate me.
    https://goo.gl/wxkBjX
  - Thank you for donating! You are Amazing!
  - You're done


There will be 3 scripts installed on your drone. 
Just press the power button on your drone the number of times below 
to start the scripts:

2 BUTTON PRESSES TO COLD START GPS.
  If your drone has difficulties finding GPS signal then you could try 
  to cold start the GPS receiver. It will only take a few seconds to complete.

3 BUTTON PRESSES TO MOVE MEDIA FIMES from internal memory to USB drive
  This script will also move navdata files if they are available.
  (Please note. The drone will delete the navdata files when you turn it off.
  If you want to save them you need to do so before you power off.)

  BEBOP DRONE (1) feedback:
    Green and orange lights will be flashing during the moving process.
    The drone will emit 4 sounds when task is complete. Just like the ones when you
    power on your Bebop.

    In case of any error the drone will emit 5 louder alarm sounds and
    the LED will turn and stay solid red.
    At this point you can run the script again or just power off the drone.

  BEBOP 2 feedback:
    The tail light will be flashing ( like a hearbeat ) during the moving process.
    The drone will emit 4 sounds when task is complete.

    In case of any error the drone will emit 5 louder alarm sounds and
    the LED light will flashing on an off.
    At this point you can run the script again or just power off the drone.

8 BUTTON PRESSES TO ENABLE/DISABLE DIRECT RECORDING TO USB DRIVE
  This will enable/disable direct recording to USB drive.
  Taks will complete very quickly in just a few seconds.
  
  IT IS IMPORTANT TO EITHER DISABLE DIRECT RECORDING OR 
  POWER OFF THE DRONE BEFORE REMOVING THE USB DRIVE!

  BEBOP DRONE (1) feedback:
    The drone will emit 4 sounds when direct recoring is ENABLED.
	It will emit 8 sounds when direct recoring is DISABLED.

    In case of any error the drone will emit 5 louder alarm sounds and
    the LED will turn and stay solid red.
    At this point you can run the script again or just power off the drone.

  BEBOP 2 feedback:
    The drone will emit 4 sounds when direct recoring is ENABLED.
	It will emit 8 sounds when direct recoring is DISABLED.

    In case of any error the drone will emit 5 louder alarm sounds and
    the LED light will flashing on an off.
    At this point you can run the script again or just power off the drone.


IT IS HIGHLY RECOMMENDED TO TURN OFF YOUR DRONE BEFORE REMOVING THE PENDRIVE!

BROKEN VIDEO FILES ( aka .mp4-encaps.tmp .mp4-encaps.dat )
  If while recording directly to the USB drive it gets removed ( by hitting a tree maybe ) 
  or you have a power cut by loosing the battery then the video file will be broken on 
  the USB drive. To fix the broken file turn on your drone and insert the USB drive.
  Then press power button for 3 times. That will run the script that is responsible for 
  moving files from internal memory to USB as well as moving the broken video files
  from the USB to internal memory. Yes you've read it right. The broken files will be moved 
  to the drone's memory. Next time you turn on your Bebop it will automatically fix the video.
  Then you can press power button 3 times to move the already fixed file back to the USB drive.

ERRORS
  If you have any mysterious errors you can run the DEBUG through your computer.
  Just use menu option 9 in the installation utility and wait 
  until task finishes then you will be shown the log file.
  Please send the log file (if you wish) to bebopexporttousb@gmail.com so I can have a look and try to solve the issue.
  If you don't want to share your email address with me then just use an anonymous email service
  like this: https://anonymousemail.me/

CREDITS
  Credit to everyone on Parrot Forum who have contributed to the project that I found in September 2016.
  Without the initial help I wouldn't be able to deal with this project.
  https://community.parrot.com/t5/Bebop-Drone/Copy-pics-vids-DIRECTLY-to-USB-Stick/td-p/113176

Applications used in this utility:
  PuTTY (Plink): http://www.chiark.greenend.org.uk/~sgtatham/putty/ (licensed under the MIT licence) PuTTY is copyright 1997-2017 Simon Tatham.
  NCFTP http://www.ncftp.com/ncftp/ (licensed under the The Clarified Artistic License)
  FAT 32 FORMATTER http://www.ridgecrop.demon.co.uk/index.htm?guiformat.htm (licensed under the GPL license) Tom Thornhill
  IExpress 2.0 to create self extracring self installing package. Microsoft Corporation. All rights reserved. http://www.microsoft.com/
