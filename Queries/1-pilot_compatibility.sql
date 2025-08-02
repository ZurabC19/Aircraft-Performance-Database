-- =======================================================================
-- Matches aircraft to pilot level based on speed and weight.
-- Helps identify aircraft suitable for sudent, pilot and commercial pilots.
-- =======================================================================


CREATE TABLE pilot_compatibility (
    pilot_type VARCHAR(50),
    max_allowed_weight INT,
    max_cruise_speed FLOAT
);

INSERT INTO pilot_compatibility VALUES 
('Student', 3000, 140),
('Private', 6000, 250),
('Commercial', 12000, 350);

CREATE TABLE compatible_aircraft AS
SELECT 
    pc.pilot_type,
    am.model_name,
    c.company_name,
    aspec.gross_weight,
    aspec.cruise_speed_knots
FROM pilot_compatibility pc
JOIN aircraft_specs aspec ON 
    aspec.gross_weight <= pc.max_allowed_weight AND
    aspec.cruise_speed_knots <= pc.max_cruise_speed
JOIN aircraft_models am ON aspec.model_id = am.model_id
JOIN companies c ON am.company_id = c.company_id;

