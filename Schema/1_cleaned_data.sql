-- =============================
-- Create a staging table out of the raw dataset
-- =============================
CREATE TABLE staging_aircraft_data AS
SELECT * FROM airplane_bluebook;

-- =============================
-- Create a cleaned and normalized table
-- =============================

-- This table stores properly typed and validated aircraft data.
-- Fields are split and cast into appropriate formats.
-- Composite units (ft/in) are broken into separate columns.

CREATE TABLE cleaned_aircraft_data (
    aircraft_id INT AUTO_INCREMENT PRIMARY KEY,
    model VARCHAR(255) UNIQUE,						# Rids of duplicate models
    company VARCHAR(255),
    engine_type VARCHAR(50),
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
	UNIQUE (model, company)				#Allows for aircraft with same model name AS LONG AS FROM DIFFERENT COMPANY
);


-- =============================
-- Insert cleaned and normalized data
-- =============================
INSERT IGNORE INTO cleaned_aircraft_data (
    model, company, engine_type, hp_engine, thrust_engine, max_speed_knots,
    cruise_speed_knots, stall_speed_knots, fuel_capacity,
    all_eng_ceiling, eng_out_ceiling, takeoff_over_50ft, takeoff_ground_run,
    landing_over_50ft, landing_ground_roll, gross_weight, empty_weight,
    range_nm, length_ft, length_in, height_ft, height_in, wingspan_ft, wingspan_in
)
SELECT DISTINCT
    -- Clean noisy model names:
    -- - Removes parentheses
    -- - Removes quoted text 
    -- - Removes "svc." and anything after
    -- - Remove 'x=value' expressions
    -- - Removes "service ceiling"
    -- - Replace commas between variants with a slash
    REGEXP_REPLACE(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                    TRIM(Model),
                                    '\\s*\\(.*?\\)', ''              -- Remove parentheses
                                ),
                                '''.*?''', ''                      -- Remove single-quoted text
                            ),
                            'svc\\..*', ''                         -- Remove svc. and anything after
                        ),
                        'length\\s*=\\s*[^,;)]*', ''               -- Remove 'length=...'
                    ),
                    '\\b[^ =]*=\\S*', ''                           -- Remove generic key=value
                ),
                '\\S*&\\S*', ''                                    -- Remove tokens with &
            ),
            'service ceiling', ''                                 -- Remove "service ceiling"
        ),
        ',', '/'                                                  -- Replace commas with slashes
    ) AS model,

    -- Trim string columns
    TRIM(Company),
    TRIM(`Engine Type`),

    -- Jet and Prop engines use different units:
    -- Props use HP and Jets use thrust, but in raw data, they are in the same column
    -- Separate into 2 columns for the sake of normalization and accurate analysis.
	CASE 
		WHEN `Engine Type` LIKE '%Prop%' AND `HP or lbs thr ea engine` IS NOT NULL 
			THEN CAST(REGEXP_SUBSTR(`HP or lbs thr ea engine`, '[0-9]+') AS SIGNED)
		ELSE NULL
	END AS hp_engine,


	 CASE 
		WHEN `Engine Type` LIKE '%Jet%' AND `HP or lbs thr ea engine` IS NOT NULL 
			THEN CAST(REGEXP_SUBSTR(`HP or lbs thr ea engine`, '[0-9]+') AS SIGNED)
		ELSE NULL
	END AS thrust_engine,


    -- Typecast numeric fields
    
    CAST(
  CASE
    WHEN s.`Max speed Knots` LIKE '%.% Mach%' THEN
        ROUND(CAST(SUBSTRING_INDEX(s.`Max speed Knots`, ' ', 1) AS DECIMAL(5,3)) * 661, 2)					#Some Speeds were passed in Mach units instead of Knots, for sake of standardization those will be converted into Knots.
    WHEN s.`Max speed Knots` REGEXP '^[0-9.]+$' THEN
        CAST(s.`Max speed Knots` AS DECIMAL(6,2))
    ELSE NULL
  END
  AS DECIMAL(6,2)
),
    CAST(NULLIF(`Rcmnd cruise Knots`, '') AS DECIMAL(6,2)),
    CAST(NULLIF(`Stall Knots dirty`, '') AS DECIMAL(6,2)),
    CAST(NULLIF(`Fuel gal/lbs`, '') AS FLOAT),
    CAST(NULLIF(`All eng service ceiling`, '') AS SIGNED),
    CAST(NULLIF(`Eng out service ceiling`, '') AS SIGNED),
    CAST(NULLIF(`Takeoff over 50ft`, '') AS SIGNED),
    CAST(NULLIF(`Takeoff ground run`, '') AS SIGNED),
    CAST(NULLIF(`Landing over 50ft`, '') AS SIGNED),
    CAST(NULLIF(`Landing ground roll`, '') AS SIGNED),
    CAST(NULLIF(`Gross weight lbs`, '') AS SIGNED),
    CAST(NULLIF(`Empty weight lbs`, '') AS SIGNED),
    CAST(NULLIF(`Range N.M.`, '') AS DECIMAL(6,2)),

    -- Normalize ft/in columns
    CAST(SUBSTRING_INDEX(`Length ft/in`, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(`Length ft/in`, '/', -1) AS SIGNED),
    CAST(SUBSTRING_INDEX(`Height ft/in`, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(`Height ft/in`, '/', -1) AS SIGNED),
    CAST(SUBSTRING_INDEX(`Wing span ft/in`, '/', 1) AS SIGNED),
    CAST(SUBSTRING_INDEX(`Wing span ft/in`, '/', -1) AS SIGNED)

FROM staging_aircraft_data s
WHERE `Length ft/in` REGEXP '^[0-9]+/[0-9]+$'
  AND `Height ft/in` REGEXP '^[0-9]+/[0-9]+$'
  AND `Wing span ft/in` REGEXP '^[0-9]+/[0-9]+$'
  AND `HP or lbs thr ea engine` REGEXP '^[0-9]+$'
  AND `Gross weight lbs` REGEXP '^[0-9]+$'
  AND `Empty weight lbs` REGEXP '^[0-9]+$'
  AND `All eng service ceiling` REGEXP '^[0-9]+$'
  AND `Eng out service ceiling` REGEXP '^[0-9]+$'
  AND `Max speed Knots` REGEXP '^[0-9.]+$'
  AND `Rcmnd cruise Knots` REGEXP '^[0-9.]+$'
  AND `Stall Knots dirty` REGEXP '^[0-9.]+$'
  AND `Fuel gal/lbs` REGEXP '^[0-9.]+$'
  AND `Range N.M.` REGEXP '^[0-9.]+$';

