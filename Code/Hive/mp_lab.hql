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
-- 2: Create mp_lab table
-- This query extracts patients' lab results
-- ******************************************************
DROP TABLE IF EXISTS mp_lab;
CREATE TABLE mp_lab AS
SELECT
    t.hadm_id
  , t.hr
  , avg(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS ANIONGAP
  , avg(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS ALBUMIN
  , avg(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS BANDS
  , avg(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS BICARBONATE
  , avg(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS BILIRUBIN
  , avg(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS CREATININE
  , avg(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS CHLORIDE
  , avg(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS GLUCOSE
  , avg(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS HEMATOCRIT
  , avg(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS HEMOGLOBIN
  , avg(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS LACTATE
  , avg(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS PLATELET
  , avg(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS POTASSIUM
  , avg(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS PTT
  , avg(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS INR
  , avg(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS PT
  , avg(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS SODIUM
  , avg(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS BUN
  , avg(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS WBC
FROM
( 
  SELECT 
      le.hadm_id
    , CEIL((UNIX_TIMESTAMP(le.charttime)-UNIX_TIMESTAMP(co.INtime))/60.0/60.0) AS hr
    -- label and group selected lab items
    , CASE
          WHEN itemid = 50868 THEN 'ANION GAP'
          WHEN itemid = 50862 THEN 'ALBUMIN'
          WHEN itemid = 51144 THEN 'BANDS'
          WHEN itemid = 50882 THEN 'BICARBONATE'
          WHEN itemid = 50885 THEN 'BILIRUBIN'
          WHEN itemid = 50912 THEN 'CREATININE'
          -- exclude blood gas
          -- WHEN itemid = 50806 THEN 'CHLORIDE'
          WHEN itemid = 50902 THEN 'CHLORIDE'
          -- exclude blood gas
          -- WHEN itemid = 50809 THEN 'GLUCOSE'
          WHEN itemid = 50931 THEN 'GLUCOSE'
          -- exclude blood gas
          --WHEN itemid = 50810 THEN 'HEMATOCRIT'
          WHEN itemid = 51221 THEN 'HEMATOCRIT'
          -- exclude blood gas
          --WHEN itemid = 50811 THEN 'HEMOGLOBIN'
          WHEN itemid = 51222 THEN 'HEMOGLOBIN'
          WHEN itemid = 50813 THEN 'LACTATE'
          WHEN itemid = 51265 THEN 'PLATELET'
          -- exclude blood gas
          -- WHEN itemid = 50822 THEN 'POTASSIUM'
          WHEN itemid = 50971 THEN 'POTASSIUM'
          WHEN itemid = 51275 THEN 'PTT'
          WHEN itemid = 51237 THEN 'INR'
          WHEN itemid = 51274 THEN 'PT'
          -- exclude blood gas
          -- WHEN itemid = 50824 THEN 'SODIUM'
          WHEN itemid = 50983 THEN 'SODIUM'
          WHEN itemid = 51006 THEN 'BUN'
          WHEN itemid = 51300 THEN 'WBC'
          WHEN itemid = 51301 THEN 'WBC'
        ELSE NULL
      END AS label
    -- sanity check
    , CASE
        WHEN itemid = 50862 AND valuenum >    10 THEN NULL -- g/dL 'ALBUMIN'
        WHEN itemid = 50868 AND valuenum > 10000 THEN NULL -- mEq/L 'ANION GAP'
        WHEN itemid = 51144 AND valuenum <     0 THEN NULL -- immature bAND forms, %
        WHEN itemid = 51144 AND valuenum >   100 THEN NULL -- immature bAND forms, %
        WHEN itemid = 50882 AND valuenum > 10000 THEN NULL -- mEq/L 'BICARBONATE'
        WHEN itemid = 50885 AND valuenum >   150 THEN NULL -- mg/dL 'BILIRUBIN'
        WHEN itemid = 50806 AND valuenum > 10000 THEN NULL -- mEq/L 'CHLORIDE'
        WHEN itemid = 50902 AND valuenum > 10000 THEN NULL -- mEq/L 'CHLORIDE'
        WHEN itemid = 50912 AND valuenum >   150 THEN NULL -- mg/dL 'CREATININE'
        WHEN itemid = 50809 AND valuenum > 10000 THEN NULL -- mg/dL 'GLUCOSE'
        WHEN itemid = 50931 AND valuenum > 10000 THEN NULL -- mg/dL 'GLUCOSE'
        WHEN itemid = 50810 AND valuenum >   100 THEN NULL -- % 'HEMATOCRIT'
        WHEN itemid = 51221 AND valuenum >   100 THEN NULL -- % 'HEMATOCRIT'
        WHEN itemid = 50811 AND valuenum >    50 THEN NULL -- g/dL 'HEMOGLOBIN'
        WHEN itemid = 51222 AND valuenum >    50 THEN NULL -- g/dL 'HEMOGLOBIN'
        WHEN itemid = 50813 AND valuenum >    50 THEN NULL -- mmol/L 'LACTATE'
        WHEN itemid = 51265 AND valuenum > 10000 THEN NULL -- K/uL 'PLATELET'
        WHEN itemid = 50822 AND valuenum >    30 THEN NULL -- mEq/L 'POTASSIUM'
        WHEN itemid = 50971 AND valuenum >    30 THEN NULL -- mEq/L 'POTASSIUM'
        WHEN itemid = 51275 AND valuenum >   150 THEN NULL -- sec 'PTT'
        WHEN itemid = 51237 AND valuenum >    50 THEN NULL -- 'INR'
        WHEN itemid = 51274 AND valuenum >   150 THEN NULL -- sec 'PT'
        WHEN itemid = 50824 AND valuenum >   200 THEN NULL -- mEq/L == mmol/L 'SODIUM'
        WHEN itemid = 50983 AND valuenum >   200 THEN NULL -- mEq/L == mmol/L 'SODIUM'
        WHEN itemid = 51006 AND valuenum >   300 THEN NULL -- 'BUN'
        WHEN itemid = 51300 AND valuenum >  1000 THEN NULL -- 'WBC'
        WHEN itemid = 51301 AND valuenum >  1000 THEN NULL -- 'WBC'
      ELSE le.valuenum END AS valuenum
    FROM labevents le
    INNER JOIN mp_cohort co
      ON le.hadm_id = co.hadm_id
    WHERE le.ITEMID IN
    (
      -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
      50868, -- ANION GAP | CHEMISTRY | BLOOD | 769895
      50862, -- ALBUMIN | CHEMISTRY | BLOOD | 146697
      51144, -- BANDS - hematology
      50882, -- BICARBONATE | CHEMISTRY | BLOOD | 780733
      50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
      50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
      50902, -- CHLORIDE | CHEMISTRY | BLOOD | 795568
      -- 50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 48187
      50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
      -- 50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734
      51221, -- HEMATOCRIT | HEMATOLOGY | BLOOD | 881846
      -- 50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 89715
      51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523
      -- 50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712
      50813, -- LACTATE | BLOOD GAS | BLOOD | 187124
      51265, -- PLATELET COUNT | HEMATOLOGY | BLOOD | 778444
      50971, -- POTASSIUM | CHEMISTRY | BLOOD | 845825
      -- 50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 192946
      51275, -- PTT | HEMATOLOGY | BLOOD | 474937
      51237, -- INR(PT) | HEMATOLOGY | BLOOD | 471183
      51274, -- PT | HEMATOLOGY | BLOOD | 469090
      50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
      -- 50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503
      51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
      51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301
      51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 2371
    )
    AND valuenum IS NOT NULL AND valuenum > 0
    AND co.excluded = 0
) t
GROUP BY t.hadm_id, t.hr
ORDER BY t.hadm_id, t.hr;