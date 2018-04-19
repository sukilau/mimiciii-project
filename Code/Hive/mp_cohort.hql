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
-- 1: Create mp_cohort table
-- This query creates patient cohort
-- ******************************************************
DROP TABLE IF EXISTS mp_cohort;
CREATE TABLE mp_cohort AS
WITH ce AS
(
  SELECT 
      ce.icustay_id
    -- ceil min(charttime) and max(charttime) to the nearest hour by adding 59min and then truncate to hour
    , FROM_UNIXTIME((UNIX_TIMESTAMP(min(charttime)) + 3540), 'yyyy-MM-dd HH:00:00.0') AS intime_hr
    , FROM_UNIXTIME((UNIX_TIMESTAMP(max(charttime)) + 3540), 'yyyy-MM-dd HH:00:00.0') AS outtime_hr
  FROM chartevents ce
  INNER JOIN icustays ie
    ON (ce.icustay_id = ie.icustay_id)
  -- adjust intime based on heart rate to remove fuzziness associated with admin records
  -- and only consider those with charttime within 12 hours before intime and 12 hours after outime
  WHERE itemid IN (211,220045)
    AND (ce.charttime > FROM_UNIXTIME(UNIX_TIMESTAMP(ie.intime) - 43200))
    AND (ce.charttime < FROM_UNIXTIME(UNIX_TIMESTAMP(ie.outtime) + 43200))
  GROUP BY ce.icustay_id
),
icu AS
(
  -- compute the number of icustays for a particular patient
  SELECT 
      icustays.subject_id
    , ce.icustay_id
    , row_number() over (partition by icustays.subject_id ORDER BY ce.INtime_hr) AS icustay_num
  FROM icustays
  LEFT JOIN ce
  ON (icustays.icustay_id = ce.icustay_id)
)
SELECT 
    ie.subject_id
  , ie.hadm_id
  , ie.icustay_id
  , ie.dbsource
  , ce.intime_hr AS intime
  , ce.outtime_hr AS outtime
  , YEAR(adm.admittime)-YEAR(pat.dob) AS age
  , pat.gender
  , adm.ethnicity
  , adm.admission_type
  , icu.icustay_num
  -- mortality labels
  , adm.hospital_expire_flag
  , pat.expire_flag
  , CASE 
      WHEN pat.dod <= FROM_UNIXTIME(UNIX_TIMESTAMP(adm.admittime) + 2592000) then 1 
      ELSE 0 END AS thirtyday_expire_flag
  -- length of stay
  , ie.los AS icu_los 
  , (UNIX_TIMESTAMP(adm.dischtime)-UNIX_TIMESTAMP(adm.admittime))/60.0/60.0/24.0 AS hosp_los
  -- death time
  , ceil((UNIX_TIMESTAMP(adm.deathtime)-UNIX_TIMESTAMP(ce.intime_hr))/60.0/60.0) AS hosp_deathtime_hours
  , ceil((UNIX_TIMESTAMP(pat.dod)-UNIX_TIMESTAMP(ce.intime_hr))/60.0/60.0) AS deathtime_hours
  , adm.deathtime AS deadthtime_check
  -- exclusion flags
  , CASE 
      WHEN YEAR(adm.admittime)-YEAR(pat.dob) <= 16 OR YEAR(adm.admittime)-YEAR(pat.dob) > 89 then 1 
      ELSE 0 END AS exclusion_adult
  , CASE 
      WHEN adm.has_chartevents_data = 0 then 1
      WHEN ie.intime is NULL then 1
      WHEN ie.outtime is NULL then 1
      WHEN ce.intime_hr is NULL then 1
      WHEN ce.outtime_hr is NULL then 1
      ELSE 0 END AS exclusion_valid_data
  , CASE
      WHEN ce.outtime_hr <= FROM_UNIXTIME(UNIX_TIMESTAMP(ce.intime_hr) + 14400) then 1 
      ELSE 0 END AS exclusion_short_stay_4hr
  , CASE 
      WHEN ce.outtime_hr <= FROM_UNIXTIME(UNIX_TIMESTAMP(ce.intime_hr) + 3600) then 1 
      ELSE 0 END AS exclusion_short_stay_1hr
  , CASE 
      WHEN ((lower(diagnosis) like '%organ donor%' AND deathtime IS NOT NULL)
        OR (lower(diagnosis) like '%donor account%' AND deathtime IS NOT NULL)) then 1 
      ELSE 0 END AS exclusion_organ_donor
  -- final exclusion
  , CASE  
      WHEN YEAR(adm.admittime)-YEAR(pat.dob) <= 16 or YEAR(adm.admittime)-YEAR(pat.dob) > 89 then 1
      WHEN adm.has_chartevents_data = 0 then 1
      WHEN ie.intime is NULL then 1
      WHEN ie.outtime is NULL then 1
      WHEN ce.intime_hr is NULL then 1
      WHEN ce.outtime_hr is NULL then 1
      WHEN ce.outtime_hr <= FROM_UNIXTIME(UNIX_TIMESTAMP(ce.intime_hr) + 3600) then 1
      WHEN ((lower(diagnosis) like '%organ dONor%' AND deathtime IS NOT NULL)
        OR (lower(diagnosis) like '%dONor account%' AND deathtime IS NOT NULL)) then 1
      ELSE 0 END AS excluded
FROM icustays ie
INNER JOIN admissions adm
  ON ie.hadm_id = adm.hadm_id
INNER JOIN patients pat
  ON ie.subject_id = pat.subject_id
INNER JOIN icu
  ON ie.icustay_id = icu.icustay_id
LEFT JOIN ce
  ON ie.icustay_id = ce.icustay_id
ORDER BY ie.icustay_id;