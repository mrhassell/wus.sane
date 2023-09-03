@echo on
TITLE "Windows Update Sanitizer"
echo:
echo "Windows Update sanitize script"
echo:
echo "Execution commence:" %DATE% %TIME%
echo:
echo:
sc config trustedinstaller start=auto
IF %ERRORLEVEL% NEQ 0 (
  echo "trustedinstaller service configured: OK"
)
echo "stopping windows update configuration services"
net stop bits
net stop wuauserv
net stop msiserver
net stop cryptsvc
net stop appidsvc
IF %ERRORLEVEL% NEQ 0 (
  echo "Windows Update configuration services stopped: OK"
)
echo:
echo "backup system SoftwareDistribution / WindowsUpdate catalog"
REN %Systemroot%\SoftwareDistribution SoftwareDistribution.old
@REM ---------------------------------------------------------
@REM IF - encounter problems after completion and full reboot
@REM open the location below in Windows Explorer:
@REM ---------------------------------------------------------
@REM     %Systemroot%\SoftwareDistribution
@REM ---------------------------------------------------------
@REM select contents inside and delete. (ONLY) if unresolved.
@REM ---------------------------------------------------------
REN %Systemroot%\System32\catroot2 catroot2.old
IF %ERRORLEVEL% NEQ 0 (
    echo "done!"
)
echo:
echo "resolves common system file registration issue"
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll
IF %ERRORLEVEL% NEQ 0 (
    echo "done"
)
@REM echo:
@REM echo reset windows network stack
@REM netsh winsock reset
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo done!
@REM )
@REM echo:
@REM echo reset windows network stack > proxy settings
@REM @REM netsh winsock reset proxy
@REM IF %ERRORLEVEL% NEQ 0 (
@REM     echo done!
@REM )
echo:
echo "cleaning windows PnP driver update / cache locations"
rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN
IF %ERRORLEVEL% NEQ 0 (
    echo "done"
)
echo:
echo "executing DISM (Deployment Image Servicing and Management)"
echo "DISM services window deployments, ensuring config is sane"
dism /Online /Cleanup-image /ScanHealth
dism /Online /Cleanup-image /CheckHealth
dism /Online /Cleanup-image /RestoreHealth
dism /Online /Cleanup-image /StartComponentCleanup
IF %ERRORLEVEL% NEQ 0 (
  echo "DISM parsed and corrected current image. This system appears: SANE"
)
echo:
echo "execute SFC (system file check) displays report of results"
sfc /ScanNow
IF %ERRORLEVEL% NEQ 0 (
    echo "SFC 100%. Completed system sanitize script: OK"
)
echo:
echo "restarting windows update configuration services"
echo:
net start bits
net start wuauserv
net start msiserver
net start cryptsvc
net start appidsvc
IF %ERRORLEVEL% NEQ 0 (
  echo "windows update configuration services started: OK"
)
echo:
echo "Finished: Please restart your computer and run Windows Update: OK"
echo:
echo "Completed " %TIME%
pause
@echo off
REM timeout /t -1
