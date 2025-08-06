{% macro concat_columns(columns, delim=', ') %}
    {% for columns in columns %}
        {{ column }} {% if not loop.last %} ||, {{ delim }} || {% endif %}
    {% endfor %}
{% endmacro %}

{% macro drop_old_relations(dryrun=False) %}

{% if execute %}

{# Находим все модели, seeds, snapshots в проекте #}

{% set current_models = [] %}

{% for node in graph.nodes.values() | selectattr('resource_type', 'in', ['model', 'snapshot', 'seed']) %}
    {% do current_models.append(node.name) %}
{% endfor %}

{# Формирования скрипта удаления всех таблиц и представлений, которым не соответсвует ни одна модель, seed или snapshot #}

{% set cleanup_query %}
with MODELS_TO_DROP as (
    select
        case
            when TABLE_TYPE = 'BASE TABLE' then 'TABLE'
            when TABLE_TYPE = 'VIEW' then 'VIEW'
        end as RELATION_TYPE,
        CONCAT_WS('.', TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME) as RELATION_NAME
    from
        {{ target.database }}.INFORMATION_SCHEMA.TABLES
    where
        TABLE_SCHEMA = '{{ target.schema }}'
        AND UPPER(TABLE_NAME) NOT IN (
            {%- for model in current_models -%}
                '{{ model.upper() }}'
                {%- if not loop.last -%}
                ,  
                {%- endif -%}
            {%- endfor -%}
        )
)
select
    'drop ' || RELATION_TYPE || ' ' || RELATION_NAME || ';' as DROP_COMMAND
from
    MODELS_TO_DROP
{% endset %}

{% do log(cleanup_query, True) %}

{% set drop_commands = run_query(cleanup_query).columns[0].values() %}

{# Выполнение сформированного скрипта и вывод логов #}

{% if drop_commands %}
    {% if dryrun | as_bool == False %}
        {% do log('Executing DROP commands ...', True) %}
    {% else %}
        {% do log('Printing DROP commands ....', True) %}
    {% endif %}

    {% for drop_command in drop_commands %}
        {% do log(drop_command, True) %}
        {% if dryrun | as_bool == False %}
            {% do run_query(drop_command) %}
        {% endif %}
    {% endfor %}
{% else %}
    {% do log('No relations to clean', True) %}
{% endif %}

{% endif %}

{% endmacro %}