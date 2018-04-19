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
-- 6-8: Create mp_data_6hr, mp_data_12hr, mp_data_24hr tables
-- This creates aggregation of features extracted from mp_data table during the first 6 hours of ICU stay
-- Note that by changing the last where clause of hour range, we can create tables for 12-hour and 24-hour similary
-- ******************************************************
DROP TABLE IF EXISTS mp_data_6hr;
CREATE TABLE mp_data_6hr AS
SELECT 
    d.subject_id
  , d.hadm_id
  , d.icustay_id 
  , max(dbsource) AS dbsource
  -- ground truth
  , max(expire_flag) AS expire_flag
  , max(hospital_expire_flag) AS hospital_expire_flag
  , max(deathtime_hours) AS deathtime_hours
  , max(hosp_deathtime_hours) AS hosp_deathtime_hours
  --, max(deathtime) AS deathtime
  -- demographic/static features
  , max(age) AS age
  , max(gender) AS gender
  , max(ethnicity) AS ethnicity
  , max(admission_type) AS admission_type
  , max(icustay_num) AS icustay_num
  -- min, max, mean of heart rate, systolic/diastolic/mean blood pressure, respiratort rate, temperature, blood oxyhen level, glucose
  , avg(heartrate) AS heartrate_mean
  , avg(sysbp) AS sysbp_mean
  , avg(diasbp) AS diasbp_mean 
  , avg(meanbp) AS meanbp_mean 
  , avg(resprate) AS resprate_mean
  , avg(tempc) AS tempc_mean
  , avg(spo2) AS spo2_mean
  , avg(glucose) AS glucose_mean
  , min(heartrate) AS heartrate_min
  , min(sysbp) AS sysbp_min
  , min(diASbp) AS diASbp_min
  , min(meanbp) AS meanbp_min
  , min(resprate) AS resprate_min
  , min(tempc) AS tempc_min
  , min(spo2) AS spo2_min
  , min(glucose) AS glucose_min
  , max(heartrate) AS heartrate_max
  , max(sysbp) AS sysbp_max
  , max(diasbp) AS diasbp_max
  , max(meanbp) AS meanbp_max 
  , max(resprate) AS resprate_max
  , max(tempc) AS tempc_max
  , max(spo2) AS spo2_max
  , max(glucose) AS glucose_max
  -- min. max Aand mean of GCS variables
  , avg(gcs) AS gcs_mean
  , avg(gcsmotor) AS gcsmotor_mean
  , avg(gcsverbal) AS gcsverbal_mean
  , avg(gcseyes) AS gcseyes_mean
  , avg(ENDotrachflag) AS ENDotrachflag_mean
  , min(gcs) AS gcs_min
  , min(gcsmotor) AS gcsmotor_min
  , min(gcsverbal) AS gcsverbal_min
  , min(gcseyes) AS gcseyes_min
  , min(ENDotrachflag) AS ENDotrachflag_min
  , max(gcs) AS gcs_max
  , max(gcsmotor) AS gcsmotor_max
  , max(gcsverbal) AS gcsverbal_max
  , max(gcseyes) AS gcseyes_max
  , max(endotrachflag) AS endotrachflag_max
  -- min, max, mean of base excess, Calcium, Carboxyhemoglobin, Methemoglobin, 
  -- partial pressure of oxygen, partial pressure of carbon dioxide, pH, Ratio of
  -- partial pressure of oxygen to fraction of oxygen inspired, Total carbon
  -- dioxide concentration, Anion gap, Albumin, Immature band forms, Bicarbonate, Bilirubin,
  -- Creatinine, Chloride, Hematocrit, Hemoglobin, Lactate, Platelet, Potassium,
  -- Partial thromboplastin time, International Normalized Ratio,
  -- Sodium, Blood urea nitrogen, White blood cell count
  , avg(bg_baseexcess) AS baseexcess_mean
  , avg(bg_carboxyhemoglobin) AS carboxyhemoglobin_mean
  , avg(bg_methemoglobin) AS methemoglobin_mean
  , avg(bg_po2) AS po2_mean
  , avg(bg_pco2) AS pco2_mean
  , avg(bg_ph) AS ph_mean
  , avg(bg_pao2fio2ratio) AS pao2fio2ratio_mean
  , avg(bg_totalco2) AS totalco2_mean
  , avg(aniongap) AS aniongap_mean
  , avg(albumin) AS albumin_mean
  , avg(bands) AS bands_mean
  , avg(bicarbonate) AS bicarbonate_mean
  , avg(bilirubin) AS bilirubin_mean
  , avg(calcium) AS calcium_mean
  , avg(creatinine) AS creatinine_mean
  , avg(chloride) AS chloride_mean
  , avg(hematocrit) AS hematocrit_mean
  , avg(hemoglobin) AS hemoglobin_mean
  , avg(lactate) AS lactate_mean
  , avg(platelet) AS platelet_mean
  , avg(potassium) AS potassium_mean
  , avg(ptt) AS ptt_mean
  , avg(inr) AS inr_mean
  , avg(sodium) AS sodium_mean
  , avg(bun) AS bun_mean
  , avg(wbc) AS wbc_mean
  , min(bg_baseexcess) AS baseexcess_min
  , min(bg_carboxyhemoglobin) AS carboxyhemoglobin_min
  , min(bg_methemoglobin) AS methemoglobin_min
  , min(bg_po2) AS po2_min
  , min(bg_pco2) AS pco2_min
  , min(bg_ph) AS ph_min
  , min(bg_pao2fio2ratio) AS pao2fio2ratio_min
  , min(bg_totalco2) AS totalco2_min
  , min(aniongap) AS aniongap_min
  , min(albumin) AS albumin_min
  , min(bANDs) AS bANDs_min
  , min(bicarbonate) AS bicarbonate_min
  , min(bilirubin) AS bilirubin_min
  , min(calcium) AS calcium_min
  , min(creatinine) AS creatinine_min
  , min(chloride) AS chloride_min
  , min(hematocrit) AS hematocrit_min
  , min(hemoglobin) AS hemoglobin_min
  , min(lactate) AS lactate_min
  , min(platelet) AS platelet_min
  , min(potassium) AS potassium_min
  , min(ptt) AS ptt_min
  , min(inr) AS inr_min
  , min(sodium) AS sodium_min
  , min(bun) AS bun_min
  , min(wbc) AS wbc_min
  , max(bg_baseexcess) AS baseexcess_max
  , max(bg_carboxyhemoglobin) AS carboxyhemoglobin_max
  , max(bg_methemoglobin) AS methemoglobin_max
  , max(bg_po2) AS po2_max
  , max(bg_pco2) AS pco2_max
  , max(bg_ph) AS ph_max
  , max(bg_pao2fio2ratio) AS pao2fio2ratio_max
  , max(bg_totalco2) AS totalco2_max
  , max(aniongap) AS aniongap_max
  , max(albumin) AS albumin_max
  , max(bands) AS bands_max
  , max(bicarbonate) AS bicarbonate_max
  , max(bilirubin) AS bilirubin_max
  , max(calcium) AS calcium_max
  , max(creatinine) AS creatinine_max
  , max(chloride) AS chloride_max
  , max(hematocrit) AS hematocrit_max
  , max(hemoglobin) AS hemoglobin_max
  , max(lactate) AS lactate_max
  , max(platelet) AS platelet_max
  , max(potassium) AS potassium_max
  , max(ptt) AS ptt_max
  , max(inr) AS inr_max
  , max(sodium) AS sodium_max
  , max(bun) AS bun_max
  , max(wbc) AS wbc_max
  -- sum of urine output
  , sum(urineoutput) AS urineoutput
FROM mp_data d
INNER JOIN mp_cohort c
  ON (d.icustay_id = c.icustay_id)
WHERE hr>=0 AND hr<=6  --change this range of hours for mp_data_12hr and mp_data_24hr
GROUP BY d.subject_id, d.hadm_id, d.icustay_id;