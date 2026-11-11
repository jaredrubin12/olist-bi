{#
    Override dbt's default schema naming.

    Default: custom schema "staging" becomes "<target schema>_staging" (e.g. main_staging).
    Here:    custom schema "staging" becomes "staging".

    Models without a custom schema fall back to the target schema from profiles.yml.
#}

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
