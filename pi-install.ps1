# Installs the lifecycle skills into ~/.pi/agent/skills as directory junctions
# pointing back into this repo — the repo stays the single source of truth,
# so `git pull` updates the live skills with no re-install.
#
# Links BOTH skills/ (the shared set, same as install.ps1) AND skills-pi/ —
# pi-only stubs of the Claude Code built-ins (code-review, review,
# security-review) so pi resolves those references instead of skipping the
# review gates. skills-pi/ must NEVER be linked into ~/.claude/skills: there
# the real built-ins exist and the stubs would shadow them.
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
