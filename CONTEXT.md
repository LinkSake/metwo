# Context: luisangel.me Redesign

## Who is this for

**Luis Angel Ortega** — Mexican developer, writer, and poet from Chihuahua. Active on Mastodon (`@link@vmst.io`) and Bluesky (`@linksake.bsky.social`). Prefers personal, independent web over social media platforms.

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

## Three common threads identified

1. **One paragraph that says who you are** — not deferred to an /about page, present on the landing itself.
2. **A unified stream or sections for all content types** — posts, notes, projects, reads — surfaced on the front page. Reflects POSSE's "own your stuff" idea.
3. **No hero, no fold** — everything meaningful is immediately visible or one obvious click away. No marketing-style above-the-fold sections.

## What already maps well to the new direction

- The "currently" section (reading/watching/playing) is exactly the kind of personal signal that makes a landing page feel alive — keep it.
- `latest-reads` (Raindrop sync) is a POSSE-friendly data stream — surface it more prominently.
- `latest posts` preview already exists — needs better visual treatment, not removal.
- The one-paragraph bio in `_index.md` is solid copy; refine, don't rewrite.
- Bilingual support (EN/ES) must be preserved in any redesign.

## What needs to change

- The landing page currently reads like a **sitemap** (bullet list of every section). Replace with a card/stream layout.
- The theme (`hugo-classic`) is a third-party base with overrides. A custom theme is the goal — built from scratch or forked and heavily modified.
- The "about" content lives only at `/about` — a distilled version belongs on the homepage.
- No clear visual identity yet (typography, color, spacing). That definition is a goal of this redesign.
