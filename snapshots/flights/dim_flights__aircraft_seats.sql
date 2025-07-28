 {% snapshot dim_flights__aircraft_seats %}

{{
    config(
        target_schema='snapshot',
        unique_key='aircraft_code',
        strategy='check',
        check_cols=['seat_no', 'fare_conditions'],
        dbt_valid_to_current="'9999-01-01'::date",
        snapshot_meta_column_names={
            "dbt_valid_from": "dbt_effective_date_from",
            "dbt_valid_to": "dbt_effective_date_to"
        },
        hard_deletes='invalidate'
    )
}}
select
    aircraft_code,
    seat_no,
    fare_conditions
from
    {{ ref('stg_flights__seats') }}


{% endsnapshot %}
