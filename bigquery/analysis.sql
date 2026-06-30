-- ============================================================
-- HIV/TB Surveillance — BigQuery Standard SQL
-- Adapted from the SQLite version in ../sql/. Dataset assumed: `hiv_tb`
-- (`dataset.table` resolves to your default/sandbox project).
-- Load the data first with bigquery/load.sh (or the console steps in bigquery/README.md).
-- ============================================================

-- Cleaning view: SAFE_CAST handles blanks/non-numerics by returning NULL
-- (no need for SQLite's NULLIF(col,'') once BigQuery autodetect has typed the load).
CREATE OR REPLACE VIEW hiv_tb.tb AS
SELECT
    country,
    iso3,
    CASE g_whoregion
        WHEN 'AFR' THEN 'Africa'           WHEN 'AMR' THEN 'Americas'
        WHEN 'EMR' THEN 'E. Mediterranean' WHEN 'EUR' THEN 'Europe'
        WHEN 'SEA' THEN 'SE Asia'          WHEN 'WPR' THEN 'W. Pacific'
        ELSE g_whoregion END                       AS region,
    SAFE_CAST(year            AS INT64)            AS year,
    SAFE_CAST(e_pop_num       AS FLOAT64)          AS population,
    SAFE_CAST(e_inc_100k      AS FLOAT64)          AS tb_inc_per_100k,
    SAFE_CAST(e_inc_num       AS FLOAT64)          AS tb_inc_cases,
    SAFE_CAST(e_tbhiv_prct    AS FLOAT64)          AS tbhiv_pct,
    SAFE_CAST(e_inc_tbhiv_num AS FLOAT64)          AS tbhiv_cases,
    SAFE_CAST(e_mort_100k     AS FLOAT64)          AS tb_mort_per_100k,
    SAFE_CAST(e_mort_num      AS FLOAT64)          AS tb_deaths,
    SAFE_CAST(e_mort_tbhiv_num AS FLOAT64)         AS tbhiv_deaths,
    CASE WHEN iso3 IN ('LSO','ZAF','SWZ','BWA','NAM','ZWE','MOZ','ZMB','MWI')
         THEN 1 ELSE 0 END                         AS southern_africa
FROM hiv_tb.tb_raw;

-- Q1. Lesotho time series (2000–2024).
SELECT year, tb_inc_per_100k, tb_inc_cases, tbhiv_pct, tbhiv_cases, tb_mort_per_100k, tb_deaths
FROM hiv_tb.tb WHERE iso3 = 'LSO' ORDER BY year;

-- Q2. Highest TB incidence per 100k, latest year.
SELECT country, region, tb_inc_per_100k, tb_inc_cases, tbhiv_pct
FROM hiv_tb.tb WHERE year = 2024 AND tb_inc_per_100k IS NOT NULL
ORDER BY tb_inc_per_100k DESC LIMIT 20;

-- Q3. TB/HIV coinfection leaders (meaningful caseload only).
SELECT country, region, tbhiv_pct, tbhiv_cases, tb_inc_cases,
       ROUND(100.0 * tbhiv_cases / tb_inc_cases, 1) AS pct_check
FROM hiv_tb.tb WHERE year = 2024 AND tb_inc_cases >= 1000 AND tbhiv_pct IS NOT NULL
ORDER BY tbhiv_pct DESC LIMIT 20;

-- Q4. Population-weighted regional burden, latest year.
SELECT region,
       COUNT(*)                                          AS countries,
       ROUND(SUM(tb_inc_cases))                          AS tb_cases,
       ROUND(100000 * SUM(tb_inc_cases) / SUM(population), 1) AS pop_wtd_inc_per_100k,
       ROUND(SUM(tbhiv_deaths))                          AS hiv_tb_deaths
FROM hiv_tb.tb WHERE year = 2024 AND population IS NOT NULL AND tb_inc_cases IS NOT NULL
GROUP BY region ORDER BY pop_wtd_inc_per_100k DESC;

-- Q5. % change in TB incidence 2010 -> 2024, southern-African peers.
WITH y2010 AS (SELECT iso3, country, tb_inc_per_100k AS inc_2010 FROM hiv_tb.tb WHERE year = 2010),
     y2024 AS (SELECT iso3, tb_inc_per_100k AS inc_2024, tbhiv_pct AS tbhiv_2024 FROM hiv_tb.tb WHERE year = 2024)
SELECT a.country, b.inc_2010, c.inc_2024,
       ROUND(100.0 * (c.inc_2024 - b.inc_2010) / b.inc_2010, 1) AS pct_change, c.tbhiv_2024
FROM (SELECT DISTINCT iso3, country FROM hiv_tb.tb WHERE southern_africa = 1) a
JOIN y2010 b ON a.iso3 = b.iso3
JOIN y2024 c ON a.iso3 = c.iso3
ORDER BY pct_change;

-- Q6. Country-year extract (dashboard main source).
SELECT country, iso3, region, southern_africa, year, population, tb_inc_per_100k, tb_inc_cases,
       tbhiv_pct, tbhiv_cases, tb_mort_per_100k, tb_deaths, tbhiv_deaths
FROM hiv_tb.tb WHERE tb_inc_per_100k IS NOT NULL;
