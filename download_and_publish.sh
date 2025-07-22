#!/bin/bash

# Calculate next month (YYYY_MM)
NEXT_MONTH=$(date -u -d "$(date +%Y-%m-15) +1 month" +"%Y_%m")
FILE_NAME="exchange_rates_${NEXT_MONTH}.xml"
DOWNLOAD_URL="https://www.trade-tariff.service.gov.uk/api/v2/exchange_rates/files/${FILE_NAME}"
OUTPUT_FILE="LastFX.xml"

echo "Downloading: $DOWNLOAD_URL"

# Download the XML
curl -s -f -o "$OUTPUT_FILE" "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
  echo "❌ Download failed. Exit."
  exit 1
fi

echo "✅ Download succeeded."

# If file unchanged, exit
if git diff --quiet "$OUTPUT_FILE"; then
  echo "No change; exit."
  exit 0
fi

git config user.name "exchange-rates-bot"
git config user.email "bot@example.com"
git add "$OUTPUT_FILE"
git commit -m "Update LastFX.xml for $NEXT_MONTH"
git push

echo "✅ Changes pushed!"
