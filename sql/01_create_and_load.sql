-- ============================================================
-- HIV/TB Surveillance Analysis
-- 01 — Schema & cleaning
-- Source: WHO Global Tuberculosis Programme — TB burden estimates
-- Engine: SQLite (portable to Postgres/BigQuery with minor tweaks)
-- ============================================================

-- Curated raw load (build.py loads only the columns used below).
-- One row = one country x one year.
CREATE TABLE IF NOT EXISTS tb_raw (
    country         TEXT,
    iso3            TEXT,
    g_whoregion     TEXT,   -- AFR, AMR, EMR, EUR, SEA, WPR
    year            TEXT,
    e_pop_num       TEXT,   -- estimated population
    e_inc_100k      TEXT,   -- TB incidence per 100k (all forms)
    e_inc_num       TEXT,   -- estimated incident TB cases (absolute)
    e_tbhiv_prct    TEXT,   -- % of incident TB cases that are HIV-positive
    e_inc_tbhiv_num TEXT,   -- estimated incident HIV-positive TB cases
    e_mort_100k     TEXT,   -- TB deaths per 100k (all)
    e_mort_num      TEXT,   -- estimated TB deaths (absolute)
    e_mort_tbhiv_num TEXT   -- estimated HIV-positive TB deaths
);

-- Analysis-ready view: numeric casts, readable region names,
-- and a southern-Africa flag for the regional peer comparison.
DROP VIEW IF EXISTS tb;
CREATE VIEW tb AS
SELECT
    country,
    iso3,
    CASE g_whoregion
        WHEN 'AFR' THEN 'Africa'        WHEN 'AMR' THEN 'Americas'
        WHEN 'EMR' THEN 'E. Mediterranean' WHEN 'EUR' THEN 'Europe'
        WHEN 'SEA' THEN 'SE Asia'       WHEN 'WPR' THEN 'W. Pacific'
        ELSE g_whoregion END                          AS region,
    CAST(year AS INTEGER)                             AS year,
    CAST(NULLIF(e_pop_num,'')        AS REAL)         AS population,
    CAST(NULLIF(e_inc_100k,'')       AS REAL)         AS tb_inc_per_100k,
    CAST(NULLIF(e_inc_num,'')        AS REAL)         AS tb_inc_cases,
    CAST(NULLIF(e_tbhiv_prct,'')     AS REAL)         AS tbhiv_pct,
    CAST(NULLIF(e_inc_tbhiv_num,'')  AS REAL)         AS tbhiv_cases,
    CAST(NULLIF(e_mort_100k,'')      AS REAL)         AS tb_mort_per_100k,
    CAST(NULLIF(e_mort_num,'')       AS REAL)         AS tb_deaths,
    CAST(NULLIF(e_mort_tbhiv_num,'') AS REAL)         AS tbhiv_deaths,
    CASE WHEN iso3 IN ('LSO','ZAF','SWZ','BWA','NAM','ZWE','MOZ','ZMB','MWI')
         THEN 1 ELSE 0 END                            AS southern_africa
FROM tb_raw;
