use rms_project;

create table case_root_causes (
	case_id   bigint,
    root_cause VARCHAR(100)
    );

insert into case_root_causes (case_id, root_cause)
with recursive split as (
	select case_id,
		trim(substring_index(root_cause, ',', 1)) as root_cause,
        substring(root_cause, char_length(substring_index(root_cause, ',', 1))+2) as rest
	from rms_cases
    union all
    select case_id,
		trim(substring_index(rest, ',', 1)),
        substring(rest, char_length(substring_index(rest, ',', 1))+2)
        from split
        where rest <> ''
	)
    select case_id, root_cause
    from split;
    
select count(*) as total_rows
from rms_cases;
    
select count(*) as bridge_rows,
count(distinct root_cause) as distinct_root_causes
from case_root_causes;