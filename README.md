# HIV/TB Surveillance: A Population-Health Analysis

**Author:** Brenden Andoseh · [LinkedIn](https://www.linkedin.com/in/brenden-andoseh-189484177/)
**Stack:** SQL (SQLite) · Python (stdlib) · Tableau
**Data:** [WHO Global Tuberculosis Programme — TB burden estimates](https://www.who.int/teams/global-tuberculosis-programme/data) (217 countries, 2000–2024)
**Live dashboard:** [Tableau Public](https://public.tableau.com/app/profile/brenden.andoseh/viz/HIV-TBSurveillance/Dashboard1)

> I spent two years as a Peace Corps Health Volunteer at a clinic in Lesotho working on HIV and TB. This project takes the question I lived day-to-day — *how bad is the HIV-driven TB epidemic, and is it getting better?* — and answers it with WHO's global surveillance data.

---

## Business problem
TB is the leading infectious killer of people living with HIV. Public-health programs (and their funders, like PEPFAR) need to know **where the HIV–TB coinfection burden is concentrated** and **whether incidence is actually falling**, so they can target integrated HIV/TB services. This analysis benchmarks Lesotho against the world and its southern-African peers.

## The data
One row per country per year, 2000–2024. Key WHO metrics: TB incidence per 100k, absolute incident cases, **% of TB cases that are HIV-positive (coinfection)**, and TB mortality (including HIV-positive TB deaths). Values are WHO modeled estimates; missing values are NULLed so they never distort an aggregate.

## Method
1. **Load** the WHO CSV into SQLite, keeping the 12 relevant columns (`build.py`).
2. **Clean** with a SQL view (`sql/01_create_and_load.sql`) — numeric casts, readable WHO-region names, a southern-Africa peer flag.
3. **Analyze** with six queries (`sql/02_analysis.sql`) → six Tableau-ready CSVs.
4. **Visualize** in Tableau (`tableau/DASHBOARD_GUIDE.md`).

## Key findings *(real WHO figures)*

**1. Lesotho's TB epidemic is uniquely HIV-driven.** In 2024, Lesotho had the **4th-highest TB incidence in the world** (548 per 100,000). But look at the company it keeps — and the difference:

| Country | TB incidence /100k | % of TB that is HIV+ |
|---|---|---|
| Kiribati | 945 | 0% |
| Papua New Guinea | 664 | 5% |
| Philippines | 625 | 1% |
| **Lesotho** | **548** | **62%** |
| Timor-Leste | 496 | 1% |

The other high-burden countries are mostly facing TB on its own. Lesotho's is tied to HIV: **62%** of its TB cases are co-infected, essentially tied with Zimbabwe for the highest share in the world. In practice that calls for integrated HIV/TB services rather than a standalone TB program, which is how the clinic I worked at was actually run.

**2. Real progress — but lagging the neighborhood.** Lesotho cut TB incidence **54%** since 2010 (1,180 → 548 per 100k). Genuine improvement — but its peers moved faster:

| Country | 2010 → 2024 incidence | % change |
|---|---|---|
| Eswatini | 1,590 → 319 | **−80%** |
| Botswana | 601 → 143 | −76% |
| South Africa | 1,230 → 389 | −68% |
| **Lesotho** | **1,180 → 548** | **−54%** |
| Zambia | 495 → 272 | −45% |

So the honest read is "improving, but underperforming comparable countries" — a finding that points toward studying what Eswatini and Botswana did differently.

**3. The burden is overwhelmingly African.** Population-weighted, Africa's TB incidence (207/100k) is ~10× Europe's (22/100k), and the region accounts for **107,402 HIV-positive TB deaths** in 2024 — more than all other regions combined.

## Recommendations
- **Integrate, don't separate.** In high-coinfection settings like Lesotho, TB and HIV services must be co-located (test-and-treat for both) — vertical programs miss the majority of patients.
- **Learn from faster-declining peers.** Benchmark Lesotho's case-finding and treatment-completion against Eswatini/Botswana.
- **Protect HIV-positive TB patients first** — they drive mortality; nutrition and ART adherence support (the kind of program I ran) directly reduce deaths.

## Honest notes (data caveats)
- WHO figures are **modeled estimates** with uncertainty intervals (the source file includes `_lo`/`_hi` bounds I kept out of the headline views for readability). Treat single-year point values as approximate.
- Coinfection % and incidence are independent estimates; the `pct_check` column in `top_coinfection_2024.csv` recomputes coinfection from absolute cases as a sanity check (lands within rounding).
- 2024 is the latest modeled year in this release.

## Reproduce it
```bash
# data/WHO_TB_burden_estimates.csv is the real WHO download (re-fetch anytime):
#   https://www.who.int/teams/global-tuberculosis-programme/data  ->  "TB burden estimates"
py build.py                 # loads, cleans, runs SQL, writes outputs/
# then open Tableau and follow tableau/DASHBOARD_GUIDE.md
```

## Files
```
hiv-tb-surveillance/
├─ README.md                ← this file
├─ build.py                 ← end-to-end pipeline (stdlib only)
├─ data/WHO_TB_burden_estimates.csv  ← real WHO source
├─ sql/01_create_and_load.sql   ← schema + cleaning view
├─ sql/02_analysis.sql          ← 6 analysis queries
├─ outputs/                 ← Tableau-ready CSVs (generated)
└─ tableau/DASHBOARD_GUIDE.md   ← step-by-step dashboard build
```
