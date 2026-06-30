# Run this analysis on BigQuery

The same analysis as the SQLite pipeline (`../sql/`), ported to **BigQuery Standard SQL** — so it runs on Google's cloud data warehouse. It works on the **free BigQuery sandbox** (no credit card / billing required).

> Adapted from the tested SQLite version; differences are BigQuery-dialect (`SAFE_CAST`, `CREATE OR REPLACE VIEW`, dataset-qualified names). Confirm on first run.

## Option A — Web console (no install)
1. Open the **BigQuery console** (`console.cloud.google.com/bigquery`). First visit enables a free **sandbox** project automatically.
2. **Create dataset** → ID `hiv_tb` (location US).
3. **Create table** → Source: *Upload* → file `data/WHO_TB_burden_estimates.csv` → Schema: **Auto detect** → Table name `tb_raw` → Create.
4. Open a new query tab, paste **`analysis.sql`**, and run. It creates the `hiv_tb.tb` view and runs the six analyses. (Run the whole script, or statement-by-statement.)

## Option B — Command line (`bq`)
With the Google Cloud SDK installed and `gcloud auth login` done:
```bash
bash bigquery/load.sh
```
Creates the dataset, loads `tb_raw`, builds the view, and runs the queries.

## Notes
- `dataset.table` references (e.g., `hiv_tb.tb`) resolve to your default/sandbox project — no project ID to hard-code.
- The WHO CSV has ~50 columns; auto-detect keeps the original names, and the view selects the dozen it needs.
