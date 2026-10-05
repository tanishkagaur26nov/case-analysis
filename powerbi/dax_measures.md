# DAX Measures and Calculations

This file documents every DAX calculation used in the Power BI report (`RMS_Case_Analytics.pbix`).
Results shown are for the full dataset with no filters applied.

---

## Data Model

| Table | Type | Description |
|---|---|---|
| `RMS_Clean` | Fact table | One row per investigation case (618 rows), cleaned in Power Query |
| `Root Cause Bridge` | Bridge table | One row per case per root cause (851 rows), built in Power Query |
| `Calendar` | Date table (DAX) | One row per day, Jan–Jun 2025; marked as the date table |
| `_Measures` | Measures table | Holds all measures below, kept separate for clarity |

**Relationships**
- `Calendar[Date]` → `RMS_Clean[Date Opened]` (one-to-many, single direction)
- `RMS_Clean[Case]` → `Root Cause Bridge[Case]` (one-to-many, **both** directions, so that selecting a root cause filters the whole report)

---

## Calculated Table

### Calendar
```dax
Calendar =
ADDCOLUMNS (
    CALENDAR ( DATE ( 2025, 1, 1 ), DATE ( 2025, 6, 30 ) ),
    "Month No", MONTH ( [Date] ),
    "Month Name", FORMAT ( [Date], "MMM" ),
    "Year", YEAR ( [Date] )
)
```
Creates one row per day for the analysis period. `Month Name` is sorted by `Month No` so months appear in calendar order. Required for time-intelligence functions such as `DATEADD`.

---

## Calculated Columns (RMS_Clean)

### Root Cause Count
```dax
Root Cause Count =
LEN ( RMS_Clean[Root Cause] ) - LEN ( SUBSTITUTE ( RMS_Clean[Root Cause], ",", "" ) ) + 1
```
Counts how many root causes each case has, by counting the commas and adding 1.

### Complexity Group
```dax
Complexity Group =
SWITCH (
    TRUE (),
    RMS_Clean[Root Cause Count] = 1, "1 cause",
    RMS_Clean[Root Cause Count] = 2, "2 causes",
    "3+ causes"
)
```
Groups cases by complexity, to test whether multi-cause cases are reimbursed more often.

### Country
```dax
Country =
SWITCH (
    RMS_Clean[Marketplace],
    "DE", "Germany",
    "UK", "United Kingdom",
    "FR", "France",
    "IT", "Italy",
    "ES", "Spain",
    "US", "United States",
    "CA", "Canada"
)
```
Converts marketplace codes to full country names for the map visual. The column's data category is set to **Country/Region**.

> **Note:** `Shipment Partnership` (Partnered / Non-Partnered) is created in Power Query, not DAX. A blank carrier means a non-partnered shipment.

---

## Measures

### Core volume and rate measures

| Measure | Result |
|---|---|
| Total Cases | 618 |
| Reimbursed Cases | 252 |
| Reimbursement Rate % | 40.8% |

```dax
Total Cases = COUNTROWS ( RMS_Clean )
```
Counts the number of cases in the current filter context.

```dax
Reimbursed Cases = CALCULATE ( [Total Cases], RMS_Clean[RMS Given] = "Yes" )
```
Counts only the cases where the seller was reimbursed. `CALCULATE` applies an extra filter to an existing measure.

```dax
Reimbursement Rate % = DIVIDE ( [Reimbursed Cases], [Total Cases] )
```
Share of cases that were reimbursed. `DIVIDE` returns blank instead of an error if the denominator is zero.

---

### Amount measures

| Measure | Result |
|---|---|
| Total RMS Amount | 262,819.01 |
| RMS Excl. Outlier | 134,368.26 |
| Avg Amount per Paid Case | 1,033.43 |
| Avg RMS per Case | 425.27 |
| Avg RMS Excl. Outlier | 217.89 |

```dax
Total RMS Amount = SUM ( RMS_Clean[RMS Amount] )
```
Total reimbursement paid. Amounts are in each marketplace's local currency.

```dax
RMS Excl. Outlier = CALCULATE ( [Total RMS Amount], RMS_Clean[RMS Amount] < 100000 )
```
Total reimbursement excluding the single extreme case (128,450.75), which accounts for 49% of total cost.

```dax
Avg Amount per Paid Case =
CALCULATE ( AVERAGE ( RMS_Clean[RMS Amount] ), RMS_Clean[RMS Given] = "Yes" )
```
Average amount paid, counting only reimbursed cases.

```dax
Avg RMS per Case = AVERAGE ( RMS_Clean[RMS Amount] )
```
Average amount across all cases, including those with no payment. Used to compare shipment types.

```dax
Avg RMS Excl. Outlier =
CALCULATE ( AVERAGE ( RMS_Clean[RMS Amount] ), RMS_Clean[RMS Amount] < 100000 )
```
Average amount per case without the outlier. This reveals that non-partnered shipments are actually cheaper per case once the outlier is removed.

```dax
Total ASINs = SUM ( RMS_Clean[No. of ASIN] )
```
Total number of products (ASINs) involved across cases. Result: 5,194.

---

### Time intelligence

```dax
Prev Month Cases = CALCULATE ( [Total Cases], DATEADD ( 'Calendar'[Date], -1, MONTH ) )
```
Case count for the previous month. `DATEADD` shifts the date filter back by one month, which requires the marked Calendar table.

```dax
MoM Change % = DIVIDE ( [Total Cases] - [Prev Month Cases], [Prev Month Cases] )
```
Month-over-month change in case volume. Highlights April's +180.7% increase versus March.

---

### Pareto analysis

```dax
Cumulative RMS % =
VAR CurrentAmount = [Total RMS Amount]
VAR RunningTotal =
    SUMX (
        FILTER ( ALLSELECTED ( RMS_Clean[FC] ), [Total RMS Amount] >= CurrentAmount ),
        [Total RMS Amount]
    )
RETURN
    DIVIDE ( RunningTotal, CALCULATE ( [Total RMS Amount], ALLSELECTED ( RMS_Clean[FC] ) ) )
```
Running total of cost across FCs, from most to least expensive, as a percentage of the total. For each FC, it adds up the cost of every FC that costs the same or more. `ALLSELECTED` respects the visual's filter, which excludes "Unknown" FCs. Result: the top FC alone accounts for 54.5%, and the top 10 of 47 FCs account for about 80%.

---

### Dynamic title

```dax
Selected FC Label =
"Showing cases for: " & SELECTEDVALUE ( RMS_Clean[FC], "All FCs" )
```
Used as the dynamic title on the Case Details drill-through page. `SELECTEDVALUE` returns the FC name when exactly one FC is selected; otherwise it shows "All FCs".

---

## Validation

All key measures were cross-checked against the equivalent MySQL queries (see `/sql`), and every result matched.

| Check | Power BI | MySQL |
|---|---|---|
| Total cases | 618 | 618 |
| Reimbursement rate | 40.8% | 40.8% |
| Total RMS amount | 262,819.01 | 262,819.01 |
| Excluding outlier | 134,368.26 | 134,368.26 |
| April MoM change | +180.7% | +180.7% |
| Top FC cumulative share | 54.5% | 54.5% |
