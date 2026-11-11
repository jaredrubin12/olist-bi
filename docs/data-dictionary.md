# Data Dictionary

A plain-English guide to the reporting tables and metrics. It's for anyone who
reads dashboards or writes queries against the `marts` schema.

For technical detail (every column, every test, full lineage), see the dbt docs
site: run `dbt docs serve` from `transform/`.

---

## Which table do I use?

| If your question is about… | Use | One row is… |
|---|---|---|
| Order volume, revenue trend, AOV | `fct_orders` | an order |
| Delivery speed, late orders | `fct_orders` | an order |
| Review scores, satisfaction | `fct_orders` | an order |
| Payment methods, installments | `fct_orders` | an order |
| Sales by product category | `fct_order_items` + `dim_products` | an item in an order |
| Sales by seller or seller state | `fct_order_items` + `dim_sellers` | an item in an order |
| Customer counts, repeat buyers, customer location | `dim_customers` | a person |
| Anything by day / week / month | either fact + `dim_dates` | a calendar day |

**Rule of thumb:** if the question mentions a **product, category or seller**,
start from `fct_order_items`. Otherwise start from `fct_orders`.

---

## Metrics

These are the official definitions, agreed in [data-model.md](data-model.md).
Use these and only these, so every report gives the same answer.

| Metric | Business meaning | How to calculate |
|---|---|---|
| **Orders** | Orders that are real sales: everything except canceled and unavailable | `count(*)` from `fct_orders` `where is_countable` |
| **Revenue** | Value of products sold, excluding shipping | `sum(revenue)` from either fact table. The definition is already applied, so no filter is needed. |
| **Average order value (AOV)** | Typical spend per order | Revenue ÷ Orders |
| **On-time rate** | Share of delivered orders that arrived by the promised date | `avg(is_on_time::int)` from `fct_orders` `where is_delivered` |
| **Average review score** | Customer satisfaction, 1–5 stars | `avg(review_score)` from `fct_orders` (orders without a review are ignored automatically) |
| **Repeat customer rate** | Share of buyers who ordered more than once | `avg(is_repeat_customer::int)` from `dim_customers` `where lifetime_orders > 0` |

**Revenue and Orders always reconcile.** Revenue summed from `fct_orders` equals
revenue summed from `fct_order_items` to the cent. An automated test enforces it.

---

## Key terms

| Term | Meaning |
|---|---|
| **Countable order** | Any order not `canceled` or `unavailable`. Includes orders still in progress. |
| **Customer** | A real person (`customer_unique_id`). Olist's own `customer_id` changes with every order, so it is not used for counting people. |
| **Item** | One unit of one product in an order. An order of 2 identical mugs has 2 items. |
| **Freight** | Shipping charge paid by the customer. Excluded from Revenue. |
| **Order value** | Items + freight: what the customer was charged. Not the same as Revenue. |
| **Primary payment type** | The payment method that covered the largest share of an order. |
| **Late / on time** | Compares the delivery **date** with the estimated delivery date. Delivered on the estimated day counts as on time. |
| **BRL / R$** | Brazilian real, the currency of all amounts. |

---

## Known caveats

Details and decisions are in [data-quality-findings.md](data-quality-findings.md).

- **Edge months are thin.** Sep–Dec 2016 and Sep–Oct 2018 have very few orders;
  trend charts should start Jan 2017 and end Aug 2018 (DQ-6).
- **Some products have no category.** They appear as `unknown` (610 products) or
  keep a Portuguese name (13 products) (DQ-3).
- **A few locations are missing.** Under 0.3% of customers and sellers have no
  map coordinates (DQ-4, DQ-8).
- **Payments don't always match order value.** About 249 orders differ by more
  than R$1; see `payment_vs_order_diff`. Revenue is based on items, so this
  doesn't affect it.
- **One review per order.** When an order has several reviews, the most recent is used (DQ-1).

---

## Table reference

### fct_orders: one row per order
| Column | Meaning |
|---|---|
| `order_id` | Unique order ID |
| `customer_unique_id` | The person who ordered → `dim_customers` |
| `purchase_date` | Date ordered → `dim_dates` |
| `order_status` | created, approved, invoiced, processing, shipped, delivered, canceled, unavailable |
| `is_countable` | True if this order counts toward Orders and Revenue |
| `item_count` | Items in the order |
| `seller_count` | Number of different sellers fulfilling the order |
| `revenue` | Official revenue for this order (0 if not countable) |
| `freight_value` | Shipping charged |
| `order_value` | Items + freight |
| `payment_total` | Amount actually paid |
| `primary_payment_type` | credit_card, boleto, voucher, debit_card, not_defined |
| `max_installments` | Most installments used on any payment |
| `review_score` | Latest review, 1–5 (blank if none) |
| `is_delivered` | True if the customer received it |
| `days_to_deliver` | Days from purchase to delivery |
| `days_late` | Days after the promised date (negative = early) |
| `is_on_time` | Delivered by the promised date (blank if not delivered) |

### fct_order_items: one row per item
| Column | Meaning |
|---|---|
| `order_id` | → `fct_orders` |
| `product_id` | → `dim_products` |
| `seller_id` | → `dim_sellers` |
| `customer_unique_id` | → `dim_customers` |
| `purchase_date` | → `dim_dates` |
| `item_price` | Price of this item |
| `freight_value` | Shipping charge allocated to this item |
| `revenue` | Official revenue for this item (0 if order not countable) |

### dim_customers: one row per person
| Column | Meaning |
|---|---|
| `customer_unique_id` | Unique person ID |
| `city`, `state` | Location at their most recent order |
| `latitude`, `longitude` | Approximate location (zip-code level) |
| `first_order_at`, `last_order_at` | First and latest countable order |
| `lifetime_orders` | Number of countable orders |
| `is_repeat_customer` | True if 2+ countable orders |

### dim_products: one row per product
| Column | Meaning |
|---|---|
| `product_id` | Unique product ID |
| `category` | Category name for reports (English where available) |
| `photo_count`, `description_length` | Listing quality indicators |
| `weight_g`, `length_cm`, `height_cm`, `width_cm` | Package size |

### dim_sellers: one row per seller
| Column | Meaning |
|---|---|
| `seller_id` | Unique seller ID |
| `city`, `state`, `latitude`, `longitude` | Seller location |

### dim_dates: one row per day (2016–2018)
| Column | Meaning |
|---|---|
| `date_day` | The date |
| `year`, `quarter`, `month`, `month_name` | Calendar parts |
| `month_start`, `week_start` | For grouping by month or week |
| `day_name`, `is_weekend` | Day of week |
