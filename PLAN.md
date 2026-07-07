# Plan: luisangel.me Redesign

## Goal

Replace the current blog-centric homepage with a presentation card landing page that reflects POSSE principles: own your identity, surface all your content types from one place, feel like a real person — not a portfolio, not a directory.

---

## Phases

### Phase 0 — Decide before touching code ✅

All decisions resolved. See `CONTEXT.md` for full rationale.

- [x] **0.1 — Aesthetics:** System default + manual toggle / Mixed type (serif body, sans/mono UI) / Ayu Light + Ayu Mirage palette / Airy density
- [x] **0.2 — Content on landing:** Bio + socials (primary) → Notes → Lately → Latest posts → Featured project. All sections: 2–3 items + "see more" link.
- [x] **0.3 — Theme strategy:** Build custom theme from scratch at `/themes/metwo`.
- [x] **0.4 — Short-form notes:** Hugo `notes` content type, ~300 words max, no title required. Syndicate to Bluesky (and Mastodon when a new instance is set up).

> **Note — automating `sync-lately.sh`:** Investigate running on a schedule. Two options to evaluate later:
> 1. **GitHub Actions scheduled workflow** (`on: schedule: cron`) — free for public repos. Would commit updated `data/lately.yaml` back and trigger a Hugo rebuild. Simple, no infrastructure.
> 2. **Cron on a cheap/free host** — e.g. a free-tier fly.io machine or a Raspberry Pi. More flexible but more to maintain.
> GH Actions is likely the right first answer. Revisit after the theme is done.

---

### Phase 0.5 — Data & content prep ✅

- [x] **0.5.1 — Substack import** — `scripts/import-substack.py`
  Pure Python 3 stdlib HTML→markdown converter. Handles poetry `<pre>` blocks, Substack CDN image extraction, subscribe widget stripping. 38 posts imported (19 EN + 19 ES). Idempotent via `.imported-substack-guids`.

- [x] **0.5.2 — Unified Lately sync script** — `scripts/sync-lately.sh`
  Pulls from GoodReads (currently-reading RSS), Letterboxd (watched RSS), and Raindrop.io (API). Writes `data/lately.yaml`. Ratings converted to star strings. Gracefully skips Raindrop if `.env` not set.

- [x] **0.5.3 — Notes content type scaffold**
  - `content/en/notes/` + `content/es/notes/` with `_index.md`
  - `archetypes/notes.md` — minimal frontmatter (date only, no title)
  - Notes added to both language menus (weight 5) in `hugo.toml`
  - Notes RSS feeds: `/notes/index.xml` + `/es/notes/index.xml`
  - i18n strings added to `en.yaml` + `es.yaml`

---

### Phase 1 — Theme scaffold ✅

Custom theme `/themes/metwo` built from scratch, replacing the `hugo-classic` git submodule.

- [x] **1.1** Created `/themes/metwo` with `theme.toml`, `layouts/`, `static/css/`.
- [x] **1.2** Introduced `baseof.html` block pattern. Split the old monolithic `header.html` (which contained the full `<!DOCTYPE>`…`<body>`) into proper partials: `head.html`, `header.html`, `footer.html`, `foot_custom.html`.
- [x] **1.3** Ported `_default/single.html`, `list.html`, `terms.html`, `rss.xml`, `404.html` using `{{ define "main" }}` blocks.
- [x] **1.4** Consolidated CSS: merged `hugo-classic/static/css/style.css` + `fonts.css` + `static/css/theme-override.css` into `/themes/metwo/static/css/main.css`. Removed `custom_css` param from `hugo.toml`.
- [x] **1.5** Updated `hugo.toml`: `theme = "metwo"`. Removed `.gitmodules` and submodule entry.
- [x] **1.6** Deleted redundant root `layouts/` files and `static/css/theme-override.css`.
- [x] **1.7** Build verified: 106 pages EN + ES, 0 errors, 0 warnings.

---

### Phase 2 — Typography & design tokens ← current

Establish the visual foundation before any layout work. Everything in CSS custom properties so every later decision is easy to change globally.

- [ ] **2.1 — Typeface selection**
  Decide on the font stack and load strategy (self-hosted, no Google Fonts for privacy). Candidates:
  - Body/headings serif: *Lora*, *Literata*, *Source Serif 4*
  - UI/labels/metadata sans: system-ui stack or *DM Sans*
  - Mono: system mono stack or *JetBrains Mono*

- [ ] **2.2 — CSS custom properties**
  Define token sets for both themes in `main.css`:
  ```css
  :root, [data-theme="light"] { /* Ayu Light tokens */ }
  [data-theme="dark"]          { /* Ayu Mirage tokens */ }
  @media (prefers-color-scheme: dark) { :root { /* Ayu Mirage tokens */ } }
  ```
  Token names:
  ```
  --font-body, --font-heading, --font-mono
  --color-bg, --color-surface, --color-text, --color-muted, --color-accent, --color-border
  --space-xs  --space-sm  --space-md  --space-lg  --space-xl  --space-2xl
  --radius-sm, --radius-md
  --measure (max prose line length)
  ```

- [ ] **2.3 — Typographic baseline**
  Body: `1rem` / `16px`, line-height `1.65`, measure `65ch`, paragraph spacing `1em`. Heading scale.

- [ ] **2.4 — Base element styles**
  `h1–h6`, `p`, `a`, `blockquote`, `code`, `pre`, `ul/ol`, `hr`, `img`, `table`. Posts should look good before any component work.

- [ ] **2.5 — Light/dark toggle**
  Small button in the header. Sets `data-theme="light"|"dark"` on `<html>`, persists to `localStorage`. Falls back to `prefers-color-scheme` on first visit.

---

### Phase 3 — Landing page layout

The core of the redesign. Inspired by paco.me (card feel) and jamesg.blog (multi-stream).

- [ ] **3.1 — Bio card**
  Name, one-paragraph description, avatar, social links (email, Mastodon, Bluesky, Instagram, Substack EN/ES). Handshake, not resume. `h-card` microformat markup.

- [ ] **3.2 — Latest notes**
  Short-form stream from `content/*/notes/`. Newest first, date + body, no title. Link to `/notes` for full list.

- [ ] **3.3 — Lately**
  Driven by `data/lately.yaml` (output of `sync-lately.sh`). Three rows: book, film, links (last 3). Single "see more" link to `/garden/latest-reads`.

- [ ] **3.4 — Latest posts**
  3 most recent posts. Title + date only, no excerpts. Link to `/post` archive.

- [ ] **3.5 — Featured project**
  One highlighted project, manually curated in `data/featured-project.yaml`. Name, one-line description, link.

- [ ] **3.6** Wire up EN and ES versions. All UI strings through `i18n/en.yaml` and `i18n/es.yaml`.

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

- [ ] **5.1** RSS/Atom feeds for every content type: posts (exists), notes (new), garden reads. Per-section feeds for writings subcategories.
- [ ] **5.2** `rel="me"` links to Mastodon and Bluesky in `<head>` — done in Phase 1, verify correct.
- [ ] **5.3** Microformats2: `h-card` on bio card, `h-entry` on posts and notes.
- [ ] **5.4** Review `sitemap.xml` and `robots.txt`.
- [ ] **5.5** Bluesky cross-posting for notes — evaluate `atp` CLI or AT Protocol API script.
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

- Phase 0 done — all decisions locked
- Phase 0.5 done — data scripts, notes type, Substack import
- Phase 1 done — custom theme `/themes/metwo`, 106 pages building clean
- **Next: Phase 2** — typography and design tokens
