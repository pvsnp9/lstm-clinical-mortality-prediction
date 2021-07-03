SET search_path to mimiciii;

DROP MATERIALIZED VIEW IF EXISTS randombalanceddata CASCADE;
CREATE MATERIALIZED VIEW randombalanceddata AS
with lived_patients as (
	select * from icuadmissiondetails where hospital_expire_flag = 0   ORDER BY random() limit 8000
), died_patients as (
	select* from icuadmissiondetails where hospital_expire_flag = 1
)
 select * from lived_patients UNION SELECT * from died_patients