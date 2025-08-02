-- =======================================================================
-- Aggregates aircraft specs per company.
-- Includes total models, average speed, range, fuel, and max horsepower.
-- Helps identify top manufacturers based on performance.
-- =======================================================================


CREATE TABLE aircraft_summary AS
SELECT
    c.company_name,
    COUNT(*) AS total_models,
    ROUND(AVG(aspec.max_speed_knots), 2) AS avg_speed,
    ROUND(AVG(aspec.range_nm), 1) AS avg_range,
    ROUND(AVG(aspec.fuel_capacity), 1) AS avg_fuel,
    MAX(aspec.hp_engine) AS max_hp
FROM aircraft_specs aspec
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN companies c ON am.company_id = c.company_id
GROUP BY c.company_name;


