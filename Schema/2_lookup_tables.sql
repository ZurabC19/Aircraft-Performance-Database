-- =================================
-- Create And Populate Lookup Tables
-- =================================


CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(255) UNIQUE
);

INSERT IGNORE INTO companies (company_name)
SELECT DISTINCT TRIM(Company)
FROM staging_aircraft_data
WHERE Company IS NOT NULL;


CREATE TABLE engine_types (
    engine_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) UNIQUE
);

INSERT IGNORE INTO engine_types (type_name)
SELECT DISTINCT TRIM(Engine Type)
FROM staging_aircraft_data
WHERE Engine Type IS NOT NULL;
