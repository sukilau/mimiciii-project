-- *********************************************************************************************************************
-- Load Data to Hive
-- This script creates external table mapping for the following csv files :
-- 1. ICUSTAYS.csv				
-- 2. ADMISSIONS.csv				 	
-- 3. PATIENTS.csv						
-- 4. CHARTEVENTS.csv					
-- 5. LABEVENTS.csv						
-- 6. OUTPUTEVENTS.csv
-- 7. mp_hourly_cohort.csv				
-- 8. mp_gcs.csv			 	
-- 9. mp_lab.csv	
--
-- Note (1) The above csv files should be uploaded to an individual folder inside /project/input/ of the same resource group of the the Microsoft Azure instance.
-- Note (2) Item 1-6 are dataset provided by MIMIC-III, whereas item 7-9 are dataset generated from relevant SQL queries on a local Postgres MIMIC-III database.
-- Note (3) Before loading the data to Hive, some data prepartion should be done to replace comma in string with empty space for ADMISSIONS.csv. For example, we can do this in SQL.
-- DROP TABLE IF EXISTS admissions CASCADE;
-- CREATE TABLE admissions as
-- SELECT 
--	  ROW_ID
--	, SUBJECT_ID
--	, HADM_ID
--  , ADMITTIME
-- 	, DISCHTIME
--	, DEATHTIME
--	, ADMISSION_TYPE
--	, ADMISSION_LOCATION
--	, DISCHARGE_LOCATION
--	, INSURANCE
--	, LANGUAGE
--	, RELIGION
--	, MARITAL_STATUS
--	, ETHNICITY
--	, EDREGTIME
--	, EDOUTTIME
--	, REPLACE(DIAGNOSIS, ',' ,' ') AS DIAGNOSIS
--	, HOSPITAL_EXPIRE_FLAG
--	, HAS_CHARTEVENTS_DATA
-- FROM admissions
--
-- *********************************************************************************************************************



-- ******************************************************
-- 1: Create table from icustays.csv
-- ******************************************************
DROP TABLE IF EXISTS icustays;
CREATE EXTERNAL TABLE icustays (
 	ROW_ID INT,
	SUBJECT_ID INT,
	HADM_ID INT,
	ICUSTAY_ID INT,
	DBSOURCE STRING,
	FIRST_CAREUNIT STRING,
	LAST_CAREUNIT STRING,
	FIRST_WARDID INT,
	LAST_WARDID INT,
	INTIME TIMESTAMP,
	OUTTIME TIMESTAMP,
	LOS DOUBLE
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/icustays'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 2: Create table from admissions.csv
-- ******************************************************
DROP TABLE IF EXISTS admissions;
CREATE EXTERNAL TABLE admissions (
	ROW_ID INT,
	SUBJECT_ID INT,
	HADM_ID INT,
	ADMITTIME TIMESTAMP,
	DISCHTIME TIMESTAMP,
	DEATHTIME TIMESTAMP,
	ADMISSION_TYPE STRING,
	ADMISSION_LOCATION STRING,
	DISCHARGE_LOCATION STRING,
	INSURANCE STRING,
	LANGUAGE STRING,
	RELIGION STRING,
	MARITAL_STATUS STRING,
	ETHNICITY STRING,
	EDREGTIME TIMESTAMP,
	EDOUTTIME TIMESTAMP,
	DIAGNOSIS STRING,
	HOSPITAL_EXPIRE_FLAG INT,
	HAS_CHARTEVENTS_DATA INT
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/admissions'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- : 3. Create table from patients.csv
-- ******************************************************
DROP TABLE IF EXISTS patients;
CREATE EXTERNAL TABLE patients (
	ROW_ID INT,
	SUBJECT_ID INT,
	GENDER STRING,
	DOB TIMESTAMP,
	DOD TIMESTAMP,
	DOD_HOSP TIMESTAMP,
	DOD_SSN TIMESTAMP,
	EXPIRE_FLAG INT
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/patients'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 4: Create table from chartevents.csv
-- ******************************************************
DROP TABLE IF EXISTS chartevents;
CREATE EXTERNAL TABLE chartevents (
	ROW_ID INT,
	SUBJECT_ID INT,
	HADM_ID INT,
	ICUSTAY_ID INT,
	ITEMID INT,
	CHARTTIME TIMESTAMP,
	STORETIME TIMESTAMP,
	CGID INT,
	VALUE DOUBLE,
	VALUENUM DOUBLE,
	VALUEUOM STRING,
	WARNING INT,
	ERROR INT,
	RESULTSTATUS DOUBLE,
	STOPPED DOUBLE
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/chartevents'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 5: Create table from labevents.csv
-- ******************************************************
DROP TABLE IF EXISTS labevents;
CREATE EXTERNAL TABLE labevents (
	ROW_ID INT,
	SUBJECT_ID INT,
	HADM_ID DOUBLE,
	ITEMID INT,
	CHARTTIME TIMESTAMP,
	VALUE STRING,
	VALUENUM DOUBLE,
	VALUEUOM TIMESTAMP,
	FLAG STRING
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/labevents'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 6: Create table from outputevents.csv
-- ******************************************************
DROP TABLE IF EXISTS outputevents;
CREATE EXTERNAL TABLE outputevents (
	ROW_ID INT,
	SUBJECT_ID INT,
	HADM_ID INT,
	ICUSTAY_ID INT,
	CHARTTIME TIMESTAMP,
	ITEMID INT,
	VALUE INT,
	VALUEUOM STRING,
	STORETIME TIMESTAMP,
	CGID INT,
	STOPPED DOUBLE,
	NEWBOTTLE DOUBLE,
	ISERROR DOUBLE
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/outputevents'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 7: Create table from mp_hourly_cohort.csv
-- ******************************************************
DROP TABLE IF EXISTS mp_hourly_cohort;
CREATE EXTERNAL TABLE mp_hourly_cohort (
	SUBJECT_ID INT,
	HADM_ID INT,
	ICUSTAY_ID INT,
	HR INT
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/mp_hourly_cohort'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 8: Create table from mp_gcs.csv
-- ******************************************************
DROP TABLE IF EXISTS mp_gcs;
CREATE EXTERNAL TABLE mp_gcs (
	ICUSTAY_ID INT,
	HR INT,
	GCS INT,
	GCSMOTOR DOUBLE,
	GCSVERBAL DOUBLE,
	GCSEYES DOUBLE,
	ENDOTRACHFLAG INT
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/mp_gcs'
TBLPROPERTIES("skip.header.line.count"="1");


-- ******************************************************
-- 9: Create table from mp_lab.csv
-- ******************************************************
DROP TABLE IF EXISTS mp_lab;
CREATE EXTERNAL TABLE mp_lab (
	HADM_ID INT,
	HR INT,
	ANIONGAP DOUBLE,
	ALBUMIN DOUBLE,
	BANDS DOUBLE,
	BICARBONATE DOUBLE,
	BILIRUBIN DOUBLE,
	CREATININE DOUBLE,
	CHLORIDE DOUBLE,
	GLUCOSE DOUBLE,
	HEMATOCRIT DOUBLE,
	HEMOGLOBIN DOUBLE,
	LACTATE DOUBLE,
	PLATELET DOUBLE,
	POTASSIUM DOUBLE,
	PTT DOUBLE,
	INR DOUBLE,
	PT DOUBLE,
	SODIUM DOUBLE,
	BUN DOUBLE,
	WBC DOUBLE
	)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 'wasb:///project/input/mp_lab'
TBLPROPERTIES("skip.header.line.count"="1");