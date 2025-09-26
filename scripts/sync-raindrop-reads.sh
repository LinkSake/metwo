#!/bin/bash

# Raindrop.io Latest Reads Sync Script
# Fetches recent bookmarks from Raindrop.io and updates latest-reads files

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLOG_DIR="$(dirname "$SCRIPT_DIR")"
EN_READS_FILE="$BLOG_DIR/content/en/garden/latest-reads.md"
ES_READS_FILE="$BLOG_DIR/content/es/garden/latest-reads.md"
EN_INDEX_FILE="$BLOG_DIR/content/en/_index.md"
ES_INDEX_FILE="$BLOG_DIR/content/es/_index.md"

# Load environment variables from .env file if it exists
ENV_FILE="$BLOG_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
    # Source the .env file, but only load RAINDROP_* variables for security
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue

        # Only load RAINDROP_* variables
        if [[ $key =~ ^RAINDROP_ ]]; then
            # Remove quotes if present
            value=$(echo "$value" | sed 's/^["'\'']\|["'\'']$//g')
            export "$key"="$value"
        fi
    done < "$ENV_FILE"
fi

# Environment variables (from .env file or environment)
RAINDROP_TOKEN="${RAINDROP_TOKEN:-}"
RAINDROP_COLLECTION_ID="${RAINDROP_COLLECTION_ID:-}"

# API Configuration
API_BASE="https://api.raindrop.io/rest/v1"
TEMP_DIR="/tmp/raindrop-sync"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

check_dependencies() {
    log "Checking dependencies..."

    for cmd in curl jq; do
        if ! command -v "$cmd" &> /dev/null; then
            error "$cmd is required but not installed. Please install it first."
        else
            log "✓ Found $cmd: $(command -v "$cmd")"
        fi
    done

    # Check .env file
    if [[ -f "$ENV_FILE" ]]; then
        log "✓ Found .env file: $ENV_FILE"
    else
        log "No .env file found at: $ENV_FILE"
    fi

    if [[ -z "$RAINDROP_TOKEN" ]]; then
        error "RAINDROP_TOKEN environment variable is not set. Please either:
  1. Create a .env file with: RAINDROP_TOKEN=your_token_here
  2. Or export it: export RAINDROP_TOKEN=\"your_token_here\""
    else
        log "✓ RAINDROP_TOKEN is set (length: ${#RAINDROP_TOKEN} characters)"
    fi

    if [[ -z "$RAINDROP_COLLECTION_ID" ]]; then
        error "RAINDROP_COLLECTION_ID environment variable is not set. Please either:
  1. Create a .env file with: RAINDROP_COLLECTION_ID=your_collection_id
  2. Or export it: export RAINDROP_COLLECTION_ID=\"your_collection_id\""
    else
        log "✓ RAINDROP_COLLECTION_ID is set: $RAINDROP_COLLECTION_ID"
    fi

    log "All dependencies verified successfully"
}

setup_temp_dir() {
    mkdir -p "$TEMP_DIR"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

fetch_recent_bookmarks() {
    log "Fetching 50 latest bookmarks from Raindrop.io..."

    local response_file="$TEMP_DIR/bookmarks.json"
    local url="$API_BASE/raindrops/$RAINDROP_COLLECTION_ID?sort=-created&perpage=50"

    log "API URL: $url"
    log "Using collection ID: $RAINDROP_COLLECTION_ID"

    # Fetch recent bookmarks (last 50, sorted by created date)
    local http_code
    http_code=$(curl -s -w "%{http_code}" \
        -H "Authorization: Bearer $RAINDROP_TOKEN" \
        -H "Content-Type: application/json" \
        "$url" \
        -o "$response_file")

    log "HTTP response code: $http_code"

    if [[ "$http_code" != "200" ]]; then
        log "API response content: $(cat "$response_file" 2>/dev/null || echo "No response content")"
        error "Failed to fetch data from Raindrop.io API. HTTP code: $http_code"
    fi

    # Check if request was successful
    if ! jq -e '.result' "$response_file" >/dev/null 2>&1; then
        log "API response: $(head -500 "$response_file" 2>/dev/null || echo "No response content")"
        error "Failed to fetch bookmarks from Raindrop.io. API returned error. Check your token and collection ID."
    fi

    local item_count=$(jq '.items | length' "$response_file" 2>/dev/null || echo "0")
    log "✓ Successfully fetched $item_count bookmarks from Raindrop.io"

    echo "$response_file"
}

parse_bookmark_data() {
    local json_file="$1"
    local parsed_file="$TEMP_DIR/parsed_bookmarks.txt"

    log "Parsing bookmark data..."

    # Verify the JSON file exists and is valid
    if [[ ! -f "$json_file" ]]; then
        error "JSON file does not exist: $json_file"
    fi

    if ! jq empty "$json_file" 2>/dev/null; then
        error "Invalid JSON in file: $json_file"
    fi

    # Show first entry date to verify order
    local first_date=$(jq -r '.items[0].created' "$json_file" 2>/dev/null || echo "unknown")
    local last_date=$(jq -r '.items[-1].created' "$json_file" 2>/dev/null || echo "unknown")
    log "Date range: $first_date (newest) to $last_date (oldest)"

    # Extract relevant fields and format them (API already returns newest first via sort=-created)
    # Clean the data to prevent newlines and pipe characters from breaking the format
    if ! jq -r '.items[] |
        select(.title != null and .link != null) |
        {
            created: .created,
            title: (.title | gsub("\\n"; " ") | gsub("\\r"; " ") | gsub("\\|"; "｜")),
            link: .link,
            excerpt: ((.excerpt // "") | gsub("\\n"; " ") | gsub("\\r"; " ") | gsub("\\|"; "｜")),
            note: ((.note // "") | gsub("\\n"; " ") | gsub("\\r"; " ") | gsub("\\|"; "｜"))
        } |
        "\(.created)|\(.title)|\(.link)|\(.excerpt)|\(.note)"' \
        "$json_file" > "$parsed_file" 2>/dev/null; then
        error "Failed to parse bookmark data with jq. Check if jq is properly installed."
    fi

    local parsed_count=$(wc -l < "$parsed_file" 2>/dev/null || echo "0")
    log "✓ Successfully parsed $parsed_count bookmark entries"

    if [[ "$parsed_count" -eq 0 ]]; then
        warn "No bookmark entries found after parsing"
    fi

    echo "$parsed_file"
}

format_date() {
    local iso_date="$1"
    # Convert ISO date to DD/MM/YY format
    local formatted_date

    # Extract date part and remove time/timezone info
    local date_part="${iso_date%T*}"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        formatted_date=$(date -j -f "%Y-%m-%d" "$date_part" +"%d/%m/%y" 2>/dev/null)
    else
        # Linux
        formatted_date=$(date -d "$date_part" +"%d/%m/%y" 2>/dev/null)
    fi

    if [[ -z "$formatted_date" ]]; then
        # Fallback to current date if parsing fails
        date +"%d/%m/%y"
    else
        echo "$formatted_date"
    fi
}


backup_files() {
    log "Creating backups..."
    cp "$EN_READS_FILE" "$EN_READS_FILE.backup"
    cp "$ES_READS_FILE" "$ES_READS_FILE.backup"
    cp "$EN_INDEX_FILE" "$EN_INDEX_FILE.backup"
    cp "$ES_INDEX_FILE" "$ES_INDEX_FILE.backup"
}

restore_backups() {
    warn "Restoring backups due to error..."
    mv "$EN_READS_FILE.backup" "$EN_READS_FILE"
    mv "$ES_READS_FILE.backup" "$ES_READS_FILE"
    mv "$EN_INDEX_FILE.backup" "$EN_INDEX_FILE"
    mv "$ES_INDEX_FILE.backup" "$ES_INDEX_FILE"
}

check_if_exists() {
    local url="$1"
    local file="$2"

    grep -qF "$url" "$file" 2>/dev/null
}

add_new_entries() {
    local parsed_file="$1"
    local new_entries=0

    log "Processing new entries..."

    # Check if file exists and has content
    if [[ ! -f "$parsed_file" ]] || [[ ! -s "$parsed_file" ]]; then
        log "Debug: Parsed file doesn't exist or is empty"
        echo "0"
        return
    fi

    # Collect new entries in an array (preserving chronological order)
    local new_entries_array=()
    local processed_count=0

    # Process each bookmark (limited to 50 latest)
    while IFS='|' read -r created title link excerpt note; do
        ((processed_count++))

        if [[ -z "$link" ]]; then
            log "Skipping entry $processed_count: empty link"
            continue
        fi

        # Skip if already exists in either file
        if check_if_exists "$link" "$EN_READS_FILE" || check_if_exists "$link" "$ES_READS_FILE"; then
            log "Skipping entry $processed_count: already exists - $title"
            continue
        fi

        local formatted_date
        formatted_date=$(format_date "$created")

        # Escape square brackets in title for markdown compatibility
        local escaped_title="${title//\[/\\[}"
        escaped_title="${escaped_title//\]/\\]}"

        # Create entry in new format: (dd/mm/yy) [Title](url)
        local entry="- ($formatted_date) [$escaped_title]($link)"

        # Add to array
        new_entries_array+=("$entry")
        ((new_entries++))
        log "Prepared entry $new_entries: ($formatted_date) $title"

        # Limit to 50 entries
        if [[ $new_entries -ge 50 ]]; then
            break
        fi

    done < "$parsed_file"

    log "Found $new_entries new entries to add"

    # Add entries in reverse order so newest appears first
    for ((i=$((new_entries-1)); i>=0; i--)); do
        local entry="${new_entries_array[$i]}"
        add_entry_to_beginning "$EN_READS_FILE" "$entry"
        add_entry_to_beginning "$ES_READS_FILE" "$entry"
        log "Added entry $((i+1))/$new_entries to files"
    done

    echo "$new_entries"
}

add_entry_to_beginning() {
    local file="$1"
    local entry="$2"

    # Find the line number of the closing +++ and add after it
    local header_end=$(grep -n "^+++" "$file" | tail -1 | cut -d: -f1)

    # Check if there's already content after the header
    local next_line=$((header_end + 1))
    local total_lines=$(wc -l < "$file")

    if [[ $next_line -le $total_lines ]]; then
        # There's content after header, insert at the beginning of that content
        sed -i '' "${next_line}i\\
$entry
" "$file"
    else
        # No content after header, append with a newline
        sed -i '' "${header_end}a\\
\\
$entry
" "$file"
    fi
}

get_last_three_entries() {
    local file="$1"

    # Extract all entries (lines starting with "- (")
    grep "^- (" "$file" | head -3
}

update_index_files() {
    log "Updating both English and Spanish index files with latest 3 entries..."

    local entries
    entries=$(get_last_three_entries "$EN_READS_FILE")

    # Update both English and Spanish index files (content is identical)
    update_index_section "$EN_INDEX_FILE" "## latest reads" "$entries"
    update_index_section "$ES_INDEX_FILE" "## últimas lecturas" "$entries"

    log "Both index files updated successfully."
}

update_index_section() {
    local file="$1"
    local section_header="$2"
    local entries="$3"

    # Find section start and end
    local start_line=$(grep -n "^$section_header" "$file" | cut -d: -f1)
    local end_line=$(sed -n "$((start_line+1)),\$p" "$file" | grep -n "^<div.*text-align.*center" | head -1 | cut -d: -f1)
    end_line=$((start_line + end_line - 1))

    # Create temporary file with new content
    local temp_file="$TEMP_DIR/$(basename "$file")"

    # Copy content before section
    sed -n "1,$((start_line))p" "$file" > "$temp_file"

    # Add empty line
    echo "" >> "$temp_file"

    # Add new entries
    echo "$entries" >> "$temp_file"

    # Add empty line
    echo "" >> "$temp_file"

    # Copy content after section
    sed -n "$((end_line)),\$p" "$file" >> "$temp_file"

    # Replace original file
    mv "$temp_file" "$file"
}

main() {
    log "Starting Raindrop.io sync..."

    check_dependencies
    setup_temp_dir

    # Create backups
    backup_files

    # Set error handler to restore backups
    trap 'restore_backups; cleanup' ERR

    # Fetch and process bookmarks
    local bookmarks_file
    bookmarks_file=$(fetch_recent_bookmarks)
    local parsed_file
    parsed_file=$(parse_bookmark_data "$bookmarks_file")

    # Add new entries only
    local new_count
    new_count=$(add_new_entries "$parsed_file")

    if [[ "$new_count" -gt 0 ]]; then
        # Update index files with latest entries
        update_index_files

        # Remove backups (success)
        rm -f "$EN_READS_FILE.backup" "$ES_READS_FILE.backup"
        rm -f "$EN_INDEX_FILE.backup" "$ES_INDEX_FILE.backup"

        log "Successfully added $new_count new entries!"
    else
        # Restore original files (no entries found)
        restore_backups
        log "No entries found."
    fi

    log "Sync completed!"
}

# Run main function
main "$@"
