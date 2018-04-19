-- aggregation of data in the first 6-hour, 12-hour and 24-hour
-- this query shows an example of the first 6-hour

DROP TABLE IF EXISTS mp_data_6hr CASCADE;
CREATE TABLE mp_data_6hr as
select mp_data.subject_id
  , mp_data.hadm_id
  , mp_data.icustay_id 
  , max(dbsource) as dbsource
  -- ground truth
  , max(expire_flag) as expire_flag
  , max(hospital_expire_flag) as hospital_expire_flag
  , max(deathtime_hours) as deathtime_hours
  , max(hosp_deathtime_hours) as hosp_deathtime_hours
  --, max(deathtime) as deathtime
  -- demographic/static features
  , max(age) as age
  , max(gender) as gender
  , max(ethnicity) as ethnicity
  , max(admission_type) as admission_type
  , max(icustay_num) as icustay_num
  -- min, max, mean of heart rate, systolic/diastolic/mean blood pressure, respiratort rate, temperature, blood oxyhen level, glucose
  , avg(heartrate) as heartrate_mean
  , avg(sysbp) as sysbp_mean
  , avg(diasbp) as diasbp_mean 
  , avg(meanbp) as meanbp_mean 
  , avg(resprate) as resprate_mean
  , avg(tempc) as tempc_mean
  , avg(spo2) as spo2_mean
  , avg(glucose) as glucose_mean
  , min(heartrate) as heartrate_min
  , min(sysbp) as sysbp_min
  , min(diasbp) as diasbp_min
  , min(meanbp) as meanbp_min
  , min(resprate) as resprate_min
  , min(tempc) as tempc_min
  , min(spo2) as spo2_min
  , min(glucose) as glucose_min
  , max(heartrate) as heartrate_max
  , max(sysbp) as sysbp_max
  , max(diasbp) as diasbp_max
  , max(meanbp) as meanbp_max 
  , max(resprate) as resprate_max
  , max(tempc) as tempc_max
  , max(spo2) as spo2_max
  , max(glucose) as glucose_max
  -- min. max and mean of GCS variables
  , avg(gcs) as gcs_mean
  , avg(gcsmotor) as gcsmotor_mean
  , avg(gcsverbal) as gcsverbal_mean
  , avg(gcseyes) as gcseyes_mean
  , avg(endotrachflag) as endotrachflag_mean
  , min(gcs) as gcs_min
  , min(gcsmotor) as gcsmotor_min
  , min(gcsverbal) as gcsverbal_min
  , min(gcseyes) as gcseyes_min
  , min(endotrachflag) as endotrachflag_min
  , max(gcs) as gcs_max
  , max(gcsmotor) as gcsmotor_max
  , max(gcsverbal) as gcsverbal_max
  , max(gcseyes) as gcseyes_max
  , max(endotrachflag) as endotrachflag_max
  -- min, max, mean of Base excess, Calcium, Carboxyhemoglobin, Methemoglobin, Partial
  -- pressure of oxygen, Partial pressure of carbon dioxide, pH, Ratio of
  -- partial pressure of oxygen to fraction of oxygen inspired, Total carbon
  -- dioxide concentration, Anion gap, Albumin, Immature band forms, Bicarbonate, Bilirubin,
  -- Creatinine, Chloride, Hematocrit, Hemoglobin, Lactate, Platelet, Potassium,
  -- Partial thromboplastin time, International Normalized Ratio,
  -- Sodium, Blood urea nitrogen, White blood cell count
  , avg(bg_baseexcess) as baseexcess_mean
  , avg(bg_carboxyhemoglobin) as carboxyhemoglobin_mean
  , avg(bg_methemoglobin) as methemoglobin_mean
  , avg(bg_po2) as po2_mean
  , avg(bg_pco2) as pco2_mean
  , avg(bg_ph) as ph_mean
  , avg(bg_pao2fio2ratio) as pao2fio2ratio_mean
  , avg(bg_totalco2) as totalco2_mean
  , avg(aniongap) as aniongap_mean
  , avg(albumin) as albumin_mean
  , avg(bands) as bands_mean
  , avg(bicarbonate) as bicarbonate_mean
  , avg(bilirubin) as bilirubin_mean
  , avg(calcium) as calcium_mean
  , avg(creatinine) as creatinine_mean
  , avg(chloride) as chloride_mean
  , avg(hematocrit) as hematocrit_mean
  , avg(hemoglobin) as hemoglobin_mean
  , avg(lactate) as lactate_mean
  , avg(platelet) as platelet_mean
  , avg(potassium) as potassium_mean
  , avg(ptt) as ptt_mean
  , avg(inr) as inr_mean
  , avg(sodium) as sodium_mean
  , avg(bun) as bun_mean
  , avg(wbc) as wbc_mean
  , min(bg_baseexcess) as baseexcess_min
  , min(bg_carboxyhemoglobin) as carboxyhemoglobin_min
  , min(bg_methemoglobin) as methemoglobin_min
  , min(bg_po2) as po2_min
  , min(bg_pco2) as pco2_min
  , min(bg_ph) as ph_min
  , min(bg_pao2fio2ratio) as pao2fio2ratio_min
  , min(bg_totalco2) as totalco2_min
  , min(aniongap) as aniongap_min
  , min(albumin) as albumin_min
  , min(bands) as bands_min
  , min(bicarbonate) as bicarbonate_min
  , min(bilirubin) as bilirubin_min
  , min(calcium) as calcium_min
  , min(creatinine) as creatinine_min
  , min(chloride) as chloride_min
  , min(hematocrit) as hematocrit_min
  , min(hemoglobin) as hemoglobin_min
  , min(lactate) as lactate_min
  , min(platelet) as platelet_min
  , min(potassium) as potassium_min
  , min(ptt) as ptt_min
  , min(inr) as inr_min
  , min(sodium) as sodium_min
  , min(bun) as bun_min
  , min(wbc) as wbc_min
  , max(bg_baseexcess) as baseexcess_max
  , max(bg_carboxyhemoglobin) as carboxyhemoglobin_max
  , max(bg_methemoglobin) as methemoglobin_max
  , max(bg_po2) as po2_max
  , max(bg_pco2) as pco2_max
  , max(bg_ph) as ph_max
  , max(bg_pao2fio2ratio) as pao2fio2ratio_max
  , max(bg_totalco2) as totalco2_max
  , max(aniongap) as aniongap_max
  , max(albumin) as albumin_max
  , max(bands) as bands_max
  , max(bicarbonate) as bicarbonate_max
  , max(bilirubin) as bilirubin_max
  , max(calcium) as calcium_max
  , max(creatinine) as creatinine_max
  , max(chloride) as chloride_max
  , max(hematocrit) as hematocrit_max
  , max(hemoglobin) as hemoglobin_max
  , max(lactate) as lactate_max
  , max(platelet) as platelet_max
  , max(potassium) as potassium_max
  , max(ptt) as ptt_max
  , max(inr) as inr_max
  , max(sodium) as sodium_max
  , max(bun) as bun_max
  , max(wbc) as wbc_max
  -- sum of urine output
  , sum(urineoutput) as urineoutput
from mp_data
inner join mp_cohort
using (icustay_id)
where hr>=0 and hr<=6
group by 1,2,3
order by 1,2,3;
