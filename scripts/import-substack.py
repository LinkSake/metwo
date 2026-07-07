#!/usr/bin/env python3
"""
import-substack.py
------------------
Imports posts from Substack RSS feeds into Hugo markdown files.

Usage:
    python3 scripts/import-substack.py [--dry-run]

Feeds:
    EN: https://linksake.substack.com/feed          → content/en/post/
    ES: https://luisangelortega.substack.com/feed   → content/es/post/

Idempotent: tracks imported GUIDs in .imported-substack-guids
"""

import sys
import os
import re
import json
import urllib.request
import xml.etree.ElementTree as ET
from html.parser import HTMLParser
from datetime import datetime, timezone
from pathlib import Path

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).parent.resolve()
BLOG_DIR   = SCRIPT_DIR.parent

FEEDS = [
    {
        "url":      "https://linksake.substack.com/feed",
        "lang":     "en",
        "out_dir":  BLOG_DIR / "content" / "en" / "post",
        "author":   "Luis Angel Ortega",
    },
    {
        "url":      "https://luisangelortega.substack.com/feed",
        "lang":     "es",
        "out_dir":  BLOG_DIR / "content" / "es" / "post",
        "author":   "Luis Angel Ortega",
    },
]

GUID_FILE = BLOG_DIR / ".imported-substack-guids"
DRY_RUN   = "--dry-run" in sys.argv

# ---------------------------------------------------------------------------
# GUID tracking (idempotency)
# ---------------------------------------------------------------------------
def load_guids():
    if GUID_FILE.exists():
        return set(GUID_FILE.read_text().splitlines())
    return set()

def save_guid(guid, guids):
    guids.add(guid)
    if not DRY_RUN:
        GUID_FILE.write_text("\n".join(sorted(guids)) + "\n")

# ---------------------------------------------------------------------------
# HTML → Markdown converter
# ---------------------------------------------------------------------------
# Substack-specific blocks to drop entirely (matched on class attribute)
DROP_CLASSES = {
    "subscription-widget-wrap-editor",
    "subscription-widget-wrap",
    "subscription-widget",
    "captioned-button-wrap",
    "image-link-expand",
    "pencraft",        # icon buttons (zoom, restack)
}

# Classes that signal a preformatted/poetry block
PRE_CLASSES = {"preformatted-block", "text"}

class SubstackConverter(HTMLParser):
    def __init__(self):
        super().__init__()
        self.output      = []       # list of markdown strings
        self.skip_depth  = 0        # >0 means we're inside a DROP block
        self.pre_depth   = 0        # >0 means we're inside a preformatted block
        self.pre_buf     = []       # buffer for pre content
        self.fig_depth   = 0        # >0 means we're inside a figure
        self.img_src     = ""       # extracted image src
        self.img_alt     = ""       # extracted image alt / figcaption
        self.cap_depth   = 0        # >0 means inside captioned-image-container
        self.link_href   = ""
        self.link_text   = []
        self.in_link     = False
        self.in_bold     = False
        self.in_em       = False
        self.list_stack  = []       # "ul" or "ol" per nesting level
        self.list_item   = False
        self.list_buf    = []
        self.para_buf    = []
        self.in_para     = False
        self.in_heading  = False
        self.heading_level = 0
        self.in_figcap   = False
        self.ignore_label = False   # for <label class="hide-text">

    # ------------------------------------------------------------------ attrs
    @staticmethod
    def _classes(attrs):
        d = dict(attrs)
        return set(d.get("class", "").split())

    @staticmethod
    def _attr(attrs, name):
        return dict(attrs).get(name, "")

    # ------------------------------------------------------------------ skip?
    def _should_skip(self, classes):
        return bool(classes & DROP_CLASSES)

    # ------------------------------------------------------------------ flush helpers
    def _flush_para(self):
        text = "".join(self.para_buf).strip()
        if text:
            self.output.append("\n\n" + text)
        self.para_buf = []
        self.in_para = False

    def _flush_list_item(self):
        text = "".join(self.list_buf).strip()
        if text:
            depth = len(self.list_stack) - 1
            prefix = "  " * depth + "- "
            self.output.append("\n" + prefix + text)
        self.list_buf = []
        self.list_item = False

    def _write(self, text):
        """Write text to the current active buffer."""
        if self.skip_depth > 0 or self.ignore_label:
            return
        if self.pre_depth > 0:
            self.pre_buf.append(text)
        elif self.in_figcap:
            self.img_alt += text
        elif self.in_link:
            self.link_text.append(text)
        elif self.list_item:
            self.list_buf.append(text)
        elif self.in_para or self.in_heading:
            self.para_buf.append(text)
        else:
            # bare text outside any block — attach to output directly
            stripped = text.strip()
            if stripped:
                self.output.append(stripped)

    # ------------------------------------------------------------------ handle_starttag
    def handle_starttag(self, tag, attrs):
        classes = self._classes(attrs)

        # --- drop blocks ---
        if self._should_skip(classes):
            self.skip_depth += 1
            return
        if self.skip_depth > 0:
            self.skip_depth += 1
            return

        # --- hide-text label ---
        if tag == "label" and "hide-text" in classes:
            self.ignore_label = True
            return

        # --- captioned image container ---
        if "captioned-image-container" in classes:
            self.cap_depth += 1
            self.img_src = ""
            self.img_alt = ""
            return

        # --- figure inside captioned image ---
        if tag == "figure" and self.cap_depth > 0:
            self.fig_depth += 1
            return

        # --- img: extract original S3 URL from data-attrs ---
        if tag == "img" and self.cap_depth > 0:
            data_attrs_str = self._attr(attrs, "data-attrs")
            if data_attrs_str:
                try:
                    da = json.loads(data_attrs_str.replace("&quot;", '"'))
                    self.img_src = da.get("src", "")
                except Exception:
                    pass
            if not self.img_src:
                # fallback: use the plain src (Substack CDN)
                self.img_src = self._attr(attrs, "src")
            return

        # --- figcaption ---
        if tag == "figcaption":
            self.in_figcap = True
            return

        # --- preformatted / poetry blocks ---
        # Only track the inner <pre> tag for depth, not the outer wrapper div.
        # The outer <div class="preformatted-block"> is just a container — ignore it.
        if tag == "pre":
            self.pre_depth += 1
            self.pre_buf = []
            return

        # --- skip internal picture/source noise ---
        if tag in ("picture", "source") and self.cap_depth > 0:
            return

        # --- headings ---
        if tag in ("h1","h2","h3","h4","h5","h6"):
            self._flush_para()
            self.in_heading  = True
            self.heading_level = int(tag[1])
            self.para_buf = []
            return

        # --- paragraphs ---
        if tag == "p":
            self._flush_para()
            self.in_para = True
            self.para_buf = []
            return

        # --- block quote ---
        if tag == "blockquote":
            self._flush_para()
            self.in_para = True
            self.para_buf = ["> "]
            return

        # --- hr ---
        if tag == "hr":
            self._flush_para()
            self.output.append("\n\n---")
            return

        # --- lists ---
        if tag in ("ul", "ol"):
            self.list_stack.append(tag)
            return
        if tag == "li":
            self._flush_list_item()
            self.list_item = True
            self.list_buf = []
            return

        # --- inline formatting ---
        if tag in ("strong", "b"):
            self.in_bold = True
            self._write("**")
            return
        if tag in ("em", "i"):
            self.in_em = True
            self._write("*")
            return
        if tag == "a":
            # Don't treat <a> tags inside image containers as content links
            if self.cap_depth > 0:
                return
            self.in_link = True
            self.link_href = self._attr(attrs, "href")
            self.link_text = []
            return
        if tag == "br":
            self._write("  \n")  # markdown line break
            return

    # ------------------------------------------------------------------ handle_endtag
    def handle_endtag(self, tag):
        classes = set()

        # --- drop block tracking ---
        if self.skip_depth > 0:
            self.skip_depth -= 1
            return

        # --- hide-text label ---
        if self.ignore_label and tag == "label":
            self.ignore_label = False
            return
        if self.ignore_label:
            return

        # --- captioned image container ---
        if tag == "div" and self.cap_depth > 0:
            # Only close on the outermost div — approximate with depth tracking
            pass  # handled via figcaption end

        if tag == "figure" and self.fig_depth > 0:
            self.fig_depth -= 1
            return

        if tag == "figcaption":
            self.in_figcap = False
            return

        # Emit the image markdown when we close the captioned-image-container.
        # We detect this by watching for the </a> that wraps the image link.
        if tag == "a" and self.cap_depth > 0:
            if self.img_src:
                alt = self.img_alt.strip() or ""
                self.output.append(f"\n\n![{alt}]({self.img_src})")
                self.img_src = ""
                self.img_alt = ""
                self.cap_depth = max(0, self.cap_depth - 1)
            # Always reset link state when closing an <a> inside an image container
            self.in_link = False
            self.link_text = []
            self.link_href = ""
            return

        # --- preformatted ---
        if tag == "pre":
            self.pre_depth -= 1
            if self.pre_depth == 0:
                content = "".join(self.pre_buf)
                self.output.append(f"\n\n<pre>\n{content}\n</pre>")
                self.pre_buf = []
            return

        # --- headings ---
        if tag in ("h1","h2","h3","h4","h5","h6"):
            text = "".join(self.para_buf).strip()
            hashes = "#" * self.heading_level
            self.output.append(f"\n\n{hashes} {text}")
            self.para_buf = []
            self.in_heading = False
            return

        # --- paragraphs ---
        if tag == "p":
            self._flush_para()
            return
        if tag == "blockquote":
            self._flush_para()
            return

        # --- lists ---
        if tag == "li":
            self._flush_list_item()
            return
        if tag in ("ul", "ol"):
            if self.list_stack:
                self.list_stack.pop()
            return

        # --- inline formatting ---
        if tag in ("strong", "b"):
            self._write("**")
            self.in_bold = False
            return
        if tag in ("em", "i"):
            self._write("*")
            self.in_em = False
            return
        if tag == "a":
            text = "".join(self.link_text).strip()
            if text and self.link_href:
                # skip internal Substack redirect links
                if "substack.com/i/" not in self.link_href:
                    if self.in_para or self.in_heading or self.list_item:
                        self.para_buf.append(f"[{text}]({self.link_href})")
                    else:
                        self.output.append(f"[{text}]({self.link_href})")
            elif text:
                self._write(text)
            self.in_link = False
            self.link_text = []
            self.link_href = ""
            return

    # ------------------------------------------------------------------ handle_data
    def handle_data(self, data):
        self._write(data)

    # ------------------------------------------------------------------ result
    def get_markdown(self):
        self._flush_para()
        self._flush_list_item()
        md = "".join(self.output)
        # clean up excessive blank lines
        md = re.sub(r'\n{3,}', '\n\n', md)
        return md.strip()


def html_to_markdown(html: str) -> str:
    parser = SubstackConverter()
    parser.feed(html)
    return parser.get_markdown()


# ---------------------------------------------------------------------------
# Slug helpers
# ---------------------------------------------------------------------------
def slug_from_guid(guid: str) -> str:
    """Extract the path slug from a Substack post URL."""
    # e.g. https://linksake.substack.com/p/without-warning → without-warning
    m = re.search(r'/p/([^/?#]+)', guid)
    if m:
        return m.group(1)
    # fallback: sanitise whatever's at the end
    return re.sub(r'[^a-z0-9-]', '-', guid.lower().split('/')[-1])

def parse_date(date_str: str) -> str:
    """Parse RSS pubDate and return ISO 8601 UTC string for Hugo frontmatter."""
    # RFC 2822: "Thu, 14 May 2026 16:53:22 GMT"
    fmt = "%a, %d %b %Y %H:%M:%S %Z"
    try:
        dt = datetime.strptime(date_str.strip(), fmt)
        return dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

# ---------------------------------------------------------------------------
# Hugo frontmatter
# ---------------------------------------------------------------------------
def make_frontmatter(title, date_iso, slug, author, original_url, lang):
    # Escape single quotes in title for TOML
    safe_title = title.replace('"', '\\"')
    return f'''+++
title = "{safe_title}"
date = {date_iso}
slug = "{slug}"
author = "{author}"
categories = ["Works"]
tags = []
original_url = "{original_url}"
draft = false
+++'''

# ---------------------------------------------------------------------------
# RSS parsing
# ---------------------------------------------------------------------------
def parse_feed(url: str):
    """Fetch and parse a Substack RSS feed. Returns list of item dicts."""
    print(f"  Fetching {url} ...", flush=True)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=20) as resp:
        raw = resp.read()

    root = ET.fromstring(raw)
    # strip namespaces
    for el in root.iter():
        if "}" in el.tag:
            el.tag = el.tag.split("}", 1)[1]

    items = []
    for item in root.findall(".//item"):
        guid    = item.findtext("guid", "").strip()
        title   = item.findtext("title", "").strip()
        pub     = item.findtext("pubDate", "").strip()
        content = item.findtext("encoded", "").strip()
        items.append({
            "guid":    guid,
            "title":   title,
            "date":    parse_date(pub),
            "content": content,
            "slug":    slug_from_guid(guid),
        })
    return items

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    if DRY_RUN:
        print("DRY RUN — no files will be written.\n")

    guids = load_guids()
    total_new = 0

    for feed in FEEDS:
        lang    = feed["lang"]
        out_dir = feed["out_dir"]
        author  = feed["author"]

        print(f"\n[{lang.upper()}] {feed['url']}")

        try:
            items = parse_feed(feed["url"])
        except Exception as e:
            print(f"  ERROR fetching feed: {e}")
            continue

        print(f"  {len(items)} posts found in feed")
        new_count = 0

        for item in items:
            guid = item["guid"]

            if guid in guids:
                print(f"  SKIP (already imported): {item['title']}")
                continue

            slug     = item["slug"]
            out_path = out_dir / f"{slug}.md"

            if out_path.exists():
                print(f"  SKIP (file exists): {out_path.name}")
                save_guid(guid, guids)
                continue

            # Convert HTML content to markdown
            md_body = html_to_markdown(item["content"])

            # Build full file
            fm = make_frontmatter(
                title        = item["title"],
                date_iso     = item["date"],
                slug         = slug,
                author       = author,
                original_url = guid,
                lang         = lang,
            )
            full_content = fm + "\n\n" + md_body + "\n"

            if DRY_RUN:
                print(f"  WOULD WRITE: {out_path.name}")
                print(f"    Title: {item['title']}")
                print(f"    Date:  {item['date']}")
                print(f"    Body:  {len(md_body)} chars")
            else:
                out_dir.mkdir(parents=True, exist_ok=True)
                out_path.write_text(full_content, encoding="utf-8")
                save_guid(guid, guids)
                print(f"  WROTE: {out_path.name}")

            new_count += 1
            total_new += 1

        print(f"  → {new_count} new posts imported")

    print(f"\nDone. {total_new} total new posts imported.")
    if DRY_RUN:
        print("(DRY RUN — nothing was written to disk)")

if __name__ == "__main__":
    main()
