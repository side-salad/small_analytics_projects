USE agriculture;

SELECT *
FROM bangladesh_agriculture;

ALTER TABLE bangladesh_agriculture
CHANGE `Average_Rainfall(mm)` Average_Rainfall_mm int,
CHANGE `Temperature(Â°C)` Temperature_C double; -- Change column names for ease of input

ALTER TABLE bangladesh_agriculture
ADD COLUMN Satellite_Observation_Date_Converted DATE; -- Add new column

UPDATE bangladesh_agriculture
SET Satellite_Observation_Date_Converted = STR_TO_DATE(Satellite_Observation_Date, '%Y-%m-%d'); -- Convert str to datetime into new column

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS missing_Location,
    SUM(CASE WHEN Soil_Type IS NULL THEN 1 ELSE 0 END) AS missing_Soil_Type,
    SUM(CASE WHEN Fertility_Index IS NULL THEN 1 ELSE 0 END) AS missing_Fertility_Index,
    SUM(CASE WHEN Land_Use_Type IS NULL THEN 1 ELSE 0 END) AS missing_Land_Use_Type,
    SUM(CASE WHEN Average_Rainfall_mm IS NULL THEN 1 ELSE 0 END) AS missing_Average_Rainfall,
    SUM(CASE WHEN Temperature_C IS NULL THEN 1 ELSE 0 END) AS missing_Temperature,
    SUM(CASE WHEN Crop_Suitability IS NULL THEN 1 ELSE 0 END) AS missing_Crop_Suitability,
    SUM(CASE WHEN Season IS NULL THEN 1 ELSE 0 END) AS missing_Season,
    SUM(CASE WHEN Satellite_Observation_Date IS NULL THEN 1 ELSE 0 END) AS missing_Satellite_Observation_Date
FROM 
    bangladesh_agriculture; -- Looking for columns with missing data

SELECT 
    Location, Soil_Type, Fertility_Index, Land_Use_Type, Average_Rainfall_mm, 
    Temperature_C, Crop_Suitability, Season, Satellite_Observation_Date, 
    COUNT(*) AS duplicate_count
FROM 
    bangladesh_agriculture
GROUP BY 
    Location, Soil_Type, Fertility_Index, Land_Use_Type, Average_Rainfall_mm, 
    Temperature_C, Crop_Suitability, Season, Satellite_Observation_Date
HAVING 
    COUNT(*) > 1; -- Check for duplicate rows

SELECT DISTINCT Season
FROM bangladesh_agriculture
WHERE Season NOT IN ('Summer', 'Winter', 'Spring', 'Autumn', 'Monsoon'); -- Check for invalid values in Season

SELECT *
FROM bangladesh_agriculture
WHERE Average_Rainfall_mm < 0 OR Temperature_C < -50 OR Temperature_C > 50; -- Check for invalid values, too high or too low

SELECT 
    COUNT(*) AS total_rows,
    MIN(Fertility_Index) AS min_Fertility_Index,
    MAX(Fertility_Index) AS max_Fertility_Index,
    AVG(Fertility_Index) AS avg_Fertility_Index,
    MIN(Average_Rainfall_mm) AS min_Average_Rainfall,
    MAX(Average_Rainfall_mm) AS max_Average_Rainfall,
    AVG(Average_Rainfall_mm) AS avg_Average_Rainfall,
    MIN(Temperature_C) AS min_Temperature,
    MAX(Temperature_C) AS max_Temperature,
    AVG(Temperature_C) AS avg_Temperature
FROM bangladesh_agriculture; -- General overview of data
