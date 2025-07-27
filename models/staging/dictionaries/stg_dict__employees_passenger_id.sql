{{
    config(
        materialized='table'
    )
}}
select
    passenger_id
from
    {{ ref("employees_passenger_id") }}
