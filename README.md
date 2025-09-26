# luisangel.me

Hello there! This is my personal blog/website. It was made using [Hugo](https://gohugo.io/) with a modified version of the theme [hugo-classic](https://github.com/goodroot/hugo-classics).

The logo/icon was made by the amazing [Horse Wizard](http://instagram.com/horse.wizard).

## Sections

I like to be organized, that's why I made specific spaces for specific kinds of content. Here's a quick round up of it:

- [**Writings**](https://luisangel.me/writings): Umbrella category for all my written content.
  - [**Blogposts**](https://luisangel.me/writings/blogposts): Toughts, rants and a more personal style of post.
  - [**Articles**](https://luisangel.me/writings/articles): Guides, essays and more serious posts.
  - [**Reports**](https://luisangel.me/writings/reports): Reviews for different kinds of media.
  - [**Works**](https://luisangel.me/writings/works): Posts about my published works.
- [**Projects**](https://luisangel.me/projects): A listing of all my projects (tech related or not).
- [**Garden**](https://luisangel.me/garden): My digital garden ([read more](https://abyss.j3s.sh/hypha/digital_abyss)).
- [**About**](https://luisangel.me/about): It's, you know, about me.

## Languages

Most of the content it's available in [English](https://luisangel.me/en) and [Spanish](https://luisangel.me/es)! Hopefully someday I'll learn another language good enough to list it here.

## Scripts

The blog includes a simple automation system for managing the "latest reads" section, which syncs bookmarks (last 50, it appends them) from Raindrop.io to both English and Spanish files.

**Usage:**
```bash
# 1. Set up credentials
cp .env.example .env
# 2. Run the sync
./scripts/sync-raindrop-reads.sh
```

## Known issues/todo list

- Right now we only list the RSS for the "archive", it's probably a good idea to have per term.
