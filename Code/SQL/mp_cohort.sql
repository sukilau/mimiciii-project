-- Source: https://github.com/alistairewj/mortality-prediction/tree/master/queries

DROP TABLE IF EXISTS mp_cohort CASCADE;
CREATE TABLE mp_cohort AS
with ce as
(
  select ce.icustay_id
    , date_trunc('hour',min(charttime) + interval '59' minute) as intime_hr
    , date_trunc('hour',max(charttime) + interval '59' minute) as outtime_hr
  from chartevents ce
  inner join icustays ie
    on ce.icustay_id = ie.icustay_id
    and ce.charttime > ie.intime - interval '12' hour
    and ce.charttime < ie.outtime + interval '12' hour
  where itemid in (211,220045)
  group by ce.icustay_id
),
icu as
(
  select icustays.subject_id, ce.icustay_id,
  row_number() over (partition by icustays.subject_id order by ce.intime_hr) as icustay_num
  from icustays
  left join ce
  using (icustay_id)
)
select
    ie.subject_id, ie.hadm_id, ie.icustay_id, ie.dbsource
  , ce.intime_hr as intime
  , ce.outtime_hr as outtime
  , round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) as age
  , pat.gender
  , adm.ethnicity
  , adm.admission_type
  , icu.icustay_num
  , adm.HOSPITAL_EXPIRE_FLAG
  , pat.expire_flag
  , case when pat.dod <= adm.admittime + interval '30' day then 1 else 0 end
      as THIRTYDAY_EXPIRE_FLAG
  , ie.los as icu_los
  , extract(epoch from (adm.dischtime - adm.admittime))/60.0/60.0/24.0 as hosp_los
  , ceil(extract(epoch from (adm.deathtime - ce.intime_hr))/60.0/60.0) as hosp_deathtime_hours
  , ceil(extract(epoch from (pat.dod - ce.intime_hr))/60.0/60.0) as deathtime_hours
  , adm.deathtime as deadthtime_check
, case when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 16 
            or round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) > 89 then 1 else 0 end as exclusion_adult
, case when adm.HAS_CHARTEVENTS_DATA = 0 then 1
       when ie.intime is null then 1
       when ie.outtime is null then 1
       when ce.intime_hr is null then 1
       when ce.outtime_hr is null then 1
    else 0 end as exclusion_valid_data
, case
    when (ce.outtime_hr-ce.intime_hr) <= interval '4' hour then 1
  else 0 end as exclusion_short_stay_4hr
, case
    when (ce.outtime_hr-ce.intime_hr) <= interval '1' hour then 1
  else 0 end as exclusion_short_stay_1hr
, case when (
       (lower(diagnosis) like '%organ donor%' and deathtime is not null)
    or (lower(diagnosis) like '%donor account%' and deathtime is not null)
  ) then 1 else 0 end as exclusion_organ_donor
, case  when round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) <= 16 
        or round((cast(adm.admittime as date) - cast(pat.dob as date)) / 365.242, 4) > 89 then 1
        when adm.HAS_CHARTEVENTS_DATA = 0 then 1
        when ie.intime is null then 1
        when ie.outtime is null then 1
        when ce.intime_hr is null then 1
        when ce.outtime_hr is null then 1
        when (ce.outtime_hr-ce.intime_hr) <= interval '1' hour then 1
        when ((lower(diagnosis) like '%organ donor%' and deathtime is not null)
            or (lower(diagnosis) like '%donor account%' and deathtime is not null)) then 1
      else 0 end as excluded
from icustays ie
inner join admissions adm
  on ie.hadm_id = adm.hadm_id
inner join patients pat
  on ie.subject_id = pat.subject_id
inner join icu
  using (icustay_id)
left join ce
  on ie.icustay_id = ce.icustay_id
order by ie.icustay_id;
