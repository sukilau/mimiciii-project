-- *********************************************************************************************************************
-- Output Data to CSV File
-- This script outputs the following tables to csv files :
-- 1. mp_data_6hr
-- 2. mp_data_12hr
-- 3. mp_data_24hr
-- *********************************************************************************************************************


-- ******************************************************
-- 1: Output mp_data_6hr
-- ******************************************************
INSERT OVERWRITE DIRECTORY 'wasb:///project/output/mp_data_6hr' 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
SELECT * FROM mp_data_6hr;


-- ******************************************************
-- 2: Output mp_data_12hr
-- ******************************************************
INSERT OVERWRITE DIRECTORY 'wasb:///project/output/mp_data_12hr' 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
SELECT * FROM mp_data_12hr;


-- ******************************************************
-- 3: Output mp_data_24hr
-- ******************************************************
INSERT OVERWRITE DIRECTORY 'wasb:///project/output/mp_data_24hr' 
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' 
SELECT * FROM mp_data_24hr;