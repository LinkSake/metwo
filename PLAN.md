# Plan: luisangel.me Redesign

## Goal

Replace the current blog-centric homepage with a **presentation card** landing page that reflects POSSE principles: own your identity, surface all your content types from one place, feel like a real person — not a portfolio, not a directory.

---

## Phases

### Phase 0 — Decide before touching code ✅

All decisions resolved. See `CONTEXT.md` for full rationale.

- [x] **0.1 — Aesthetics:** System default + manual toggle / Mixed type (serif body, sans/mono UI) / Ayu Light + Ayu Mirage palette / Airy density
- [x] **0.2 — Content on landing:** Bio + socials (primary) → Notes → Lately → Latest posts → Featured project. All sections: 2–3 items + "see more" link.
- [x] **0.3 — Theme strategy:** Option A — build custom theme from scratch at `/themes/metwo`.
- [x] **0.4 — Short-form notes:** Yes. Hugo `notes` content type, ~300 words max, no title required. Syndicate to Bluesky (and Mastodon when a new instance is set up).

> **Note — automating `sync-lately.sh`:** Investigate running the script on a schedule without a always-on server. Two options to evaluate later:
> 1. **GitHub Actions scheduled workflow** (`on: schedule: cron`) — free for public repos, limited minutes for private. Would commit the updated `data/lately.yaml` back to the branch and trigger a Hugo rebuild. Simple, no infrastructure.
> 2. **Cron on a cheap/free host** — e.g. a free-tier fly.io machine, a Raspberry Pi, or the same VM this site runs on if it has one. More flexible but more to maintain.
> GH Actions is likely the right first answer. Revisit after the theme is done.

---

### Phase 0.5 — Data & content prep (new, before Phase 1)
Groundwork that doesn't require the theme to exist yet.

- [x] **0.5.1 — Substack import script** — `scripts/import-substack.py`
  Pure Python 3 stdlib HTML→markdown converter. Handles poetry `<pre>` blocks, Substack CDN image extraction, subscribe widget stripping. 38 posts imported (19 EN + 19 ES). Idempotent via `.imported-substack-guids`.
  Write a script (`scripts/import-substack.sh`) that:
  - Fetches both Substack RSS feeds (EN: `linksake.substack.com/feed`, ES: `luisangelortega.substack.com/feed`)
  - Strips Substack-specific HTML (subscribe widgets, share buttons, Substack image CDN wrappers)
  - Converts content to clean markdown
  - Generates Hugo frontmatter: `title`, `date`, `lang`, `categories: [works]`, `original_url` (for canonical reference)
  - Places files in `content/en/post/` and `content/es/post/` respectively
  - Is idempotent (won't duplicate posts on re-run, uses `guid` as dedup key)

- [x] **0.5.2 — Unified "Lately" sync script** — `scripts/sync-lately.sh`
  Pulls from GoodReads (currently-reading RSS), Letterboxd (watched RSS), and Raindrop.io (API). Writes `data/lately.yaml`. Ratings converted to ★ strings. Gracefully skips Raindrop if `.env` not set.

- [x] **0.5.3 — Notes content type scaffold**
  - `content/en/notes/` + `content/es/notes/` with `_index.md`
  - `archetypes/notes.md` — minimal frontmatter (date only, no title)
  - Notes added to both language menus (weight 5) in `hugo.toml`
  - Notes RSS feeds: `/notes/index.xml` + `/es/notes/index.xml`
  - i18n strings added to `en.yaml` + `es.yaml`

---

### Phase 1 — Theme scaffold ← current
Create the new custom theme and migrate the site to it without changing any content or layout yet.

- [ ] **1.1** Create `/themes/metwo` with `theme.toml`, `layouts/`, `static/css/`.
- [ ] **1.2** Introduce `baseof.html` block pattern. Split the current monolithic `header.html` (which contains the full `<!DOCTYPE>`…`<body>`) into proper partials: `head.html`, `header.html`, `footer.html`, `foot_custom.html`.
- [ ] **1.3** Port `_default/single.html`, `list.html`, `terms.html`, `rss.xml`, `404.html` using `{{ define "main" }}` blocks.
- [ ] **1.4** Consolidate CSS: merge `hugo-classic/static/css/style.css` + `fonts.css` + `static/css/theme-override.css` into `/themes/metwo/static/css/main.css`. Remove `custom_css` param from `hugo.toml`.
- [ ] **1.5** Update `hugo.toml`: `theme = "metwo"`. Remove `.gitmodules` submodule entry.
- [ ] **1.6** Delete the now-redundant root `layouts/` files and `static/css/theme-override.css`.
- [ ] **1.7** Verify all existing pages render correctly. Fix any regressions.

---

### Phase 2 — Typography & design tokens
Establish the visual foundation before any layout work. Everything in CSS custom properties.

- [ ] **2.1** Choose and load typefaces. Candidates to evaluate:
  - Body/headings serif: *Lora*, *Playfair Display*, *Literata*, *Source Serif 4*
  - UI/labels sans: *Inter*, *DM Sans*, system-ui stack
  - Mono: *JetBrains Mono*, *Fira Code*, system mono stack
  - Self-host via Bunny Fonts or manual download (no Google Fonts for privacy).
- [ ] **2.2** Define CSS custom properties:
  ```css
  --font-body, --font-heading, --font-mono
  --color-bg, --color-surface, --color-text, --color-muted, --color-accent, --color-border
  --space-xs through --space-2xl
  --radius-sm, --radius-md
  --measure (max prose width)
  ```
  Implement both light (Ayu Light) and dark (Ayu Mirage) token sets, switched via `prefers-color-scheme` and a `data-theme` attribute for the manual toggle.
- [ ] **2.3** Baseline: body font-size (`1rem`/`16px`), line-height (`1.65`), measure (`65ch`), paragraph spacing.
- [ ] **2.4** Style base HTML: `h1–h6`, `p`, `a`, `blockquote`, `code`, `pre`, `ul/ol`, `hr`, `img`. Posts should look good before any component work.
- [ ] **2.5** Implement the light/dark toggle: a small button in the header that sets `data-theme="light"|"dark"` on `<html>` and persists to `localStorage`.

---

### Phase 3 — Landing page layout
The core of the redesign. Inspired by paco.me (card feel) and jamesg.blog (multi-stream).

- [ ] **3.1 — Bio card**
  Name, one-paragraph description, avatar, social links (email, Mastodon, Bluesky, Instagram, Substack EN, Substack ES). Handshake, not resume. `h-card` microformat markup.

- [ ] **3.2 — Latest notes**
  Short-form stream from `content/*/notes/`. Newest first, date + body, no title. Link to `/notes` for full list.

- [ ] **3.3 — Lately**
  Driven by `data/lately.yaml` (output of `sync-lately.sh`). Three sub-rows: 📖 book, 🎬 film, 🔗 links (last 3). Single "see more" link to `/garden/latest-reads`.

- [ ] **3.4 — Latest posts**
  3 most recent posts. Title + date. No excerpts. Link to `/post` archive.

- [ ] **3.5 — Featured project**
  One highlighted project, manually curated in a Hugo data file (`data/featured-project.yaml`). Name, one-line description, link.

- [ ] **3.6** Wire up EN and ES versions fully. All UI strings go through `i18n/en.yaml` and `i18n/es.yaml`.

---

### Phase 4 — Inner pages
Style the rest of the site to match the new theme.

- [ ] **4.1** Post/article single page — title, date, reading time, body, tags.
- [ ] **4.2** List/archive pages (writings categories, post archive, tags).
- [ ] **4.3** Notes list page — reverse-chron stream, paginated.
- [ ] **4.4** Projects page.
- [ ] **4.5** Garden pages (index + individual notes + latest-reads).
- [ ] **4.6** About page — lighter now that the bio is on the landing.
- [ ] **4.7** 404 page.

---

### Phase 5 — POSSE plumbing
Make the site a first-class IndieWeb citizen.

- [ ] **5.1** RSS/Atom feeds for every content type: posts (already exists), notes (new), garden reads. Per-section feeds for writings subcategories.
- [ ] **5.2** Add `rel="me"` links to Mastodon and Bluesky in the `<head>` for identity verification.
- [ ] **5.3** Microformats2: `h-card` on bio card, `h-entry` on posts and notes.
- [ ] **5.4** Review `sitemap.xml` and `robots.txt`.
- [ ] **5.5** Bluesky cross-posting for notes — evaluate `atp` CLI or a simple script using the AT Protocol API.
- [ ] **5.6** *(Stretch)* Webmentions — add endpoint and/or display received Webmentions on posts.

---

### Phase 6 — Polish & ship

- [ ] **6.1** Performance: image optimization, CSS bundle size, font loading (`font-display: swap`).
- [ ] **6.2** Accessibility: contrast ratios (WCAG AA minimum), keyboard navigation, semantic HTML, `aria` where needed.
- [ ] **6.3** Mobile: all layouts reviewed at 375px, 390px, 768px viewports.
- [ ] **6.4** Cross-browser sanity check (Firefox, Safari, Chrome).
- [ ] **6.5** Merge `redesign/posse-landing` → `main`, deploy.

---

## Current status

- Phase 0 ✅ — all decisions locked
- Phase 0.5.1 ✅ — Substack import (38 posts, EN + ES)
- Phase 0.5.2 ✅ — `sync-lately.sh` live, `data/lately.yaml` generating
- Phase 0.5.3 ✅ — notes content type scaffolded
- **Next:** Phase 1 — custom theme scaffold (`/themes/metwo`)
