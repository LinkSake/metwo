#!/usr/bin/env python3
"""
post-to-bluesky.py
------------------
Cross-posts a Hugo note to Bluesky via the AT Protocol API.

Usage:
    python3 scripts/post-to-bluesky.py content/en/notes/2026-07-07-my-note.md
    python3 scripts/post-to-bluesky.py content/en/notes/2026-07-07-my-note.md --dry-run

Credentials (in .env or environment):
    BSKY_IDENTIFIER   your Bluesky handle, e.g. linksake.bsky.social
    BSKY_APP_PASSWORD an app password from bsky.app/settings/app-passwords
                      (NOT your main account password)

How it works:
    1. Parses the note file — strips TOML/YAML frontmatter, reads body.
    2. Constructs the post text:
         - If the body fits in 280 chars: posts the body + canonical link.
         - Otherwise: truncates to ~250 chars at a word boundary + "..." + link.
    3. Adds a rich-text facet so the canonical URL is a clickable link.
    4. POSTs to com.atproto.repo.createRecord on bsky.social.

The canonical URL is derived from the site baseURL in hugo.toml + the note slug.
"""

import sys
import os
import re
import json
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
SCRIPT_DIR   = Path(__file__).parent.resolve()
BLOG_DIR     = SCRIPT_DIR.parent
ENV_FILE     = BLOG_DIR / ".env"
HUGO_TOML    = BLOG_DIR / "hugo.toml"
BSKY_API     = "https://bsky.social/xrpc"
MAX_CHARS    = 280   # Bluesky grapheme limit is 300; we leave room for the URL
DRY_RUN      = "--dry-run" in sys.argv

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_env():
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, _, v = line.partition("=")
            k = k.strip()
            v = v.strip().strip("'\"")
            if k in ("BSKY_IDENTIFIER", "BSKY_APP_PASSWORD"):
                os.environ.setdefault(k, v)


def get_base_url():
    """Read baseURL from hugo.toml."""
    text = HUGO_TOML.read_text()
    m = re.search(r'^baseURL?\s*=\s*["\']([^"\']+)["\']', text, re.MULTILINE | re.IGNORECASE)
    return m.group(1).rstrip("/") if m else "https://luisangel.me"


def parse_note(path: Path):
    """Return (slug, date_iso, body_text) for a Hugo note file."""
    raw = path.read_text(encoding="utf-8")

    # Strip TOML frontmatter (+++ ... +++)
    if raw.startswith("+++"):
        end = raw.index("+++", 3)
        fm  = raw[3:end]
        body = raw[end + 3:].strip()
    # Strip YAML frontmatter (--- ... ---)
    elif raw.startswith("---"):
        end = raw.index("---", 3)
        fm  = raw[3:end]
        body = raw[end + 3:].strip()
    else:
        fm   = ""
        body = raw.strip()

    # Extract date from frontmatter
    date_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    m = re.search(r'date\s*=\s*["\']?([0-9T:Z+\-]+)', fm)
    if m:
        date_iso = m.group(1)

    # Slug = stem of filename
    slug = path.stem

    # Strip any markdown formatting from body for the post text
    text = body
    text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)   # links → text
    text = re.sub(r'[*_`#>]+', '', text)                    # bold/italic/code/headings
    text = re.sub(r'\n{2,}', '\n\n', text).strip()

    return slug, date_iso, text


def build_post_text(body: str, url: str) -> tuple[str, int, int]:
    """
    Returns (post_text, link_byte_start, link_byte_end).
    The URL is always appended; body is truncated if needed.
    """
    suffix = "\n\n" + url
    available = MAX_CHARS - len(url) - 2   # -2 for the \n\n

    if len(body) <= available:
        text = body + suffix
    else:
        # Truncate at word boundary
        truncated = body[:available].rsplit(None, 1)[0]
        text = truncated + "…" + suffix

    encoded  = text.encode("utf-8")
    url_bytes = url.encode("utf-8")
    start    = encoded.rfind(url_bytes)
    end      = start + len(url_bytes)
    return text, start, end


def api_post(endpoint: str, payload: dict, token: str = None) -> dict:
    url  = f"{BSKY_API}/{endpoint}"
    data = json.dumps(payload).encode("utf-8")
    req  = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP {e.code} from {endpoint}: {body}") from e


def create_session(identifier: str, password: str) -> tuple[str, str]:
    resp = api_post("com.atproto.server.createSession", {
        "identifier": identifier,
        "password":   password,
    })
    return resp["accessJwt"], resp["did"]


def create_post(token: str, did: str, text: str,
                link_start: int, link_end: int, url: str,
                created_at: str) -> dict:
    record = {
        "$type":     "app.bsky.feed.post",
        "text":      text,
        "createdAt": created_at,
        "facets": [
            {
                "index": {
                    "byteStart": link_start,
                    "byteEnd":   link_end,
                },
                "features": [
                    {
                        "$type": "app.bsky.richtext.facet#link",
                        "uri":   url,
                    }
                ],
            }
        ],
    }
    return api_post("com.atproto.repo.createRecord", {
        "repo":       did,
        "collection": "app.bsky.feed.post",
        "record":     record,
    }, token=token)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print("Usage: python3 scripts/post-to-bluesky.py <note-file> [--dry-run]")
        sys.exit(1)

    note_path = Path(args[0])
    if not note_path.exists():
        print(f"Error: file not found: {note_path}")
        sys.exit(1)

    load_env()
    identifier = os.environ.get("BSKY_IDENTIFIER", "")
    password   = os.environ.get("BSKY_APP_PASSWORD", "")

    if not identifier or not password:
        print("Error: BSKY_IDENTIFIER and BSKY_APP_PASSWORD must be set in .env or environment.")
        sys.exit(1)

    base_url   = get_base_url()
    slug, date_iso, body = parse_note(note_path)

    # Derive canonical URL: base + /notes/<slug>/
    canonical = f"{base_url}/notes/{slug}/"

    post_text, byte_start, byte_end = build_post_text(body, canonical)

    print(f"Note:      {note_path}")
    print(f"Canonical: {canonical}")
    print(f"Date:      {date_iso}")
    print(f"Post ({len(post_text)} chars):")
    print("-" * 40)
    print(post_text)
    print("-" * 40)
    print(f"Link facet bytes: {byte_start}–{byte_end}")

    if DRY_RUN:
        print("\nDry run — nothing posted.")
        return

    print(f"\nAuthenticating as {identifier}...")
    token, did = create_session(identifier, password)
    print(f"Authenticated. DID: {did}")

    print("Posting...")
    result = create_post(token, did, post_text, byte_start, byte_end, canonical, date_iso)
    uri = result.get("uri", "")
    cid = result.get("cid", "")
    print(f"Posted. URI: {uri}  CID: {cid}")
    bsky_url = uri.replace("at://", "https://bsky.app/profile/").replace("/app.bsky.feed.post/", "/post/")
    print(f"View at: {bsky_url}")


if __name__ == "__main__":
    main()
