# br-screenshots

Image/screenshot host for **Claude Code** sessions. GitHub has no `gh`/REST API for
the browser-only drag-and-drop attachment path (`github.com/user-attachments`), so
Claude cannot attach images to issues, PRs, or review comments directly. This repo
is the workaround: an image is committed here via the Contents API, and its stable
`raw.githubusercontent.com` URL is embedded in the target markdown, where it renders
inline for everyone.

Upload is automated — see `.claude/skills/screenshot-upload/` and
`.claude/scripts/upload-screenshot.sh` in the monorepo. Don't hand-manage this repo.

## ⚠️ This repo is PUBLIC — world-readable

Inline rendering only works from a public repo (GitHub's image proxy can't
authenticate to private/internal raw URLs). The tradeoff: **anything committed here
is public forever** (git history preserves it even after deletion).

**Never upload:** secrets, tokens, credentials, PII, customer data, prod database
contents, or internal admin-UI screenshots that expose any of the above. When in
doubt, don't. Safe content: public-facing UI, rendered diagrams, before/after
mockups, anonymized graphs.

## Layout

```
<yyyy-mm>/<slug>.<ext>
```

- One folder per month, e.g. `2026-07/`.
- `slug` is a short kebab-case name (often the issue/PR number + subject).
- Formats: `png`, `jpg`, `gif`, `webp`.

Raw URL to embed:

```
https://raw.githubusercontent.com/borma-dago/br-screenshots/main/<yyyy-mm>/<slug>.<ext>
```

## Retention

Monthly folders make pruning cheap. Delete folders older than **12 months**
occasionally — embedded links in long-closed issues/PRs are the only thing that
breaks, and those are historical by then.
