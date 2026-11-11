---
title: Olist BI
---

_Connection check. The real dashboards replace this page in the next steps._

```sql row_counts
select 'fct_orders' as table_name, count(*) as row_count from olist.fct_orders
union all select 'fct_order_items', count(*) from olist.fct_order_items
union all select 'dim_customers', count(*) from olist.dim_customers
union all select 'dim_products', count(*) from olist.dim_products
union all select 'dim_sellers', count(*) from olist.dim_sellers
union all select 'dim_dates', count(*) from olist.dim_dates
```

<DataTable data={row_counts} />
