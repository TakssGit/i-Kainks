@echo off
setlocal
chcp 65001 >nul
set "SCRIPT=%~dp0IKAINKS_PREVIEW_SERVER.ps1"
if not exist "%SCRIPT%" (
 echo ERREUR: IKAINKS_PREVIEW_SERVER.ps1 absent du meme dossier que ce BAT.
 pause
 exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
if errorlevel 1 (
 echo.
 echo Le lancement a echoue. Consultez le message ci-dessus.
 pause
 exit /b 1
)
endlocal
