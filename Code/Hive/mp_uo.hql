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
-- 3: Create mp_uo table
-- This query extracts patients' urine output
-- ******************************************************
DROP TABLE IF EXISTS mp_uo;
CREATE TABLE mp_uo AS
SELECT
    icustay_id
  , hr
  , SUM(UrineOutput) AS UrineOutput
FROM
(
  SELECT
      co.icustay_id
    , CEIL((UNIX_TIMESTAMP(oe.charttime)-UNIX_TIMESTAMP(co.intime))/60.0/60.0) AS hr
    -- consider input of GU irrigant as a negative volume
    , CASE WHEN oe.itemid = 227489 THEN -1*oe.value
        ELSE oe.value END AS UrineOutput
    FROM mp_cohort co
    INNER JOIN outputevents oe
      ON co.icustay_id = oe.icustay_id
    -- exclude rows marked as error
    WHERE (oe.iserror = 0 or oe.iserror is null)
      AND co.excluded = 0
      AND itemid IN
      (
        -- the most frequently occurring urine output observations in MetaVision
        40055, -- "Urine Out Foley"
        43175, -- "Urine ."
        40069, -- "Urine Out Void"
        40094, -- "Urine Out Condom Cath"
        40715, -- "Urine Out Suprapubic"
        40473, -- "Urine Out IleoConduit"
        40085, -- "Urine Out Incontinent"
        40057, -- "Urine Out Rt Nephrostomy"
        40056, -- "Urine Out Lt Nephrostomy"
        40405, -- "Urine Out Other"
        40428, -- "Urine Out Straight Cath"
        40086,--  Urine Out Incontinent
        40096, -- "Urine Out Ureteral Stent #1"
        40651, -- "Urine Out Ureteral Stent #2"

        -- the most frequently occurring urine output observations in CareVue
        226559, -- "Foley"
        226560, -- "Void"
        226561, -- "Condom Cath"
        226584, -- "Ileoconduit"
        226563, -- "Suprapubic"
        226564, -- "R Nephrostomy"
        226565, -- "L Nephrostomy"
        226567, --  Straight Cath
        226557, -- R Ureteral Stent
        226558, -- L Ureteral Stent
        227488, -- GU Irrigant Volume In
        227489  -- GU Irrigant/Urine Volume Out
      )
) t
GROUP BY t.icustay_id, t.hr
ORDER BY t.icustay_id, t.hr;