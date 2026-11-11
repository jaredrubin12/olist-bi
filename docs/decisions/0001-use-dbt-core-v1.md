# 0001: Use dbt Core v1 instead of dbt v2

- **Status:** Accepted
- **Date:** 2026-11-10

## Context

dbt is the transformation layer of this project. When it was installed, dbt
announced that v2 is now the default for new installations. The project
connects dbt to DuckDB through the community `dbt-duckdb` adapter.

## Decision

Use **dbt Core v1** (currently 1.12.6) with `dbt-duckdb` 1.11.1, pinned in
`requirements.txt`.

## Why

- **Adapter maturity:** `dbt-duckdb` is built and tested against dbt Core v1.
- **Ecosystem:** most documentation, tutorials, packages and current
  job descriptions still assume v1.
- **Transferable skills:** the core concepts (models, sources, tests,
  layering, lineage) are the same in both versions, so nothing learned here
  is wasted.
- **Low risk:** this is a portfolio project that must run reliably in CI;
  a stable, well-trodden path matters more than the newest release.

## Consequences

- We miss v2-specific features for now.
- A future upgrade to v2 should be a deliberate, separate piece of work:
  review the official upgrade guide, test on a branch, update this record.
- Pinned versions mean CI won't silently pick up a breaking change.
