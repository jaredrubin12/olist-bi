"""Open the DuckDB web UI on the warehouse, for browsing and ad-hoc SQL.

Opens read-only, so exploring can never change the data.
Close it (press Enter here) before running anything that writes to the
database, such as load_raw.py or dbt.

Usage (from the repo root, with the venv active):
    python scripts/explore.py
"""

from pathlib import Path

import duckdb

DB_PATH = Path(__file__).resolve().parent.parent / "warehouse" / "olist.duckdb"

# Attach the warehouse read-only rather than opening it with read_only=True:
# that flag makes the whole session read-only, which stops the UI from
# creating its own internal state database.
con = duckdb.connect()
con.sql(f"attach '{DB_PATH.as_posix()}' as olist (read_only)")
con.sql("call start_ui()")  # starts a local server and opens your browser
# Each UI notebook has its own session: run `use olist;` in its first cell,
# or write table names in full (olist.raw.orders).
print("DuckDB UI running at http://localhost:4213")
input("Press Enter to stop... ")
con.close()
