#!/bin/bash

# sync-lately.sh
# Syncs "Lately" data from GoodReads, Letterboxd, and Raindrop.io
# into data/lately.yaml for use by the Hugo landing page.

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOG_DIR="$(dirname "$SCRIPT_DIR")"
DATA_FILE="$BLOG_DIR/data/lately.yaml"
TEMP_DIR="/tmp/sync-lately"
ENV_FILE="$BLOG_DIR/.env"

# ---------------------------------------------------------------------------
# External sources
# ---------------------------------------------------------------------------
GOODREADS_RSS="https://www.goodreads.com/review/list_rss/76567849?shelf=currently-reading"
LETTERBOXD_RSS="https://letterboxd.com/linksake/rss/"
RAINDROP_API="https://api.raindrop.io/rest/v1"
RAINDROP_LINKS_COUNT=5

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1" >&2; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
error(){ echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------
load_env() {
    if [[ -f "$ENV_FILE" ]]; then
        while IFS='=' read -r key value; do
            [[ $key =~ ^[[:space:]]*# ]] && continue
            [[ -z $key ]] && continue
            if [[ $key =~ ^RAINDROP_ ]]; then
                value=$(echo "$value" | sed 's/^["'\'']\|["'\'']$//g')
                export "$key"="$value"
            fi
        done < "$ENV_FILE"
    fi
}

check_deps() {
    for cmd in curl jq python3; do
        command -v "$cmd" &>/dev/null || error "Required tool not found: $cmd"
    done
    log "Dependencies OK"
}

setup() {
    mkdir -p "$TEMP_DIR"
    mkdir -p "$(dirname "$DATA_FILE")"
}

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# ---------------------------------------------------------------------------
# XML helper (used for both RSS feeds)
# ---------------------------------------------------------------------------
# Usage: parse_rss <xml_file> <xpath_like_query>
# We use a small inline Python script for reliable XML parsing.
xml_get() {
    local file="$1"
    local query="$2"   # e.g. "channel/item[0]/title"
    python3 - "$file" "$query" <<'PYEOF'
import sys, xml.etree.ElementTree as ET

def find_text(root, path):
    """Navigate a simple path like 'channel/item[0]/title'.
    Supports [N] index notation on any element."""
    parts = path.split('/')
    node = root
    for part in parts:
        idx = 0
        tag = part
        if '[' in part:
            tag, rest = part.split('[', 1)
            idx = int(rest.rstrip(']'))
        children = list(node) if tag == '*' else [c for c in node if c.tag.split('}')[-1] == tag or c.tag == tag]
        if not children or idx >= len(children):
            return ''
        node = children[idx]
    return (node.text or '').strip()

try:
    tree = ET.parse(sys.argv[1])
    root = tree.getroot()
    # Strip namespace from all tags for simpler querying
    for el in root.iter():
        if '}' in el.tag:
            el.tag = el.tag.split('}', 1)[1]
    print(find_text(root, sys.argv[2]))
except Exception as e:
    print('')
PYEOF
}

# ---------------------------------------------------------------------------
# GoodReads — currently-reading shelf
# ---------------------------------------------------------------------------
fetch_book() {
    log "Fetching book from GoodReads..."
    local rss_file="$TEMP_DIR/goodreads.xml"

    curl -s --max-time 15 "$GOODREADS_RSS" -o "$rss_file" || { warn "GoodReads fetch failed"; echo ""; return; }

    local title author url
    title=$(xml_get "$rss_file" "channel/item[0]/title")
    author=$(xml_get "$rss_file" "channel/item[0]/author_name")
    url=$(xml_get "$rss_file" "channel/item[0]/link")

    if [[ -z "$title" ]]; then
        warn "No currently-reading book found on GoodReads"
        echo ""
        return
    fi

    # Escape for YAML single-quote: double any single quotes
    title="${title//\'/\'\'}"
    author="${author//\'/\'\'}"

    log "Book: $title by $author"
    cat <<YAML
book:
  title: '$title'
  author: '$author'
  url: '$url'
YAML
}

# ---------------------------------------------------------------------------
# Letterboxd — most recently watched film
# ---------------------------------------------------------------------------
fetch_film() {
    log "Fetching film from Letterboxd..."
    local rss_file="$TEMP_DIR/letterboxd.xml"

    curl -s --max-time 15 "$LETTERBOXD_RSS" -o "$rss_file" || { warn "Letterboxd fetch failed"; echo ""; return; }

    local title year rating watched url
    title=$(xml_get "$rss_file" "channel/item[0]/filmTitle")
    year=$(xml_get "$rss_file" "channel/item[0]/filmYear")
    rating=$(xml_get "$rss_file" "channel/item[0]/memberRating")
    watched=$(xml_get "$rss_file" "channel/item[0]/watchedDate")
    url=$(xml_get "$rss_file" "channel/item[0]/link")

    if [[ -z "$title" ]]; then
        warn "No recent film found on Letterboxd"
        echo ""
        return
    fi

    title="${title//\'/\'\'}"

    # Convert rating (e.g. 4.5) to star string (★★★★½)
    local stars
    stars=$(python3 - "$rating" <<'PYEOF'
import sys
try:
    r = float(sys.argv[1])
    full = int(r)
    half = 1 if (r - full) >= 0.5 else 0
    print('★' * full + ('½' if half else '') + '☆' * (5 - full - half))
except:
    print('')
PYEOF
)

    log "Film: $title ($year) $stars"
    cat <<YAML
film:
  title: '$title'
  year: '$year'
  rating: '$rating'
  stars: '$stars'
  watched: '$watched'
  url: '$url'
YAML
}

# ---------------------------------------------------------------------------
# Raindrop.io — latest N links
# ---------------------------------------------------------------------------
fetch_links() {
    log "Fetching links from Raindrop.io..."

    local token="${RAINDROP_TOKEN:-}"
    local collection="${RAINDROP_COLLECTION_ID:-}"

    if [[ -z "$token" || -z "$collection" ]]; then
        warn "RAINDROP_TOKEN or RAINDROP_COLLECTION_ID not set — skipping links"
        echo "links: []"
        return
    fi

    local response_file="$TEMP_DIR/raindrop.json"
    local url="$RAINDROP_API/raindrops/$collection?sort=-created&perpage=$RAINDROP_LINKS_COUNT"

    local http_code
    http_code=$(curl -s --max-time 15 -w "%{http_code}" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        "$url" -o "$response_file")

    if [[ "$http_code" != "200" ]]; then
        warn "Raindrop.io API returned HTTP $http_code — skipping links"
        echo "links: []"
        return
    fi

    # Build YAML list using jq
    local links_yaml
    links_yaml=$(jq -r '
        .items[] |
        select(.title != null and .link != null) |
        {
            title: (.title | gsub("[\n\r]"; " ") | gsub("'\''"; "'\\'''\''") ),
            url:   .link,
            date:  (.created | split("T")[0])
        } |
        "  - title: '\''\(.title)'\''\n    url:   '\''\(.url)'\''\n    date:  '\''\(.date)'\''"
    ' "$response_file" 2>/dev/null || echo "")

    if [[ -z "$links_yaml" ]]; then
        warn "No links returned from Raindrop.io"
        echo "links: []"
        return
    fi

    local count
    count=$(echo "$links_yaml" | grep -c "^  - title:" || true)
    log "Links: $count fetched"

    echo "links:"
    echo "$links_yaml"
}

# ---------------------------------------------------------------------------
# Assemble and write data/lately.yaml
# ---------------------------------------------------------------------------
write_yaml() {
    local book_yaml="$1"
    local film_yaml="$2"
    local links_yaml="$3"

    cat > "$DATA_FILE" <<YAML
# Auto-generated by scripts/sync-lately.sh — do not edit by hand
# Last updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

$book_yaml

$film_yaml

$links_yaml
YAML

    log "Written to $DATA_FILE"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    log "Starting sync-lately..."
    load_env
    check_deps
    setup

    local book_yaml film_yaml links_yaml
    book_yaml=$(fetch_book)
    film_yaml=$(fetch_film)
    links_yaml=$(fetch_links)

    write_yaml "$book_yaml" "$film_yaml" "$links_yaml"

    log "Done."
}

main "$@"
