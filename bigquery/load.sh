#!/usr/bin/env bash
# Load the HIV/TB data into BigQuery, create the cleaning view, and run the analyses.
# Works on the free BigQuery sandbox (no billing). Prereqs:
#   - Google Cloud SDK (gcloud + bq)   https://cloud.google.com/sdk/docs/install
#   - gcloud auth login
#   - gcloud config set project YOUR_PROJECT_ID
# Run from the repo root:  bash bigquery/load.sh
set -euo pipefail
DATASET=hiv_tb

bq --location=US mk -f --dataset "$DATASET"

# The WHO file has ~50 columns; --autodetect keeps their original names (e_inc_100k, etc.),
# which is exactly what bigquery/analysis.sql references.
bq load --replace --autodetect --source_format=CSV --skip_leading_rows=1 \
    "${DATASET}.tb_raw" "data/WHO_TB_burden_estimates.csv"

# Creates VIEW hiv_tb.tb and runs the six analysis queries.
bq query --use_legacy_sql=false < "bigquery/analysis.sql"

echo "Done — explore dataset '${DATASET}' in the BigQuery console."
