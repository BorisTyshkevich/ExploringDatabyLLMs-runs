WITH monthly_stats AS (
    SELECT
        toStartOfMonth(FlightDate) AS MonthStart,
        Dest,
        DepTimeBlk
    FROM default.ontime_v2
    WHERE IATA_CODE_Reporting_Airline = 'DL'
      AND Origin = 'ATL'
      AND Cancelled = 0
    GROUP BY MonthStart, Dest, DepTimeBlk
    HAVING count() >= 40
),
qualifying_raw AS (
    SELECT
        toStartOfMonth(t.FlightDate) AS MonthStart,
        t.Dest,
        t.DepTimeBlk,
        t.DepDelayMinutes,
        t.DepDel15
    FROM default.ontime_v2 t
    INNER JOIN monthly_stats m
      ON toStartOfMonth(t.FlightDate) = m.MonthStart
     AND t.Dest = m.Dest
     AND t.DepTimeBlk = m.DepTimeBlk
    WHERE t.IATA_CODE_Reporting_Airline = 'DL'
      AND t.Origin = 'ATL'
      AND t.Cancelled = 0
),
hotspot_metrics AS (
    SELECT
        Dest,
        DepTimeBlk,
        uniqExact(MonthStart) AS QualifyingMonths,
        count() AS CompletedFlights,
        min(MonthStart) AS FirstQualifyingMonth,
        max(MonthStart) AS LastQualifyingMonth,
        avg(DepDelayMinutes) AS raw_avg,
        quantile(0.9)(DepDelayMinutes) AS raw_p90,
        (sum(DepDel15) / count()) * 100 AS raw_pct
    FROM qualifying_raw
    GROUP BY Dest, DepTimeBlk
    HAVING CompletedFlights >= 1000
),
top_20_hotspots AS (
    SELECT
        Dest,
        DepTimeBlk,
        QualifyingMonths,
        CompletedFlights,
        FirstQualifyingMonth,
        LastQualifyingMonth,
        raw_avg,
        raw_p90,
        raw_pct,
        row_number() OVER (ORDER BY raw_avg DESC, raw_p90 DESC, raw_pct DESC, CompletedFlights DESC) AS HotspotRank
    FROM hotspot_metrics
    ORDER BY HotspotRank
    LIMIT 20
)
SELECT
    'hotspot_summary' AS RowType,
    CAST(NULL AS Nullable(Date)) AS MonthStart,
    Dest,
    DepTimeBlk,
    QualifyingMonths,
    CompletedFlights,
    round(raw_avg, 2) AS AvgDepDelayMinutes,
    round(raw_p90, 2) AS P90DepDelayMinutes,
    round(raw_pct, 2) AS DepDel15Pct,
    FirstQualifyingMonth,
    LastQualifyingMonth,
    HotspotRank
FROM top_20_hotspots

UNION ALL

SELECT
    'monthly_trend' AS RowType,
    CAST(q.MonthStart AS Nullable(Date)) AS MonthStart,
    h.Dest,
    h.DepTimeBlk,
    h.QualifyingMonths,
    count() AS CompletedFlights,
    round(avg(q.DepDelayMinutes), 2) AS AvgDepDelayMinutes,
    round(quantile(0.9)(q.DepDelayMinutes), 2) AS P90DepDelayMinutes,
    round((sum(q.DepDel15) / count()) * 100, 2) AS DepDel15Pct,
    h.FirstQualifyingMonth,
    h.LastQualifyingMonth,
    h.HotspotRank
FROM qualifying_raw q
INNER JOIN top_20_hotspots h
  ON q.Dest = h.Dest
 AND q.DepTimeBlk = h.DepTimeBlk
GROUP BY
    h.Dest,
    h.DepTimeBlk,
    q.MonthStart,
    h.QualifyingMonths,
    h.FirstQualifyingMonth,
    h.LastQualifyingMonth,
    h.HotspotRank

ORDER BY
    RowType,
    HotspotRank ASC,
    MonthStart ASC,
    Dest,
    DepTimeBlk;
