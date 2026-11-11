# Olist BI: An End-to-End Modern BI Stack

A portfolio project that takes raw e-commerce data from CSV files to tested,
documented models and interactive dashboards. It uses open-source tools and
runs entirely on a laptop.

> **Status:** Phase 4 of 8 (dimensional model). See [Roadmap](#roadmap).

## The business

[Olist](https://olist.com) is a Brazilian marketplace that connects small
retailers to large e-commerce channels. The public dataset covers about 100k
orders from 2016 to 2018, including customers, sellers, products, payments,
delivery timestamps and customer reviews.

## Architecture

```
CSV files  →  DuckDB  →  dbt (staging → intermediate → marts)  →  Evidence dashboards
                              ↑ tests + docs                    ↑ GitHub Actions CI
```

| Layer | Tool | Role |
|---|---|---|
| Storage | **DuckDB** | Fast, file-based analytical database; no server needed |
| Transformation | **dbt** | SQL models in layers, with data-quality tests and lineage docs |
| Presentation | **Evidence.dev** | Dashboards written as code (SQL + Markdown) |
| Automation | **GitHub Actions** | Builds and tests everything on every change |

## Repository layout

```
data/raw/            Source CSVs (not committed; see Getting started)
warehouse/           DuckDB database file (generated, not committed)
transform/           dbt project
dashboards/          Evidence project
docs/                Architecture notes, data dictionary, decision records
.github/workflows/   CI pipeline
```

## Getting started

**Prerequisites:** Python 3.12+, Git, Node.js LTS (for dashboards)

1. Clone this repo.
2. Download the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
   from Kaggle and put the 9 CSV files in `data/raw/`.
3. Create the Python environment:
   ```powershell
   python -m venv .venv
   .venv\Scripts\Activate.ps1        # macOS/Linux: source .venv/bin/activate
   pip install -r requirements.txt
   ```

More steps will be added as the project grows.

## Roadmap

- [x] **1. Setup:** repo, environment, structure
- [x] **2. Ingest & explore:** load CSVs into DuckDB, profile data quality ([findings](docs/data-quality-findings.md))
- [x] **3. Staging layer:** dbt sources, staging models, basic tests
- [ ] **4. Dimensional model:** star schema marts
- [ ] **5. Data quality:** deeper tests, dbt docs, data dictionary
- [ ] **6. Dashboards:** executive, sales, delivery and review insights
- [ ] **7. CI/CD:** automated build and test on every PR
- [ ] **8. Polish:** architecture diagram, decision records, deployment

## Design principles

- **Clarity over cleverness:** conventional patterns that a new team member can follow.
- **Quality is a feature:** every model is documented and tested.
- **Decisions are written down:** see `docs/decisions/`.

## Data license

The Olist dataset is published on Kaggle under CC BY-NC-SA 4.0.
