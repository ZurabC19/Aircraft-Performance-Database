-- =======================================================================
-- Calculates power-to-weight ratios for aircraft using horsepower.
-- Useful for analyzing which models deliver the most performance per pound.
-- Filters only aircraft with valid horsepower and weight values.
-- =======================================================================


CREATE VIEW best_power_to_weight AS
SELECT
    am.model_name,
    c.company_name,
    aspec.hp_engine,
    aspec.gross_weight,
    ROUND(aspec.hp_engine / aspec.gross_weight, 4) AS hp_per_lb
FROM aircraft_specs aspec
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN companies c ON am.company_id = c.company_id
WHERE aspec.hp_engine IS NOT NULL AND aspec.gross_weight > 0
ORDER BY hp_per_lb DESC;

SELECT * FROM best_power_to_weight;
