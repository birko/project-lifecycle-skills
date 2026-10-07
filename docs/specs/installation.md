---
area: installation
generated-at: 53c587805869ccff17920c6cc4270a34136d3b2d
generated-on: 2026-10-07
sources:
  - install.ps1
  - install.sh
  - pi-install.ps1
  - pi-install.sh
shaped-by: [FEATURE-002]
shaped-by-derived: true
shaped-by-unresolved: 5
---

# Installing the skills into an agent runtime — Claude Code, or the in-house pi runtime

## Purpose

Installation makes the skills in this repository visible to an agent runtime without copying them. Four scripts do it: `install.sh` and `install.ps1` put one link per skill folder of `skills/` into `~/.claude/skills` for Claude Code, and `pi-install.sh` and `pi-install.ps1` put one link per skill folder of both `skills/` and `skills-pi/` into `~/.pi/agent/skills` for pi. The bash scripts make symbolic links and the PowerShell scripts make directory junctions. Because each entry is a link, an edit to a skill in this repository is live in every runtime right away, but a newly added skill folder has no link until an installer is run again. Every developer and project on the machine that uses these skills depends on this.

## Requirements

### Requirement: Claude Code installs only the generic tree

The system SHALL, when `install.sh` or `install.ps1` runs, link each immediate subfolder of the repository's `skills/` folder into `~/.claude/skills` under the same folder name, and SHALL NOT link anything from `skills-pi/`.

#### Scenario: A fresh Claude Code install

- **Given** `~/.claude/skills` has no entry named `tasks`, and the repository has `skills/tasks/`
- **When** the developer runs `./install.sh`
- **Then** `~/.claude/skills/tasks` is created as a symbolic link to the repository's `skills/tasks` folder and the script prints `+ tasks -> <path>`

#### Scenario: Review stubs stay out of Claude Code

- **Given** `skills-pi/code-review/` exists in the repository
- **When** the developer runs `./install.ps1`
- **Then** no `code-review` entry is created in `~/.claude/skills`, so Claude Code's built-in review skill is not shadowed

### Requirement: pi installs both trees into one root

The system SHALL, when `pi-install.sh` or `pi-install.ps1` runs, link each immediate subfolder of `skills/` and then of `skills-pi/` into `~/.pi/agent/skills`, processing `skills/` first, and SHALL skip a tree that does not exist without error.

#### Scenario: Both trees present

- **Given** the repository has `skills/tasks/` and `skills-pi/review/`
- **When** the developer runs `./pi-install.sh`
- **Then** `~/.pi/agent/skills/tasks` and `~/.pi/agent/skills/review` are both created as links to their source folders

#### Scenario: The pi-only tree is missing

- **Given** the repository has no `skills-pi/` folder
- **When** the developer runs `./pi-install.ps1`
- **Then** the folders of `skills/` are linked and the script finishes without reporting an error for `skills-pi/`

#### Scenario: The same name exists in both trees

- **Given** a folder named `review` exists in both `skills/` and `skills-pi/`
- **When** a pi installer runs on an empty root
- **Then** `review` is linked to the `skills/` copy, and the `skills-pi/` copy is reported as "links elsewhere" and left unlinked

### Requirement: Link type depends on the script, not the operating system

The system SHALL create entries with `ln -s` in the bash installers and with `New-Item -ItemType Junction` in the PowerShell installers. Under Git Bash (when `uname -s` starts with `MINGW` or `MSYS`), the bash installers SHALL append `winsymlinks:nativestrict` to the `MSYS` environment variable, keeping any value it already had, so that `ln -s` makes a native link or fails rather than copying. Every installer SHALL check that each entry it creates is a link, and SHALL report `+ <name> -> <path>` only for an entry that is one.

#### Scenario: PowerShell on Windows

- **Given** a Windows machine with no `~/.claude/skills/domain` entry
- **When** the developer runs `install.ps1`
- **Then** `~/.claude/skills/domain` is created as a directory junction pointing at `skills/domain`

#### Scenario: Bash under Git Bash on Windows without symlink rights

- **Given** Git Bash on Windows, where the developer has no right to create native symbolic links
- **When** the developer runs `./install.sh`
- **Then** `ln -s` fails instead of copying the folder, nothing is left at the entry's path, the script writes `error: could not link <name> — on Windows without symlink rights, run the .ps1 installer instead` to standard error, and it exits with status 1 without printing its closing line

#### Scenario: The developer's own MSYS setting is kept

- **Given** Git Bash on Windows with `MSYS` set to `noglob`
- **When** the developer runs `./pi-install.sh`
- **Then** `ln -s` runs with `MSYS` set to `noglob winsymlinks:nativestrict`

### Requirement: The target root is created if missing

The system SHALL create the target root (`~/.claude/skills` or `~/.pi/agent/skills`), including any missing parent folders, before linking anything.

#### Scenario: pi has never been set up

- **Given** `~/.pi` does not exist
- **When** the developer runs `./pi-install.sh`
- **Then** `~/.pi/agent/skills` is created and the skills are linked into it

### Requirement: Re-running is safe and leaves correct links alone

The system SHALL, for an entry that is already a link resolving to the same skill folder, leave it unchanged and print `= <name> (already linked)`. The bash scripts SHALL compare the fully resolved physical paths of both sides; the PowerShell scripts SHALL compare the link's stored target with the source folder's full path, case-insensitively, after following any link found at every component of each path.

#### Scenario: A second run with nothing new

- **Given** every skill folder already has a correct link in the target root
- **When** the installer runs again
- **Then** it prints `= <name> (already linked)` for each skill and creates or changes nothing

#### Scenario: A newly added skill folder

- **Given** every existing skill is linked and a new folder `skills/new-skill/` has just been added
- **When** the installer runs again
- **Then** only `new-skill` is linked, reported with `+`, and every other skill is reported as already linked

#### Scenario: The repository is reached through a link

- **Given** `C:\src` is a junction to `D:\work`, the repository was cloned at `D:\work\project-lifecycle-skills`, and `~/.claude/skills/tasks` is a junction to `D:\work\project-lifecycle-skills\skills\tasks`
- **When** the developer runs `C:\src\project-lifecycle-skills\install.ps1`
- **Then** `tasks` is reported `= tasks (already linked)` rather than as linking elsewhere

### Requirement: A link to somewhere else is reported, never replaced

The system SHALL, for an entry that is a link but does not resolve to this repository's skill folder, leave it unchanged and print a warning naming where it points and telling the user to remove it and re-run. The bash scripts SHALL write this warning to standard error, and SHALL also give it for a broken link, since a broken link cannot be resolved. The PowerShell scripts SHALL also give it for a link with no stored target.

#### Scenario: A link from another checkout

- **Given** `~/.claude/skills/tasks` is a link to `D:/old-clone/skills/tasks`
- **When** the developer runs `./install.sh`
- **Then** the link is not touched and the script warns `tasks links elsewhere (D:/old-clone/skills/tasks) — remove it and re-run to relink here`

#### Scenario: A link whose source was deleted

- **Given** `~/.pi/agent/skills/old-skill` is a junction to a folder that no longer exists, and `skills/old-skill/` now lives at a different path
- **When** the developer runs `pi-install.ps1`
- **Then** the junction is not touched and the script warns that `old-skill` links elsewhere

### Requirement: A real folder in the way is reported, never overwritten

The system SHALL, for an entry that exists and is not a link, leave it unchanged and warn that a directory already exists at that path and must be moved aside before re-running. When the entry is a file rather than a folder, the warning SHALL say a file instead of a directory.

#### Scenario: A hand-copied skill folder

- **Given** `~/.claude/skills/feature` is an ordinary folder holding an older copy of the skill
- **When** the developer runs `install.ps1`
- **Then** the folder is not modified and the script warns `feature: a directory already exists at <path> - move it aside and re-run`

#### Scenario: A file in the way

- **Given** `~/.claude/skills/feature` is an ordinary file
- **When** the developer runs `./install.sh`
- **Then** the file is not modified and the script warns `feature: a file already exists at <path> — move it aside and re-run` on standard error

### Requirement: Installers only ever add

The system SHALL NOT remove, rename or repoint any entry in a target root that existed before the installer reached it. The one removal SHALL be the bash installers deleting a non-link entry that their own `ln -s` produced at a path where nothing existed. A link left behind by a renamed or deleted skill folder SHALL remain until someone removes it by hand.

#### Scenario: A skill was renamed

- **Given** `skills/old-name/` was renamed to `skills/new-name/`, and `old-name` was linked by an earlier run
- **When** the installer runs again
- **Then** `new-name` is linked, and the `old-name` entry is left in place pointing at a folder that no longer exists

#### Scenario: `ln -s` leaves a copy instead of a link

- **Given** `~/.claude/skills/tasks` did not exist, and `ln -s` produces an ordinary folder there instead of a link
- **When** `./install.sh` runs
- **Then** that folder is removed, the error is reported, and the run exits with status 1

### Requirement: Failure handling differs between bash and PowerShell

The bash scripts SHALL stop at the first failing command (`set -euo pipefail`). Every installer SHALL stop at the first skill whose link it could not create, or whose created entry is not a link, writing an error naming that skill to standard error and exiting with status 1, with the remaining skills unlinked and the links already made in that run left in place. The bash error SHALL be `error: could not link <name> — on Windows without symlink rights, run the .ps1 installer instead`; the PowerShell error SHALL be `error: could not link <name>: <reason>` when `New-Item` fails, and `error: <name> was created but is not a junction` when the created entry is not a link. All four scripts SHALL exit successfully when every problem was only a warning.

#### Scenario: Link creation is refused in PowerShell

- **Given** `New-Item` cannot create the junction for `tasks`
- **When** `install.ps1` runs
- **Then** the script writes `error: could not link tasks: <reason>` to standard error, prints no `+ tasks` line, links no further skill, and exits with status 1

#### Scenario: Warnings do not fail the run

- **Given** one skill's entry is a real folder and the rest are linked correctly
- **When** `./install.sh` runs
- **Then** it prints the warning and exits with status 0

### Requirement: Every visible subfolder is treated as a skill

The system SHALL treat every immediate subfolder of a source tree as a skill, excluding hidden ones — dot-folders in bash, and folders with the hidden attribute in PowerShell — and SHALL NOT check that the folder contains a `SKILL.md`. In bash, an empty source tree SHALL produce a single link named `*` pointing at the literal path `<tree>/*`, because the folder pattern is left unexpanded.

#### Scenario: A folder without a skill definition

- **Given** `skills/scratch/` exists with no `SKILL.md`
- **When** the installer runs
- **Then** `scratch` is linked into the target root like any skill

#### Scenario: An empty source tree under bash

- **Given** `skills-pi/` exists but has no subfolders
- **When** `./pi-install.sh` runs
- **Then** it creates `~/.pi/agent/skills/*` as a link to the literal path `skills-pi/*` and prints `+ * -> <repo>/skills-pi/*`
