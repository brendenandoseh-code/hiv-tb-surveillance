# Tableau Dashboard Build Guide — HIV/TB Surveillance

Goal: a **"Global HIV/TB Burden"** dashboard for Tableau Public, with Lesotho as the throughline. ~30–45 min.

## Connect the data
1. Run `py build.py` to generate `outputs/`.
2. Tableau Public → **Connect → Text file** → `outputs/country_year.csv` (main extract).
3. Add the others as separate sources: `lesotho_trend.csv`, `top_incidence_2024.csv`, `top_coinfection_2024.csv`, `by_region_2024.csv`, `southern_africa_progress.csv`.

## Sheet 1 — "Lesotho over time" (dual-axis line, from `lesotho_trend.csv`)
- Columns: `year`. Rows: `tb_inc_per_100k` and `tbhiv_pct` (drag the second onto a dual axis).
- Title: **"Lesotho cut TB incidence 54% since 2010 — but 62% of TB is still HIV-positive."**
- This is your signature visual; it's your lived experience in one chart.

## Sheet 2 — "Where TB hits hardest" (bar, from `top_incidence_2024.csv`)
- Columns: `tb_inc_per_100k` · Rows: `country` (sorted desc). Color by `tbhiv_pct`.
- The color makes the point instantly: Lesotho is dark (high HIV) while equally-high-incidence countries are pale.
- Title: **"Same TB rate, very different epidemic: HIV coinfection."**

## Sheet 3 — "The coinfection leaders" (bar, from `top_coinfection_2024.csv`)
- Columns: `tbhiv_pct` · Rows: `country` (sorted desc). Highlight Lesotho.
- Title: **"Lesotho has among the highest TB/HIV coinfection on earth."**

## Sheet 4 — "Progress vs. peers" (bar of % change, from `southern_africa_progress.csv`)
- Columns: `pct_change` · Rows: `country` (sorted). Reference line at 0.
- Title: **"Improving, but slower than its neighbors."**

## Sheet 5 — "Regional burden" (filled map or bar, from `by_region_2024.csv` or `country_year.csv`)
- Map: from `country_year.csv` (filter year = 2024), drag `country` → map, color by `tb_inc_per_100k`.
- Or bar from `by_region_2024.csv`: `pop_wtd_inc_per_100k` by `region`.

## Assemble
1. Dashboard 1200×900. Sheet 1 across the top (hero). Sheets 2–4 in a row. Sheet 5 as context.
2. Add a `year` filter (where relevant) and a dashboard title: **"Global HIV/TB Burden — WHO Estimates, 2000–2024."**
3. Footer (honesty builds credibility):
   *"Source: WHO Global TB Programme, TB burden estimates (modeled, with uncertainty intervals). 'TB/HIV %' = share of incident TB cases that are HIV-positive."*

## Publish
- **File → Save to Tableau Public.** Copy the URL into your resume header, LinkedIn **Featured**, and the top of this README.

## Talking point (for interviews)
> "I served in Lesotho on HIV and TB, so I pulled WHO's global TB data to test what I saw on the ground. Lesotho has the 4th-highest TB incidence in the world, but the real story is in the segmentation: 62% of its TB is HIV-positive, versus near-zero in the other top-incidence countries. That reframes the whole intervention — it's not a TB program, it's an integrated HIV/TB program. I also benchmarked the decline against neighbors and found Lesotho improving but lagging Eswatini and Botswana, which is where I'd point a program evaluation next. The analysis lined up with what I lived, which is exactly why I trust good surveillance data."
