#!/bin/bash
set -e

# Calculate next month and current month with no leading zero for month
NEXT_YEAR=$(date -u -d "$(date +%Y-%m-15) +1 month" +"%Y")
NEXT_MONTH=$(date -u -d "$(date +%Y-%m-15) +1 month" +"%-m")  # no leading zero

CURRENT_YEAR=$(date -u +"%Y")
CURRENT_MONTH=$(date -u +"%-m")  # no leading zero

OUTPUT_FILE="LastFX.xml"

download_file() {
  local year=$1
  local month=$2
  local url="https://www.trade-tariff.service.gov.uk/api/v2/exchange_rates/files/monthly_xml_${year}-${month}.xml"
  echo "Attempting to download: $url"
  curl -s -f -o "$OUTPUT_FILE" "$url"
}

if download_file "$NEXT_YEAR" "$NEXT_MONTH"; then
  echo "Downloaded next month (${NEXT_YEAR}-${NEXT_MONTH}) exchange rates."
  FILE_MONTH="${NEXT_YEAR}-${NEXT_MONTH}"
elif download_file "$CURRENT_YEAR" "$CURRENT_MONTH"; then
  echo "Downloaded current month (${CURRENT_YEAR}-${CURRENT_MONTH}) exchange rates."
  FILE_MONTH="${CURRENT_YEAR}-${CURRENT_MONTH}"
else
  echo "ERROR: Both next and current month files not available."
  exit 1
fi

# Force commit if file not tracked yet
if git ls-files --error-unmatch "$OUTPUT_FILE" > /dev/null 2>&1; then
  if git diff --quiet "$OUTPUT_FILE"; then
    echo "No changes detected in $OUTPUT_FILE; no commit needed."
    exit 0
  fi
else
  echo "$OUTPUT_FILE not tracked yet, will commit."
fi

git config user.name "exchange-rates-bot"
git config user.email "bot@example.com"
git add "$OUTPUT_FILE"
git commit -m "Update LastFX.xml for $FILE_MONTH"
git push

echo "Committed and pushed updated $OUTPUT_FILE for $FILE_MONTH."
