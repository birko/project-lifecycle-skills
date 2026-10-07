# Links BOTH skills/ and skills-pi/ into ~/.pi/agent/skills as directory junctions, one per skill folder.
# Why links rather than copies: ADR 0009. Why that tree is pi-only and frozen: ADR 0010.
#
# Usage:  ./pi-install.ps1      (idempotent; safe to re-run)

$sources = @(
    (Join-Path $PSScriptRoot 'skills'),
    (Join-Path $PSScriptRoot 'skills-pi')
)
$target = Join-Path $HOME '.pi\agent\skills'

# The PowerShell counterpart of bash's `pwd -P`: follow a link at every component of the path.
function Resolve-Real([string]$path) {
    $parts = [IO.Path]::GetFullPath($path).TrimEnd([char]92) -split '\\'
    $acc = $parts[0] + [char]92
    foreach ($part in $parts[1..($parts.Count - 1)]) {
        if (-not $part) { continue }
        $acc = Join-Path $acc $part
        $item = Get-Item -LiteralPath $acc -Force -ErrorAction SilentlyContinue
        if ($item -and $item.LinkType -and "$($item.Target)") { $acc = Resolve-Real "$($item.Target)" }
    }
    $acc.TrimEnd([char]92)
}

if (-not (Test-Path $target)) { New-Item -ItemType Directory -Force $target | Out-Null }

foreach ($repoSkills in $sources) {
    if (-not (Test-Path $repoSkills)) { continue }
    Get-ChildItem $repoSkills -Directory | ForEach-Object {
        $name = $_.Name
        $link = Join-Path $target $name
        if (Test-Path $link) {
            $existing = Get-Item $link -Force
            if ($existing.LinkType) {
                $stored = "$($existing.Target)"
                if (-not $stored -or (Resolve-Real $stored) -ne (Resolve-Real $_.FullName)) {
                    Write-Warning "$($_.Name): links elsewhere ($($existing.Target)) — remove it and re-run to relink here"
                } else {
                    Write-Host "= $($_.Name) (already linked)"
                }
                return
            }
            $kind = if ($existing.PSIsContainer) { 'directory' } else { 'file' }
            Write-Warning "$($_.Name): a $kind already exists at $link — move it aside and re-run"
            return
        }
        try {
            New-Item -ItemType Junction -Path $link -Target $_.FullName -ErrorAction Stop | Out-Null
        } catch {
            [Console]::Error.WriteLine("error: could not link ${name}: $($_.Exception.Message)")
            exit 1
        }
        if (-not (Get-Item -LiteralPath $link -Force).LinkType) {
            [Console]::Error.WriteLine("error: $name was created but is not a junction")
            exit 1
        }
        Write-Host "+ $($_.Name) -> $($_.FullName)"
    }
}

Write-Host "`nDone. Skills resolve from this repo via junctions; edit here, they're live immediately."
