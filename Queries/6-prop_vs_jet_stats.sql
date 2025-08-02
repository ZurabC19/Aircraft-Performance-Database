-- =======================================================================
-- Compares average fuel capacity and range between jet and propeller aircraft.
-- Leverages GROUP BY on engine type to provide a summary comparison.
-- =======================================================================


CREATE VIEW prop_vs_jet_stats AS
SELECT 
  et.type_name AS engine_type,
  ROUND(AVG(aspec.fuel_capacity), 2) AS avg_fuel_capacity,
  ROUND(AVG(aspec.range_nm), 2) AS avg_range
FROM aircraft_specs aspec
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN engine_types e ON am.engine_type_id = et.engine_type_id
GROUP BY et.type_name;

SELECT * FROM prop_vs_jet_stats;
