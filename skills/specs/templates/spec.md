---
area: {{AREA_NAME}}
generated-at: {{HEAD_SHA}}
generated-on: {{YYYY-MM-DD}}
sources:
  - {{RESOLVED_FILE_1}}
shaped-by: []
---

# {{Area Title}}

## Purpose

{{One short paragraph: what this capability is for and who/what depends on it. Grounded in the code, written for a reader who hasn't opened it.}}

## Requirements

### Requirement: {{Short requirement name}}

The system SHALL {{observable behavior, stated as it actually is in the code — bugs included (flag suspected bugs in the regen diff review, but spec the real behavior)}}.

#### Scenario: {{concrete case name}}

- **Given** {{precondition / state}}
- **When** {{action / input}}
- **Then** {{observable outcome}}

#### Scenario: {{edge / failure case name}}

- **Given** {{...}}
- **When** {{...}}
- **Then** {{...}}

<!--
Authoring rules (for the harvester, not the reader):
- Every Requirement carries ≥1 Scenario — scenarios are the populate-tests join point.
- Stable wording: on regen, keep requirements the code still satisfies VERBATIM;
  the diff must mean "behavior changed", never "rephrased".
- shaped-by is append-only and machine-written (FEATURE-NNN provenance).
-->
