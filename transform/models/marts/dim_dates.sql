-- One row per calendar day, covering the full data range with margin.
-- Lets dashboards show days, weeks or months with zero orders.

with days as (

    select cast(day as date) as date_day
    from generate_series(date '2016-01-01', date '2018-12-31', interval 1 day) as t(day)

)

select
    date_day,
    year(date_day)                              as year,
    quarter(date_day)                           as quarter,
    month(date_day)                             as month,
    strftime(date_day, '%B')                    as month_name,
    cast(date_trunc('month', date_day) as date) as month_start,
    cast(date_trunc('week', date_day) as date)  as week_start,
    isodow(date_day)                            as day_of_week,   -- 1 = Monday
    strftime(date_day, '%A')                    as day_name,
    isodow(date_day) in (6, 7)                  as is_weekend

from days
