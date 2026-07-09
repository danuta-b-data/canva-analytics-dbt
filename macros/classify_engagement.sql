{% macro classify_engagement(total_events) %}
    case
        when {{ total_events }} = 0     then 'inactive'
        when {{ total_events }} < 3     then 'low'
        when {{ total_events }} < 6     then 'medium'
        else 'high'
    end
{% endmacro %}