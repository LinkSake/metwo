# luisangel.me

Personal website of Luis Angel Ortega — developer, writer, and poet from Chihuahua, Mexico. Built with [Hugo](https://gohugo.io/), custom theme (`themes/metwo`), bilingual English and Spanish.

The logo/icon was made by [Horse Wizard](http://instagram.com/horse.wizard).

> **Redesign in progress** on branch `redesign/posse-landing` — Phase 3 (landing page) next. See [`CONTEXT.md`](CONTEXT.md) for intent and [`PLAN.md`](PLAN.md) for the full roadmap.

## Sections

- [**Writings**](https://luisangel.me/categories): All written content.
  - **Blogposts** — thoughts, rants, personal style posts
  - **Articles** — guides, essays, more serious posts
  - **Reports** — reviews for different kinds of media
  - **Works** — published literary works (poetry, short stories)
- [**Notes**](https://luisangel.me/notes): Short-form, untitled posts (~300 words max). The POSSE-native microblog.
- [**Projects**](https://luisangel.me/projects): All projects.
- [**Garden**](https://luisangel.me/garden): Digital garden — links, reads, notes.
- [**About**](https://luisangel.me/about): About me.

## Languages

Most content is available in [English](https://luisangel.me/en) and [Spanish](https://luisangel.me/es). The nav includes a language switcher linking to the translated version of the current page.

## Theme

Custom Hugo theme at `themes/metwo`. No external submodule dependency.

```
themes/metwo/
  layouts/_default/   baseof.html, single.html, list.html, terms.html, rss.xml
  layouts/partials/   head.html, header.html, footer.html, foot_custom.html
  layouts/            404.html
  static/css/         main.css
  static/fonts/       lora.woff2, lora-italic.woff2 (+ latin-ext variants)
  theme.toml
```

Design tokens live in `main.css` as CSS custom properties. Ayu Light (default) and Ayu Mirage (dark) palettes, switchable via OS preference or the `~/dark` / `~/light` nav toggle.

## Scripts

All scripts live in `scripts/` and read credentials from a `.env` file (copy from `.env.example`).

```bash
cp .env.example .env
# fill in RAINDROP_TOKEN and RAINDROP_COLLECTION_ID
```

### `sync-lately.sh` — Lately section data

Fetches the landing page "Lately" data and writes `data/lately.yaml`:
- Book: currently-reading shelf from GoodReads (public RSS, no credentials needed)
- Film: most recently watched from Letterboxd (public RSS, no credentials needed)
- Links: last 5 bookmarks from Raindrop.io (requires `.env`)

```bash
./scripts/sync-lately.sh
```

### `sync-raindrop-reads.sh` — Garden latest reads

Syncs the last 50 Raindrop.io bookmarks into the full garden `latest-reads` pages (EN + ES) and injects a 3-item preview into both `_index.md` files.

```bash
./scripts/sync-raindrop-reads.sh
```

### `import-substack.py` — Substack migration

Imports posts from both Substacks (*tiny engines* EN, *pequeños motores* ES) into `content/*/post/` as Hugo markdown files with proper frontmatter (`categories = ["Works"]`, `original_url`). Pure Python 3 stdlib — no dependencies. Idempotent via `.imported-substack-guids`.

```bash
python3 scripts/import-substack.py
python3 scripts/import-substack.py --dry-run  # preview only
```
