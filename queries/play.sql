SET search_path to mimiciii;

select 
ceve.subject_id, ceve.itemid, ceve.hadm_id, to_char(ceve.charttime, 'Mon-dd-YYYY, HH24:MM:SS')as chart_time,
extract(MONTH FROM ceve.charttime) as chart_month, extract(DAY FROM ceve.charttime) as	chart_day, 
extract(HOUR FROM ceve.charttime) as	chart_hour, extract(MINUTE FROM ceve.charttime) as	chart_minute, ceve.value,
to_char(adm.admittime, 'Mon-dd-YYYY, HH24:MM:SS') as admitted_date, to_char(adm.deathtime, 'Mon-dd-YYYY, HH24:MM:SS')
as death_time, to_char(adm.dischtime, 'Mon-dd-YYYY, HH24:MM:SS') as discharge_time, adm.hospital_expire_flag, 

--count(itm.label) as cnt, itm.label
FROM (
		(admissions adm INNER JOIN chartevents ceve ON adm.subject_id = ceve.subject_id)
		INNER JOIN d_items itm ON ceve.itemid = itm.itemid
	)
where adm.subject_id = 117 --group by itm.label ORDER BY cnt DESC limit 50