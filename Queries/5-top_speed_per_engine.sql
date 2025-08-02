-- =======================================================================
-- Uses ROW_NUMBER() to rank aircraft within each engine type.
-- Returns the fastest aircraft for each engine category.
-- A good way to showcase analytic window function usage.
-- =======================================================================


CREATE VIEW top_speed_per_engine AS
WITH ranked_models AS (
    SELECT 
        et.type_name AS engine_type,
        am.model_name,
        c.company_name,
        aspec.max_speed_knots,
        ROW_NUMBER() OVER (
            PARTITION BY et.type_name 
            ORDER BY aspec.max_speed_knots DESC
        ) AS rn
    FROM aircraft_specs aspec
    JOIN aircraft_models am ON aspec.model_id = am.model_id
    JOIN companies c ON am.company_id = c.company_id
    JOIN engine_types et ON am.engine_type_id = et.engine_type_id
    WHERE aspec.max_speed_knots IS NOT NULL
)
SELECT engine_type, model_name, company_name, max_speed_knots
FROM ranked_models
WHERE rn = 1;
