-- =======================================================================
-- Calculates two metrics: range per pound and speed per pound.
-- Helps evaluate aircraft efficiency relative to weight.
-- Ignores aircraft with 0 or null weight to prevent division errors
-- =======================================================================


CREATE TABLE efficiency_scores AS
SELECT 
    am.model_name,
    c.company_name,
    aspec.range_nm,
    aspec.max_speed_knots,
    aspec.gross_weight,
    ROUND(aspec.range_nm / aspec.gross_weight, 4) AS range_per_lb,
    ROUND(aspec.max_speed_knots / aspec.gross_weight, 4) AS speed_per_lb
FROM aircraft_specs aspec
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN companies c ON am.company_id = c.company_id
WHERE aspec.gross_weight > 0;		
