use rms_project;

	-- Q5. Headline KPIs --
select
	count(*) as total_cases,
    sum(asin_count) as total_asins,
    sum(rms_given = 'Yes') as reimbursed_cases,
    sum(rms_amount) as total_rms_amount,
    round(avg(case when rms_given = 'Yes' then rms_amount end), 2) as avg_amount_per_paid_case,
    round(100 * avg (rms_given='Yes'),1) as reimbursement_rate_pct
from rms_cases;

	-- Q6. Monthly trend with month-over-month change (LAG) --
with monthly as(
	select month,
		   count(*) as cases,
           sum(rms_given='Yes') as reimbursed,
           sum(rms_amount) as rms_amount
	from rms_cases
    group by month
)
select month, cases, reimbursed, rms_amount,
	lag(cases) over w as prev_month_cases,
    round(100*cases - lag(cases) over w/lag(cases) over w,1) as mom_change_pct
from monthly
window w as (order by field(month,'Jan','Feb','March','April','May','June'))
order by field(month,'Jan','Feb','March','April','May','June');

		-- Q7. Performance by Region --
select marketplace, region,
	count(*) as cases,
    round(100*avg(rms_given='Yes'),1) as reimbursement_rate_pct,
    sum(rms_amount) as rms_amount
from rms_cases
group by marketplace, region
order by cases desc;

		-- Q8. Re-evaluation outcomes --
select re_evaluation, approved,
	   count(*) as cases,
       sum(re_eval_amount) as eval_amount
from rms_cases
group by re_evaluation, approved;
