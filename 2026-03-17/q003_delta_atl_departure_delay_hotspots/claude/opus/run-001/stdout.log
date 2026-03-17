The query is working correctly. The ordering is correct with `hotspot_summary` rows first (sorted by HotspotRank), followed by `monthly_trend` rows (sorted by HotspotRank, then MonthStart).

```sql
WITH
-- Step 1: Base filtered flights for DL departures from ATL
base_flights AS (
    SELECT
        toStartOfMonth(FlightDate) AS MonthStart,
        Dest,
        DepTimeBlk,
        DepDelayMinutes,
        DepDel15
    FROM default.ontime_v2
    WHERE IATA_CODE_Reporting_Airline = 'DL'
      AND Origin = 'ATL'
      AND Cancelled = 0
),

-- Step 2: Monthly aggregation with qualification (>= 40 flights)
monthly_qualified AS (
    SELECT
        MonthStart,
        Dest,
        DepTimeBlk,
        count(*) AS MonthlyFlights
    FROM base_flights
    GROUP BY MonthStart, Dest, DepTimeBlk
    HAVING MonthlyFlights >= 40
),

-- Step 3: Hotspot-level stats from raw flights in qualifying monthly cells
hotspot_raw AS (
    SELECT
        bf.Dest,
        bf.DepTimeBlk,
        bf.DepDelayMinutes,
        bf.DepDel15,
        bf.MonthStart
    FROM base_flights bf
    INNER JOIN monthly_qualified mq
        ON bf.MonthStart = mq.MonthStart
       AND bf.Dest = mq.Dest
       AND bf.DepTimeBlk = mq.DepTimeBlk
),

-- Step 4: Compute hotspot-level metrics from raw flights
hotspot_metrics AS (
    SELECT
        Dest,
        DepTimeBlk,
        count(*) AS CompletedFlights,
        avg(DepDelayMinutes) AS AvgDepDelayMinutes,
        quantile(0.9)(DepDelayMinutes) AS P90DepDelayMinutes,
        100.0 * sum(DepDel15) / count(*) AS DepDel15Pct,
        count(DISTINCT MonthStart) AS QualifyingMonths,
        min(MonthStart) AS FirstQualifyingMonth,
        max(MonthStart) AS LastQualifyingMonth
    FROM hotspot_raw
    GROUP BY Dest, DepTimeBlk
    HAVING CompletedFlights >= 1000
),

-- Step 5: Rank hotspots
ranked_hotspots AS (
    SELECT
        *,
        row_number() OVER (
            ORDER BY AvgDepDelayMinutes DESC, P90DepDelayMinutes DESC, DepDel15Pct DESC, CompletedFlights DESC
        ) AS HotspotRank
    FROM hotspot_metrics
),

-- Step 6: Top 20 hotspots
top_hotspots AS (
    SELECT * FROM ranked_hotspots WHERE HotspotRank <= 20
),

-- Step 7: Monthly trend rows for top 20 hotspots (from raw flights in qualifying months)
monthly_trends AS (
    SELECT
        hr.MonthStart,
        hr.Dest,
        hr.DepTimeBlk,
        count(*) AS CompletedFlights,
        avg(hr.DepDelayMinutes) AS AvgDepDelayMinutes,
        quantile(0.9)(hr.DepDelayMinutes) AS P90DepDelayMinutes,
        100.0 * sum(hr.DepDel15) / count(*) AS DepDel15Pct
    FROM hotspot_raw hr
    INNER JOIN top_hotspots th ON hr.Dest = th.Dest AND hr.DepTimeBlk = th.DepTimeBlk
    GROUP BY hr.MonthStart, hr.Dest, hr.DepTimeBlk
),

-- Step 8: Attach hotspot metadata to monthly trends
monthly_trends_with_meta AS (
    SELECT
        mt.MonthStart,
        mt.Dest,
        mt.DepTimeBlk,
        mt.CompletedFlights,
        mt.AvgDepDelayMinutes,
        mt.P90DepDelayMinutes,
        mt.DepDel15Pct,
        th.QualifyingMonths,
        th.FirstQualifyingMonth,
        th.LastQualifyingMonth,
        th.HotspotRank
    FROM monthly_trends mt
    INNER JOIN top_hotspots th ON mt.Dest = th.Dest AND mt.DepTimeBlk = th.DepTimeBlk
),

-- Step 9: Hotspot summary rows
hotspot_summary AS (
    SELECT
        'hotspot_summary' AS RowType,
        toNullable(toDate('1970-01-01')) AS MonthStart,
        Dest,
        DepTimeBlk,
        QualifyingMonths,
        CompletedFlights,
        round(AvgDepDelayMinutes, 2) AS AvgDepDelayMinutes,
        round(P90DepDelayMinutes, 2) AS P90DepDelayMinutes,
        round(DepDel15Pct, 2) AS DepDel15Pct,
        FirstQualifyingMonth,
        LastQualifyingMonth,
        HotspotRank
    FROM top_hotspots
),

-- Step 10: Monthly trend rows
monthly_trend_rows AS (
    SELECT
        'monthly_trend' AS RowType,
        toNullable(MonthStart) AS MonthStart,
        Dest,
        DepTimeBlk,
        QualifyingMonths,
        CompletedFlights,
        round(AvgDepDelayMinutes, 2) AS AvgDepDelayMinutes,
        round(P90DepDelayMinutes, 2) AS P90DepDelayMinutes,
        round(DepDel15Pct, 2) AS DepDel15Pct,
        FirstQualifyingMonth,
        LastQualifyingMonth,
        HotspotRank
    FROM monthly_trends_with_meta
),

-- Final union
combined AS (
    SELECT * FROM hotspot_summary
    UNION ALL
    SELECT * FROM monthly_trend_rows
)

SELECT
    RowType,
    if(RowType = 'hotspot_summary', NULL, MonthStart) AS MonthStart,
    Dest,
    DepTimeBlk,
    QualifyingMonths,
    CompletedFlights,
    AvgDepDelayMinutes,
    P90DepDelayMinutes,
    DepDel15Pct,
    FirstQualifyingMonth,
    LastQualifyingMonth,
    HotspotRank
FROM combined
ORDER BY RowType ASC, HotspotRank ASC, MonthStart ASC, Dest ASC, DepTimeBlk ASC
```
