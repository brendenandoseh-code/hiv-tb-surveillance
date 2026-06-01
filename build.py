"""
HIV/TB Surveillance Analysis — pipeline
---------------------------------------
Loads the WHO Global TB burden estimates into SQLite, applies the cleaning
view from sql/01_create_and_load.sql, runs sql/02_analysis.sql, and writes
Tableau-ready CSVs to outputs/.

Run:  py build.py        (Python standard library only)
"""
import csv, sqlite3, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "data", "WHO_TB_burden_estimates.csv")
DB   = os.path.join(HERE, "tb.db")
OUT  = os.path.join(HERE, "outputs")
os.makedirs(OUT, exist_ok=True)

# columns we keep, in tb_raw order
KEEP = ["country","iso3","g_whoregion","year","e_pop_num","e_inc_100k",
        "e_inc_num","e_tbhiv_prct","e_inc_tbhiv_num","e_mort_100k",
        "e_mort_num","e_mort_tbhiv_num"]

def load():
    if os.path.exists(DB):
        os.remove(DB)
    con = sqlite3.connect(DB); cur = con.cursor()
    with open(os.path.join(HERE,"sql","01_create_and_load.sql"), encoding="utf-8") as f:
        cur.executescript(f.read())
    with open(DATA, encoding="utf-8-sig", newline="") as f:
        rdr = csv.DictReader(f)
        batch = [tuple(row.get(c,"") for c in KEEP) for row in rdr]
    cur.executemany(
        f"INSERT INTO tb_raw ({','.join(KEEP)}) VALUES ({','.join('?'*len(KEEP))})",
        batch)
    con.commit()
    print(f"Loaded {len(batch):,} country-year rows.")
    return con

def split_queries(path):
    text = open(path, encoding="utf-8").read()
    out = []
    for chunk in text.split(";"):
        if "SELECT" in chunk.upper():
            m = re.search(r"outputs/([\w]+)\.csv", chunk)
            out.append((m.group(1) if m else f"query_{len(out)}", chunk.strip()))
    return out

def export(con, label, sql):
    cur = con.execute(sql)
    cols = [d[0] for d in cur.description]; rows = cur.fetchall()
    with open(os.path.join(OUT, f"{label}.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f); w.writerow(cols); w.writerows(rows)
    return cols, rows

def main():
    con = load()
    res = {}
    for label, sql in split_queries(os.path.join(HERE,"sql","02_analysis.sql")):
        cols, rows = export(con, label, sql); res[label] = (cols, rows)
        print(f"  outputs/{label}.csv  ({len(rows)} rows)")

    print("\n================ KEY FINDINGS ================")
    if "lesotho_trend" in res:
        cols, rows = res["lesotho_trend"]; ci = {c:i for i,c in enumerate(cols)}
        first = rows[0]; last = rows[-1]
        f10 = next((r for r in rows if r[ci['year']] == 2010), first)
        print(f"\nLesotho TB incidence/100k: {f10[ci['tb_inc_per_100k']]:.0f} (2010) -> "
              f"{last[ci['tb_inc_per_100k']]:.0f} ({last[ci['year']]}) "
              f"= {100*(last[ci['tb_inc_per_100k']]-f10[ci['tb_inc_per_100k']])/f10[ci['tb_inc_per_100k']]:.0f}%")
        print(f"Lesotho TB/HIV coinfection: {last[ci['tbhiv_pct']]:.0f}% of TB cases "
              f"are HIV-positive ({last[ci['year']]}).")
    if "top_incidence_2024" in res:
        cols, rows = res["top_incidence_2024"]; ci = {c:i for i,c in enumerate(cols)}
        rank = next((i+1 for i,r in enumerate(rows) if r[ci['country']]=='Lesotho'), None)
        print(f"\nGlobal TB-incidence rank (2024): Lesotho is #{rank} of all countries.")
        print("Top 5 highest TB incidence per 100k:")
        for r in rows[:5]:
            print(f"  {r[ci['country']]:<22} {r[ci['tb_inc_per_100k']]:.0f}/100k  (TB/HIV {r[ci['tbhiv_pct']] or 0:.0f}%)")
    if "by_region_2024" in res:
        cols, rows = res["by_region_2024"]; ci = {c:i for i,c in enumerate(cols)}
        print("\nPopulation-weighted TB incidence by WHO region (2024):")
        for r in rows:
            print(f"  {r[ci['region']]:<18} {r[ci['pop_wtd_inc_per_100k']]:>6}/100k | "
                  f"HIV+ TB deaths {int(r[ci['hiv_tb_deaths']] or 0):,}")
    con.close()
    print("\nDone. Connect Tableau to the files in outputs/.")

if __name__ == "__main__":
    main()
