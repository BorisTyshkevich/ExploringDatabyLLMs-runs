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

Result columns: `TailNum, FlightNum, Carrier, FlightDate, Hops, Route`

Question-specific report guidance:

Explain:

- the maximum hop count observed and whether it appears to be a repeated operating pattern or a one-off itinerary,
- the single most recent itinerary among the maximum-hop rows, including carrier, flight number, date, and full route,
- and any notable route repetition or clustering visible across the top 10 longest itineraries.

Create `visual.html` using the `ontime-analyst-dashboard` skill.

The returned `visual.html` must be final browser-ready HTML. qforge will not patch or rewrite it after generation.

Saved SQL to embed directly in the final page:

```sql
SELECT
    TailNum,
    FlightNum,
    Carrier,
    FlightDate,
    length(legs) AS Hops,
    arrayStringConcat(
        arrayPushBack(
            arrayMap(x -> concat(x.1, ' (', toString(x.3), ')'), legs),
            tupleElement(legs[-1], 2)
        ),
        ' - '
    ) AS Route
FROM (
    SELECT
        TailNum,
        FlightNum,
        Carrier,
        FlightDate,
        arraySort(x -> toFloat64OrZero(toString(x.3)), groupArray(tuple(Origin, Dest, DepTime))) AS legs
    FROM default.ontime_v2
    WHERE TailNum != ''
      AND toString(FlightNum) != ''
      AND toString(DepTime) != ''
      AND Cancelled = 0
    GROUP BY
        TailNum,
        FlightNum,
        Carrier,
        FlightDate
)
ORDER BY
    Hops DESC,
    FlightDate DESC
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