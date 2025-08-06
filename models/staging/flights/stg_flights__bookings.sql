{{
    config(
        materialized = 'table',
        incremental_strategy = 'append'
    )
}}
select
    "book_ref",
    "book_date",
    {{ kopeck_to_ruble("total_amount") }} as total_amount
from
    {{ source('demo_src', 'bookings') }}
{{ limit_data_dev('book_date', 3000) }}