use rms_project;

	-- Q1. Duplicate check: should return No rows -- 
select case_id,
count(*) as occurrences
from rms_cases
group by case_id
having count(*) > 1
;

	-- Q2. Missing-Value Check --
select
sum(fc = 'Unknown') as fc_unknown,
sum(shipment_type = 'Unknown') as shipment_unknown,
sum(carrier = 'Unknown') as carrier_unknown,
sum(seller_name = 'Unknown') as seller_unknown,
sum(date_opened is Null) as missing_open_date,
sum(date_closed is Null) as missing_close_date
from rms_cases;

   -- Q3. Logic Check: dates or RMS fields that contradict each other -- 
select case_id, date_opened, date_closed, rms_given, rms_amount,
	case when date_closed < date_opened then 'Closed before opened'
		else 'RMS Given/Amount Conflict' end as issue
from rms_cases
where date_closed < date_opened
	or (rms_given = 'No' and rms_amount > 0)
    or (rms_given = 'Yes' and rms_amount = 0)
order by issue, case_id;

	-- Q4. Range check --
select min(date_opened) as first_case,
	   max(date_closed) as last_case,
       min(rms_amount) as min_amount,
       max(rms_amount) as max_amount,
       min(asin_count) as min_asins,
       max(asin_count) as max_asins
from rms_cases;