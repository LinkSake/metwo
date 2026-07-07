# luisangel.me

Hello there! This is my personal website. It was made using [Hugo](https://gohugo.io/) with a custom theme (`themes/metwo`), bilingual in English and Spanish.

The logo/icon was made by the amazing [Horse Wizard](http://instagram.com/horse.wizard).

> **Redesign in progress** on branch `redesign/posse-landing`. See [`CONTEXT.md`](CONTEXT.md) for intent and [`PLAN.md`](PLAN.md) for the full roadmap.

## Sections

- [**Writings**](https://luisangel.me/categories): Umbrella category for all written content.
  - **Blogposts** — thoughts, rants, personal style posts
  - **Articles** — guides, essays, more serious posts
  - **Reports** — reviews for different kinds of media
  - **Works** — published literary works (poetry, short stories)
- [**Notes**](https://luisangel.me/notes): Short-form, untitled posts (~300 words max). The POSSE-native microblog.
- [**Projects**](https://luisangel.me/projects): A listing of all projects.
- [**Garden**](https://luisangel.me/garden): Digital garden — links, reads, notes.
- [**About**](https://luisangel.me/about): About me.

## Languages

Most content is available in [English](https://luisangel.me/en) and [Spanish](https://luisangel.me/es).

## Scripts

All scripts live in `scripts/` and read credentials from a `.env` file (copy from `.env.example`).

```bash
cp .env.example .env
# fill in RAINDROP_TOKEN and RAINDROP_COLLECTION_ID
```

### `sync-lately.sh` — Lately section data

Fetches the landing page "Lately" data and writes `data/lately.yaml`:
- 📖 Currently-reading book from GoodReads (public RSS — no credentials needed)
- 🎬 Most recently watched film from Letterboxd (public RSS — no credentials needed)
- 🔗 Last 5 bookmarks from Raindrop.io (requires `.env`)

```bash
./scripts/sync-lately.sh
```

### `sync-raindrop-reads.sh` — Garden latest reads

Syncs the last 50 Raindrop.io bookmarks into the full garden `latest-reads` pages (EN + ES) and injects a 3-item preview into both `_index.md` files.

```bash
./scripts/sync-raindrop-reads.sh
```

### `import-substack.sh` — One-time Substack migration

Imports posts from both Substacks (*tiny engines* EN, *pequeños motores* ES) into `content/*/post/` as Hugo markdown files with proper frontmatter. Idempotent — safe to re-run.

```bash
./scripts/import-substack.sh
```
