name: Update Exchange Rates

on:
  schedule:
    - cron: '0 7 20 * *'   # runs at 07:00 UTC on the 20th of each month (adjust as needed)
  workflow_dispatch:       # allows manual triggering

permissions:
  contents: write          # important to allow pushing commits

jobs:
  update-exchange-rates:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3
        with:
          persist-credentials: true  # crucial to allow pushing changes

      - name: Set execute permission for script
        run: chmod +x ./download_and_publish.sh

      - name: Run download and publish script
        run: ./download_and_publish.sh
