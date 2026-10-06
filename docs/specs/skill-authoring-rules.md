---
area: skill-authoring-rules
generated-at: 20c038b36b869ce21fee8cdd7d30bd0a8bcdfae9
generated-on: 2026-10-06
sources:
  - .github/workflows/skills-lint-test.sh
  - .github/workflows/skills-lint.sh
shaped-by: [FEATURE-002]
shaped-by-derived: true
shaped-by-unresolved: 5
---

# If you write your own skill, the shape it must have — frontmatter, links, refs

## Purpose

A skill in this repo is a folder of Markdown that an agent reads at runtime, so the only thing standing between a malformed skill and every project that has it installed is the repository lint, `skills-lint.sh`. It runs eight numbered checks over the `skills/` and `skills-pi/` trees. Seven can fail the run: frontmatter shape, wikilinks, relative file links, cross-skill flags, the two copies of the comment rule, CRLF-tolerant id patterns, and shell-script line endings. The eighth, install-root drift, only advises. The lint has its own regression suite, `skills-lint-test.sh`, which runs 71 cases against a throwaway two-tree fixture. Anyone authoring or editing a skill depends on this gate. So does anyone installing one, because a skill that passes here can still fail to load in pi if the lint misses the defect.

## Requirements

### Requirement: Refuse a vacuous pass

The system SHALL fail the run when either `skills/` or `skills-pi/` is missing at the repository root, and SHALL fail it when neither tree contains a single skill folder, so that a missing tree can never produce a clean result.

#### Scenario: A whole skill tree is missing

- **Given** a repository with `skills/` but no `skills-pi/`
- **When** the lint runs
- **Then** it reports that the expected tree `skills-pi` is missing and exits non-zero

#### Scenario: A clean fixture passes

- **Given** a fixture with skills `alpha` and `beta` in `skills/` and `gamma` in `skills-pi/`, all well formed
- **When** the lint runs
- **Then** it prints `skills-lint: OK (3 skills)` and exits 0

### Requirement: Every skill folder carries a SKILL.md opening with frontmatter

The system SHALL treat every immediate subfolder of `skills/` and `skills-pi/` as a skill and SHALL fail the run when it has no `SKILL.md`, or when that file's first line is not exactly `---` or nothing non-empty follows it before a closing `---`. A missing closing `---` is not detected: the rest of the file is read as frontmatter.

#### Scenario: A folder with no SKILL.md

- **Given** an empty folder `skills/orphan/`
- **When** the lint runs
- **Then** it reports that `skills/orphan` has no SKILL.md and exits non-zero

#### Scenario: A name that appears only inside a fenced block

- **Given** a SKILL.md whose frontmatter has `description:` but no `name:`, and whose body contains `name: beta` inside a code fence
- **When** the lint runs
- **Then** it reports that the file has no `name:`, because only the frontmatter is read

### Requirement: The frontmatter name is a valid, folder-matching identifier

The system SHALL fail the run when the frontmatter `name:` is missing, does not equal the folder's name, contains any character other than `a-z`, `0-9` and `-`, starts or ends with a hyphen, contains a doubled hyphen, or is longer than 64 characters. The value is compared exactly as written, so a quoted name such as `"beta"` does not match the folder `beta`.

#### Scenario: Name does not match the folder

- **Given** `skills/beta/SKILL.md` declaring `name: not-beta`
- **When** the lint runs
- **Then** it reports that name `not-beta` does not match folder `beta` and exits non-zero

#### Scenario: Uppercase, underscore or doubled hyphen

- **Given** a skill folder and name `Beta_2`, or one named `be--ta`
- **When** the lint runs
- **Then** it reports that the name must be a-z, 0-9 and single inner hyphens, and exits non-zero

#### Scenario: Name over 64 characters

- **Given** a skill whose folder and name are 65 lowercase letters
- **When** the lint runs
- **Then** it reports that the name is 65 characters and the limit is 64 (no case in the test suite pins this branch)

### Requirement: A skill name exists in only one tree

The system SHALL fail the run when the same folder name exists in both `skills/` and `skills-pi/`, because pi links both trees into one root and drops the second.

#### Scenario: Same name in both trees

- **Given** `skills/beta/` and a copy at `skills-pi/beta/`
- **When** the lint runs
- **Then** it reports that skill `beta` exists in both trees and exits non-zero

### Requirement: The description line must be present and must parse as YAML

The system SHALL fail the run when the frontmatter has no `description:` line. It SHALL also fail the run when the value on that line does not start with `"`, `'`, `|` or `>` and either contains `: ` (which pi's YAML parser rejects) or contains ` #` (which YAML reads as the start of a comment, cutting the description short). The system SHALL accept any value that starts with a quote or block-scalar indicator without further inspection. It SHALL NOT fail an empty description (`description:` or `description: ""`), a value ending in a bare `:`, or a value starting with another YAML indicator such as `*`, `[` or `{`.

#### Scenario: Missing description

- **Given** a SKILL.md whose frontmatter has `name: beta` and no `description:` line
- **When** the lint runs
- **Then** it reports that there is no `description:` and exits non-zero

#### Scenario: Unquoted colon-space

- **Given** `description: Do a thing: then another`
- **When** the lint runs
- **Then** it reports that the description is unquoted and contains `': '`, and exits non-zero

#### Scenario: Unquoted space-hash

- **Given** `description: Review PR #N`
- **When** the lint runs
- **Then** it reports that YAML truncates the description at `' #'`, and exits non-zero

#### Scenario: A quoted value may contain both

- **Given** `description: "Do a thing: then #N"`
- **When** the lint runs
- **Then** the description is accepted

#### Scenario: Empty description passes

- **Given** a frontmatter line that reads `description:` with no value
- **When** the lint runs
- **Then** the run passes: the lint does not detect an empty description

### Requirement: The description fits pi's length limit when it is on one line

The system SHALL fail the run when the text after `description:` on that line is longer than 1024 characters. Under a C locale this counts bytes, which is never less than pi's character count. Only that single line is measured, so a block-scalar description (`|` or `>`) whose text continues on later lines is measured as one character and is never length-checked.

#### Scenario: Description over 1024 characters

- **Given** a one-line description of 1025 characters
- **When** the lint runs
- **Then** it reports that the description is 1025 characters and the limit is 1024, and exits non-zero

#### Scenario: A long block-scalar description is not measured

- **Given** `description: |` followed by an indented 2000-character line
- **When** the lint runs
- **Then** the run passes

### Requirement: Every wikilink resolves to a skill folder or a known runtime built-in

The system SHALL scan every `.md` file under `skills/` and `skills-pi/`, including files under `templates/`. In each file it SHALL extract every `[[target]]` or `[[target|alias]]` and fail the run unless `target` exactly matches, case included, the name of a folder in either tree or one of the runtime references `init`, `update-config` and `Explore`. Content inside fenced code blocks (backtick or tilde, at least three, with the fence length tracked so a shorter inner fence does not close an outer one) and inside single- or double-backtick inline code spans SHALL be ignored. Files that do not end in `.md`, and wikilinks anywhere outside the two trees, SHALL NOT be checked.

#### Scenario: Unknown, mis-cased or misspelled target

- **Given** `SKILL.md` content `See [[no-such-skill]].`, or `[[Beta]]`, or `[[jira_task]]`, or `[[al.ha]]`
- **When** the lint runs
- **Then** it reports that the file references a skill that does not exist, and exits non-zero

#### Scenario: Aliased link

- **Given** `[[beta|the beta skill]]` and, separately, `[[no-such-skill|display text]]`
- **When** the lint runs
- **Then** the first is accepted, because only the part before `|` is resolved, and the second fails

#### Scenario: Illustrative links in code

- **Given** `[[my-new-skill]]` inside a backtick fence, `[[no-such-thing]]` inside a tilde fence, `[[nope-skill]]` inside a three-backtick fence nested in a four-backtick fence, and `[[no-such-skill]]` inside a double-backtick span
- **When** the lint runs
- **Then** none of them is reported

### Requirement: An unclosed code fence fails the file

The system SHALL fail the run when a scanned `.md` file opens a code fence it never closes, and SHALL say that the rest of the file cannot be checked. Without this, the unclosed fence would hide every link after it.

#### Scenario: Unbalanced fence hiding broken links

- **Given** a companion doc that opens a fence and then contains `[[definitely-not-a-skill]]` and `[x](nope.md)` with no closing fence
- **When** the lint runs
- **Then** it reports an unbalanced code fence and exits non-zero

### Requirement: Relative Markdown links resolve, case-sensitively

The system SHALL scan every `.md` file under both trees except those under a `templates/` path, because template links resolve in the generated project rather than here. In each file it SHALL check every inline link target `](...)` that is not `http…`, `mailto:` or a bare `#anchor`. Before resolving, it SHALL drop any trailing `"title"` or `'title'` and any `#fragment`. It SHALL resolve a target starting with `/` from the repository root and any other target from the linking file's folder. It SHALL fail the run when the resulting path does not exist with exactly that case. Content in fences and inline code spans SHALL be ignored. Reference-style link definitions (`[x]: path`) SHALL NOT be checked.

#### Scenario: Broken link in a companion doc

- **Given** `skills/alpha/companion.md` containing `[x](nope.md)`
- **When** the lint runs
- **Then** it reports that the file links to `nope.md`, not found from `skills/alpha`, and exits non-zero

#### Scenario: Mis-cased file link

- **Given** `[x](SKILL.MD)` next to a real `SKILL.md`, on a case-insensitive filesystem
- **When** the lint runs
- **Then** it still fails, because the file name is matched case-sensitively

#### Scenario: Title, anchor, root-relative and template links

- **Given** `[x](SKILL.md "The title")`, `[x](SKILL.md#a-section)`, `[x](/skills/beta/SKILL.md)`, and a `templates/seed.md` linking to `tasks/README.md`
- **When** the lint runs
- **Then** none of them is reported

### Requirement: A flag passed to another skill's verb is declared by that verb

The system SHALL search every file under `skills/` (any extension, `templates/` included, `skills-pi/` excluded) for invocations shaped like `/<skill> <verb> [one more lowercase word] [args] --flag [args] [--flag …]`. An argument SHALL be accepted only as a `<placeholder>`, a `{{TOKEN}}`, a word starting with a capital letter or digit, or `...`. A bare lowercase word SHALL end the match, so that prose cannot be mistaken for an invocation. For each match whose `skills/<skill>/` exists, the system SHALL use `skills/<skill>/verbs/<verb>.md` as the receiver, falling back to `skills/<skill>/SKILL.md`. It SHALL fail the run for each space-preceded flag in the match that does not appear anywhere in the receiver as a whole flag, bounded on both sides by characters outside `[a-z-]`. This is an existence check only: a receiver that mentions a flag in order to reject it still satisfies it. A flag that comes after a bare lowercase value (`--real value --nosuch`) falls outside the match and SHALL NOT be checked.

#### Scenario: Undeclared flag

- **Given** alpha's SKILL.md says ``Run `/beta go --nosuch` `` and `skills/beta/verbs/go.md` declares only `--real`
- **When** the lint runs
- **Then** it reports that alpha passes `--nosuch` to `/beta go`, not declared in the receiver, and exits non-zero

#### Scenario: Declared in bullets or in a table

- **Given** the invocation uses `--real` and the receiver declares it in a bullet, or uses `--tabled` and the receiver shows it in an invocation table
- **When** the lint runs
- **Then** the invocation is accepted

#### Scenario: A prefix of a declared flag

- **Given** the invocation uses `--unattend` and the receiver declares only `--unattended`
- **When** the lint runs
- **Then** it fails, because the match is anchored

#### Scenario: Arguments and a second flag

- **Given** ``/beta go <target> --nosuch``, and separately ``/beta go --real VALUE --nosuch``, against a receiver declaring only `--real`
- **When** the lint runs
- **Then** both fail on `--nosuch`, and ``/beta go <target> --real`` passes

#### Scenario: Prose and foreign paths are not invocations

- **Given** the unbackticked sentence `The /beta go step runs before the --nosuch cleanup in your log.`, and separately ``/usr/bin/thing go --whatever``
- **When** the lint runs
- **Then** neither is reported. The first fails to match because of the lowercase words, and the second because `skills/usr/` does not exist.

#### Scenario: Templates and non-Markdown files are scanned

- **Given** ``/beta go --nosuch`` inside `skills/alpha/templates/seed.md` or `skills/alpha/templates/README.md.tmpl`
- **When** the lint runs
- **Then** it fails on `--nosuch`

### Requirement: The two copies of the comment rule are byte-identical

The system SHALL extract, from `AGENTS.md` and from `skills/new-project/templates/CONVENTIONS-universal.md`, the first block running from a line that is exactly `<!-- comment-rule:start -->` to a line that is exactly `<!-- comment-rule:end -->`, ignoring surrounding whitespace and a trailing CR on the marker lines only. When neither file has a block, it SHALL print that there is nothing to compare and pass. When only one file has a block, it SHALL fail and name the missing side. When the blocks differ in any byte, it SHALL fail. When they match, it SHALL report the line count. A marker that is only mentioned mid-line SHALL NOT start the block. This check is fatal, unlike check 6.

#### Scenario: Identical blocks

- **Given** both files carry the same delimited block
- **When** the lint runs
- **Then** it reports that the two files agree, with the line count, and passes

#### Scenario: One word of drift

- **Given** the AGENTS.md copy says `cannot carry, and nothing else.` where the template says `cannot carry.`
- **When** the lint runs
- **Then** it reports that the block differs between AGENTS.md and the template, and exits non-zero

#### Scenario: One side missing

- **Given** only the template carries the block, or only AGENTS.md does
- **When** the lint runs
- **Then** it fails, saying either "AGENTS.md does not" or "consumers would receive nothing"

#### Scenario: Neither file present

- **Given** a repository with neither file
- **When** the lint runs
- **Then** it prints `nothing to compare` and passes

#### Scenario: Prose mentioning the markers

- **Given** AGENTS.md mentions both markers in backticks on a prose line above a correct block
- **When** the lint runs
- **Then** the copies are still reported as agreeing

### Requirement: Install-root drift is reported but never changes the exit code

The system SHALL inspect the Claude root (`$CLAUDE_SKILLS_ROOT`, default `~/.claude/skills`) against `skills/`, and the pi root (`$PI_SKILLS_ROOT`, default `~/.pi/agent/skills`) against `skills/` and `skills-pi/`. It SHALL print every finding as an advisory `~` line and SHALL NOT change the exit code. For each root it SHALL report:

- that the root was skipped, if it does not exist
- each skill folder with no entry of that name in the root, or one summary line when no expected skill is linked
- each link into this repository whose target directory no longer exists (stale)
- each link into one of this repository's trees that the root is not meant to hold (a shadow)
- that the root is in sync, when none of the above applies

A link counts as pointing into this repository when its raw target contains `/<repo-folder-name>/`. The tree is taken from the last occurrence of that component. Links into other repositories SHALL be ignored. Any existing entry, including a copied folder rather than a link, SHALL count as linked.

#### Scenario: Absent and empty roots

- **Given** no root directories exist, or both exist but are empty
- **When** the lint runs
- **Then** it prints `skipped …` for absent roots, or one `exists but nothing is linked into it` line per empty root, and exits 0

#### Scenario: One skill not linked

- **Given** the Claude root links `alpha` but not `beta`
- **When** the lint runs
- **Then** it prints `beta is not linked into` that root and exits 0

#### Scenario: Stale junction and foreign link

- **Given** the Claude root holds a link to a deleted `skills/ghost`, and a dangling link into another repository
- **When** the lint runs
- **Then** it reports the first as a stale junction, says nothing about the second, and exits 0

#### Scenario: skills-pi shadowing the Claude root

- **Given** the Claude root links `gamma` from `skills-pi/` and nothing from `skills/`
- **When** the lint runs
- **Then** it reports that the link points into a tree never linked into this root, summarises the root as having `only shadow junctions`, does not call it empty, and exits 0

#### Scenario: Fully linked roots and a repeated repo name

- **Given** both roots correctly linked, or the Claude root linked into `<repo>/wt/<repo>/skills/`
- **When** the lint runs
- **Then** each root is reported in sync, `gamma` is not reported missing from the Claude root, and nested links are not reported as shadows

### Requirement: An `^id:` search pattern tolerates CRLF line endings

The system SHALL fail the run for every line under `skills/` or `skills-pi/` containing an `^id: …$` pattern whose `$` follows a character other than `*`, a backtick or a double quote. The fix is to end the pattern with `[[:space:]]*$`, which also matches the `\r` of a CRLF task file. Inline code and quotes SHALL NOT exempt a line.

#### Scenario: Bare dollar in backticks or quotes

- **Given** ``Grep `^id: TASK-NNN$` ``, or `git grep -E "^id: (EPIC|TASK)-[0-9]+$"`
- **When** the lint runs
- **Then** it reports that the pattern ends in a bare `$`, and the run ends `skills-lint: FAILED`

#### Scenario: CRLF-tolerant pattern

- **Given** ``Grep `^id: TASK-NNN[[:space:]]*$` ``
- **When** the lint runs
- **Then** it prints that every `^id:` pattern tolerates CRLF, and passes

### Requirement: Shell scripts are stored as LF text

The system SHALL fail the run for any `*.sh` file anywhere in the working tree outside `.git/`, tracked or not, that contains a carriage return followed by another character on the same line. Inside a git work tree it SHALL also fail the run for any tracked `*.sh` file whose index line-ending state, as reported by `git ls-files --eol`, is anything other than `i/lf`. That covers `crlf`, `mixed`, `-text`, `none`, and the empty state of an empty file. A file that is CRLF only in the working copy SHALL pass, because git normalises it on commit. Outside a git work tree the index half SHALL be skipped silently.

#### Scenario: Carriage return inside a line

- **Given** an untracked `tool.sh` containing `echo a\rb`
- **When** the lint runs
- **Then** it reports a carriage return inside a line and exits non-zero

#### Scenario: CRLF working copy outside git

- **Given** `tool.sh` with CRLF endings and no git repository
- **When** the lint runs
- **Then** it passes

#### Scenario: Stored as CRLF or as binary

- **Given** a git repo where `tool.sh` is staged with CRLF under `*.sh -text`, or is classed as binary because it contains a lone CR
- **When** the lint runs
- **Then** it reports `stored as crlf` or `stored as -text` respectively, and exits non-zero

### Requirement: Failures inside subshells still fail the run, and nothing leaks between runs

The system SHALL record failures found in piped loops (checks 2, 3 and 4) in a temporary file outside the repository, which is deleted on exit. It SHALL exit 1 and print `skills-lint: FAILED` if any check recorded a failure, and otherwise print `skills-lint: OK (<n> skills)` and exit 0. A leftover `.lint-fail` file in the repository SHALL have no effect.

#### Scenario: Stale sentinel in the repo

- **Given** a file `.lint-fail` containing `x` at the repository root of a clean fixture
- **When** the lint runs
- **Then** it passes

### Requirement: The lint's own suite runs hermetically before the lint

The test suite SHALL build a fresh fixture for every case: a copy of the lint plus a minimal valid two-tree repo. Each case SHALL assert one of four things: the exit status, a substring on a failing run, a substring on a passing run, or the absence of a substring on a run where check 6 demonstrably ran. The suite SHALL point both install roots at a non-existent path unless a case overrides them, and on Windows it SHALL create link fixtures as junctions when `ln -s` produced a copy. It SHALL report the count of passed and failed cases and exit non-zero on any failure.

#### Scenario: Developer's own installed skills do not affect the result

- **Given** a developer with skills installed under `~/.claude/skills`
- **When** the suite runs
- **Then** every case other than the install-root cases sees the roots as absent, and the total is 71 cases
