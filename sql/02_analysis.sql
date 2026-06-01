-- ============================================================
-- HIV/TB Surveillance Analysis
-- 02 — Analysis queries  (run after 01_create_and_load.sql)
-- Each query maps to one exported CSV / one Tableau sheet.
-- "Latest year" = 2024 (most recent in this WHO release).
-- ============================================================

-- Q1. Lesotho time series, 2000-2024: the country I served in.
--     TB incidence, TB/HIV coinfection %, and mortality over time.
--     -> outputs/lesotho_trend.csv  (Tableau: dual-axis line — incidence vs coinfection %)
SELECT
    year,
    tb_inc_per_100k,
    tb_inc_cases,
    tbhiv_pct,
    tbhiv_cases,
    tb_mort_per_100k,
    tb_deaths
FROM tb
WHERE iso3 = 'LSO'
ORDER BY year;

-- Q2. Where does Lesotho rank? Highest TB incidence per 100k, latest year.
--     -> outputs/top_incidence_2024.csv  (Tableau: ranked bar, Lesotho highlighted)
SELECT
    country, region, tb_inc_per_100k, tb_inc_cases, tbhiv_pct
FROM tb
WHERE year = 2024 AND tb_inc_per_100k IS NOT NULL
ORDER BY tb_inc_per_100k DESC
LIMIT 20;

-- Q3. The HIV-driven TB epidemic: countries where TB is most tied to HIV.
--     Restricted to a meaningful caseload so small denominators don't dominate.
--     -> outputs/top_coinfection_2024.csv  (Tableau: ranked bar of TB/HIV %)
SELECT
    country, region, tbhiv_pct, tbhiv_cases, tb_inc_cases,
    ROUND(100.0 * tbhiv_cases / tb_inc_cases, 1) AS pct_check
FROM tb
WHERE year = 2024 AND tb_inc_cases >= 1000 AND tbhiv_pct IS NOT NULL
ORDER BY tbhiv_pct DESC
LIMIT 20;

-- Q4. Regional burden, latest year: population-weighted TB incidence
--     and total HIV-positive TB deaths by WHO region.
--     -> outputs/by_region_2024.csv  (Tableau: bar / map)
SELECT
    region,
    COUNT(*)                                                   AS countries,
    ROUND(SUM(tb_inc_cases))                                   AS tb_cases,
    ROUND(1e5 * SUM(tb_inc_cases) / SUM(population), 1)        AS pop_wtd_inc_per_100k,
    ROUND(SUM(tbhiv_deaths))                                   AS hiv_tb_deaths
FROM tb
WHERE year = 2024 AND population IS NOT NULL AND tb_inc_cases IS NOT NULL
GROUP BY region
ORDER BY pop_wtd_inc_per_100k DESC;

-- Q5. Progress check: % change in TB incidence per 100k, 2010 -> 2024,
--     for the southern-African peer group (incl. Lesotho).
--     -> outputs/southern_africa_progress.csv  (Tableau: slope / bar of % change)
WITH y2010 AS (SELECT iso3, country, tb_inc_per_100k AS inc_2010 FROM tb WHERE year = 2010),
     y2024 AS (SELECT iso3, tb_inc_per_100k AS inc_2024, tbhiv_pct AS tbhiv_2024 FROM tb WHERE year = 2024)
SELECT
    a.country,
    b.inc_2010,
    c.inc_2024,
    ROUND(100.0 * (c.inc_2024 - b.inc_2010) / b.inc_2010, 1) AS pct_change,
    c.tbhiv_2024
FROM (SELECT DISTINCT iso3, country FROM tb WHERE southern_africa = 1) a
JOIN y2010 b ON a.iso3 = b.iso3
JOIN y2024 c ON a.iso3 = c.iso3
ORDER BY pct_change;

-- Q6. Main country-year extract powering the dashboard (key metrics only).
--     -> outputs/country_year.csv  (Tableau main extract)
SELECT
    country, iso3, region, southern_africa, year,
    population, tb_inc_per_100k, tb_inc_cases, tbhiv_pct, tbhiv_cases,
    tb_mort_per_100k, tb_deaths, tbhiv_deaths
FROM tb
WHERE tb_inc_per_100k IS NOT NULL;
