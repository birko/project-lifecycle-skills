# {{PROJECT_NAME}}

{{ONE_LINE_PURPOSE}}

## Status

Early scaffold. See [`tasks/README.md`](tasks/README.md) for the live backlog and [`docs/features/`](docs/features/) for in-flight features.

## Getting started

```
{{GETTING_STARTED_COMMANDS}}
```
<!-- e.g. `npm install && npm run dev` / `dotnet run` / `uv sync && pytest` — fill once the stack skeleton exists. -->

## How we work

Real work flows through a tracked, testable, reviewable lifecycle:

```
idea ─▶ prototype ─▶ decisions ─▶ tasks ─▶ human-test ─▶ review
```

- **Features** — `/feature new` captures an idea, prototypes it for stakeholders, and records decisions (approved / deferred / changed / removed) in `docs/features/`.
- **Tasks** — approved decisions decompose into small, trackable tasks under `tasks/`; each carries a human test plan.
- **Review** — `/feature review` gates on code review + manual-test verification + stakeholder sign-off.

See [`{{AGENT_GUIDE_FILE}}`]({{AGENT_GUIDE_FILE}}) for the full convention.

## Layout

```
{{LAYOUT_TREE}}
```

## License

{{LICENSE_LINE}}
