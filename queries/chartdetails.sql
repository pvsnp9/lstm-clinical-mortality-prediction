SET search_path to mimiciii;

DROP MATERIALIZED VIEW IF EXISTS patient24hrschartdetails CASCADE;
CREATE MATERIALIZED VIEW patient24hrschartdetails AS
with patient_chartevents as (
	select ch.itemid, ch.hadm_id, ch.icustay_id, ch.charttime, ROUND(ch.valuenum::numeric,2)::float as valuenum, 
	rbd.icu_discharge, rbd.deathtime
	from randombalanceddata rbd INNER JOIN chartevents ch ON rbd.hadm_id = ch.hadm_id
)
select *,
	--- ### getting data before death or ICU discharge time
	--- ## case for starting date and time
	case 
		When deathtime IS NULL then (icu_discharge - interval '24' hour)
		else (deathtime - interval '24' hour)
	end as starting_hour,
	--- ### starting hour ends here
	--- ## case for end date time
	case 
		when deathtime IS NULL then icu_discharge
		else deathtime
	end as ending_hour
	--- ##end hour ends here
	
	from patient_chartevents
	WHERE valuenum IS NOT NULL
	--- ### ends here


