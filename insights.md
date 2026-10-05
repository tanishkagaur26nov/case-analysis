# Key Insights and Recommendations

**Scope:** 618 inbound shipment reimbursement investigation cases, January–June 2025,
across 7 marketplaces (DE, UK, FR, IT, ES, US, CA) and 47 fulfilment centres (FCs).

**Sources:** SQL scripts in `/sql` and the Power BI report in `/powerbi`.
All figures were cross-checked between MySQL and Power BI.

---

## Headline Numbers

| Metric | Value |
|---|---|
| Total cases | 618 |
| Reimbursed cases | 252 (40.8%) |
| Total reimbursement | 262,819 (local currencies) |
| Total excluding one outlier case | 134,368 |
| Average paid per reimbursed case | 1,033.43 |
| Partnered / non-partnered shipments | 375 (60.7%) / 243 (39.3%) |

---

## Insight 1: One case distorts the overall picture

A single non-partnered pallet (LTL) case at FC-DE01, with 412 ASINs and a payout of
128,451, accounts for **48.9% of total reimbursement cost**.

This one case explains three findings that would otherwise be misleading:
- **April's cost spike:** April shows 156,141 in reimbursements; without the outlier it is 27,691.
- **FC-DE01's ranking:** FC-DE01 appears to drive 54.5% of all FC cost. Without the outlier,
  its cost falls to about 12,769, and it is no longer the most expensive FC.
- **Non-partnered cost:** non-partnered shipments appear to cost twice as much as partnered
  ones, but only because of this case (see Insight 6).

**Recommendation:** report cost both with and without outliers, and route high-value
cases (for example, above 10,000) to a secondary review before payment.

---

## Insight 2: Three root causes drive most investigations

| Root cause | Cases | Reimbursement rate |
|---|---|---|
| FC Operation | 204 | 70.6% |
| Carton Missing | 151 | 55.0% |
| Item Substitution | 130 | 41.5% |

FC Operation is both the most frequent root cause and the most likely to be reimbursed.
At the other end, cases where the shipment was received in full (6.7%), was not eligible
(12.2%) or was a duplicate (14.3%) are rarely reimbursed.

**Recommendation:** prioritise FC process audits, because FC Operation errors are the
largest and most "valid" source of reimbursement cost.

---

## Insight 3: Root causes differ by region

- **EU (DE, UK, FR, IT):** FC Operation is the top root cause.
- **US, CA and ES:** Carton Missing is the top root cause.

**Recommendation:** tailor prevention by region: FC process controls in most EU
marketplaces, and carton tracking and receiving checks in North America and Spain.

---

## Insight 4: Cost is concentrated in a few FCs

**10 of 47 FCs account for about 80% of reimbursement cost**, a clear Pareto pattern.
FC-DE01 leads at 54.5%, although most of that is the single outlier case (Insight 1).

**Recommendation:** focus improvement efforts on these 10 FCs first for the largest impact.

---

## Insight 5: Pallet shipments are fewer but costlier

| Shipment type | Cases | Avg ASINs | Reimbursement rate | Avg amount per case |
|---|---|---|---|---|
| SPD (small parcel) | 409 | 5.3 | 43.5% | 173.39 |
| LTL (pallet) | 193 | 15.2 | 34.7% | 985.11 |

LTL cases involve about three times as many products and cost far more per case,
but they are reimbursed less often.

---

## Insight 6: Non-partnered pallet shipments are harder to recover

243 cases (39.3%) are non-partnered shipments, where the seller used their own carrier
rather than a partnered carrier.

| | Partnered | Non-partnered |
|---|---|---|
| Overall reimbursement rate | 41.9% | 39.1% |
| LTL (pallet) reimbursement rate | 37.8% | **30.5%** |
| SPD (parcel) reimbursement rate | 43.5% | 43.6% |
| Avg amount per case (excl. outlier) | 231.32 | 196.78 |

For small parcels, partnership makes no difference. For pallets, non-partnered
shipments are reimbursed noticeably less often, likely because without partnered-carrier
tracking data, losses are harder to prove.

Raw totals suggest non-partnered shipments cost twice as much (176,072 vs 86,747), but
this is driven entirely by the outlier case; excluding it, non-partnered shipments cost
less per case.

The share of non-partnered shipments is highest in France (45.2%) and the UK (44.0%),
and lowest in the US (33.9%) and Canada (33.3%).

**Recommendation:** encourage sellers, especially in France and the UK, to use
partnered carriers for pallet shipments, where tracking evidence most affects claim success.

---

## Insight 7: Case volume peaked in April and May

| Month | Cases | Change vs previous month |
|---|---|---|
| Jan | 140 | n/a |
| Feb | 48 | -65.7% |
| Mar | 57 | +18.8% |
| Apr | 160 | +180.7% |
| May | 175 | +9.4% |
| Jun | 38 | -78.3% |

Volume rose sharply in April and stayed high in May. Average resolution time stayed
stable at about 8 to 9 days per month, so the team handled the higher volume without
slowing down. Cases with no root-cause summary took longest to resolve (12.4 days on average).

**Recommendation:** investigate what drove the April–May increase (for example, seasonal
inbound volume) and plan capacity for similar peaks. Require a root-cause summary at case
creation to reduce resolution time.

---

## Data Quality Findings

- **26 duplicate records** were removed during cleaning (22 exact duplicates and 4 cases re-logged in a later month).
- **11 records** contain logical inconsistencies: 5 closed before they were opened, and 6 where
  the "RMS Given" flag contradicts the amount. These were kept and flagged, not corrected,
  because the correct values cannot be known.
- **14 cases** have the root cause "Non-Partnered" but also list a named carrier, which
  conflicts with the partnership rule. In real data, this would point to a labelling error.

**Recommendation:** add validation at case entry, so the closed date cannot be earlier than
the opened date, and the payment flag must match the amount.

---

## Limitations

- Amounts are in each marketplace's local currency (EUR, GBP, USD, CAD) and are not converted,
  so cross-country cost comparisons use case counts and rates rather than amounts.
- The dataset is synthetic and anonymised. It is modelled on a real investigation workflow but
  contains no real case, seller or FC data.
- Six months of data is not enough to confirm seasonal patterns.

---

## Next Steps (if extended)

- Convert all amounts to a single currency using monthly exchange rates
- Extend the data to 12+ months to test seasonality
- Connect Power BI directly to MySQL for a fully automated pipeline
