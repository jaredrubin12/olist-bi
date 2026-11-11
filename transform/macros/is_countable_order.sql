{#
    Single source of truth for which orders count toward Orders and Revenue.
    Agreed definition (docs/data-model.md): every order except canceled and unavailable.

    Usage: where {{ is_countable_order('order_status') }}
#}

{% macro is_countable_order(status_column) -%}
    ({{ status_column }} not in ('canceled', 'unavailable'))
{%- endmacro %}
