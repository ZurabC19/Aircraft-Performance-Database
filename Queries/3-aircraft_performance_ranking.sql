-- =======================================================================
-- Utilizes Rank Function to allow the user to pick the best on their desired metric.
-- Ranks aircraft models across speed, range, and weight using the RANK() function.
-- Enables performance comparison based on different criteria.
-- Useful for pilots, engineers, or analysts choosing the best aircraft for a specific mission set.
-- =======================================================================
CREATE TABLE aircraft_performance_rankings AS
SELECT 
    am.model_name,
    c.company_name,
    et.type_name AS engine_type,
    aspec.max_speed_knots,
    aspec.range_nm,
    aspec.gross_weight,
    
    RANK() OVER (ORDER BY aspec.max_speed_knots DESC) AS speed_rank,
    RANK() OVER (ORDER BY aspec.range_nm DESC) AS range_rank,
    RANK() OVER (ORDER BY aspec.gross_weight DESC) AS weight_rank

FROM aircraft_specs aspec
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN companies c ON am.company_id = c.company_id
JOIN engine_types et ON am.engine_type_id = et.engine_type_id;
