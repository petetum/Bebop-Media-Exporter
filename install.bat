@echo off
for /F "skip=2 tokens=* delims=" %%v in (README.md) do set "version=%%v"&goto nextline
:nextline
Title Bebop Media Exporter %version%

REM ------- WARNING -----------
Mode con cols=70 lines=12
cls
color 4B
ECHO.
ECHO                        !!!!!! WARNING !!!!!!
ECHO.
ECHO        As confirmed by 'PARROT CUSTOMER SERVICE AND SUPPORT'
ECHO           Any modifications on Telnet voids the warranty.
ECHO.
ECHO       BY USING THIS UTILITY YOU WILL VOID YOUR BEBOP'S WARRANTY!
ECHO.
ECHO.
echo   Press any key to continue to Main Menu.
pause >nul
REM ------- MENU -----------
:menu
Mode con cols=80 lines=26
color 1A
cls
ECHO.
ECHO     'Bebop Media Exporter' for exporting media files to a USB drive.
ECHO      Copyright (C) 2016-2017  Pete Tum http://github.com/petetum
ECHO     %version%
ECHO.
ECHO     This installer is for PARROT BEBOP Drone and BEBOP 2 Aircraft ONLY
ECHO.
ECHO     **********************************************************
ECHO     *       The USB Drive needs to be formatted by           *
ECHO     *                 using this utility.                    *
ECHO     *      ( Even if it has been formatted already. )        *
ECHO     **********************************************************
ECHO.
ECHO   1   Install scripts to your Bebop
ECHO   2   Format USB Drive
ECHO   3   Uninstall scripts from your Bebop
ECHO   4   RESET your Bebop to it's factory settings.
ECHO   5   README
ECHO   6   LICENSE
ECHO.
ECHO   9   Enter DEBUG Menu
ECHO   0   EXIT
ECHO.
ECHO.
SET "M="
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

REM ---------- user instructions ---------
:instructions
Mode con cols=42 lines=12
cls
echo.
echo     Turn ON your Bebop and connect to
echo      it's WI-FI network in Windows.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   When connected press any key to continue.
pause >nul
cls
echo.
echo   Press the POWER BUTTON 4 times on your Bebop.
echo.
echo.
echo.
echo.
echo.
echo.
echo   When done press any key to continue.
pause >nul

goto eof

REM ---------- INSTALL ---------
:install
SET "M="
cls
:select
Mode con cols=82 lines=30
echo.
echo.
echo    There will be 3 scripts installed on your Bebop. 
echo      to start the scripts just press the power button on  
echo      your Bebop the number of times below.
echo.
echo      2 BUTTON PRESSES TO COLD START GPS
echo        If your Bebop has difficulties finding GPS signals then you could try 
echo        to cold start the GPS receiver.
echo        It will only take a few seconds to complete.
echo.
echo      3 BUTTON PRESSES TO MOVE MEDIA FILES from internal memory to USB Drive
echo        This script will also move NavData files if they are available.
echo        Please note. The Bebop will delete the NavData files when you turn it off.
echo        If you want to save them you need to do so before you power off the Bebop.
echo.
echo      8 BUTTON PRESSES TO ENABLE/DISABLE DIRECT RECORDING TO USB DRIVE
echo        This will enable/disable direct recording to USB Drive.
echo        Tasks will complete very quickly in just a few seconds.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   Press any key to continue.
pause >nul
cls
echo.
echo     Please select the method you want to use to move media files.
echo.
echo     1 - STANDARD ( Recommended )
echo        This script copies your files from the Bebop to the USB Drive and
echo        IF FILES COPIED SUCCESSFULLY WITHOUT ERRORS
echo        then the original files will be removed from the Bebop.
echo        In case of any error the original media files will be kept.
echo.
echo     2 - WITH DATA INTEGRITY CHECK
echo        Same as the STANDARD but as an addition this script will also perform
echo        data verification ( md5sum check ) before removing the original files.
echo        It will read back the entire data from the USB Drive and
echo        compare it to the original.
echo        It takes twice the time to complete.
echo.
SET /P VERS=   Type 1 or 2 then press ENTER: 


call :instructions
Mode con cols=80 lines=30
cls
echo.
echo   Removing previous version scripts from your Bebop . . .
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto telnet_remprev_error
echo   Uploading script to your Bebop . . .
ncftpput.exe 192.168.42.1 / shortpress_2.sh shortpress_3.sh shortpress_8.sh >nul 2>nul
if %errorlevel% equ 1 goto ftp_connection_error

IF %VERS%==2 ncftpput.exe 192.168.42.1 / md5check_on >nul 2>nul
if %errorlevel% equ 1 goto ftp_connection_error

echo   Installing Script . . .
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
echo   Please read the README now.
echo.
echo.
echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:telnet_remprev_error
:ftp_connection_error
echo   Failed to connect to Bebop.
echo   Installation terminates.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:telnet_connection_error
echo   Failed to connect to Bebop.
echo   Removing temporary files from Bebop . . .
mkdir remove
ncftpget.exe -DD 192.168.42.1 remove md5check_on >nul 2>nul
ncftpget.exe -DD 192.168.42.1 remove shortpress_2.sh shortpress_3.sh shortpress_8.sh >nul 2>nul
if %errorlevel% equ 1 goto ftpdd_connection_error
rmdir /Q /S remove
echo   Temporary files removed.
echo   Installation terminates.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:ftpdd_connection_error
echo   Failed to remove temporary files from your Bebop.
echo   Installation terminates.
echo.
echo   Please reset your Bebop to factory
echo   settings by pressing and holding the
echo   POWER BUTTON for 10 seconds.
echo   Please note.. by reseting the drone you will loose all media files and settings.
echo.
echo   It will take a up to 10 minutes to complete
echo   then your Bebop will reboot.
echo.
echo.

echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:failed_to_install
echo   Failed to install files to Bebop.
echo   Installation terminates . . .
echo   Removing installation files from your Bebop.
goto   failed_to_install_remove

REM -------- REMOVE INSTALLED SCRIPTS ------------
:remove
SET "M="
call :instructions
Mode con cols=80 lines=30
cls
:failed_to_install_remove
echo.
echo   Removing Scripts from your Bebop.
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto remove_cantconnect
plink.exe -telnet -P 23 192.168.42.1 < ls.tn > ls.res 2>nul
find /c "shortpress_3.sh" ls.res >nul 2>nul
if %errorlevel% equ 1 goto remove_ok
del ls.res >nul 2>nul
echo.
echo   Failed to remove files from Bebop.
echo   Terminate . . .
echo.
echo   Please reset your Bebop to factory
echo   settings by pressing and holding the
echo   POWER BUTTON for 10 seconds.
echo   Please note.. by reseting the drone you will loose all media files and settings.
echo.
echo   It will take a up to 10 minutes to complete
echo   then your Bebop will reboot.
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
echo   Failed to connect to Bebop
echo.
echo   Please make sure your Bebop is turned on, computer is connected
echo   to the Bebop and you have pressed the 
echo   power button 4 times on your Bebop.
echo.
echo   If the problem still exists then please reset your Bebop to 
echo   factory settings by pressing and holding the 
echo   POWER BUTTON for 10 seconds.
echo   It will take a up to 10 minutes to complete 
echo   then your Bebop will reboot.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

:factory
SET "M="
Mode con cols=80 lines=30
cls
echo.
ECHO     FACTORY RESET
ECHO   ====================================================
ECHO     YOU WILL LOOSE ALL DATA FROM YOUR BEBOP
echo     INCLUDING ALL MEDIA FILES !!!!
echo.
ECHO     REMOVE USB DRIVE NOW !!!!
echo.
ECHO     IF YOU LEAVE USB DRIVE CONNECTED
ECHO     THEN YOU WILL LOOSE ALL DATA
ECHO     FROM THE USB DRIVE TOO !!!!
ECHO   ====================================================
echo.
echo   Press any key to continue.
pause >nul
Mode con cols=80 lines=30
call :instructions
Mode con cols=80 lines=30
cls
echo.
echo   DO NOT touch your Bebop NOW !!
plink.exe -telnet -P 23 192.168.42.1 < remove.tn >nul 2>nul
if %errorlevel% equ 1 goto factory_cantconnect
plink.exe -telnet -P 23 192.168.42.1 < ls.tn > ls.res 2>nul
find /c "shortpress_3.sh" ls.res >nul 2>nul
if %errorlevel% equ 0 goto factory_cantconnect
del ls.res >nul 2>nul
echo.
plink.exe -telnet -P 23 192.168.42.1 < factory.tn >nul 2>nul
if %errorlevel% equ 1 goto factory_cantconnect
echo FACTORY RESET request successfully executed.
echo.
echo.
echo.
echo.
echo.
echo   Press any key to continue.
pause >nul
echo   It can take up to 10 minutes to complete.
echo       Then your Bebop will restart.
echo.
echo   The tail light will be flashing and the
echo   cooling fan will stop spinning at some point.
echo   When complete the fan will turn on again.
echo.
echo               Please wait patiently!
echo.
echo   Press any key to go back to MAIN MENU
pause >nul
goto menu

:factory_cantconnect
del ls.res >nul 2>nul
echo   Failed to connect to Bebop.
echo   Can't reset your Bebop.
echo.
echo   Press and hold the power button for 10 seconds on your Bebop.
echo   It will then perform a factory reset.
echo.
echo   It can take up to 10 munutes to complete. Then your Bebop will reboot.
echo.
echo   Please note.. by reseting the Bebop you will loose all media files and settings.
echo   However the installed script will NOT be deleted.
echo   Run this utility again after your Bebop has rebooted and select
echo   option 3 or 4 to remove scripts.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu

REM ---------- FORMAT ------------
:format
SET "M="
cls
echo.
echo   Connect your USB Drive to your PC
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo   Press any key to continue.
pause >nul
cls
wmic LOGICALDISK where driveType=2 get deviceID, size >drives.txt 2>nul
find /I "DeviceID  Size" drives.txt >nul 2>nul
if %errorlevel% equ 1 (
del drives.txt
echo.
echo   There is no USB Drive connected to your PC.
echo   Please connect your USB Drive to your PC and try again.
echo.
echo.
echo.
echo.
echo.
echo.
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
echo   If you keep getting this message but the USB Drive is connected
echo   you can OVERRIDE the scan by going back to Main Menu and type
echo   in the word OVERRIDE then press ENTER.
echo. 
pause >nul
GOTO menu
)

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
goto format_do

:OVERRIDE
cls
echo.
echo   WARNING! MAKE SURE YOU ENTER THE RIGHT DEVICE LETTER!
ECHO   YOU WILL LOOSE ALL DATA ON THE USB DRIVE!
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

:format_do
cls

echo.
echo.
echo   ALL OPEN FILE EXPLORERS WILL BE CLOSED (explorer.exe)
echo.
echo.
echo   Press any key to Continue.
pause >nul
powershell -command "$a = (New-Object -comObject Shell.Application).Windows() | ? { $_.FullName -ne $null} | ? { $_.FullName.toLower().Endswith('\explorer.exe') }; $a | %% {  $_.Quit() }"
cls


color 4B
SET "SURE="

echo   ===============================================================
echo         FAT 32 Formatter (licensed under the GPL license) 
echo       Copyright (C) Tom Thornhill www.ridgecrop.demon.co.uk 
echo   ===============================================================
echo.
echo.
echo Warning ALL data on drive '%LETTER%' will be lost irretrievably, are you sure
SET /P SURE= (y/n) :

echo %SURE%|fat32format.exe %LETTER%: > format.txt 2>&1
if %errorlevel% equ 1 (
color 1A
cls
echo. 
echo.
echo   Aborted.
echo   The USB Drive has NOT been formatted.
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
echo   The USB Drive has NOT been formatted properly!
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
echo Format finished.
echo.
echo.
echo   Press any key to go back to MAIN MENU.
pause >nul
goto menu


REM ---------- NFO ------------
:nfofile
cls
echo.
echo.
echo          Close the README file to go back to the MENU
echo.
echo.
SET "M="
notepad.exe README.md
goto menu

REM ---------- LICENSE ------------
:license
cls
echo.
echo.
echo          Close the LICENSE file to go back to the MENU
echo.
echo.
SET "M="
notepad.exe LICENSE.md
goto menu

:debug
Mode con cols=80 lines=30
cls
ECHO.
ECHO   Run one of the following scripts on your Bebop and see the debug log.
ECHO.
ECHO   2   COLD START GPS
ECHO   3   MOVE MEDIA FILES
ECHO   8   ENABLE/DISABLE DIRECT RECORDING
ECHO.
ECHO   0   Back to Main menu
ECHO.
SET /P D= Type 2, 3, 8 or 0 then press ENTER: 
IF not %D%==2 IF not %D%==3 IF not %D%==8 GOTO menu
cls
Mode con cols=80 lines=30
echo.
call :instructions
Mode con cols=80 lines=30
cls
echo.
echo   Script is running on the Bebop.
echo   This can take several minutes.
echo   Please Wait . . .
echo.
echo.
IF %D%==2 plink.exe -telnet -P 23 192.168.42.1 < debug2.tn >nul
IF %D%==3 plink.exe -telnet -P 23 192.168.42.1 < debug3.tn >nul
IF %D%==8 plink.exe -telnet -P 23 192.168.42.1 < debug8.tn >nul
if %errorlevel% equ 1 ( 
echo.
echo   Can't connect to the Bebop.
echo.
echo   Are you are connected to the Bebop's WiFi network?
echo   Did you press the power button 4 times?
echo.
echo.
echo.
echo.
echo   Press any key to return to MAIN MENU.
pause >nul
GOTO menu
)
echo.
echo   Downloading debug data . . .
ncftpget.exe -DD 192.168.42.1 . debug.txt >nul
if %errorlevel% equ 1 ( 
echo.
echo   Something went wrong.
echo.
echo   Dear user please let Pete Tum know that he has srewed up the Debug.
echo   Just send an email to BebopMediaExpoter@gmail.com
echo   Cheers
echo.
echo   Press any key to return to MAIN MENU.
pause >nul
GOTO menu
)
cls
Mode con cols=80 lines=30
color E0
echo.
echo   If you want a to keep the log then please go to File menu - Save As..
echo   You can also send the debug information to:
echo.
echo   BebopMediaExpoter@gmail.com
echo.
echo.
echo   Press any key to continue.
pause >nul
echo.
echo.
echo   Close the file to go back to the MAIN MENU
notepad.exe debug.txt
del debug.txt
GOTO menu


REM ---------- EXIT ------------
:eof
