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

Question title: `Highest daily hops for one aircraft on one flight number`

Result columns: `Aircraft ID, Flight Number, Carrier, Date, Route`

Question-specific report guidance:

Explain:

- the maximum hop count observed and whether it appears to be a repeated operating pattern or a one-off itinerary,
- the single most recent itinerary among the maximum-hop rows, including carrier, flight number, date, and full route,
- and any notable route repetition or clustering visible across the top 10 longest itineraries.

Create `visual.html` using the `ontime-analyst-dashboard` skill.

The returned `visual.html` must be final browser-ready HTML. qforge will not patch or rewrite it after generation.

Saved SQL to embed directly in the final page:

```sql
WITH legs AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        Origin,
        Dest,
        toDateTime(FlightDate) + toIntervalMinute(if(DepTime = 2400, 1440, intDiv(DepTime, 100) * 60 + (DepTime % 100))) AS dep_ts
    FROM default.ontime_v2
    WHERE Cancelled = 0
      AND Diverted = 0
      AND Tail_Number != ''
      AND Flight_Number_Reporting_Airline != ''
      AND IATA_CODE_Reporting_Airline != ''
      AND DepTime IS NOT NULL
),
itineraries AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        count() AS hops,
        arraySort(groupArray((dep_ts, Origin, Dest))) AS ordered_legs,
        max(dep_ts) AS max_dep_ts
    FROM legs
    GROUP BY
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate
)
SELECT
    Tail_Number AS `Aircraft ID`,
    Flight_Number_Reporting_Airline AS `Flight Number`,
    IATA_CODE_Reporting_Airline AS Carrier,
    FlightDate AS Date,
    concat(
        arrayStringConcat(arrayMap(x -> concat(x.2, ' ', formatDateTime(x.1, '%Y-%m-%d %H:%i')), ordered_legs), ' -> '),
        ' -> ',
        ordered_legs[length(ordered_legs)].3
    ) AS Route
FROM itineraries
ORDER BY hops DESC, FlightDate DESC, max_dep_ts DESC
LIMIT 10
```

Visual context:

- Question title: `Highest daily hops for one aircraft on one flight number`
- Visual type: `html_map`

Question-specific visual guidance:

The page must:

- use Leaflet with a slippy map and remote basemap tiles
- show the lead itinerary returned by the primary query and parse its `Route` string in JavaScript
- derive hop count, stop sequence, and repeated-route comparisons from the result set
- run an explicit airport-coordinate enrichment query against `default.airports_bts` using airport codes parsed from the route strings
- label the map as airport-coordinate enrichment in the query ledger
- use enrichment results to place airport markers and route lines for the lead itinerary
- include KPI cards for tail number, flight number, date, hop count, and route repetition context
- include a legend and a route table or route sequence panel below the map
- if enrichment fails, report the degraded map in the ledger and continue rendering the non-map analysis