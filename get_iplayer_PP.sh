#!/bin/bash

# === LOAD CONFIG FILE IF EXISTS ===
CONFIG_FILE="$HOME/.iplayer_convert.conf"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# === DEFAULT CONFIG VALUES (may be overridden) ===
src_dir="${src_dir:-$HOME/Downloads/get_iplayer-3.35}"
dest_dir="${dest_dir:-$HOME/remote/downloads/transmission/sonarr}"
enable_log="${enable_log:-false}"
log_file="${log_file:-$HOME/iplayer_convert.log}"
log_prefix="[📺 iPlayer Convert]"

# === LOGGING FUNCTION ===
log() {
  local msg="$1"
  printf "%b\n" "$msg"
  if [ "$enable_log" = true ]; then
    printf "%s %b\n" "$(date '+%F %T')" "$msg" >> "$log_file"
  fi
}

# === FILE COMPLETION CHECK ===
is_file_complete() {
  local f="$1"
  local size1 size2
  size1=$(stat -c%s "$f" 2>/dev/null) || return 1
  sleep 10
  size2=$(stat -c%s "$f" 2>/dev/null) || return 1
  [ "$size1" -eq "$size2" ]
}

# === PARSE CLI ARGS ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --show-name)     show_name="$2"; shift 2 ;;
    --series)        series_number="$2"; shift 2 ;;
    --src-dir)       src_dir="$2"; shift 2 ;;
    --dest-dir)      dest_dir="$2"; shift 2 ;;
    --enable-log)    enable_log=true; shift ;;
    *)               echo "Unknown option: $1"; exit 1 ;;
  esac
done

cd "$src_dir" || { log "$log_prefix ❌ Failed to cd into $src_dir"; exit 1; }

log "$log_prefix 🔍 Scanning for .mp4 files..."

shopt -s nullglob
files=(*.mp4)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  log "$log_prefix ℹ️  No .mp4 files found to process."
  exit 0
fi

IFS=$'\n' sorted=($(ls -1tr "${files[@]}"))
unset IFS

for file in "${sorted[@]}"; do
  log "\n$log_prefix ➡️  Found: $file"

  if ! is_file_complete "$file"; then
    log "$log_prefix ⏳ Skipping (still downloading)"
    continue
  fi

  # === AUTO-DETECT show_name, series_number, episode_number ===
  # Pattern: Show_Name_Series_25_-_01._Extra.mp4
  if [[ "$file" =~ ^([A-Za-z0-9_]+)_Series_([0-9]+)_-?_([0-9]+)\. ]]; then
    raw_show="${BASH_REMATCH[1]}"
    series_number="${series_number:-${BASH_REMATCH[2]}}"
    ep_num_raw="${BASH_REMATCH[3]}"
    show_name="${show_name:-$(echo "$raw_show" | tr '_' ' ')}"
    ep_num=$(printf "%02d" "$ep_num_raw")
    newname="${show_name} S${series_number}E${ep_num}.mp4"
  else
    log "$log_prefix ⚠️ Could not extract show/series/episode from: $file"
    continue
  fi

  log "$log_prefix 🎬 Transcoding to $newname"

  if ffmpeg -y -nostdin -hide_banner -loglevel error -stats \
    -i "$file" -c:v libx265 -preset medium -crf 24 -c:a copy "$newname"; then

    log "$log_prefix ✅ Transcode complete"

    if mv -f "$newname" "$dest_dir"; then
      log "$log_prefix 📦 Moved to: $dest_dir/$newname"
      rm -f "$file" && log "$log_prefix 🧹 Deleted original: $file"
    else
      log "$log_prefix ❌ Failed to move $newname to $dest_dir. Keeping original."
      rm -f "$newname" 2>/dev/null
    fi

  else
    log "$log_prefix ❌ ffmpeg failed for: $file"
    rm -f "$newname" 2>/dev/null
  fi
done

log "\n$log_prefix ✅ Done processing all files."
