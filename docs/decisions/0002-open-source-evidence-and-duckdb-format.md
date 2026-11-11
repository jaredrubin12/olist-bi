# 0002: Use open-source Evidence, with a DuckDB 1.4-compatible warehouse file

- **Status:** Accepted
- **Date:** 2026-11-10

## Context

The plan called for Evidence.dev dashboards. When setting up Phase 6:

1. **Evidence's official template now targets Evidence Studio**, a hosted
   product launched in June 2025. Its CLI workflow depends on a Studio account
   (`evidence login`) and an organization data connection.
2. **Open-source Evidence is still published** (`@evidence-dev/evidence`
   40.1.8, February 2026). It runs locally with no account, but has had no
   release since February 2026.
3. **Open-source Evidence's DuckDB connector bundles DuckDB 1.4.** Our pipeline
   (Python, dbt-duckdb) uses DuckDB 2.0, whose default file format DuckDB 1.4
   cannot read.

## Decision

- Use **open-source Evidence** (template at commit `4b13d42e15`, the last
  pre-Studio version), trimmed to the DuckDB connector only.
- Create the warehouse file in **DuckDB storage format v1.4.0**.
  `scripts/load_raw.py` sets this when it creates the file. DuckDB keeps a
  file's format when it is reopened, so dbt (DuckDB 2.0) writes to it without
  changing it.

## Why

- **Reproducible:** anyone can clone the repo and rebuild the dashboards
  without an account. That matters for a portfolio project.
- **CI-friendly:** builds a static site that GitHub Actions can publish free.
- **No vendor lock-in or licensing cost.**
- **Older file format, not older tools:** we keep current DuckDB and dbt and
  change only the on-disk format, which loses no data or SQL features we use.
  The format was verified by writing with DuckDB 2.0 and reading with
  Evidence's DuckDB 1.4.

## Consequences

- A warehouse created by anything other than `load_raw.py` (e.g. by running
  dbt on a fresh clone first) will be in the 2.x format. `load_raw.py` detects
  this and tells the user to delete and rebuild. The documented order is:
  load → `dbt build` → `npm run sources`.
- The open-source Evidence release cadence is slow. If it stalls further,
  options are to export the marts to Parquet for Evidence to read (avoiding
  the file-format coupling entirely) or to switch dashboard tools. The marts
  are tool-agnostic, so a switch would only affect `dashboards/`.
- Revisit when open-source Evidence ships a DuckDB 2.x connector: remove
  `STORAGE_VERSION` and rebuild.
