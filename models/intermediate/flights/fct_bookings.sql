{{
    config(
        materialized = 'table',
        meta = {
            'owner': 'example@mail.com'
        }
    )
}}
select
    book_ref,
    book_date,
    total_amount
from {{ ref('stg_flights__bookings') }}