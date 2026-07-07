# Context: luisangel.me Redesign

## Who is this for

**Luis Angel Ortega** — Mexican developer, writer, and poet from Chihuahua. Active on Mastodon (`@link@vmst.io`), Bluesky (`@linksake.bsky.social`), and Instagram (`@linksake`). Prefers personal, independent web over social media platforms.

## The site now

- **Stack:** Hugo, custom theme `themes/metwo`, bilingual EN/ES.
- **URL:** `luisangel.me`
- **Content sections:** Writings (blogposts, articles, reports, works), Notes, Projects, Garden, About.
- **Automations:** `sync-lately.sh` (GoodReads + Letterboxd + Raindrop → `data/lately.yaml`), `sync-raindrop-reads.sh` (full reads list to garden pages).

## The intent

Refresh the landing page to act as a **presentation card** — the page should answer "who is this person and what are they up to" at a glance. This aligns with the **POSSE principle** (Publish on your Own Site, Syndicate Elsewhere): the homepage becomes the canonical hub of Luis's online identity.

Reference: https://indieweb.org/POSSE

## Inspirational sites

Sites Luis likes for structure and idea (not aesthetics):

| Site | What's notable |
|---|---|
| [macwright.com](https://macwright.com) | Short bio + recent items in a clean layout. Developer/writer hybrid model. |
| [jamesg.blog](https://jamesg.blog) | IndieWeb-native. Streams all content types from one owned source. |
| [paco.me](https://paco.me) | Polished card feel. Minimal bio, strong typographic hierarchy. |
| [leerob.com](https://leerob.com) | Bio-first. The nav is the taxonomy. Fast, no fluff. |
| [notesbylex.com](https://notesbylex.com) | Personal and warm. Feels like a real person, not a portfolio. |

Layout inspiration specifically from paco.me and jamesg.blog: bio card at top, named sections below as compact lists with "see more" links.

## Three common threads

1. One paragraph that says who you are — on the landing itself, not deferred to /about.
2. A unified set of sections for all content types — posts, notes, projects, reads — surfaced on the front page.
3. No hero, no fold — everything meaningful is immediately visible or one click away.

## What has been built (branch: `redesign/posse-landing`)

| Task | Status | Notes |
|---|---|---|
| Phase 0 decisions | Done | See below |
| `scripts/sync-lately.sh` | Done | GoodReads + Letterboxd + Raindrop → `data/lately.yaml` |
| `scripts/sync-raindrop-reads.sh` | Done (pre-existing) | Full reads list to garden pages |
| `archetypes/notes.md` | Done | Minimal frontmatter, no title |
| `content/*/notes/` + `_index.md` | Done | EN + ES |
| Notes menus + RSS feeds | Done | `hugo.toml` updated |
| Notes i18n strings | Done | `en.yaml` + `es.yaml` |
| `scripts/import-substack.py` | Done | 38 posts imported (19 EN + 19 ES), idempotent via `.imported-substack-guids` |
| Custom theme `/themes/metwo` | Done | Phase 1 complete — 106 pages, 0 build errors |
| Typography + design tokens | Next | Phase 2 |

## External data sources (all verified)

| Source | Feed URL | Data available |
|---|---|---|
| GoodReads | `https://www.goodreads.com/review/list_rss/76567849?shelf=currently-reading` | Title, author |
| Letterboxd | `https://letterboxd.com/linksake/rss/` | Film title, year, rating, watched date |
| Raindrop.io | API (token in `.env`) | Link title, URL, date |
| Substack EN | `https://linksake.substack.com/feed` | *tiny engines* — poetry and short stories |
| Substack ES | `https://luisangelortega.substack.com/feed` | *pequeños motores* — poetry and short stories |

## Social presences

| Platform | Handle | POSSE strategy |
|---|---|---|
| Mastodon | `@link@vmst.io` | Cross-post notes; `rel="me"` in `<head>` (done in Phase 1) |
| Bluesky | `@linksake.bsky.social` | Cross-post notes via AT Protocol script (Phase 5) |
| Instagram | `@linksake` | Social link only — no public RSS/API |
| Substack EN | `linksake.substack.com` | Write on site first, cross-post to Substack |
| Substack ES | `luisangelortega.substack.com` | Same |

## Phase 0 decisions (resolved)

### 0.1 — Aesthetics
- **Color mode:** System default (`prefers-color-scheme`) + a manual toggle.
- **Type personality:** Mixed — serif for body/headings (literary, warm), sans or mono for UI labels and metadata.
- **Color palette:** Ayu Light (light mode) + Ayu Mirage (dark mode). Warm, deliberate — not a generic cold dark theme.
  - Ayu Light: bg `#FAFAFA`, text `#5C6166`, accent `#FF9940`
  - Ayu Mirage: bg `#1F2430`, text `#CBCCC6`, accent `#FFCC66`
- **Density:** Airy — generous whitespace, especially on the landing page.

### 0.2 — Content on the landing

All sections show 2–3 items max + a "see more" link.

```
[ Bio + social links ]     primary card; the handshake
[ Latest notes ]           short-form (~300 words max), newest first
[ Lately ]                 book (GoodReads) + film (Letterboxd) + links (Raindrop)
[ Latest posts ]           3 most recent writings; title + date only
[ Featured project ]       one highlighted project
```

### 0.3 — Theme strategy
Build custom theme from scratch at `/themes/metwo`. Done — hugo-classic submodule removed.

### 0.4 — Short-form notes
Added as `notes` content type. Max ~300 words, no title required. Syndicate to Bluesky (Phase 5).

## Theme architecture (`/themes/metwo`)

Hugo `baseof.html` block pattern. Partials: `head.html` (meta, RSS, `rel="me"`), `header.html` (nav), `footer.html`, `foot_custom.html` (image-centering script). Page templates all use `{{ define "main" }}`. Single CSS file at `static/css/main.css` — Ayu Light and Ayu Mirage via `prefers-color-scheme`. Phase 2 will replace the flat CSS with custom properties and add the manual toggle.

## Notes content type

First-class Hugo content type in `content/en/notes/` and `content/es/notes/`. Archetype at `archetypes/notes.md` — date-only frontmatter, no title. Menu weight 5 in both languages. RSS feeds at `/notes/index.xml` and `/es/notes/index.xml`.

```bash
hugo new notes/$(date +%Y-%m-%d)-slug.md
```

## Substack migration

`scripts/import-substack.py` — pure Python 3 stdlib, no external dependencies. Converts Substack HTML to Hugo markdown: preserves poetry `<pre>` blocks, extracts original S3 image URLs, strips subscribe widgets and share buttons. Idempotent via `.imported-substack-guids`. Re-run after publishing new pieces to Substack.

Going forward: write on the site first (`categories = ["Works"]`), then cross-post to Substack.
