-- Source: https://github.com/alistairewj/mortality-prediction/tree/master/queries

DROP TABLE IF EXISTS mp_gcs CASCADE;
CREATE TABLE mp_gcs as
with base as
(
  SELECT pvt.ICUSTAY_ID
  , pvt.charttime
  , max(case when pvt.itemid = 454 then pvt.valuenum else null end) as GCSMotor
  , max(case when pvt.itemid = 723 then pvt.valuenum else null end) as GCSVerbal
  , max(case when pvt.itemid = 184 then pvt.valuenum else null end) as GCSEyes
  , case
      when max(case when pvt.itemid = 723 then pvt.valuenum else null end) = 0
    then 1
    else 0
    end as EndoTrachFlag
  , ROW_NUMBER ()
          OVER (PARTITION BY pvt.ICUSTAY_ID ORDER BY pvt.charttime ASC) as rn
  FROM  (
    select l.icustay_id, l.charttime
    , case
        when l.ITEMID in (723,223900) then 723
        when l.ITEMID in (454,223901) then 454
        when l.ITEMID in (184,220739) then 184
        else l.ITEMID end
      as ITEMID
    , case
        when l.ITEMID = 723 and l.VALUE = '1.0 ET/Trach' then 0
        when l.ITEMID = 223900 and l.VALUE = 'No Response-ETT' then 0
        else VALUENUM
        end
      as VALUENUM
    from CHARTEVENTS l
    inner join mp_cohort co
      on l.icustay_id = co.icustay_id
      and co.excluded = 0
    where l.ITEMID in
    (
      184, 454, 723
      , 223900, 223901, 220739
    )
    and l.error IS DISTINCT FROM 1
  ) pvt
  group by pvt.ICUSTAY_ID, pvt.charttime
)
, gcs as (
  select b.*
  , b2.GCSVerbal as GCSVerbalPrev
  , b2.GCSMotor as GCSMotorPrev
  , b2.GCSEyes as GCSEyesPrev
  , case
      when b.GCSVerbal = 0
        then 15
      when b.GCSVerbal is null and b2.GCSVerbal = 0
        then 15
      when b2.GCSVerbal = 0
        then
            coalesce(b.GCSMotor,6)
          + coalesce(b.GCSVerbal,5)
          + coalesce(b.GCSEyes,4)
      else
            coalesce(b.GCSMotor,coalesce(b2.GCSMotor,6))
          + coalesce(b.GCSVerbal,coalesce(b2.GCSVerbal,5))
          + coalesce(b.GCSEyes,coalesce(b2.GCSEyes,4))
      end as GCS
  from base b
  left join base b2
    on b.ICUSTAY_ID = b2.ICUSTAY_ID
    and b.rn = b2.rn+1
    and b2.charttime > b.charttime - interval '6' hour
)
, gcs_stg as
(
  select gs.icustay_id
  , charttime
  , ceil(extract(EPOCH from gs.charttime-co.intime)/60.0/60.0)::smallint as hr
  , GCS
  , coalesce(GCSMotor,GCSMotorPrev) as GCSMotor
  , coalesce(GCSVerbal,GCSVerbalPrev) as GCSVerbal
  , coalesce(GCSEyes,GCSEyesPrev) as GCSEyes
  , case when coalesce(GCSMotor,GCSMotorPrev) is null then 0 else 1 end
  + case when coalesce(GCSVerbal,GCSVerbalPrev) is null then 0 else 1 end
  + case when coalesce(GCSEyes,GCSEyesPrev) is null then 0 else 1 end
    as components_measured
  , EndoTrachFlag as EndoTrachFlag
  from gcs gs
  inner join mp_cohort co
    on gs.icustay_id = co.icustay_id
    and co.excluded = 0
)
, gcs_priority as
(
  select icustay_id
    , hr
    , GCS
    , GCSMotor
    , GCSVerbal
    , GCSEyes
    , EndoTrachFlag
    , ROW_NUMBER() over
      (
        PARTITION BY icustay_id, hr
        ORDER BY components_measured DESC, endotrachflag, gcs, charttime desc
      ) as rn
  from gcs_stg
)
select icustay_id
  , hr
  , GCS
  , GCSMotor
  , GCSVerbal
  , GCSEyes
  , EndoTrachFlag
from gcs_priority gs
where rn = 1
ORDER BY icustay_id, hr;
