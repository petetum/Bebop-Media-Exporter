@echo off
REM #################################################################################################################################
Title Bebop Export Media to USB
Mode con cols=80 lines=30
REM #################################################################################################################################
cd install
REM ------- MENU -----------

cls
color 4B
ECHO.
ECHO.
ECHO.
ECHO                        !!!!!! CAUTION !!!!!!
ECHO.
ECHO        As per confirmed by PARROT CUSTOMER SERVICE AND SUPPORT
ECHO           Any modifications on Telnet voids the warranty.
ECHO.
ECHO       BY USING THIS UTILITY YOU WILL VOID YOUR DRONE'S WARRANTY!
ECHO.
ECHO.
ECHO.
echo   Press any key to continue to Main Menu.
pause >nul


:menu
color 1A
cls
ECHO.
ECHO     'Bebop Export Media to USB' for saving media files dirctly to USB drive.
ECHO      Copyright (C) 2016-2017  Pete Tum http://github.com/petetum
ECHO.
ECHO     This installer is for PARROT BEBOP DRONE and BEBOP 2  
ECHO     v1.4 alpha - 10/08/2017
ECHO.
ECHO     **********************************************************
ECHO     *       The USB drive need to be formatted to            *
ECHO     *      FAT32 filesystem before it can be used.           *
ECHO     **********************************************************
ECHO.
ECHO   1   Install scripts to your Drone
ECHO   2   Format USB Drive
ECHO   3   Remove Installed scripts from your Drone
ECHO   4   RESET your drone to it's factory settings.
ECHO.
ECHO   5   README
ECHO   6   LICENSE
ECHO   9   DEBUG
ECHO.
ECHO   0   Exit the installer.
ECHO.
ECHO.
SET M=
SET /P M= "  Type 1, 2, 3, 4, 5, 6, 9 or 0 then press ENTER:" 
IF %M%==1 GOTO install
IF %M%==3 GOTO remove
IF %M%==2 GOTO format
IF %M%==4 GOTO factory
IF %M%==5 GOTO nfofile
IF %M%==6 GOTO license
IF %M%==9 GOTO debug
IF %M%==0 GOTO eof
IF /I %M%==OVERRIDE GOTO OVERRIDE

GOTO menu

:debug
cls
ECHO.
ECHO   Run one of the following scripts on your drone and see the debug file.
ECHO.
ECHO   2   Run shortpress_2
ECHO   3   Run shortpress_3
ECHO   8   Run shortpress_8
ECHO.
ECHO   0   Back to Main menu
ECHO.
SET /P D= Type 2, 3, 8 or 0 then press ENTER: 
IF not %D%==2 IF not %D%==3 IF not %D%==8 GOTO menu
cls
echo.
echo   Turn ON your Drone.
echo   Connect to it's WI-FI network in Windows.
echo.
echo   When connected press any key to continue.
pause >nul
cls
echo.
echo   Please press the POWER BUTTON 4 times on your drone.
echo.
echo   When done press any key to continue.
pause >nul
cls
echo.
echo   Please Wait... script is running on the drone.
echo   This can take several minutes.
echo.
echo.
IF %D%==2 plink.exe -telnet -P 23 192.168.42.1 < debug2.tn >nul
IF %D%==3 plink.exe -telnet -P 23 192.168.42.1 < debug3.tn >nul
IF %D%==8 plink.exe -telnet -P 23 192.168.42.1 < debug8.tn >nul
if %errorlevel% equ 1 ( 
echo.
echo   Can't connect to the drone.
echo.
echo   Please make sure you are connected to the drone's WiFi network and the power button has been pressed 4 times.
echo.
echo   Press any key to to return to MAIN MENU.
pause >nul
GOTO menu
)
echo.
echo   Downloading debug data..
ncftpget.exe -DD 192.168.42.1 . debug.txt >nul
if %errorlevel% equ 1 ( 
echo.
echo   Something went wrong.
echo.
echo   Dear user please let Pete Tum know that he has srewed up the Debug..
echo   Just send an email to bebopexporttousb@gmail.com
echo   Cheers
echo.
echo   Press any key to to return to MAIN MENU.
pause >nul
GOTO menu
)
cls
color E0
echo.
echo   If you want a to keep the log then please go to File menu - Save As..
echo   You can also send the debug information to me so I can have a look.
echo   Please send it to bebopexporttousb@gmail.com
echo   Press any key to continue.
pause >nul
echo.
echo.
echo   Close the file to go back to the MAIN MENU
notepad.exe debug.txt
del debug.txt
GOTO menu

:factory
SET M=
cls
echo.
ECHO     FACTORY RESET
ECHO   ====================================================
ECHO     YOU WILL LOOSE ALL DATA FROM YOUR DRONE
echo     INCLUDING ALL MEDIA FILES !!!!
echo.
ECHO     REMOVE USB DRIVE NOW !!!!
ECHO     IF YOU LEAVE FLASH DRIVE CONNECTED
ECHO     THEN YOU WILL LOOSE ALL DATA
ECHO     FROM THE USB DRIVE TOO !!!!
ECHO   ====================================================
echo.
echo   Press any key to continue.
pause >nul
echo.
echo   Turn ON your Drone.
echo   Connect to it's WI-FI network in Windows.
echo.
echo   When connected press any key to continue.
pause >nul
echo.
echo   Please press the POWER BUTTON 4 times on your drone.
echo.
echo   When done press any key to continue.
pause >nul
cls
echo.
echo   Please wait... and be patient! DO NOT touch your drone NOW!!
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto factory_cantconnect
plink.exe -telnet -P 23 192.168.42.1 < ls.tn > ls.res 2>nul
find /c "shortpress_3.sh" ls.res >nul 2>nul
if %errorlevel% equ 0 goto factory_cantconnect
del ls.res >nul 2>nul
echo.
plink.exe -telnet -P 23 192.168.42.1 < factory.tn >nul 2>nul
if %errorlevel% equ 1 goto factory_cantconnect
echo   It can take up to 10 minutes to complete. Your drone will restart.
echo   The tail light will be flashing and the 
echo   cooling fan will stop spinning at some point.
echo   Once all complete the fan will turn on again.
echo.
echo   Press any key to go back to MAIN MENU. this utility.. and then wait patiently!
pause >nul
goto menu


:factory_cantconnect
del ls.res >nul 2>nul
echo   Failed to connect to Drone.
echo   Can't reset your drone. Please press and hold power button for 15 seconds.
echo   Your drone then will perform a factory reset. It can take up to 10 munutes.
echo.
echo   Please note.. by reseting the drone you will loose all media files and settings.
echo   However the installed sctipt will NOT be deleted.
echo   Run this utility again after your drone has rebooted and select 
echo   option no 2 or 4 to remove scripts.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

REM ---------- INSTALL ---------
:install
SET M=
cls
:select
echo.
echo    There will be 3 scripts installed on your drone.
echo.
echo    COLDSTART - This will be used to cold start the GPS receiver in case
echo    it cannot find signal. You can activate the script by pressing the
echo    power button 2 times.
echo.
echo    MOVE MEDIA - This is to move media files from your drone to the 
echo    USB drive you attach. You can activate the script by pressing
echo    the power button 3 times.
echo.
echo   ---------------------------------------------------------------------------
echo.
echo   Please select the method you want to use to move media files.
echo.
echo   1 - STANDARD ( Recommended )
echo        This script copies your files from the drone to the usb drive and
echo        IF FILES COPIED SUCCESSFULLY WITHOUT ERRORS
echo        then original files will be removed from the drone.
echo        In case of any error the original media files will be kept.
echo.
echo   2 - WITH DATA INTEGRITY CHECK
echo        Same as above plus this script will also perform
echo        verification ( md5sum check ) before removing the original files.
echo        It will read back the entire data from the pendrive and
echo        compare it to the original.
echo        It takes twice the time to complete.
echo.
SET /P VERS=   Type 1 or 2 then press ENTER: 
cls
echo.
echo   Turn ON your Drone and
echo   connect to it's WI-FI network in Windows.
echo.
echo   When connected press any key to continue.
pause >nul
cls
echo.
echo   Please press the POWER BUTTON 4 TIMES on your drone.
echo.
echo   When done press any key to continue.
pause >nul
cls
echo.
echo   Removing previous version scripts from your Drone . . .
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto telnet_remprev_error
echo   Uploading script to your drone . . .
ncftpput.exe 192.168.42.1 / ../shortpress_2.sh ../shortpress_3.sh ../shortpress_8.sh >nul 2>nul
if %errorlevel% equ 1 goto ftp_connection_error

IF %VERS%==2 ncftpput.exe 192.168.42.1 / md5check_on >nul 2>nul
if %errorlevel% equ 1 goto ftp_connection_error

echo   Installnig Script . . .
plink.exe -telnet -P 23 192.168.42.1 < install.tn >nul 2>nul
if %errorlevel% equ 1 goto telnet_connection_error
plink.exe -telnet -P 23 192.168.42.1 < ls.tn > ls.res 2>nul
find /c "shortpress_3.sh" ls.res >nul 2>nul
if %errorlevel% equ 1 goto telnet_connection_error
del ls.res >nul 2>nul
echo   Done
echo.
echo   Installation Successful.
echo.
echo.
echo   Press any key to continue.
pause >nul
cls
echo.
echo.
echo   Please read the README now. :)
echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:telnet_remprev_error
echo   Failed to connect to Drone.
echo   Installation terminates.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:ftp_connection_error
echo   Failed to connect to Drone.
echo   Installation terminates.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:telnet_connection_error
echo   Failed to connect to Drone. Removing temporaly files from drone . . .
mkdir remove
ncftpget.exe -DD 192.168.42.1 remove md5check_on >nul 2>nul
ncftpget.exe -DD 192.168.42.1 remove shortpress_2.sh shortpress_3.sh shortpress_8.sh >nul 2>nul
if %errorlevel% equ 1 goto ftpdd_connection_error
rmdir /Q /S remove
echo   Temporaly files removed.
echo   Installation terminates.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:ftpdd_connection_error
echo   Failed to remove temporaly files from your drone.
echo   Please connect to your drone ( ftp://192.168.42.1 ) using an FTP client and delete fileas manually.
echo   Installation terminates.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:failed_to_install
echo   Failed to intall files to Drone. Installation terminates . . .
echo   Removing installation files from your Drone.
goto   failed_to_install_remove

REM -------- REMOVE INSTALLED SCRIPTS ------------
:remove
SET M=
cls
echo.
echo   Turn ON your Drone.
echo   Connect to it's WI-FI network in Windows.
echo.
echo   When connected press any key to continue.
pause >nul
cls
echo.
echo   Please press the POWER BUTTON 4 times on your drone.
echo.
echo   When done press any key to continue.
pause >nul
cls
:failed_to_install_remove
echo.
echo   Removing Scripts from your Drone.
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto remove_cantconnect
plink.exe -telnet -P 23 192.168.42.1 < ls.tn > ls.res 2>nul
find /c "shortpress_3.sh" ls.res >nul 2>nul
if %errorlevel% equ 1 goto remove_ok
del ls.res >nul 2>nul
echo.
echo   Failed to remove files from Drone. Terminate . . .
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:remove_ok
del ls.res >nul 2>nul
echo.
echo   Successfully removed files.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:remove_cantconnect
echo.
echo   Failed to connect to Drone
echo.
echo   Please make sure your drone is turned on, computer is connected
echo   to the drone and you have pressed the 
echo   power button 4 times on your drone.
echo.
echo   If the problem still exists then please reset your drone to 
echo   factory settings by pressing and holding the 
echo   POWER BUTTON for 10 seconds.
echo   It will take a up to 5 minutes to complete 
echo   then your drone will reboot.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu


REM ---------- FORMAT ------------
:format
SET M=
cls
echo.
echo   ===============================================================
echo         FAT 32 Formatter (licensed under the GPL license) 
echo       Copyright (C) Tom Thornhill www.ridgecrop.demon.co.uk 
echo   ===============================================================
echo.
echo   Connect your USB drive to your PC
echo.
echo   Press any key to continue.
pause >nul
cls
:findletter
wmic LOGICALDISK where driveType=2 get deviceID, size >drives.txt 2>nul
find /I "DeviceID  Size" drives.txt >nul 2>nul
if %errorlevel% equ 1 (
del drives.txt
echo.
echo   There is no USB drive connected to your PC.
echo   Please connect it and try again.
echo.
echo.
echo   Press any key to go back to MAIN MENU.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   If you keep getting this message but the USB drive is connected
echo   you can OVERRIDE the scan by going back to Main Menu and type
echo   in the word OVERRIDE then press ENTER.
echo. 
pause >nul
GOTO menu
)



echo. > drives.txt

setlocal enableextensions enabledelayedexpansion
set /a count = 0
for /f "skip=1 tokens=1,2" %%a IN ('type drives.txt') DO (
  set /a count += 1
  FOR /F "tokens=* USEBACKQ" %%s IN (`powershell -command "[math]::Round((%%b/1073741824),2)"`) DO (
    SET size=%%s
  )
  if !count! equ 1 echo DeviceID  Size
  echo %%a        !size! GB
)
endlocal

SET /P LETTER= Type in the device letter then press ENTER: 
SET LETTER=%LETTER:~0,1%
cls

find /I "%LETTER%:" drives.txt >nul 2>nul
if %errorlevel% equ 1 (
del drives.txt
echo.
echo   Incorrect DeviceID
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
GOTO menu
)
del drives.txt
goto formatdo

:OVERRIDE
cls
echo.
echo   ===============================================================
echo         FAT 32 Formatter (licensed under the GPL license) 
echo       Copyright (C) Tom Thornhill www.ridgecrop.demon.co.uk 
echo   ===============================================================
echo.
echo   WARNING! MAKE SURE YOU ENTER THE RIGHT DEVICE LETTER!
ECHO   YOU WILL LOOSE ALL DATA ON THE DRIVE!
echo.
SET /P LETTER= Type in the device letter then press ENTER: 
SET LETTER=%LETTER:~0,1%
cls
echo                     CURRENT FILES AND DIRECTORIES IN %LETTER%:\
dir %LETTER%:\
echo.
echo.
echo   Press any key to Continue.
pause >nul
cls

:formatdo
cls

echo.
echo.
echo   ALL OPEN FILE EXPLORERS (explorer.exe) WILL BE CLOSED
echo.
echo.
echo   Press any key to Continue.
pause >nul
powershell -command "$a = (New-Object -comObject Shell.Application).Windows() | ? { $_.FullName -ne $null} | ? { $_.FullName.toLower().Endswith('\explorer.exe') }; $a | %% {  $_.Quit() }"
cls


color 4B
SET SURE=

echo Warning ALL data on drive '%LETTER%' will be lost irretrievably, are you sure
SET /P SURE= (y/n) :

echo %SURE%|fat32format.exe %LETTER%: > format.txt 2>&1
if %errorlevel% equ 1 (
color 1A
cls
echo. 
echo.
echo   Aborted..
echo   The drive has NOT been formatted.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
GOTO menu
)

find /I "Done" format.txt >nul 2>nul
if %errorlevel% equ 1 (
cls
echo. 
echo   An error occurred!
echo   The drive has NOT been formatted properly!
echo.
for /f "skip=1 tokens=* delims=(y/n) " %%l in (format.txt) do ( echo %%l )


echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
del format.txt
GOTO menu
)

del format.txt

color 1A
echo.
echo.
echo Done
echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

REM ---------- NFO ------------
:nfofile
cls
echo Close the README file to go back to the MENU
SET M=
notepad.exe ../README.md
goto menu

REM ---------- LICENSE ------------
:license
cls
echo Close the LICENSE file to go back to the MENU
SET M=
notepad.exe ../LICENSE.md
goto menu

REM ---------- EXIT ------------
:eof
