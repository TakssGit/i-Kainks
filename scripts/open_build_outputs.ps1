# Run on the Windows machine where the application was built.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$found = $false
foreach ($relative in @('build\windows\x64\runner\Release', 'build\app\outputs\flutter-apk')) {
    $destination = Join-Path $root $relative
    if (Test-Path -LiteralPath $destination -PathType Container) {
        Start-Process explorer.exe -ArgumentList ('"' + $destination + '"')
        $found = $true
    } else {
        Write-Warning "Aucun build à cet emplacement : $destination"
    }
}
if (-not $found) { throw 'Aucun dossier de compilation trouvé. Générez ou téléchargez les builds avant de les ouvrir.' }
