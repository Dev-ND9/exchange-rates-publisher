#!/bin/bash

set -e

# Calculate dates
NEXT_MONTH=$(date -u -d "$(date +%Y-%m-15) +1 month" +"%Y_%m")
CURRENT_MONTH=$(date -u +"%Y_%m")
OUTPUT_FILE="LastFX.xml"

# Function to download a given month's file
download_file() {
  local month=$1
  local file_name="exchange_rates_${month}.xml"
  local url="https://www.trade-tariff.service.gov.uk/api/v2/exchange_rates/files/${file_name}"
  echo "Attempting to download: $url"
  curl -s -f -o "$OUTPUT_FILE" "$url"
}

# Try next month first
if download_file "$NEXT_MONTH"; then
  echo "Downloaded next month ($NEXT_MONTH) exchange rates."
  FILE_MONTH=$NEXT_MONTH
else
  echo "Next month ($NEXT_MONTH) file not available, trying current month ($CURRENT_MONTH)..."
  if download_file "$CURRENT_MONTH"; then
    echo "Downloaded current month ($CURRENT_MONTH) exchange rates."
    FILE_MONTH=$CURRENT_MONTH
  else
    echo "ERROR: Both next and current month files not available."
    exit 1
  fi
fi

# Check for changes
if git diff --quiet "$OUTPUT_FILE"; then
  echo "No changes detected in $OUTPUT_FILE; no commit needed."
  exit 0
fi

# Configure git and commit changes
git config user.name "exchange-rates-bot"
git config user.email "bot@example.com"
git add "$OUTPUT_FILE"
git commit -m "Update LastFX.xml for $FILE_MONTH"
git push

echo "Committed and pushed updated $OUTPUT_FILE for $FILE_MONTH."
