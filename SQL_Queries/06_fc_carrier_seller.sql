use rms_projects;

	-- Q11. Top 10 FCs by cost, with share of total and rank --
select fc,
	   count(*) as cases,
       sum(rms_amount) as rms_amount,
       round(100*sum(rms_amount)/sum(sum(rms_amount)) over(),1) as share_pct,
       rank() over(order by sum(rms_amount) desc) as cost_rank
from rms_cases
where fc <> 'Unknown'
group by fc
order by rms_amount desc
limit 10;
       
       -- Q12. Small parcel(SPD) vs pallet(LTL)
select shipment_type,
	count(*) as cases,
    round(avg(asin_count),1) as avg_asins,
    round(100*avg(rms_given='Yes'),1) as reimbursement_rate_pct,
    round(avg(rms_amount),2) as avg_rms_amount
from rms_cases
group by shipment_type;

		-- Q13. Performance by carrier --
select carrier,
	count(*) as cases,
    round(avg(rms_given='Yes'),1) as reimbursement_share_pct,
    sum(rms_amount) as rms_amount
from rms_cases
group by carrier
order by cases desc;

		-- Q14. Top 10 repeat sellers --
select seller_name, 
	   count(*) as cases,
       sum(rms_amount) as rms_amount
from rms_cases
where seller_name <> 'Unknown'
group by seller_name
having count(*) > 1
order by cases desc, rms_amount desc
limit 10 ;

		-- Q15. Cumulative share of cost across FCs --
with fc_cost as(
	select fc,
			sum(rms_amount) as rms_amount
	from rms_cases
    where fc <> 'Unknown'
    group by fc
    )
select fc, rms_amount,
		row_number() over(order by rms_amount desc) as fc_rank,
		round(100*sum(rms_amount) over(order by rms_amount desc rows unbounded preceding)/
			sum(rms_amount) over (),1) as cumulative_pct
from fc_cost
order by rms_amount desc;

	 -- Q16. Outliner detection --
with stats as(
		select avg(rms_amount) as mean_amt,
        stddev_samp(rms_amount) as sd_amt
        from rms_cases
        where rms_given='Yes'
)
select c.case_id, c.asin_count, c.region, c.marketplace, c.month, c.fc, c.shipment_type, c.rms_amount
from rms_cases c
cross join stats s 
where rms_given='Yes'
	  and c.rms_amount > s.mean_amt + 3* s.sd_amt;
      
      -- Q17. Total cost with and without the outliner --
select sum(rms_amount) as total_with_outliner,
	   sum(case when rms_amount < 100000 then rms_amount else 0 end) as total_without_outliner
from rms_cases;



