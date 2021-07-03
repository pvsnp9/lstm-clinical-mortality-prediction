SET search_path to mimiciii;

--select * from patient24hrschartdetails;
--where itemid in(220045, 223761, 223762, 225624, 43372, 44603, 227464, 225690, 220546, 227003)
--ORDER BY itemid ASC
DROP MATERIALIZED VIEW IF EXISTS chartwithitemdetails CASCADE;
CREATE MATERIALIZED VIEW chartwithitemdetails AS
with chartevetnswithitems as (
	select 
	lower(sp.label) as label, sp.unitname,
	p24hrs.*
	FROM patient24hrschartdetails p24hrs INNER JOIN sapiivars sp ON p24hrs.itemid = sp.itemid
)
Select hadm_id, itemid, icustay_id, charttime, icu_discharge, deathtime, starting_hour, 
	ending_hour,
	--- ## cases for sapsii vars
	case 
		when label like '%heart rate%' then valuenum
		else null
	end as heart_rate,
	case 
		when label like '%temperature fahrenheit%' then ROUND(((valuenum - 32) * (5/9))::decimal,2)::float
		when label like '%temperature celsius%' then valuenum
		else null
	end as temperature,
	case 
		when label like '%bun%'then valuenum
		else null
	end as bun,
	case 
		when label like '%24hr urine output%' then valuenum
		else null 
	end as urinout24hrs,
	case 
		when label like '%gi unit intake%' then valuenum
		else null
	end as sodium_citrate,
	case 
		when label like '%potassium (whole blood)%' then valuenum 
		else null
	end as potasium,
	case 
		when label like '%total bilirubin%' then valuenum
		else null
	end as bilirubin,
	case 
		when label like '%wbc%' then valuenum
		else null
	end as wbc,
	case 
		when label like '%chronic health on admission%' then valuenum
		else 0
	end as chronic_health
	
	-- ## when we do not have labels on tiems 
--  	case 
--  		when label is null then valuenum
--  		else 0
-- 	end as unknown_chart_value
	-- ## end case 
from chartevetnswithitems 








