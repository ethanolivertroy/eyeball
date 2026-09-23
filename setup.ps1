$ErrorActionPreference = 'Stop'
$root = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$skillInRepo = Join-Path $root ".cursor/skills/eyeball"
$skillInPlugin = Join-Path $root "plugins/eyeball/skills/eyeball"
if ((Test-Path $skillInRepo) -and (Test-Path $skillInPlugin)) {
    $repoFiles = Get-ChildItem $skillInRepo -Recurse -File | Where-Object { $_.Extension -ne ".pyc" }
    $pluginFiles = Get-ChildItem $skillInPlugin -Recurse -File | Where-Object { $_.Extension -ne ".pyc" }
    $repoRel = $repoFiles | ForEach-Object { $_.FullName.Substring($skillInRepo.Length).Replace("\", "/") } | Sort-Object
    $pluginRel = $pluginFiles | ForEach-Object { $_.FullName.Substring($skillInPlugin.Length).Replace("\", "/") } | Sort-Object
    $sameNames = ($repoRel -join "`n") -eq ($pluginRel -join "`n")
    $sameBytes = $true
    if ($sameNames) {
        foreach ($rel in $repoRel) {
            $a = Join-Path $skillInRepo ($rel.TrimStart("/").Replace("/", [IO.Path]::DirectorySeparatorChar))
            $b = Join-Path $skillInPlugin ($rel.TrimStart("/").Replace("/", [IO.Path]::DirectorySeparatorChar))
            if ((Get-FileHash $a).Hash -ne (Get-FileHash $b).Hash) { $sameBytes = $false; break }
        }
    }
    if (-not $sameNames -or -not $sameBytes) {
        Write-Error ".cursor/skills/eyeball and plugins/eyeball/skills/eyeball differ. Cursor's skill scan skips a directory symlink, so both copies are real files and must match."
        exit 1
    }
}
& (Join-Path $root "plugins/eyeball/setup.ps1")
exit $LASTEXITCODE
