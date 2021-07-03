SET search_path to mimiciii;

--select * from randombalanceddata 

DROP MATERIALIZED VIEW IF EXISTS sapiivars CASCADE;
CREATE MATERIALIZED VIEW sapiivars AS
with features as (
	select itemid, lower(label) as label, unitname from d_items 
	where itemid in(220045, 223761, 223762, 225624, 43372, 44603, 227464, 225690, 220546, 227003)
	ORDER BY itemid ASC
)
Select * from features