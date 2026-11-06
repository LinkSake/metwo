#!/bin/bash

# sync-lately.sh
# Syncs "Lately" data from GoodReads, Letterboxd, MyAnimeList,
# Last.fm, and Raindrop.io into data/lately.yaml for use by the Hugo
# landing page, and appends new Raindrop reads to the
# garden/latest-reads.md archive (EN+ES).

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOG_DIR="$(dirname "$SCRIPT_DIR")"
DATA_FILE="$BLOG_DIR/data/lately.yaml"
EN_READS_FILE="$BLOG_DIR/content/en/garden/latest-reads.md"
ES_READS_FILE="$BLOG_DIR/content/es/garden/latest-reads.md"
TEMP_DIR="/tmp/sync-lately"
ENV_FILE="$BLOG_DIR/.env"

# ---------------------------------------------------------------------------
# External sources
# ---------------------------------------------------------------------------
GOODREADS_RSS="https://www.goodreads.com/review/list_rss/76567849?shelf=currently-reading"
LETTERBOXD_RSS="https://letterboxd.com/linksake/rss/"
MAL_WATCHING_URL="https://myanimelist.net/animelist/LinkSake/load.json?status=1"
LASTFM_API="https://ws.audioscrobbler.com/2.0/"
LASTFM_USER="LinkSake"
RAINDROP_API="https://api.raindrop.io/rest/v1"
RAINDROP_WIDGET_COUNT=1    # shown in the landing page "lately" widget
RAINDROP_ARCHIVE_FETCH=20  # fetched per run to backfill the latest-reads archive
RAINDROP_JSON_FILE="$TEMP_DIR/raindrop.json"  # fetch_links() writes here on success

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
