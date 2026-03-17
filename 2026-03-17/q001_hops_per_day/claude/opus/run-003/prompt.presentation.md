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

Result columns: `Aircraft ID, Flight Number, Carrier, Date, Hops, Route`

Question-specific report guidance:

Explain:

- the maximum hop count observed and whether it appears to be a repeated operating pattern or a one-off itinerary,
- the single most recent itinerary among the maximum-hop rows, including carrier, flight number, date, and full route,
- and any notable route repetition or clustering visible across the top 10 longest itineraries.

Create `visual.html` using the `ontime-analyst-dashboard` skill.

The returned `visual.html` must be final browser-ready HTML. qforge will not patch or rewrite it after generation.

General visual rules:

- Derive KPIs, chart values, table rows, filters, and highlights from the actual analytical data. Do not invent or hardcode them.
- Respect the declared visual mode and visual type shown below.
- Follow question-specific visual guidance after the shared contract. Put reusable runtime behavior in shared page code, not in prose comments.
- Keep report logic out of `visual.html`; qforge already renders `report.md` separately.

Saved SQL to preserve in the final page contract:

```sql
WITH flight_legs AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        Origin,
        Dest,
        DepTime
    FROM default.ontime_v2
    WHERE Tail_Number != ''
      AND Cancelled = 0
      AND DepTime IS NOT NULL
),
grouped AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        count() AS Hops,
        arraySort(x -> x.1, groupArray(tuple(DepTime, Origin, Dest))) AS legs_sorted
    FROM flight_legs
    GROUP BY Tail_Number, Flight_Number_Reporting_Airline, IATA_CODE_Reporting_Airline, FlightDate
    HAVING Hops >= 2
)
SELECT
    Tail_Number AS `Aircraft ID`,
    Flight_Number_Reporting_Airline AS `Flight Number`,
    IATA_CODE_Reporting_Airline AS Carrier,
    FlightDate AS `Date`,
    Hops,
    arrayStringConcat(
        arrayMap(x -> concat(
            lpad(toString(x.1 DIV 100), 2, '0'), ':', lpad(toString(x.1 MOD 100), 2, '0'),
            ' ', x.2
        ), legs_sorted),
        ' → '
    ) || ' → ' || legs_sorted[length(legs_sorted)].3 AS Route
FROM grouped
ORDER BY Hops DESC, FlightDate DESC
LIMIT 10
```

Visual context:

- Question title: `Highest daily hops for one aircraft on one flight number`
- Visual mode: `dynamic`
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

Dynamic-mode requirements:

- The dashboard must execute the saved SQL in the browser via MCP OpenAPI using a browser-stored JWE token as the primary analytical query.
- Additional browser queries are allowed only for explicit enrichment or drill-down purposes that materially improve the visualization and stay within dataset constraints.
- Keep every browser query visible in a single query ledger that includes purpose, role, status, row count where available, and the full SQL text.
- Include a dedicated footer control block at the very end of the page containing the token input, SQL textarea, fetch action, forget-token action, and status text.
- Use browser `localStorage` key `OnTimeAnalystDashboard::auth::jwe` for the shared JWE token and prefill the token field from it on page init.
- Prefill the SQL textarea with the saved SQL shown above and treat it as the primary query source.
- Normalize fetched `columns` + `rows` into row objects before deriving KPIs, charts, tables, filtering, formatting, and highlights.
- Treat `count = 0` with `rows = null` as a valid empty result, not a malformed payload.
- Do not embed analytical `result.json` payloads or CSV snapshots for the main dataset in dynamic mode.
- Prefer dataset-native dimensions and lookup tables when enrichment is needed; do not hide follow-up queries behind unexplained UI behavior.
- Normalize temporal fields before rendering or comparisons. If a ClickHouse `Date` may arrive as an ISO timestamp, derive a stable `YYYY-MM-DD` key and reuse it everywhere.
- If the page uses `<template>` cloning, avoid duplicated fixed `id` values inside cloned content; use scoped selectors or stored element references instead.
- For Leaflet maps, initialize the map only after the visible container is in layout, or call `invalidateSize()` after reveal.

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