# Plan: luisangel.me Redesign

## Goal

Replace the current blog-centric homepage with a presentation card landing page that reflects POSSE principles: own your identity, surface all your content types from one place, feel like a real person — not a portfolio, not a directory.

---

## Phases

### Phase 0 — Decide before touching code ✅

- [x] **0.1** Ayu Light / Ayu Mirage palette / system default + toggle / Lora serif body + system-ui UI / airy density
- [x] **0.2** Landing hierarchy: Bio + socials → Notes → Lately → Latest posts → Featured project. 2–3 items per section + "see more" link.
- [x] **0.3** Custom theme from scratch at `/themes/metwo`.
- [x] **0.4** `notes` content type, ~300 words max, no title. Syndicate to Bluesky (Phase 5).

> **Note — automating `sync-lately.sh`:** GH Actions scheduled workflow (`on: schedule: cron`) is the right first answer — free for public repos, commits updated `data/lately.yaml` back and triggers a rebuild. Revisit after the theme is done.

---

### Phase 0.5 — Data & content prep ✅

- [x] **0.5.1** `scripts/import-substack.py` — 38 posts imported (19 EN + 19 ES). Idempotent via `.imported-substack-guids`.
- [x] **0.5.2** `scripts/sync-lately.sh` — GoodReads + Letterboxd + Raindrop → `data/lately.yaml`.
- [x] **0.5.3** Notes content type — archetype, `_index.md` EN + ES, menus, RSS feeds, i18n strings.

---

### Phase 1 — Theme scaffold ✅

Custom theme `/themes/metwo` built from scratch. `hugo-classic` submodule removed.

- [x] `baseof.html` block pattern with proper partials (`head.html`, `header.html`, `footer.html`, `foot_custom.html`)
- [x] All page templates using `{{ define "main" }}` blocks
- [x] CSS consolidated into `themes/metwo/static/css/main.css`
- [x] `hugo.toml`: `theme = "metwo"`, `custom_css` param removed
- [x] Root `layouts/` and `static/css/theme-override.css` deleted
- [x] Build: 106 pages EN + ES, 0 errors

---

### Phase 2 — Typography & design tokens ✅

- [x] **2.1** Lora (variable font, self-hosted) — 4 WOFF2 files (normal + italic, latin + latin-ext, ~118KB). Preload hints in `<head>`.
- [x] **2.2** CSS custom properties: full token set (`--color-*`, `--font-*`, `--space-*`, `--measure`, `--radius-*`). Ayu Light on `:root`, Ayu Mirage under `prefers-color-scheme: dark` and `[data-theme="dark"]`. `[data-theme="light"]` override for the toggle.
- [x] **2.3** Typographic baseline: body 1rem/1.65, prose 1.05rem/1.75/65ch, heading scale 1rem–1.75rem.
- [x] **2.4** Base element styles: headings, links, code, pre, blockquote, lists, tables, images. Poetry `<pre>` blocks get serif font + left border rule.
- [x] **2.5** Theme toggle (`~/dark` / `~/light`) + language switcher (`~/español` / `~/english`) in the nav. Toggle reads `localStorage`, falls back to `prefers-color-scheme`, stays in sync with OS changes.

---

### Phase 3 — Landing page layout ← current

The core of the redesign. Inspired by paco.me (card feel) and jamesg.blog (multi-stream).

- [ ] **3.1 — Bio card**
  Name, one-paragraph description, avatar, social links (email, Mastodon, Bluesky, Instagram, Substack EN/ES). Handshake, not resume. `h-card` microformat markup.

- [ ] **3.2 — Latest notes**
  Short-form stream from `content/*/notes/`. Newest first, date + body, no title. Link to `/notes` for full list.

- [ ] **3.3 — Lately**
  Driven by `data/lately.yaml`. Three rows: book, film, links (last 3). "See more" link to `/garden/latest-reads`.

- [ ] **3.4 — Latest posts**
  3 most recent posts. Title + date only, no excerpts. Link to `/post` archive.

- [ ] **3.5 — Featured project**
  One highlighted project, manually curated in `data/featured-project.yaml`. Name, one-line description, link.

- [ ] **3.6** Wire up EN and ES versions. All UI strings through `i18n/en.yaml` and `i18n/es.yaml`.

---

### Phase 4 — Inner pages

- [ ] **4.1** Post/article single page — title, date, reading time, body, tags.
- [ ] **4.2** List/archive pages (writings categories, post archive, tags).
- [ ] **4.3** Notes list page — reverse-chron stream, paginated.
- [ ] **4.4** Projects page.
- [ ] **4.5** Garden pages (index + individual notes + latest-reads).
- [ ] **4.6** About page — lighter now that the bio is on the landing.
- [ ] **4.7** 404 page.

---

### Phase 5 — POSSE plumbing

- [ ] **5.1** RSS/Atom feeds for every content type. Per-section feeds for writings subcategories.
- [ ] **5.2** `rel="me"` links to Mastodon and Bluesky in `<head>` — done in Phase 1, verify.
- [ ] **5.3** Microformats2: `h-card` on bio card, `h-entry` on posts and notes.
- [ ] **5.4** Review `sitemap.xml` and `robots.txt`.
- [ ] **5.5** Bluesky cross-posting for notes via AT Protocol API script.
- [ ] **5.6** *(Stretch)* Webmentions endpoint and/or display.

---

### Phase 6 — Polish & ship

- [ ] **6.1** Performance: image optimisation, CSS size, `font-display: swap` (already set).
- [ ] **6.2** Accessibility: WCAG AA contrast, keyboard nav, semantic HTML, `aria` where needed.
- [ ] **6.3** Mobile: all layouts at 375px, 390px, 768px.
- [ ] **6.4** Cross-browser: Firefox, Safari, Chrome.
- [ ] **6.5** Merge `redesign/posse-landing` → `main`, deploy.

---

## Current status

- Phase 0 done
- Phase 0.5 done
- Phase 1 done — custom theme, 106 pages building clean
- Phase 2 done — Lora, design tokens, theme toggle, language switcher
- **Next: Phase 3** — landing page layout
