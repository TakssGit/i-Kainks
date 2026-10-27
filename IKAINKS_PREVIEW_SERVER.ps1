$ErrorActionPreference = 'Stop'
$Port = 51711
$Candidates = New-Object System.Collections.Generic.List[string]
$Candidates.Add('D:\IA\AppWebWin\i-kainks')
$Candidates.Add((Split-Path -Parent $PSScriptRoot))
$Candidates.Add($PSScriptRoot)
if ($env:IKAINKS_PROJECT_ROOT) { $Candidates.Insert(0, $env:IKAINKS_PROJECT_ROOT) }

function Find-WebRoot([string]$root) {
    if (-not $root -or -not (Test-Path -LiteralPath $root -PathType Container)) { return $null }
    $possibilities = @($root, (Join-Path $root 'web'), (Join-Path $root 'public'), (Join-Path $root 'preview'), (Join-Path $root 'build\web'))
    foreach ($dir in $possibilities) {
        if ((Test-Path -LiteralPath (Join-Path $dir 'preview_pc.html') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $dir 'preview_mobile.html') -PathType Leaf)) {
            return $dir
        }
    }
    return $null
}

$WebRoot = $null
foreach ($candidate in $Candidates) {
    $WebRoot = Find-WebRoot $candidate
    if ($WebRoot) { break }
}
if (-not $WebRoot) {
    Write-Host 'ERREUR: Les deux fichiers preview_pc.html et preview_mobile.html sont introuvables.' -ForegroundColor Red
    Write-Host 'Dossiers examines:'
    $Candidates | Select-Object -Unique | ForEach-Object { Write-Host " - $_" }
    Write-Host 'Indiquez le vrai dossier du projet (pas un dossier PATCH_IKAINKS_XXX).'
    $manual = Read-Host 'Chemin du projet (Entree pour annuler)'
    if ($manual) { $WebRoot = Find-WebRoot $manual.Trim('"') }
    if (-not $WebRoot) {
        Write-Host 'Aucun fichier de projet n a ete modifie. Verifiez que les apercus ont ete installes.'
        exit 2
    }
}
Write-Host "Racine des apercus: $WebRoot" -ForegroundColor Green

$Base = "http://127.0.0.1:$Port"
$ServerActive = $false
try {
    $response = Invoke-WebRequest -Uri "$Base/preview_pc.html" -UseBasicParsing -TimeoutSec 2
    if ($response.StatusCode -eq 200) { $ServerActive = $true }
} catch { }

if (-not $ServerActive) {
    $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if ($listener) {
        Write-Host "ERREUR: Le port $Port est deja utilise mais ne sert pas l apercu PC." -ForegroundColor Red
        Write-Host 'Arretez le serveur concurrent ou verifiez son dossier racine.'
        exit 3
    }
    $python = Get-Command py -ErrorAction SilentlyContinue
    if ($python) {
        $exe = $python.Source
        $arguments = @('-3', '-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', $WebRoot)
    } else {
        $python = Get-Command python -ErrorAction SilentlyContinue
        if (-not $python) { Write-Host 'ERREUR: Python 3 est requis pour demarrer ce serveur local.' -ForegroundColor Red; exit 4 }
        $exe = $python.Source
        $arguments = @('-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', $WebRoot)
    }
    Start-Process -FilePath $exe -ArgumentList $arguments -WindowStyle Minimized | Out-Null
    Start-Sleep -Seconds 2
}
foreach ($page in @('preview_pc.html','preview_mobile.html')) {
    try {
        $r = Invoke-WebRequest -Uri "$Base/$page" -UseBasicParsing -TimeoutSec 4
        if ($r.StatusCode -ne 200) { throw "HTTP $($r.StatusCode)" }
    } catch {
        Write-Host "ERREUR: $Base/$page inaccessible: $($_.Exception.Message)" -ForegroundColor Red
        exit 5
    }
}
Write-Host "PC     : $Base/preview_pc.html"
Write-Host "MOBILE : $Base/preview_mobile.html"
# Le navigateur par defaut est utilise; les onglets existants peuvent etre reutilises par Chrome.
Start-Process "$Base/preview_pc.html"
Start-Process "$Base/preview_mobile.html"
Write-Host 'Les deux apercus ont ete ouverts. Si deja ouverts, fermez les doublons eventuels.' -ForegroundColor Green
