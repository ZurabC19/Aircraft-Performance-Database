-- =======================================================================
-- Create a stored procedure called top_speed_aircrafts
-- This procedure accepts a parameter n,  the number of aircraft records to return.
-- It retrieves the top n aircraft models with the highest maximum speed (in knots),
-- Includes JOINs with aircraft_models and companies to provide contextual data,
-- =======================================================================


DELIMITER //
CREATE PROCEDURE top_speed_aircrafts(IN n INT)
BEGIN
  SELECT am.model_name, c.company_name, aspec.max_speed_knots
  FROM aircraft_specs aspec
  JOIN aircraft_models am ON aspec.model_id = am.model_id
  JOIN companies c ON am.company_id = c.company_id
  ORDER BY aspec.max_speed_knots DESC
  LIMIT n;
END //
DELIMITER ;

