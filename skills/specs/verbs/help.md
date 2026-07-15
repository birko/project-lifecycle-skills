# /specs help

Print this and exit:

```
/specs — capability specs harvested from code, reviewed as diffs

  /specs                      staleness summary (verify, compact)
  /specs init                 discovery pass → propose + bless the area map (.map.yml)
  /specs regen <area> [...]   harvest area(s) → diff review → stamp provenance
  /specs regen --all          every area (parallel harvest, serial review)
  /specs regen --story STORY-NNN      areas touched by a closed story (the /tasks close hook)
  /specs regen --feature FEATURE-NNN  areas touched by a feature (the /feature review hook)
  /specs verify               full read-only staleness report
  /specs show <area>          print one spec + freshness

Specs live in docs/specs/ — .map.yml (hand-editable area map) + one generated <area>.md
per capability. Code is the source of truth; an unexpected regen diff is a finding.
```
