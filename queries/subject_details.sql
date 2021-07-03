SET search_path to mimiciii;

DROP MATERIALIZED VIEW IF EXISTS icuadmissiondetails CASCADE;
CREATE MATERIALIZED VIEW icuadmissiondetails AS
with subject_details as (
	
	select adm.hadm_id, adm.subject_id, adm.admittime, adm.dischtime as admission_discharge, adm.deathtime, 
	adm.hospital_expire_flag, adm.has_chartevents_data, 
	case 
		when pts.gender = 'M' then 1
		when pts.gender = 'F' then 0
		else null
	end 
	as gender,
	-- ## one-hot vector encoding for the admission type, whe have EMERGENCY, NEWBORN, ELECTIVE, URGENT
	case 
		when adm.admission_type = 'EMERGENCY' then 1
		else 0
	end as emergency_admission,
	case 
		when adm.admission_type = 'NEWBORN' then 1
		else 0
	end as newborn_admission,
	case 
		when adm.admission_type = 'ELECTIVE' then 1
		else 0
	end as elective_admission,
	case 
		when adm.admission_type = 'URGENT' then 1
		else 0
	end as urgent_admission,
	-- ## one hot encoding ends here
	pts.dob
	from admissions adm LEFT JOIN patients pts ON adm.subject_id = pts.subject_id
	where has_chartevents_data =1 
), icuadmission_detail as (
	select  ics.icustay_id, ics.los, ics.intime, ics.outtime as icu_discharge ,sd.*,
	--## one-hot encoding for last care unit, we have MICU, CSRU, NICU, CCU, and TSICU as category
	case 
		when ics.last_careunit = 'MICU' then 1
		else 0
	end as last_micu_unit,
	case 
		when ics.last_careunit = 'CSRU' then 1
		else 0
	end as last_csru_unit,
	case
		when ics.last_careunit = 'NICU' then 1
		else 0
	end as last_nicu_unit,
	case
		when ics.last_careunit = 'CCU' then 1
		else 0
	end as last_ccu_unit,
	case 
		when ics.last_careunit = 'TSICU' then 1
		else 0
	end as last_tsicu_unit,
	--- ### one vector encoding
	ROUND( (cast(ics.intime as date) - cast(sd.dob as date)) / 365.242,2) AS age
	from icustays ics INNER JOIN subject_details sd ON ics.hadm_id = sd.hadm_id
)
-- ### this calculatest the dieffrence bewtween hospital discharge and ICU discharge
-- select hadm_id,to_char(admission_discharge, 'Mon-dd-YYYY, HH24:MM:SS') as adm_discharge,
-- to_char(icu_discharge, 'Mon-dd-YYYY, HH24:MM:SS') as ice_discharge, hospital_expire_flag, cast(admission_discharge as DATE)as ts,
-- cast(icu_discharge as DATE)as its,
-- (cast(admission_discharge as date) - cast(icu_discharge as date)) as difference
-- from icuadmission_detail 
-- where age >= 15
-- ## difference ends here

--- examiming how many patients are died or survived under age of 15
-- select count(hadm_id) as cnt,hospital_expire_flag  
-- from icuadmission_detail where age <= 15 
-- group by hospital_expire_flag 

--- ## [died] 0 = 8027, [Survived] 1 = 61. This will not help much in prediction
-- ## [ Note: we select the patients with age >= 15]

-- ## preparing final adimmsions details view here

select 
subject_id, hadm_id, icustay_id, age, gender, hospital_expire_flag, admittime, 
admission_discharge as hospital_discharge, los, intime as icu_intime, deathtime ,icu_discharge, emergency_admission,
elective_admission, newborn_admission ,urgent_admission, last_micu_unit, last_csru_unit, last_ccu_unit, last_tsicu_unit
from icuadmission_detail where age > 15 ORDER BY hadm_id ASC

---- ## final adimmsions details query ends here






