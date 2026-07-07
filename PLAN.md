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
- [x] Lately: book + film from `data/lately.yaml`; links when Raindrop is wired.
- [x] Latest posts: 3 most recent, title + date only.
- [x] Featured project: from `data/{lang}/featured_project.yaml`, bilingual.
- [x] `_index.md` EN + ES stripped to front matter. `hugo.toml`: `params.socials` added, footer updated.
- [x] Landing CSS: bio card, lately list, post list, project card, section labels, mobile responsive.

---

### Phase 4 — Inner pages ✅

- [x] `single.html` rewritten: left-aligned title, `<time>` + reading time in muted metadata row, semantic structure, tag pills in `<footer>`.
- [x] `list.html` cleaned up: title left / date right, border separators, dropped bracket decoration.
- [x] `notes/list.html` created: full stream layout (date + body, no titles), permalink anchor, empty state.
- [x] `terms.html` cleaned up: proper classes, no inline styles.
- [x] `404.html` rewritten: text-only, go-back / go-home nav.
- [x] Inner page CSS: ~120 lines covering all list, article, terms, notes, and 404 pages. Mobile responsive.

---

### Phase 5 — POSSE plumbing ← current

- [ ] **5.1 — RSS feeds audit**
  Verify feeds exist and are well-formed for every content type: posts, notes, garden reads. Check per-section feeds for writings subcategories. Add any missing.

- [ ] **5.2 — `rel="me"` verification**
  Confirm `rel="me"` links to Mastodon and Bluesky are correct in `<head>`. These were added in Phase 1 — verify they match the live handles.

- [ ] **5.3 — Microformats2 on posts and notes**
  Add `h-entry` markup to `single.html` and `notes/list.html`. Landing bio card already has `h-card`.

- [ ] **5.4 — `sitemap.xml` and `robots.txt` review**
  Confirm Hugo is generating both correctly for the bilingual site.

- [ ] **5.5 — Bluesky cross-posting script**
  Write `scripts/post-to-bluesky.sh` (or `.py`). Takes a note file path, reads date + body, posts to Bluesky via the AT Protocol API. Run manually after `hugo new notes/...`.

- [ ] **5.6 — *(Stretch)* Webmentions**
  Add a Webmention endpoint and/or display received Webmentions on posts.

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
- Phase 4 done — inner page templates and styles
- **Next: Phase 5** — POSSE plumbing
