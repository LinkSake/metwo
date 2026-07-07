# Plan: luisangel.me Redesign

## Goal

Replace the current blog-centric homepage with a presentation card landing page that reflects POSSE principles: own your identity, surface all your content types from one place, feel like a real person — not a portfolio, not a directory.

---

## Phases

### Phase 0 — Decide before touching code ✅

- [x] Ayu Light / Ayu Mirage / system default + toggle / Lora serif body + system-ui UI / airy density
- [x] Landing: Bio + socials → Notes → Lately → Latest posts → Featured project. 2–3 items + "see more".
- [x] Custom theme from scratch at `/themes/metwo`.
- [x] `notes` content type, ~300 words max, no title. Syndicate to Bluesky (Phase 5).

> **Note — automating `sync-lately.sh`:** GH Actions scheduled workflow is the right first answer. Revisit after the theme is done.

---

### Phase 0.5 — Data & content prep ✅

- [x] `scripts/import-substack.py` — 38 posts (19 EN + 19 ES). Idempotent via `.imported-substack-guids`.
- [x] `scripts/sync-lately.sh` — GoodReads + Letterboxd + Raindrop → `data/lately.yaml`.
- [x] Notes content type — archetype, sections EN + ES, menus, RSS feeds, i18n strings.

---

### Phase 1 — Theme scaffold ✅

- [x] `baseof.html` block pattern, proper partials, all page templates via `{{ define "main" }}`.
- [x] CSS consolidated into `themes/metwo/static/css/main.css`. Root `layouts/` and old CSS removed.
- [x] `hugo.toml`: `theme = "metwo"`, submodule removed. Build: 106 pages, 0 errors.

---

### Phase 2 — Typography & design tokens ✅

- [x] Lora self-hosted variable WOFF2 (4 files, latin + latin-ext, ~118KB). Preload hints in `<head>`.
- [x] CSS custom properties: full Ayu Light / Mirage token sets on `:root` / `[data-theme]` / `prefers-color-scheme`.
- [x] Typographic baseline: body 1rem/1.65, prose 1.05rem/1.75/65ch, heading scale.
- [x] Base element styles: headings, links, code, pre, blockquote, lists, tables. Poetry `<pre>` with left border.
- [x] Theme toggle (`~/dark` / `~/light`) + language switcher (`~/español` / `~/english`) in nav.

---

### Phase 3 — Landing page layout ✅

- [x] `themes/metwo/layouts/index.html` — dedicated home template.
- [x] Bio card: name, bio text, avatar, 6 social links, `h-card` microformat.
- [x] Latest notes section (renders when notes exist).
- [x] Lately: book + film from `data/lately.yaml`; links when Raindrop is wired.
- [x] Latest posts: 3 most recent, title + date only.
- [x] Featured project: from `data/{lang}/featured_project.yaml`, bilingual.
- [x] `_index.md` EN + ES stripped to front matter (bio + avatar params).
- [x] `hugo.toml`: `params.socials` added, footer updated.
- [x] Landing CSS: bio card, notes stream, lately list, post list, project card, section labels, mobile responsive.

---

### Phase 4 — Inner pages ← current

Style the rest of the site to match the new theme. The templates already exist from Phase 1; this phase is about making them look intentional.

- [ ] **4.1 — Single post page**
  Title prominent, metadata (date, reading time, author) in a subdued row, prose body in Lora at comfortable measure, tags at bottom.

- [ ] **4.2 — List / archive pages**
  Post archive (`/post`), category pages (`/categories/*`), tag pages (`/tags/*`). Clean scannable lists, consistent date formatting, section description where available.

- [ ] **4.3 — Notes list page**
  Reverse-chronological stream. Notes have no title so each entry is date + body. Paginate if needed.

- [ ] **4.4 — Projects page**
  The existing `projects.md` content renders as a single page. Make it read well with the new typography.

- [ ] **4.5 — Garden pages**
  Garden index + `latest-reads` page. Both are simple content pages — typography pass.

- [ ] **4.6 — About page**
  Simple content page. Should feel lighter now that the bio card lives on the landing.

- [ ] **4.7 — 404 page**
  Friendly, on-brand.

---

### Phase 5 — POSSE plumbing

- [ ] **5.1** RSS/Atom feeds for every content type. Per-section feeds for writings subcategories.
- [ ] **5.2** `rel="me"` links to Mastodon and Bluesky in `<head>` — done in Phase 1, verify.
- [ ] **5.3** Microformats2: `h-card` on bio card (done), `h-entry` on posts and notes.
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
- Phase 3 done — landing page, all sections, bilingual, data-driven
- **Next: Phase 4** — inner page styles
