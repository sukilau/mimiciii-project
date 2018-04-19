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
-- 5: Create mp_data table
-- This combines all tables created above to get all features at every hour during ICU stay
-- ******************************************************
DROP TABLE IF EXISTS mp_data;
CREATE TABLE mp_data AS
SELECT
    mp.subject_id, 
    mp.hadm_id, 
    mp.icustay_id
  , mp.hr
  -- vitals
  , vi.HeartRate
  , vi.SysBP
  , vi.DiASBP
  , vi.MeanBP
  , vi.RespRate
  , coalesce(bg.TEMPERATURE, vi.TempC) AS tempc
  , coalesce(bg.SO2, vi.SpO2) AS spo2
  , coalesce(lab.GLUCOSE,bg.GLUCOSE,vi.Glucose) AS glucose
  -- gcs
  , gcs.GCS
  , gcs.GCSMotor
  , gcs.GCSVerbal
  , gcs.GCSEyes
  , gcs.endoTrachFlag
  -- blood gas, oxygen related parameters
  , bg.PO2 AS bg_PO2
  , bg.PCO2 AS bg_PCO2
  , bg.PaO2FiO2Ratio AS bg_PaO2FiO2Ratio
  -- acid-base parameters
  , bg.PH AS bg_PH
  , bg.BASEEXCESS AS bg_BASEEXCESS
  , bg.TOTALCO2 AS bg_TOTALCO2
  -- blood count parameters
  , bg.CARBOXYHEMOGLOBIN AS bg_CARBOXYHEMOGLOBIN
  , bg.METHEMOGLOBIN AS bg_METHEMOGLOBIN
  -- labs
  , lab.ANIONGAP AS ANIONGAP
  , lab.ALBUmin AS ALBUmin
  , lab.BANDS AS BANDS
  , coalesce(lab.BICARBONATE,bg.BICARBONATE) AS BICARBONATE
  , lab.BILIRUBIN AS BILIRUBIN
  , bg.CALCIUM AS CALCIUM
  , lab.CREATININE AS CREATININE
  , coalesce(lab.CHLORIDE, bg.CHLORIDE) AS CHLORIDE
  , coalesce(lab.HEMATOCRIT,bg.HEMATOCRIT) AS HEMATOCRIT
  , coalesce(lab.HEMOGLOBIN,bg.HEMOGLOBIN) AS HEMOGLOBIN
  , coalesce(lab.LACTATE,bg.LACTATE) AS LACTATE
  , lab.PLATELET AS PLATELET
  , coalesce(lab.POTASSIUM, bg.POTASSIUM) AS POTASSIUM
  , lab.PTT AS PTT
  , lab.INR AS INR
  -- , lab.PT AS PT -- PT AND INR are redundant
  , coalesce(lab.SODIUM, bg.SODIUM) AS SODIUM
  , lab.BUN AS BUN
  , lab.WBC AS WBC
  , uo.UrINeOutput
FROM mp_hourly_cohort mp
LEFT JOIN mp_vital vi
  ON  mp.icustay_id = vi.icustay_id
  AND mp.hr = vi.hr
LEFT JOIN mp_gcs gcs
  ON  mp.icustay_id = gcs.icustay_id
  AND mp.hr = gcs.hr
LEFT JOIN mp_uo uo
  ON  mp.icustay_id = uo.icustay_id
  AND mp.hr = uo.hr
LEFT JOIN mp_bg_art bg
  ON  mp.hadm_id = bg.hadm_id
  AND mp.hr = bg.hr
LEFT JOIN mp_lab lab
  ON  mp.hadm_id = lab.hadm_id
  AND mp.hr = lab.hr
ORDER BY mp.subject_id, mp.hadm_id, mp.icustay_id, mp.hr;