set search_path to mimiciii;

DROP MATERIALIZED VIEW IF EXISTS lstmdataprep CASCADE;
CREATE MATERIALIZED VIEW lstmdataprep AS 
with lstmdata as (
	select rd.hadm_id, rd.age, rd.gender, ROUND(rd.los::numeric,2)::float as los, 
	to_char(chitm.charttime, 'Mon-dd-YYYY, HH24:MM:SS') as charttime,
	to_char(chitm.starting_hour, 'Mon-dd-YYYY, HH24:MM:SS') as starttime,
	to_char(chitm.ending_hour, 'Mon-dd-YYYY, HH24:MM:SS') as endtime, rd.emergency_admission, rd.newborn_admission, 
	rd.urgent_admission,rd.last_micu_unit, 
	rd.last_csru_unit, rd.last_ccu_unit, rd.last_tsicu_unit, chitm.heart_rate, chitm.temperature, chitm.bun,
	chitm.urinout24hrs, chitm.sodium_citrate, chitm.potasium, chitm.bilirubin, chitm.wbc,chitm.chronic_health, 
	rd.hospital_expire_flag 
	FROM 
	randombalanceddata rd INNER JOIN chartwithitemdetails chitm ON rd.hadm_id = chitm.hadm_id
	
)
select * from lstmdata;