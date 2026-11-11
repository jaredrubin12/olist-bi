---
title: Executive Overview
---

Olist marketplace performance, September 2016 – October 2018. All metrics use the
official definitions in the [data dictionary](https://github.com/jaredrubin12/olist-bi/blob/main/docs/data-dictionary.md):
canceled and unavailable orders are excluded, and revenue is product value excluding shipping.

```sql kpis
select
    count(*) filter (where is_countable)                                as orders,
    sum(revenue)                                                        as revenue,
    sum(revenue) / count(*) filter (where is_countable)                 as aov,
    avg(case when is_on_time then 1.0 else 0.0 end) filter (where is_delivered) as on_time_rate,
    avg(review_score)                                                   as avg_review
from olist.fct_orders
```

```sql repeat
select avg(case when is_repeat_customer then 1.0 else 0.0 end) as repeat_rate
from olist.dim_customers
where lifetime_orders > 0
```

<BigValue data={kpis} value=orders title="Orders" fmt="#,##0" />
<BigValue data={kpis} value=revenue title="Revenue" fmt='"R$"#,##0.00,,"M"' />
<BigValue data={kpis} value=aov title="Avg order value" fmt='"R$"#,##0.00' />
<BigValue data={kpis} value=on_time_rate title="On-time delivery" fmt="pct1" />
<BigValue data={kpis} value=avg_review title="Avg review score" fmt="0.00" />
<BigValue data={repeat} value=repeat_rate title="Repeat customers" fmt="pct1" />

## Monthly trend

Shown for January 2017 – August 2018. The months before and after have too few
orders to be meaningful (see DQ-6 in the data-quality findings).

```sql monthly
select
    date_trunc('month', purchase_date)                  as month,
    count(*) filter (where is_countable)                as orders,
    sum(revenue)                                        as revenue
from olist.fct_orders
where purchase_date >= '2017-01-01'
  and purchase_date <  '2018-09-01'
group by 1
order by 1
```

<LineChart
    data={monthly}
    x=month
    y=revenue
    title="Revenue by month"
    yFmt='"R$"#,##0,"k"'
/>

<BarChart
    data={monthly}
    x=month
    y=orders
    title="Orders by month"
    yFmt="#,##0"
/>

## Late deliveries drive bad reviews

```sql delivery_vs_review
select
    case when is_on_time then 'On time' else 'Late' end    as delivery,
    count(*)                                                as orders,
    avg(review_score)                                       as avg_review,
    avg(case when review_score <= 2 then 1.0 else 0.0 end) as low_review_share
from olist.fct_orders
where is_delivered
  and has_review
group by 1
order by 1 desc
```

Orders that arrive late average
**<Value data={delivery_vs_review.filter(d => d.delivery === 'Late')} column=avg_review fmt="0.00" /> stars**,
versus **<Value data={delivery_vs_review.filter(d => d.delivery === 'On time')} column=avg_review fmt="0.00" /> stars**
for on-time orders. Late orders are far more likely to get a 1- or 2-star review.

<BarChart
    data={delivery_vs_review}
    x=delivery
    y=avg_review
    title="Average review score"
    yFmt="0.0"
    yMax=5
/>

<DataTable data={delivery_vs_review}>
    <Column id=delivery />
    <Column id=orders fmt="#,##0" />
    <Column id=avg_review title="Avg review" fmt="0.00" />
    <Column id=low_review_share title="1–2 star share" fmt="pct1" />
</DataTable>
