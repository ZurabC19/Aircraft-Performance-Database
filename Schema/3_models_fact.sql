-- ================================
-- Create and Populate Models Table
-- ================================

select *
from aircraft_models;

CREATE TABLE aircraft_models (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(255),
    company_id INT,
    engine_type_id INT,
    UNIQUE(model_name, company_id, engine_type_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id),
    FOREIGN KEY (engine_type_id) REFERENCES engine_types(engine_type_id)
);


INSERT IGNORE INTO aircraft_models (model_name, company_id, engine_type_id)
SELECT DISTINCT
    -- Clean model as before
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                    TRIM(Model),
                                    '\\s*\\(.*?\\)', ''
                                ),
                                '''.*?''', ''
                            ),
                            'svc\\..*', ''
                        ),
                        'length\\s*=\\s*[^,;)]*', ''
                    ),
                    '\\b[^ =]*=\\S*', ''
                ),
                '\\S*&\\S*', ''
            ),
            'service ceiling', ''
        ),
        ',', '/'
    ) AS model_name,
    c.company_id,
    e.engine_type_id
FROM staging_aircraft_data s
JOIN companies c ON TRIM(s.Company) = c.company_name
JOIN engine_types e ON TRIM(s.Engine Type) = e.type_name;





-- ===================================
-- Create and Populate Main Fact Table
-- ===================================






select *
from aircraft_specs;

CREATE TABLE aircraft_specs (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model_id INT UNIQUE,
    hp_engine INT,
    thrust_engine INT,
    max_speed_knots FLOAT,
    cruise_speed_knots FLOAT,
    stall_speed_knots FLOAT,
    fuel_capacity FLOAT,
    all_eng_ceiling INT,
    eng_out_ceiling INT,
    takeoff_over_50ft INT,
    takeoff_ground_run INT,
    landing_over_50ft INT,
    landing_ground_roll INT,
    gross_weight INT,
    empty_weight INT,
    range_nm FLOAT,
    length_ft INT,
    length_in INT,
    height_ft INT,
    height_in INT,
    wingspan_ft INT,
    wingspan_in INT,
    FOREIGN KEY (model_id) REFERENCES aircraft_models(model_id)
);



INSERT IGNORE INTO  aircraft_specs (
	model_id, hp_engine, thrust_engine,
    max_speed_knots, cruise_speed_knots, stall_speed_knots, fuel_capacity,
    all_eng_ceiling, eng_out_ceiling, takeoff_over_50ft, takeoff_ground_run,
    landing_over_50ft, landing_ground_roll, gross_weight, empty_weight,
    range_nm, length_ft, length_in, height_ft, height_in, wingspan_ft, wingspan_in
)
SELECT 
    am.model_id,

	CASE 
		WHEN Engine Type LIKE '%Prop%' AND HP or lbs thr ea engine IS NOT NULL 
			THEN CAST(REGEXP_SUBSTR(HP or lbs thr ea engine, '[0-9]+') AS SIGNED)
		ELSE NULL
	END AS hp_engine,


	 CASE 
		WHEN Engine Type LIKE '%Jet%' AND HP or lbs thr ea engine IS NOT NULL 
			THEN CAST(REGEXP_SUBSTR(HP or lbs thr ea engine, '[0-9]+') AS SIGNED)
		ELSE NULL
	END AS thrust_engine,


    CAST(
  CASE
    WHEN s.Max speed Knots LIKE '%.% Mach%' THEN
        ROUND(CAST(SUBSTRING_INDEX(s.Max speed Knots, ' ', 1) AS DECIMAL(5,3)) * 661, 2)
    WHEN s.Max speed Knots REGEXP '^[0-9.]+$' THEN
        CAST(s.Max speed Knots AS DECIMAL(6,2))
    ELSE NULL
  END
  AS DECIMAL(6,2)
),
    CAST(NULLIF(s.Rcmnd cruise Knots, '') AS DECIMAL(6,2)),															
    CAST(NULLIF(s.Stall Knots dirty, '') AS DECIMAL(6,2)),
    CAST(NULLIF(s.Fuel gal/lbs, '') AS FLOAT),
    CAST(NULLIF(s.All eng service ceiling, '') AS SIGNED),
    CAST(NULLIF(s.Eng out service ceiling, '') AS SIGNED),
    CAST(NULLIF(s.Takeoff over 50ft, '') AS SIGNED),
    CAST(NULLIF(s.Takeoff ground run, '') AS SIGNED),
    CAST(NULLIF(s.Landing over 50ft, '') AS SIGNED),
    CAST(NULLIF(s.Landing ground roll, '') AS SIGNED),
    CAST(NULLIF(s.Gross weight lbs, '') AS SIGNED),
    CAST(NULLIF(s.Empty weight lbs, '') AS SIGNED),
    CAST(NULLIF(s.Range N.M., '') AS DECIMAL(6,2)),

    CAST(SUBSTRING_INDEX(s.Length ft/in, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(s.Length ft/in, '/', -1) AS SIGNED),
    CAST(SUBSTRING_INDEX(s.Height ft/in, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(s.Height ft/in, '/', -1) AS SIGNED),
    CAST(SUBSTRING_INDEX(s.Wing span ft/in, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(s.Wing span ft/in, '/', -1) AS SIGNED)

FROM staging_aircraft_data s
JOIN companies c ON TRIM(s.Company) = c.company_name
JOIN engine_types e ON TRIM(s.Engine Type) = e.type_name
JOIN aircraft_models am 
    ON am.model_name = REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                    REGEXP_REPLACE(
                                        REGEXP_REPLACE(
                                            REGEXP_REPLACE(
                                                REGEXP_REPLACE(
                                                    REGEXP_REPLACE(
                                                        TRIM(s.Model),
                                                        '\\s*\\(.*?\\)', ''
                                                    ),
                                                    '''.*?''', ''
                                                ),
                                                'svc\\..*', ''
                                            ),
                                            'length\\s*=\\s*[^,;)]*', ''
                                        ),
                                        '\\b[^ =]*=\\S*', ''
                                    ),
                                    '\\S*&\\S*', ''
                                ),
                                'service ceiling', ''
                            ),
                            ',', '/'
                        )
    AND am.company_id = c.company_id
    AND am.engine_type_id = e.engine_type_id

WHERE s.Length ft/in REGEXP '^[0-9]+/[0-9]+$'
  AND s.Height ft/in REGEXP '^[0-9]+/[0-9]+$'
  AND s.Wing span ft/in REGEXP '^[0-9]+/[0-9]+$'
  AND s.HP or lbs thr ea engine REGEXP '^[0-9]+$'
  AND s.Gross weight lbs REGEXP '^[0-9]+$'
  AND s.Empty weight lbs REGEXP '^[0-9]+$'
  AND s.All eng service ceiling REGEXP '^[0-9]+$'
  AND s.Eng out service ceiling REGEXP '^[0-9]+$'
  AND s.Max speed Knots REGEXP '^[0-9.]+$'
  AND s.Rcmnd cruise Knots REGEXP '^[0-9.]+$'
  AND s.Stall Knots dirty REGEXP '^[0-9.]+$'
  AND s.Fuel gal/lbs REGEXP '^[0-9.]+$'
  AND s.Range N.M. REGEXP '^[0-9.]+$';
