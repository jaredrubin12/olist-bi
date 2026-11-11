# Olist BI Portfolio Project

## Purpose
An end-to-end modern BI stack built on the Olist Brazilian e-commerce dataset,
as a portfolio piece for BI leadership roles. It should show sound architecture,
clear documentation and disciplined data quality. Those matter more here than
technical complexity.

## Stack
- DuckDB: local analytical warehouse
- dbt-duckdb: transformations and tests (dbt Core v1, deliberately; see docs/decisions)
- Evidence.dev: dashboards
- GitHub Actions: CI (dbt build/test, Evidence build)

## Learning-pace rules (important)
- The owner is learning as we go. Work in one small step at a time.
- Before each step, explain in plain English what you're about to do and why.
- After each step, give a 3-sentence summary written for a non-technical manager,
  so the owner can follow and retell the progress.
- Then stop and wait for the owner to say "next".
- If the owner asks a question, answer it fully before continuing.
- Prefer the simple, conventional approach. Explain trade-offs briefly when they matter.

## Environment
- Windows, PowerShell. Python 3.13 virtual env in .venv (activate: .venv\Scripts\Activate.ps1).
- Exact package versions are pinned in requirements.txt.

## Shortcuts
- "open the db": the DuckDB UI must run in the owner's own terminal (it waits for
  Enter to stop), so reply with these commands to paste:
  ```
  cd C:\Users\mjrub\projects\olist-bi
  .venv\Scripts\Activate.ps1
  python scripts/explore.py
  ```
  Remind them to run `use olist;` first in each notebook (or write tables as
  olist.raw.<table>), and to press Enter to close it before running load scripts or dbt.

## Folder layout
- data/raw/: the 9 Olist CSVs. Never modified, never committed.
- warehouse/: DuckDB database file (git-ignored).
- transform/: dbt project (added in Phase 3).
- dashboards/: Evidence project (added in Phase 6).
- docs/: architecture, data dictionary, decision records (docs/decisions/).
- .github/workflows/: CI.

## Conventions
- Run dbt from transform/ (profiles.yml lives there; DB path is relative to it).
  Close the DuckDB UI first, or dbt can't get write access to the database.
- dbt layers: staging (stg_) → intermediate (int_) → marts (fct_, dim_).
- Every model gets a description in YAML. Every primary key gets unique + not_null tests.
- Significant design choices get a short decision record in docs/decisions/.
- SQL style: lowercase keywords, CTEs over subqueries, one model per file.

## Phased plan
1. Setup: repo, env, folders, docs skeleton  ✓ done
2. Ingest & explore: load CSVs into DuckDB, profile the data  ✓ done
3. Staging layer: dbt sources, staging models, basic tests  ✓ done
4. Dimensional model: intermediate + marts (star schema)  ← current
5. Data quality: deeper tests, dbt docs, data dictionary
6. Dashboards: Evidence pages (exec KPIs, sales, delivery, reviews)
7. CI/CD: GitHub Actions on every PR
8. Portfolio polish: architecture diagram, decision records, README, deployment
