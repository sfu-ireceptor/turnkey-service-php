#!/usr/bin/env bash
#
# extract_daily_log.sh - extract one day's HTTP access log entries from a
# docker compose service into a daily log file. Written with the assistance
# of Claude.
#
# Usage:
#   ./extract_daily_log.sh [-s SERVICE] [-d YYYY-MM-DD] [-o OUTDIR] [-f COMPOSE_FILE]
#
# Defaults:
#   SERVICE = ireceptor-api
#   PROJECT="turnkey-service"
#   DATE    = today (UTC, since the log timestamps are +0000)
#   OUTDIR  = ./daily_logs
#
# Output: OUTDIR/SERVICE-YYYY-MM-DD.log (overwritten each run, so re-running is safe)
# 
# Can be added to a cron file to extract daily logs from the container. Since logs
# are not persistent across container restarts, this is required to capture logs 
# over time. This runs just after midnight and extracts the logs for the previous day.
#
# 5 0 * * * cd /home/ubuntu/turnkey-service-php/scripts && ./extract_daily_log.sh -o /data/http/daily_logs -d $(date -u -d yesterday +\%Y-\%m-\%d)

set -euo pipefail

SERVICE="ireceptor-api"
PROJECT="turnkey-service"
DAY=""
OUTDIR="./daily_logs"
COMPOSE_FILE=""

while getopts "s:d:o:f:h" opt; do
  case "$opt" in
    s) SERVICE="$OPTARG" ;;
    d) DAY="$OPTARG" ;;
    o) OUTDIR="$OPTARG" ;;
    f) COMPOSE_FILE="$OPTARG" ;;
    h|*) sed -n '2,15p' "$0"; exit 1 ;;
  esac
done

# Default to today in UTC to match the +0000 timestamps in the log
if [[ -z "$DAY" ]]; then
  DAY=$(date -u +%Y-%m-%d)
fi

# Convert YYYY-MM-DD to the log's DD/Mon/YYYY format (e.g. 06/Nov/2026).
# LC_ALL=C forces English month abbreviations to match the log.
if LC_ALL=C date -d "$DAY" +%d/%b/%Y >/dev/null 2>&1; then
  LOGDATE=$(LC_ALL=C date -d "$DAY" +%d/%b/%Y)            # GNU date (Linux)
else
  LOGDATE=$(LC_ALL=C date -j -f %Y-%m-%d "$DAY" +%d/%b/%Y) # BSD date (macOS)
fi

mkdir -p "$OUTDIR"
OUTFILE="$OUTDIR/${SERVICE}-${DAY}.log"

COMPOSE=(docker compose)
if [[ -n "$COMPOSE_FILE" ]]; then
  COMPOSE+=(-f "$COMPOSE_FILE")
fi

# --no-log-prefix strips the "service  | " prefix.
# grep -F matches the literal "[DD/Mon/YYYY:" so only that day's entries are kept.
# "|| true" stops grep's exit code 1 (no matches) from aborting under set -e.
sudo "${COMPOSE[@]}" --project-name "$PROJECT" logs --no-log-prefix "$SERVICE" 2>/dev/null \
  | grep -F "[${LOGDATE}:" > "$OUTFILE" || true

COUNT=$(wc -l < "$OUTFILE" | tr -d ' ')
echo "Wrote $COUNT entries for $LOGDATE to $OUTFILE on $(date)"

