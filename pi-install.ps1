# Links BOTH skills/ and skills-pi/ into ~/.pi/agent/skills as directory junctions, one per skill folder.
# skills-pi/ is never linked into ~/.claude/skills.
# Why links rather than copies: ADR 0009. Why that tree is pi-only and frozen: ADR 0010.
#
# Usage:  ./pi-install.ps1      (idempotent; safe to re-run)

$sources = @(
    (Join-Path $PSScriptRoot 'skills'),
    (Join-Path $PSScriptRoot 'skills-pi')
)
$target = Join-Path $HOME '.pi\agent\skills'

if (-not (Test-Path $target)) { New-Item -ItemType Directory -Force $target | Out-Null }

foreach ($repoSkills in $sources) {
    if (-not (Test-Path $repoSkills)) { continue }
    Get-ChildItem $repoSkills -Directory | ForEach-Object {
        $link = Join-Path $target $_.Name
        if (Test-Path $link) {
            $existing = Get-Item $link -Force
            if ($existing.LinkType) {
                if ($existing.Target -ne $_.FullName) {
                    Write-Warning "$($_.Name): links elsewhere ($($existing.Target)) — remove it and re-run to relink here"
                } else {
                    Write-Host "= $($_.Name) (already linked)"
                }
                return
            }
            Write-Warning "$($_.Name): a real directory already exists at $link — move it aside and re-run"
            return
        }
        New-Item -ItemType Junction -Path $link -Target $_.FullName | Out-Null
        Write-Host "+ $($_.Name) -> $($_.FullName)"
    }
}

Write-Host "`nDone. Skills resolve from this repo via junctions; edit here, they're live immediately."
