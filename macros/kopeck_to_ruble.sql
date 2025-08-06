{% macro kopeck_to_ruble(column_name, scale=2) %}
    ({{ column_name }} / 100 )::NUMERIC(16, {{ scale }})
{% endmacro %}
