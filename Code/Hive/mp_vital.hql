-- *********************************************************************************************************************
-- Creat Tables in Hive
-- This script creates one of the following table in Hive. Tables should be created in the following sequence :
-- 1. mp_cohort                                           
-- 2. mp_lab                         
-- 3. mp_uo                          
-- 4. mp_vital                          
-- 5. mp_data                       
-- 6. mp_data_6hr                    
-- 7. mp_data_12hr                  
-- 8. mp_data_24hr                 
-- For item 1-5, reference has been made to the SQL queries in this link (https://github.com/alistairewj/mortality-prediction/tree/master/queries).
-- *********************************************************************************************************************


-- ******************************************************
-- 4: Create mp_vital table
-- This query extracts patients' vital signs, eg. heart rate, blood pressure, respiration rate, temperature
-- ******************************************************
DROP TABLE IF EXISTS mp_vital;
CREATE TABLE mp_vital AS
WITH ce AS
(
  SELECT 
      co.icustay_id
    , CEIL((UNIX_TIMESTAMP(ce.charttime)-UNIX_TIMESTAMP(co.INtime))/60.0/60.0) AS hr
    , (CASE WHEN itemid IN (211,220045) AND valuenum > 0 AND valuenum < 300 then valuenum ELSE NULL END) AS HeartRate
    , (CASE WHEN itemid IN (51,442,455,6701,220179,220050) AND valuenum > 0 AND valuenum < 400 then valuenum ELSE NULL END) AS SysBP
    , (CASE WHEN itemid IN (8368,8440,8441,8555,220180,220051) AND valuenum > 0 AND valuenum < 300 then valuenum ELSE NULL END) AS DiASBP
    , (CASE WHEN itemid IN (456,52,6702,443,220052,220181,225312) AND valuenum > 0 AND valuenum < 300 then valuenum ELSE NULL END) AS MeanBP
    , (CASE WHEN itemid IN (615,618,220210,224690) AND valuenum > 0 AND valuenum < 70 then valuenum ELSE NULL END) AS RespRate
    , (CASE WHEN itemid IN (223761,678) AND valuenum > 70 AND valuenum < 120 then (valuenum-32)/1.8 -- convert to degree celcius
            WHEN itemid IN (223762,676) AND valuenum > 10 AND valuenum < 50  then valuenum ELSE NULL END) AS TempC
    , (CASE WHEN itemid IN (646,220277) AND valuenum > 0 AND valuenum <= 100 then valuenum ELSE NULL END) AS SpO2
    , (CASE WHEN itemid IN (807,811,1529,3745,3744,225664,220621,226537) AND valuenum > 0 then valuenum ELSE NULL END) AS Glucose
  FROM mp_cohort co
  INNER JOIN chartevents ce
    ON (co.icustay_id = ce.icustay_id)
  WHERE (ce.error = 0 OR ce.error IS NULL)
    AND co.excluded = 0
    AND ce.itemid IN
    (
      -- HEART RATE
      211, --"Heart Rate"
      220045, --"Heart Rate"
      -- SYSTOLIC/DIASTILIC BLOOD PRESSURE
      51, --  Arterial BP [Systolic]
      442, -- Manual BP [Systolic]
      455, -- NBP [Systolic]
      6701, --  Arterial BP #2 [Systolic]
      220179, --  NON INvASive Blood Pressure systolic
      220050, --  Arterial Blood Pressure systolic
      8368, --  Arterial BP [Diastolic]
      8440, --  Manual BP [Diastolic]
      8441, --  NBP [Diastolic]
      8555, --  Arterial BP #2 [Diastolic]
      220180, --  NON INvASive Blood Pressure diastolic
      220051, --  Arterial Blood Pressure diastolic
      -- MEAN ARTERIAL PRESSURE
      456, --"NBP Mean"
      52, --"Arterial BP Mean"
      6702, --  Arterial BP Mean #2
      443, -- Manual BP Mean(calc)
      220052, --"Arterial Blood Pressure mean"
      220181, --"NON INvASive Blood Pressure mean"
      225312, --"ART BP mean"
      -- RESPIRATORY RATE
      618,--  Respiratory Rate
      615,--  Resp Rate (Total)
      220210,-- Respiratory Rate
      224690, --  Respiratory Rate (Total)
      -- SPO2, peripheral
      646, 220277,
      -- GLUCOSE, both lab and fingerstick
      807,--  Fingerstick Glucose
      811,--  Glucose (70-105)
      1529,-- Glucose
      3745,-- Blood Glucose
      3744,-- Blood Glucose
      225664,-- Glucose finger stick
      220621,-- Glucose (serum)
      226537,-- Glucose (whole blood)
      -- TEMPERATURE
      223762, -- "Temperature Celsius"
      676,  -- "Temperature C"
      223761, -- "Temperature Fahrenheit"
      678 --  "Temperature F"
    )
)
SELECT
    ce.icustay_id, 
    ce.hr
  , avg(HeartRate) AS HeartRate
  , avg(SysBP) AS SysBP
  , avg(DiasBP) AS DiasBP
  , avg(MeanBP) AS MeanBP
  , avg(RespRate) AS RespRate
  , avg(TempC) AS TempC
  , avg(SpO2) AS SpO2
  , avg(Glucose) AS Glucose
FROM ce
GROUP BY ce.icustay_id, ce.hr
ORDER BY ce.icustay_id, ce.hr;

