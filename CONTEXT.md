# Context: luisangel.me Redesign

## Who is this for

**Luis Angel Ortega** — Mexican developer, writer, and poet from Chihuahua. Active on Mastodon (`@link@vmst.io`), Bluesky (`@linksake.bsky.social`), and Instagram (`@linksake`). Prefers personal, independent web over social media platforms.

## The site today

- **Stack:** Hugo, `hugo-classic` theme (single custom theme in `/themes/hugo-classic`), bilingual EN/ES.
- **URL:** `luisangel.me`
- **Content sections:**
  - **Writings** (blogposts, articles, reports, works)
  - **Archive** — flat list of all posts
  - **Projects**
  - **Garden** — digital garden, includes a `latest-reads` file synced from Raindrop.io
  - **About**
- **Existing automations:** `scripts/sync-raindrop-reads.sh` pulls the last 50 bookmarks from Raindrop.io and writes them to both EN and ES garden files, and also injects a preview into `_index.md`.
- **Current landing page (`content/en/_index.md`):** A welcome header, a bullet-list site map, a "currently" section (reading/watching/playing), a latest reads preview, and a latest posts preview. Functional but navigation-heavy, feels more like a directory than a front door.

## The intent

Refresh the landing page to act as a **presentation card** — the page should answer "who is this person and what are they up to" at a glance, before the visitor decides where to go next. This aligns with the **POSSE principle** (Publish on your Own Site, Syndicate Elsewhere): the homepage becomes the canonical hub of Luis's online identity.

**POSSE reference:** https://indieweb.org/POSSE

## Inspirational sites

Sites Luis likes for **structure and idea** (not necessarily aesthetics):

| Site | What's notable |
|---|---|
| [macwright.com](https://macwright.com) | Short bio + recent items (posts, notes, projects) in a clean grid. Developer/writer hybrid model. |
| [jamesg.blog](https://jamesg.blog) | IndieWeb-native. Streams all content types (posts, bookmarks, replies, likes) from a single owned source. |
| [paco.me](https://paco.me) | Polished card feel. Minimal bio, strong typographic hierarchy, links to things he's made. |
| [leerob.com](https://leerob.com) | Bio-first. The nav IS the taxonomy. Fast, no fluff. |
| [notesbylex.com](https://notesbylex.com) | Personal and warm. Good example of making a site feel like a real person, not a portfolio. |

Layout inspiration specifically from **paco.me** and **jamesg.blog**: bio card at top, then named sections below as compact lists with "see more" links.

## Three common threads identified

1. **One paragraph that says who you are** — not deferred to an /about page, present on the landing itself.
2. **A unified stream or sections for all content types** — posts, notes, projects, reads — surfaced on the front page. Reflects POSSE's "own your stuff" idea.
3. **No hero, no fold** — everything meaningful is immediately visible or one obvious click away. No marketing-style above-the-fold sections.

## What already maps well to the new direction

- The "currently" section (reading/watching/playing) is exactly the kind of personal signal that makes a landing page feel alive — merging into automated "Lately" section.
- `latest-reads` (Raindrop sync) is a POSSE-friendly data stream — surface it more prominently.
- `latest posts` preview already exists — needs better visual treatment, not removal.
- The one-paragraph bio in `_index.md` is solid copy; refine, don't rewrite.
- Bilingual support (EN/ES) must be preserved in any redesign.

## External data sources (all verified)

| Source | Feed URL | Data available |
|---|---|---|
| GoodReads | `https://www.goodreads.com/review/list_rss/76567849?shelf=currently-reading` | Title, author, cover image |
| Letterboxd | `https://letterboxd.com/linksake/rss/` | Film title, year, rating, watched date, poster |
| Raindrop.io | (existing script, uses API token) | Link title, URL, date |
| Substack EN | `https://linksake.substack.com/feed` | *tiny engines* — poetry & short stories |
| Substack ES | `https://luisangelortega.substack.com/feed` | *pequeños motores* — poetry & short stories |

## Social presences

| Platform | Handle/URL | POSSE strategy |
|---|---|---|
| Mastodon | `@link@vmst.io` | Cross-post notes; add `rel="me"` for identity verification |
| Bluesky | `@linksake.bsky.social` | Cross-post notes via AT Protocol CLI |
| Instagram | `@linksake` | Social link only — no public RSS/API; full POSSE would require major workflow shift |
| Substack EN | `linksake.substack.com` (*tiny engines*) | Migrate existing posts to site; write on site first going forward, cross-post to Substack |
| Substack ES | `luisangelortega.substack.com` (*pequeños motores*) | Same as above |

## Phase 0 decisions (resolved)

### 0.1 — Aesthetics
- **Color mode:** System default (`prefers-color-scheme`) + a manual toggle.
- **Type personality:** Mixed — serif for body/headings (literary, warm), sans or mono for UI labels and metadata.
- **Color palette:** Ayu Light (light mode) + Ayu Mirage (dark mode). Warm, deliberate — not a generic cold dark theme.
  - Ayu Light: bg `#FAFAFA`, text `#5C6166`, accent `#FF9940`
  - Ayu Mirage: bg `#1F2430`, text `#CBCCC6`, accent `#FFCC66`
- **Density:** Airy — generous whitespace, especially on the landing page.

### 0.2 — Content on the landing

All sections show **2–3 items max + a "see more" link**. The page is alive without being a wall.

Final landing page hierarchy:

```
[ Bio + social links ]     ← primary card; always visible; the handshake
[ Latest notes ]           ← short-form (~300 words max), newest first
[ Lately ]                 ← books (GoodReads) + films (Letterboxd) + links (Raindrop); no gaming (not automatable)
[ Latest posts ]           ← 3 most recent writings; title + date only
[ Featured project ]       ← one highlighted project
```

### 0.3 — Theme strategy
**Option A: Build custom theme from scratch** at `/themes/metwo`. Clean break, full control, no inherited cruft from `hugo-classic`.

### 0.4 — Short-form notes
**Yes.** A `notes` content type will be added. Max ~300 words — anything without a title that doesn't warrant a full post. Syndicate to Bluesky (and Mastodon when a new instance is chosen). This fills the Twitter-shaped hole without depending on any platform.

## Substack migration

Luis has published literary works (poetry, short stories) on both Substacks that don't exist on the site yet. These map naturally to the `categories/works` section. Plan:
1. One-time import script: fetch both Substack RSS feeds, strip Substack HTML, convert to Hugo markdown with proper frontmatter (title, date, language, category: works).
2. Going forward: write on the site first, cross-post to Substack.
