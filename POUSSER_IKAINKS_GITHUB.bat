@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
title i-Kainks - Publication GitHub
set "LOG=%~dp0RESULTAT_PUSH_GITHUB.txt"
set "GIT_TERMINAL_PROMPT=1"
echo ============================================================
echo   i-Kaink's - Publication GitHub depuis le dossier projet
echo ============================================================
echo Dossier : %CD%
echo.
where git >nul 2>&1
if errorlevel 1 (
 echo ERREUR : Git n'est pas installe ou absent du PATH.
 echo Installez Git for Windows : https://git-scm.com/download/win
 goto :fail
)
if not exist ".git\" (
 echo Aucun depot Git trouve dans ce dossier.
 choice /C ON /M "Initialiser un depot Git ici ? [O=Oui, N=Non]"
 if errorlevel 2 goto :cancel
 git init
 if errorlevel 1 goto :fail
)
if not exist ".gitignore" (
 echo Creation d'un .gitignore de securite...
 >".gitignore" echo # i-Kainks - exclusions locales
 >>".gitignore" echo .env
 >>".gitignore" echo .env.*
 >>".gitignore" echo ^!.env.example
 >>".gitignore" echo *.keystore
 >>".gitignore" echo *.jks
 >>".gitignore" echo *.p12
 >>".gitignore" echo *.pem
 >>".gitignore" echo *.key
 >>".gitignore" echo *service-account*.json
 >>".gitignore" echo *credentials*.json
 >>".gitignore" echo node_modules/
 >>".gitignore" echo build/
 >>".gitignore" echo dist/
 >>".gitignore" echo .dart_tool/
 >>".gitignore" echo .gradle/
 >>".gitignore" echo .idea/
 >>".gitignore" echo .flutter-plugins-dependencies
 >>".gitignore" echo .ikainks_backups/
 >>".gitignore" echo .ikainks_backup/
 >>".gitignore" echo backups/
 >>".gitignore" echo *.sqlite
 >>".gitignore" echo *.sqlite3
 >>".gitignore" echo *.db
 >>".gitignore" echo *.db-shm
 >>".gitignore" echo *.db-wal
 >>".gitignore" echo RESULTAT_*.txt
 >>".gitignore" echo *.log
)
rem Exclure les scripts et rapports locaux du commit (sans modifier un .gitignore existant)
if not exist ".git\info\exclude" type nul > ".git\info\exclude"
findstr /L /X /C:"RESULTAT_PUSH_GITHUB.txt" ".git\info\exclude" >nul 2>&1 || >>".git\info\exclude" echo RESULTAT_PUSH_GITHUB.txt

git remote get-url origin >nul 2>&1
if errorlevel 1 (
 echo.
 echo Aucune adresse GitHub configuree pour origin.
 set /p "REPO=Collez l'URL HTTPS ou SSH du depot GitHub : "
 if not defined REPO goto :cancel
 git remote add origin "%REPO%"
 if errorlevel 1 goto :fail
)
echo.
echo Depot distant :
git remote -v
set "BRANCH="
for /f "delims=" %%B in ('git branch --show-current 2^>nul') do set "BRANCH=%%B"
if not defined BRANCH (
 set "BRANCH=main"
 git branch -M main
)
echo Branche locale : %BRANCH%
echo.
echo Verification des modifications :
git status --short
if errorlevel 1 goto :fail
echo.
echo ATTENTION : les fichiers suivis precedemment restent suivis meme s'ils figurent dans .gitignore.
echo Verifiez qu'aucun secret, mot de passe, base reelle ou fichier prive n'est inclus.
choice /C ON /M "Ajouter les fichiers du projet a l'index Git ? [O=Oui, N=Non]"
if errorlevel 2 goto :cancel
git add -A
if errorlevel 1 goto :fail

echo.
echo ========== FICHIERS PRETS A PUBLIER ==========
git diff --cached --name-status
if errorlevel 1 goto :fail

echo.
echo Verification de noms potentiellement sensibles dans l'index...
set "SENSITIVE=0"
for /f "delims=" %%F in ('git diff --cached --name-only') do (
 echo(%%F | findstr /I /R /C:"\.env$" /C:"\.env\." /C:"\.pem$" /C:"\.key$" /C:"\.jks$" /C:"\.keystore$" /C:"credentials" /C:"service-account" /C:"\.sqlite$" /C:"\.db$" >nul && echo ALERTE : %%F
)
echo.
choice /C ON /M "Confirmer que cette liste peut etre publiee sur GitHub ? [O=Oui, N=Non]"
if errorlevel 2 goto :cancel

git diff --cached --quiet
if errorlevel 1 (
 set "MESSAGE="
 set /p "MESSAGE=Message de commit (Entree = Mise a jour i-Kainks) : "
 if not defined MESSAGE set "MESSAGE=Mise a jour i-Kainks"
 git commit -m "%MESSAGE%"
 if errorlevel 1 (
  echo ERREUR : commit impossible. Configurez git config user.name et user.email.
  goto :fail
 )
) else (
 echo Aucune nouvelle modification a committer.
)
echo.
echo Verification de la connexion distante...
git ls-remote --exit-code origin HEAD >nul 2>&1
if errorlevel 1 echo INFO : depot vide, acces restreint ou authentification necessaire.
echo.
choice /C ON /M "Envoyer la branche %BRANCH% sur GitHub maintenant ? [O=Oui, N=Non]"
if errorlevel 2 goto :cancel
(
 echo Projet : %CD%
 echo Branche : %BRANCH%
 echo Remote :
 git remote -v
 echo.
 echo Date : %DATE% %TIME%
) > "%LOG%"
git push -u origin "%BRANCH%" >> "%LOG%" 2>&1
if errorlevel 1 (
 echo.
 echo ECHEC DU PUSH. Le depot distant contient peut-etre des commits absents localement,
 echo ou GitHub demande une authentification. Aucune operation forcee n'a ete faite.
 echo Consultez : "%LOG%"
 type "%LOG%"
 goto :fail
)
echo.
echo SUCCES : branche %BRANCH% envoyee vers GitHub.
echo Rapport : "%LOG%"
goto :end
:cancel
echo Operation annulee. Aucun push effectue.
goto :end
:fail
echo.
echo Operation interrompue. Verifiez les messages ci-dessus.
:end
echo.
pause
endlocal
