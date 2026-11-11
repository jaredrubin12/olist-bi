"""Load the raw Olist CSVs into DuckDB, untouched, as tables in the `raw` schema.

This is the "EL" in ELT: no cleaning or renaming happens here. All
transformation is done later in dbt. Safe to re-run; tables are replaced.

Usage (from the repo root, with the venv active):
    python scripts/load_raw.py
"""

from pathlib import Path

import duckdb

REPO_ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = REPO_ROOT / "data" / "raw"
DB_PATH = REPO_ROOT / "warehouse" / "olist.duckdb"

# File format for the warehouse. Evidence's DuckDB connector bundles DuckDB 1.4,
# which can't read files in the newer 2.x format. The format is fixed when the
# file is created and kept when dbt writes to it later. See ADR 0002.
STORAGE_VERSION = "v1.4.0"


def connect_warehouse() -> duckdb.DuckDBPyConnection:
    """Open the warehouse, creating it in the Evidence-compatible format if new."""
    rebuild_hint = (
        f"{DB_PATH.relative_to(REPO_ROOT)} is in a newer format than Evidence can read "
        f"(needs {STORAGE_VERSION}).\nDelete it, re-run this script, then run `dbt build`."
    )
    con = duckdb.connect()
    try:
        con.execute(f"attach '{DB_PATH.as_posix()}' as olist (storage_version '{STORAGE_VERSION}')")
    except duckdb.InvalidInputException as e:
        if "storage version" in str(e):
            raise SystemExit(rebuild_hint) from None
        raise
    con.execute("use olist")

    actual = con.execute(
        "select tags['storage_version'] from duckdb_databases() where database_name = 'olist'"
    ).fetchone()[0]
    if not actual or not actual.startswith(STORAGE_VERSION):
        con.close()
        raise SystemExit(rebuild_hint)
    return con


def table_name_for(csv_path: Path) -> str:
    """olist_order_items_dataset.csv -> order_items"""
    name = csv_path.stem
    name = name.removeprefix("olist_").removesuffix("_dataset")
    return name


def main() -> None:
    csv_files = sorted(RAW_DIR.glob("*.csv"))
    if not csv_files:
        raise SystemExit(f"No CSV files found in {RAW_DIR}. See README > Getting started.")

    with connect_warehouse() as con:
        con.execute("create schema if not exists raw")

        for csv_path in csv_files:
            table = table_name_for(csv_path)
            # read_csv detects column types automatically; header row gives column names.
            con.execute(
                f"create or replace table raw.{table} as "
                f"select * from read_csv(?, header = true)",
                [str(csv_path)],
            )
            rows = con.execute(f"select count(*) from raw.{table}").fetchone()[0]
            print(f"  raw.{table:<36} {rows:>10,} rows")

    print(f"\nLoaded {len(csv_files)} tables into {DB_PATH.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
