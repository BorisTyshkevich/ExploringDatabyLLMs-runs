You are running inside qforge.

Use the configured MCP server for all data access.
Do not construct raw OpenAPI URLs manually.
Stay within the configured dataset scope.
Do not reference tables outside the allowed dataset constraints.

Dataset constraints:

- Use `default.ontime_v2` as the primary fact table.
- Do not reference `default.ontime`.

You are generating presentation artifacts inside qforge.

The harness already executed the saved SQL and produced `result.json`.
Do not invent KPIs or data values.
The report is a Markdown template that qforge will render from `result.json`.

Return exactly these fenced sections:

```report
Use placeholders only where data is needed.
Allowed placeholders: {{row_count}}, {{generated_at}}, {{columns_csv}}, {{question_title}}, {{data_overview_md}}, {{result_table_md}}
```

```html
<!doctype html>
<html>...</html>
```

Report rules:

- The report must be Markdown.
- The report must be a template, not a data-filled summary.
- Prefer `{{data_overview_md}}` and `{{result_table_md}}` for JSON-derived sections.
- Keep the report concise and analytical.

Question title: `Delta ATL departure delay hotspots by destination and time block`

Result columns: `RowType, MonthStart, Dest, DepTimeBlk, QualifyingMonths, CompletedFlights, AvgDepDelayMinutes, P90DepDelayMinutes, DepDel15Pct, FirstQualifyingMonth, LastQualifyingMonth, HotspotRank`

Question-specific report guidance:

Explain:

- which destination and time block is the worst hotspot,
- whether the hotspot is persistent or concentrated in a narrower era,
- and what the top 5 hotspot cells suggest about ATL departure pressure for Delta.

Create `visual.html` using the `ontime-analyst-dashboard` skill.

The returned `visual.html` must be final browser-ready HTML. qforge will not patch or rewrite it after generation.

Saved SQL to embed directly in the final page:

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

Visual context:

- Question title: `Delta ATL departure delay hotspots by destination and time block`
- Visual type: `html_heatmap`

Question-specific visual guidance:

Build a dynamic non-map dashboard for Delta ATL departure delay hotspots.

Layout intent:

- headline and subtitle that clearly frame Delta departures from ATL
- KPI strip for worst hotspot, worst average departure delay, p90 departure delay, and qualifying months
- primary heatmap with `Dest` on one axis and `DepTimeBlk` on the other, colored by average `DepDelayMinutes`
- supporting monthly trend view for the top 3 hotspot cells
- ranked table for the top 20 hotspot cells
- visible legend for the heatmap color scale

Behavior:

- derive the top 3 hotspot cells for the trend view from the fetched ranking rows, not from hardcoded labels
- make the single worst hotspot cell visually prominent
- keep the heatmap readable on mobile by allowing horizontal scrolling if necessary
- preserve useful content when the fetched result set is empty