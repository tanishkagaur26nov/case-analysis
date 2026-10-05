-- Business rule: carrier = 'Unknown' means a non-partnered shipment (seller's own carrier);
-- any named carrier means a partnered shipment.
 
 use rms_project;
 
  -- Add the new column and fill it (run once)
alter table rms_cases add column shipment_partnership varchar(15);

update rms_cases
set shipment_partnership = case when carrier = 'Unknown' then 'Non-Partnered'
                                else 'Partnered' end;

select shipment_partnership, count(*) as cases
from rms_cases
group by shipment_partnership;

-- Q18. Partnered vs non-partnered: volume, reimbursement rate, cost
select shipment_partnership,
       count(*) as cases,
       round(100 * count(*) / sum(count(*)) over (), 1) as share_of_cases_pct,
       round(100 * avg(rms_given = 'Yes'), 1) as reimbursement_rate_pct,
       sum(rms_amount) as total_rms_amount,
       sum(case when rms_amount < 100000 then rms_amount else 0 end) as rms_excl_outlier,
       round(avg(rms_amount), 2) as avg_rms_per_case,
       round(avg(case when rms_amount < 100000 then rms_amount end), 2) as avg_rms_excl_outlier
from rms_cases
group by shipment_partnership;

-- Q19. Share of non-partnered shipments by marketplace
select marketplace,
       count(*) as cases,
       sum(shipment_partnership = 'Non-Partnered') as non_partnered_cases,
       round(100 * avg(shipment_partnership = 'Non-Partnered'), 1) as non_partnered_pct
from rms_cases
group by marketplace
order by non_partnered_pct desc;

-- Q20. Partnership by shipment type (SPD vs LTL)
select shipment_type, shipment_partnership,
       count(*) as cases,
       round(100 * avg(rms_given = 'Yes'), 1) as reimbursement_rate_pct,
       round(avg(rms_amount), 2) as avg_rms_per_case
from rms_cases
group by shipment_type, shipment_partnership
order by shipment_type, shipment_partnership;

-- Q21. Top root causes for each group (ROW_NUMBER)
with rc as (
    select c.shipment_partnership, r.root_cause, count(*) as cases,
           row_number() over (partition by c.shipment_partnership
                              order by count(*) desc, r.root_cause) as rn
    from rms_cases c
    join case_root_causes r on r.case_id = c.case_id
    group by c.shipment_partnership, r.root_cause
)
select shipment_partnership, rn as rank_no, root_cause, cases
from rc
where rn <= 3
order by shipment_partnership, rn;

-- Q22. Consistency check: do cases with root cause 'Non-Partnered' have no carrier?
select c.shipment_partnership, count(*) as cases_with_non_partnered_root_cause
from rms_cases c
join case_root_causes r on r.case_id = c.case_id
where r.root_cause = 'Non-Partnered'
group by c.shipment_partnership;