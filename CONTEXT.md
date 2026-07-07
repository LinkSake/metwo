# Context: luisangel.me Redesign

## Who is this for

**Luis Angel Ortega** — Mexican developer, writer, and poet from Chihuahua. Active on Mastodon (`@link@vmst.io`), Bluesky (`@linksake.bsky.social`), and Instagram (`@linksake`). Prefers personal, independent web over social media platforms.

## The site now

- **Stack:** Hugo, custom theme `themes/metwo`, bilingual EN/ES.
- **URL:** `luisangel.me`
- **Content sections:** Writings (blogposts, articles, reports, works), Notes, Projects, Garden, About.
- **Automations:** `sync-lately.sh` (GoodReads + Letterboxd + Raindrop → `data/lately.yaml`), `sync-raindrop-reads.sh` (full reads list to garden pages), `import-substack.py` (one-time + ongoing Substack import).

## The intent

Refresh the landing page to act as a **presentation card** — the page should answer "who is this person and what are they up to" at a glance. This aligns with the POSSE principle (Publish on your Own Site, Syndicate Elsewhere): the homepage becomes the canonical hub of Luis's online identity.

Reference: https://indieweb.org/POSSE

## Inspirational sites

| Site | What's notable |
|---|---|
| [macwright.com](https://macwright.com) | Short bio + recent items in a clean layout. Developer/writer hybrid model. |
| [jamesg.blog](https://jamesg.blog) | IndieWeb-native. Streams all content types from one owned source. |
| [paco.me](https://paco.me) | Polished card feel. Minimal bio, strong typographic hierarchy. |
| [leerob.com](https://leerob.com) | Bio-first. The nav is the taxonomy. Fast, no fluff. |
| [notesbylex.com](https://notesbylex.com) | Personal and warm. Feels like a real person, not a portfolio. |

Layout inspiration: paco.me and jamesg.blog — bio card at top, named sections below as compact lists with "see more" links.

## Three common threads

1. One paragraph that says who you are — on the landing, not deferred to /about.
2. Sections for all content types — posts, notes, projects, reads — on the front page.
3. No hero, no fold — everything meaningful is immediately visible or one click away.

## What has been built (branch: `redesign/posse-landing`)

| Task | Status | Notes |
|---|---|---|
| Phase 0 decisions | Done | See below |
| `scripts/sync-lately.sh` | Done | GoodReads + Letterboxd + Raindrop → `data/lately.yaml` |
| `scripts/import-substack.py` | Done | 38 posts (19 EN + 19 ES), idempotent |
| Notes content type | Done | Archetype, sections, menus, RSS, i18n |
| Custom theme `/themes/metwo` | Done | Phase 1 — 106 pages, 0 build errors |
| Lora typeface (self-hosted) | Done | Variable WOFF2, latin + latin-ext |
| CSS design tokens | Done | Full Ayu Light / Mirage token sets |
| Theme toggle + lang switcher | Done | localStorage + prefers-color-scheme |
| Landing page layout | Next | Phase 3 |

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
| Mastodon | `@link@vmst.io` | Cross-post notes; `rel="me"` in `<head>` (done) |
| Bluesky | `@linksake.bsky.social` | Cross-post notes via AT Protocol script (Phase 5) |
| Instagram | `@linksake` | Social link only — no public RSS/API |
| Substack EN | `linksake.substack.com` | Write on site first, cross-post to Substack |
| Substack ES | `luisangelortega.substack.com` | Same |

## Phase 0 decisions (resolved)

### 0.1 — Aesthetics
- **Color mode:** System default (`prefers-color-scheme`) + manual toggle in nav.
- **Type:** Lora (serif) for body and headings; system-ui for nav, labels, metadata; system mono for code.
- **Palette:** Ayu Light + Ayu Mirage. Implemented as CSS custom properties.
  - Light: bg `#fafafa`, text `#5c6166`, accent `#f2ae49`
  - Dark: bg `#1f2430`, text `#cbccc6`, accent `#ffcc66`
- **Density:** Airy — generous whitespace, especially on the landing.

### 0.2 — Landing page content

All sections: 2–3 items max + "see more" link.

```
[ Bio + social links ]     primary card; the handshake
[ Latest notes ]           short-form (~300 words max), newest first
[ Lately ]                 book (GoodReads) + film (Letterboxd) + links (Raindrop)
[ Latest posts ]           3 most recent writings; title + date only
[ Featured project ]       one highlighted project
```

### 0.3 — Theme strategy
Custom theme from scratch at `/themes/metwo`. Done — hugo-classic submodule removed.

### 0.4 — Short-form notes
`notes` content type added. Max ~300 words, no title. Syndicate to Bluesky in Phase 5.

## Theme architecture (`/themes/metwo`)

`baseof.html` block pattern. Partials: `head.html` (meta, RSS autodiscovery, `rel="me"` links, font preloads), `header.html` (nav + theme toggle + language switcher), `footer.html`, `foot_custom.html`. All page templates use `{{ define "main" }}`.

Single CSS file `static/css/main.css`: `@font-face` for Lora, full token set, base element styles. Poetry `<pre>` blocks use Lora + left border rule instead of code box styling. Phase 3 will add landing-specific layout styles to this file.

### Nav controls

Both are right-aligned text labels matching the `~/name` nav convention:
- **Theme toggle:** `~/dark` or `~/light` — shows where you're going. Reads `localStorage` on load, falls back to `prefers-color-scheme`. Sets `data-theme` on `<html>`.
- **Language switcher:** `~/español` on EN pages, `~/english` on ES pages. Uses Hugo's `.Translations` (excludes current language).

## Notes content type

`content/en/notes/` and `content/es/notes/`. Archetype: date-only frontmatter, no title. Menu weight 5. RSS at `/notes/index.xml` and `/es/notes/index.xml`.

```bash
hugo new notes/$(date +%Y-%m-%d)-slug.md
```

## Substack migration

`scripts/import-substack.py` — pure Python 3 stdlib. Handles poetry `<pre>` blocks, Substack CDN image extraction, subscribe widget stripping. Idempotent via `.imported-substack-guids`. Re-run after publishing new pieces to Substack.

Going forward: write on site first (`categories = ["Works"]`), then cross-post to Substack.
