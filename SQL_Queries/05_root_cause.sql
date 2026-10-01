use	rms_project;

	-- Q9. Root cause frequency and reimbursement rate --
select r.root_cause,
	   count(*) as cases,
       sum(c.rms_given='Yes') as reimbursed,
       round(100*avg(c.rms_given='Yes'),1) as reimbursement_rate_pct
from case_root_causes r
join rms_cases c on r.case_id = c.case_id
group by r.root_cause
order by cases desc;

		-- Q10. Top root causes in marketplace --
with mc as(
		select c.marketplace, r.root_cause, count(*) as cases,
				row_number() over (partition by c.marketplace order by count(*) desc, r.root_cause) as rn
		from rms_cases c
        join case_root_causes r on r.case_id = c.case_id
        group by c.marketplace, r.root_cause
        )
select marketplace, root_cause as top_root_causes, cases
from mc
where rn = 1
order by cases desc;
