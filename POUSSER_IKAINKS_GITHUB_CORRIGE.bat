@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
set "GIT_PAGER=cat"
set "PAGER=cat"
set "GIT_TERMINAL_PROMPT=1"
set "LOG=%CD%\RESULTAT_PUSH_GITHUB.txt"
>"%LOG%" echo i-Kaink's GitHub publication - %date% %time%
echo ============================================================
echo  i-Kaink's - PUSH GITHUB CORRIGE - SANS PAGER
 echo ============================================================
echo Projet : %CD%
where git >nul 2>&1 || (echo ERREUR: Git non installe.& pause & exit /b 1)
git rev-parse --show-toplevel >nul 2>&1 || (echo ERREUR: dossier Git introuvable.& pause & exit /b 1)
if not exist "web\preview_pc.html" echo INFO: web\preview_pc.html absent de ce dossier.
if not exist "web\preview_mobile.html" echo INFO: web\preview_mobile.html absent de ce dossier.
echo.
echo Configuration des exclusions locales...
for %%P in (".ikainks_backups/" ".dart_tool/" "build/" ".gradle/" "android/.gradle/" ".idea/" ".vscode/" ".env" ".env.*" "*.keystore" "*.jks" "key.properties" "RESULTAT_*.txt") do call :ignore "%%~P"
rem Retirer de l'index les sauvegardes qui auraient ete ajoutees par le precedent BAT.
git rm -r --cached --ignore-unmatch -- .ikainks_backups >nul 2>&1
if errorlevel 1 echo INFO: verification des sauvegardes terminee.
rem Ne jamais publier de fichiers de secrets courants meme s'ils sont deja suivis.
git rm --cached --ignore-unmatch -- .env .env.local .env.production android/key.properties key.properties >nul 2>&1
rem Ne pas publier de fichiers de sauvegarde hors du projet.
echo.
echo Depot distant :
git remote -v
set "REMOTE="
for /f "delims=" %%R in ('git remote') do if not defined REMOTE set "REMOTE=%%R"
if defined REMOTE goto remote_ready
set /p "REPO=URL du depot GitHub (https://github.com/UTILISATEUR/DEPOT.git) : "
if not defined REPO (echo ERREUR: URL manquante.& pause & exit /b 1)
git remote add origin "%REPO%" || (pause & exit /b 1)
set "REMOTE=origin"
:remote_ready
echo.
echo Modifications actuelles :
git --no-pager status --short
choice /c ON /m "Ajouter les fichiers autorises a Git"
if errorlevel 2 (echo Annule.& pause & exit /b 0)
git add -A || (echo ERREUR git add.& pause & exit /b 1)
rem Exclure explicitement les sauvegardes meme si elles ont ete precedemment ajoutees.
git rm -r --cached --ignore-unmatch -- .ikainks_backups >nul 2>&1
echo.
echo Fichiers selectionnes (sans visualiseur interactif) :
git --no-pager diff --cached --name-status
>>"%LOG%" echo Fichiers selectionnes:
git --no-pager diff --cached --name-status >>"%LOG%" 2>&1
echo.
echo IMPORTANT: Verifiez l'absence de secrets et de donnees personnelles.
choice /c ON /m "Confirmer le commit et le push vers GitHub"
if errorlevel 2 (echo Annule. Fichiers seulement indexes, aucun push.& pause & exit /b 0)
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "Mise a jour i-Kainks - %date%" >>"%LOG%" 2>&1
  if errorlevel 1 (echo ERREUR pendant le commit. Voir %LOG%& pause & exit /b 1)
) else (
  echo Aucun nouveau changement a committer.
)
for /f "delims=" %%B in ('git branch --show-current') do set "BRANCH=%%B"
if not defined BRANCH (echo ERREUR: branche Git inconnue.& pause & exit /b 1)
echo.
echo Verification du depot distant...
git fetch "%REMOTE%" >>"%LOG%" 2>&1
if errorlevel 1 (echo ERREUR git fetch. Voir %LOG%& pause & exit /b 1)
echo Publication de %BRANCH% vers %REMOTE%...
git -c core.pager=cat push -u "%REMOTE%" "%BRANCH%" >>"%LOG%" 2>&1
if errorlevel 1 (
 echo ERREUR: push refuse ou connexion impossible. Aucun push force effectue.
 echo Consultez : %LOG%
 type "%LOG%"
 pause
 exit /b 1
)
echo.
echo SUCCES : projet publie sur GitHub.
echo Rapport : %LOG%
>>"%LOG%" echo SUCCES: push termine.
pause
exit /b 0
:ignore
findstr /x /l /c:"%~1" ".gitignore" >nul 2>&1 && exit /b 0
>>".gitignore" echo %~1
exit /b 0
