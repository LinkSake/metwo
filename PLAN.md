# Plan: luisangel.me Redesign

## Goal

Replace the current blog-centric homepage with a **presentation card** landing page that reflects POSSE principles: own your identity, surface all your content types from one place, feel like a real person — not a portfolio, not a directory.

---

## Phases

### Phase 0 — Decide before touching code
These decisions need answers before any layout or theming work begins. They can be resolved through conversation or quick experiments.

- [ ] **0.1 — Aesthetics direction**
  Pick a visual language. Some axes to decide on:
  - Light / Dark / System-default / Both?
  - Typographic personality: serif (literary, warm) vs. sans-serif (clean, dev-ish) vs. mixed?
  - Color: monochrome + one accent / full palette / pastel / high contrast?
  - Density: airy and spacious vs. compact and information-rich?
  - Reference: look at the five inspiration sites and note what *feels* right, not just what *works*.

- [ ] **0.2 — Content types to surface on landing**
  Confirm which streams appear on the homepage. Candidates:
  - Latest posts (writings)
  - Currently (reading/watching/playing) — strong candidate, keep
  - Latest reads (Raindrop sync)
  - Projects (featured, not full list)
  - Notes / short-form? (does this exist or is it a new content type?)
  - Social links (Mastodon, Bluesky, email)

- [ ] **0.3 — Theme strategy**
  - Option A: Build a custom Hugo theme from scratch in `/themes/metwo` (clean break, full control).
  - Option B: Fork `hugo-classic`, rename it, strip it down, and rebuild on top of it (lower risk, preserves existing template logic).
  - Recommendation: Option A — the existing theme is minimal enough that forking adds no real advantage, and a clean theme directory is easier to maintain long-term.

- [ ] **0.4 — Short-form / notes**
  POSSE works best when you have a short-form content type (equivalent to tweets/toots) that you own and then syndicate. Decide: do you want to add a `notes` or `microblog` section? If yes, this shapes both the landing page layout and the Hugo content model.

---

### Phase 1 — Theme scaffold
Create the new custom theme and migrate the site to it without changing any content or layout yet. This is a purely structural step — the site should look identical (or close enough) after it.

- [ ] **1.1** Create `/themes/metwo` with the standard Hugo theme structure.
- [ ] **1.2** Port all existing layouts (`_default`, partials, 404) into the new theme.
- [ ] **1.3** Move `static/css/theme-override.css` into the new theme's CSS. Remove the old override pattern.
- [ ] **1.4** Update `hugo.toml` to point `theme = "metwo"`.
- [ ] **1.5** Verify all existing pages render correctly. Fix any regressions.

---

### Phase 2 — Typography & design tokens
Before building any layout, establish the visual foundation. Work in CSS custom properties so every later decision is easy to change globally.

- [ ] **2.1** Choose and load typefaces (Google Fonts, Bunny Fonts, or self-hosted).
- [ ] **2.2** Define CSS variables: `--font-body`, `--font-heading`, `--font-mono`, `--color-bg`, `--color-text`, `--color-accent`, `--color-muted`, `--space-*`, `--radius`.
- [ ] **2.3** Set a baseline: body font-size, line-height, measure (max-width for prose), paragraph spacing.
- [ ] **2.4** Style headings, links, blockquotes, code blocks — the basic HTML elements. Posts should look good before any custom component work.
- [ ] **2.5** Light/dark mode (if decided in Phase 0) via `prefers-color-scheme` media query or a toggle.

---

### Phase 3 — Landing page layout
This is the core of the redesign. Build the new `index.html` layout.

- [ ] **3.1 — Bio card**
  Top section: name, one-paragraph description, avatar (optional — currently hidden on mobile anyway), social links (email, Mastodon, Bluesky). Should feel like a handshake, not a resume.

- [ ] **3.2 — Currently section**
  Preserve the reading/watching/playing block. Consider making it data-driven (YAML front matter or a Hugo data file) instead of hardcoded markdown so it's easier to update.

- [ ] **3.3 — Latest posts**
  Show the 3–5 most recent posts with title, date, and optionally a one-line description. No excerpts — keep it scannable.

- [ ] **3.4 — Latest reads**
  Surface the Raindrop-synced reads directly on the landing. 3–5 items with title and date. Link to the full garden page.

- [ ] **3.5 — Projects teaser** *(optional based on Phase 0.2)*
  Featured project(s) — not a full list. One card or a two-column micro-grid.

- [ ] **3.6 — Notes / microblog feed** *(only if Phase 0.4 decides yes)*
  Short-form stream, newest first. Dates, no titles.

- [ ] **3.7** Wire up both EN and ES versions. Use Hugo's `i18n` strings for any UI labels.

---

### Phase 4 — Inner pages
Style the rest of the site to match the new theme.

- [ ] **4.1** Post/article single page layout.
- [ ] **4.2** List/archive pages (writings, posts, tags).
- [ ] **4.3** Projects page.
- [ ] **4.4** Garden pages (index + individual notes + latest-reads).
- [ ] **4.5** About page — consider making it lighter now that the landing carries the bio.
- [ ] **4.6** 404 page.

---

### Phase 5 — POSSE plumbing
Make the site a better first-class citizen of the IndieWeb.

- [ ] **5.1** Ensure every post type has a clean RSS/Atom feed. Consider per-section feeds (writings, notes, reads).
- [ ] **5.2** Add `rel="me"` links to Mastodon and Bluesky for identity verification.
- [ ] **5.3** Add basic microformats2 markup (`h-card` on the bio card, `h-entry` on posts) for IndieWeb compatibility.
- [ ] **5.4** Review `sitemap.xml` and `robots.txt`.
- [ ] **5.5** *(Stretch)* Add a Webmention endpoint or display Webmentions on posts.

---

### Phase 6 — Polish & ship
- [ ] **6.1** Performance pass: image optimization, CSS size, font loading strategy.
- [ ] **6.2** Accessibility check: contrast ratios, keyboard nav, semantic HTML.
- [ ] **6.3** Mobile review: all layouts tested at small viewport.
- [ ] **6.4** Cross-browser sanity check.
- [ ] **6.5** Merge `redesign/posse-landing` → `main`, deploy.

---

## Immediate next step

**Answer Phase 0 questions.** Nothing should be built until the aesthetic direction and content scope are decided. A short conversation or a quick mood-board pass over the five reference sites is enough to unblock Phase 1.
