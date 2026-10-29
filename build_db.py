"""Builds ecommerce.db, runs every SQL file in order, and saves each query's
output to results/*.csv plus a combined results/summary.md.
Usage:  python build_db.py
"""
import csv, re, sqlite3, pathlib

ROOT = pathlib.Path(__file__).parent
DB = ROOT / "ecommerce.db"
if DB.exists():
    DB.unlink()
con = sqlite3.connect(DB)

def run_script(name):
    con.executescript((ROOT / "sql" / name).read_text())

# 1) schema + staging load
run_script("01_schema.sql")
with open(ROOT / "data" / "ecommerce_sales_analytics_5000.csv", newline="") as f:
    rows = [tuple(r.values()) for r in csv.DictReader(f)]
con.executemany("INSERT INTO stg_orders VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", rows)
con.commit()

# 2) transform to star schema
run_script("02_transform.sql")
con.commit()

# 3) run queries from files that contain several statements
def split_queries(text):
    blocks = re.split(r"(?m)^-- (Q\d+[^\n]*)\n", text)
    return [(blocks[i], blocks[i + 1].strip()) for i in range(1, len(blocks), 2)]

def to_md(cols, data):
    out = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    out += ["| " + " | ".join("" if v is None else str(v) for v in r) + " |" for r in data]
    return "\n".join(out)

summary = []
for fname in ["03_data_quality.sql", "04_business_analysis.sql"]:
    text = (ROOT / "sql" / fname).read_text()
    if fname.startswith("03"):
        text = re.sub(r"(?m)^-- (Q\d+\.)", r"-- \1", text)
        parts = [(m.group(1), m.group(2)) for m in re.finditer(
            r"-- (Q\d+\.[^\n]*)\n((?:(?!\n-- Q\d+\.).)*)", text, re.S)]
    else:
        parts = split_queries(text)
    for title, sql in parts:
        sql = sql.strip().rstrip(";")
        sql = "\n".join(l for l in sql.splitlines() if not l.startswith("-- ====")).strip()
        cur = con.execute(sql)
        cols = [d[0] for d in cur.description]
        data = cur.fetchall()
        slug = re.sub(r"\W+", "_", title.split(":")[0].split(".")[0]).lower()
        prefix = "dq" if fname.startswith("03") else "analysis"
        with open(ROOT / "results" / f"{prefix}_{slug}.csv", "w", newline="") as out:
            w = csv.writer(out); w.writerow(cols); w.writerows(data)
        summary.append(f"### {title}\n\n{to_md(cols, data)}\n")

(ROOT / "results" / "summary.md").write_text("\n".join(summary))
con.close()
print("Built", DB.name, "and wrote", len(summary), "result tables")
