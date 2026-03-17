# q001 Experiment Note

## Question

**ID:** `q001`  
**Slug:** `q001_hops_per_day`  
**Title:** Highest daily hops for one aircraft on one flight number

The question asks for the top 10 longest single-day itineraries where one aircraft flew the same flight number multiple times. Required output: Aircraft ID, Flight Number, Carrier, Date, Route (with departure times), and hop count.

## Why this question is useful

This question exercises several SQL capabilities simultaneously:

- **Aggregation with array functions**: Building ordered leg sequences from grouped flight records
- **Date/time manipulation**: Sorting and formatting departure timestamps
- **String construction**: Assembling human-readable route strings from structured data
- **Window/ranking logic**: Identifying maximum-hop itineraries with proper tie-breaking

Airlines operating "milk run" or regional shuttle patterns can fly the same flight number across 6–8+ legs in a single day. Identifying these patterns reveals operational intensity and network structure.

## Experiment setup

- **Day:** 2026-03-17
- **Dataset:** `default.ontime_v2`
- **Runners:** Claude (opus), Codex (gpt-5.4), Gemini (gemini-3.1-pro-preview)
- **Run ID:** run-003 for all three
- **Prompts:** [prompt.md](prompts/q001_hops_per_day/prompt.md), [report_prompt.md](prompts/q001_hops_per_day/report_prompt.md), [visual_prompt.md](prompts/q001_hops_per_day/visual_prompt.md)
- **Compare contract:** [compare.yaml](prompts/q001_hops_per_day/compare.yaml)

## Result summary

| Runner | Model | Status | Rows | Duration | Read Rows | Memory |
|--------|-------|--------|-----:|----------|----------:|-------:|
| Claude | opus | ok | 10 | 18.63 s | 193,061,941 | 35.1 GiB |
| Codex | gpt-5.4 | ok | 10 | 7.88 s | 193,061,941 | 45.3 GiB |
| Gemini | gemini-3.1-pro-preview | partial | 10 | 15.53 s | 230,307,587 | 48.9 GiB |

All three runs returned exactly 10 rows. The key columns (`Aircraft ID`, `Flight Number`, `Carrier`, `Date`) match across all runs. Gemini's status is `partial` due to `presentation_render: failed`.

## Full SQL artifacts

### Claude (opus)

[runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql)

- Uses a CTE (`flight_legs`) filtering cancelled flights and null departure times
- Groups by tail, flight number, carrier, date
- Outputs explicit `Hops` column via `count()`
- Builds route string with `arraySort` and `arrayMap`, appending final destination

### Codex (gpt-5.4)

[runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql)

- No CTE; single aggregation query with inline `groupArray`
- Filters cancelled *and* diverted flights
- Omits `Hops` column (hop count implicit in route string)
- Uses `formatDateTime` for time formatting; `|` delimiter between legs

### Gemini (gemini-3.1-pro-preview)

[runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/query.sql](runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/query.sql)

- Uses `Reporting_Airline` instead of `IATA_CODE_Reporting_Airline` (both map to WN for Southwest)
- Outputs `Actual Departure Times` as a raw integer array
- Route string uses `-` delimiter with airport codes only (no times inline)
- Filter uses `length(Tail_Number) > 0` instead of `!= ''`

## Real output differences

### Key columns: Identical

Verified from `result.json` files. All 10 rows share the same:

- Aircraft ID: N957WN, N7835A, N429WN, N228WN, N569WN, N7742B, N929WN, N8631A, N8809L, N8811L
- Flight Numbers: 366, 3149 (4×), 154 (2×), 2787 (3×)
- Carrier: WN (all rows)
- Dates: 2024-12-01 through 2022-09-25

### Route content: Semantically equivalent, format varies

All three identify the same airport sequences. The first row across all runs:

| Runner | Route format |
|--------|--------------|
| Claude | `05:43 ISP → 08:10 BWI → 10:20 MYR → 11:42 BNA → 14:01 VPS → 16:43 DAL → 18:28 LAS → 20:41 OAK → SEA` |
| Codex | `05:43 ISP->BWI \| 08:10 BWI->MYR \| 10:20 MYR->BNA \| ... \| 20:41 OAK->SEA` |
| Gemini | `ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA` |

Departure times match across Claude and Codex (both include inline times). Gemini's departure times appear in a separate `Actual Departure Times` array column: `[543, 810, 1020, 1142, 1401, 1643, 1828, 2041]`.

### Column differences

| Runner | Columns |
|--------|---------|
| Claude | Aircraft ID, Flight Number, Carrier, Date, **Hops**, Route |
| Codex | Aircraft ID, Flight Number, Carrier, Date, Route |
| Gemini | Aircraft ID, Flight Number, Carrier, Date, Route, **Actual Departure Times** |

Claude is the only run outputting the `Hops` column explicitly. Gemini outputs departure times as a separate array. Codex outputs neither.

## SQL comparison

### Filtering logic

| Runner | Cancelled filter | Diverted filter | Tail filter |
|--------|------------------|-----------------|-------------|
| Claude | `Cancelled = 0` | none | `Tail_Number != ''` |
| Codex | `Cancelled = 0` | `Diverted = 0` | `Tail_Number != ''` |
| Gemini | none | none | `length(Tail_Number) > 0` |

Codex additionally filters diverted flights, which has no impact on this result set. Gemini omits cancelled/diverted filters entirely but matches because the highest-hop itineraries are all non-cancelled Southwest routes.

### Route string construction

- **Claude**: `arrayStringConcat(arrayMap(...), ' → ') || ' → ' || legs_sorted[length(legs_sorted)].3` — appends final destination explicitly
- **Codex**: `arrayStringConcat(arrayMap(x -> x.2, arraySort(x -> x.1, legs)), ' | ')` — each element is `HH:MM Origin->Dest`
- **Gemini**: `arrayStringConcat(arrayPushBack(arrayMap(...), argMax(Dest, DepTime)), '-')` — uses `argMax` to get final destination

### Carrier column source

Claude and Codex use `IATA_CODE_Reporting_Airline`; Gemini uses `Reporting_Airline`. Both columns contain `WN` for Southwest Airlines, so results align.

### Read volume difference

Gemini read 230.3M rows vs 193.1M for Claude/Codex (37.2M additional rows, +19%). This suggests Gemini's filter logic (`length(Tail_Number) > 0` with no cancelled/diverted filters) scanned more data before aggregation.

## Presentation artifacts

### Claude (opus)

- **Report:** [runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md) — 64 lines, includes analytical context on milk-run patterns and route clustering
- **Visual:** [runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html) — 781 lines, dynamic dashboard with Leaflet map, KPI cards, results table, query ledger with expandable SQL, CSV export

### Codex (gpt-5.4)

- **Report:** [runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md) — 27 lines, concise with lead-itinerary focus and route comparison guidance
- **Visual:** [runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html) — 1,668 lines, extensive dashboard with filtering (carrier, repeat-only toggle), route clustering analysis, sequence visualization, multi-section layout

### Gemini (gemini-3.1-pro-preview)

- **Report:** [runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/report.md](runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/report.md) — 32 lines, structured with overview and analytical summary
- **Visual:** [runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/visual.html](runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/visual.html) — 671 lines, simpler layout; `presentation_render` phase failed but HTML artifact was generated

All three HTML dashboards use Leaflet for mapping, JWE-token-based MCP authentication, query ledger with expandable SQL, and localStorage token persistence. Codex's dashboard is most feature-rich with carrier filtering and route-signature clustering. Claude's includes similar features in a more compact implementation. Gemini's is functional but has a rendering failure in the pipeline.

## Execution stats

### Claude (opus)

- Query duration: 18.63 s
- Read rows: 193,061,941
- Memory usage: 35.1 GiB
- Peak threads: 34

### Codex (gpt-5.4)

- Query duration: 7.88 s (fastest)
- Read rows: 193,061,941
- Memory usage: 45.3 GiB
- Peak threads: 34

### Gemini (gemini-3.1-pro-preview)

- Query duration: 15.53 s
- Read rows: 230,307,587 (+19% vs Claude/Codex)
- Memory usage: 48.9 GiB
- Peak threads: 34

Codex achieved fastest execution (7.88 s vs 15–18 s for others) despite identical read volume to Claude. Claude used the least memory (35.1 GiB vs 45–49 GiB). Gemini's looser filtering caused 37M additional rows to be read.

## Takeaway

All three models correctly identified the same 10 maximum-hop itineraries, with Southwest Airlines (WN) dominating due to their multi-leg same-flight-number operations. The key finding—8-hop itineraries for flight numbers 366, 3149, 154, and 2787—is consistent across all runs.

**Differences are localized to formatting and auxiliary columns**, not analytical correctness:

1. **Route string format**: Claude and Codex include inline departure times; Gemini separates them into an array column
2. **Hop count column**: Only Claude outputs `Hops` explicitly
3. **Performance**: Codex was 2.4× faster than Claude despite similar memory profiles; Gemini's looser filters increased read volume by 19%
4. **Presentation completeness**: Gemini's visualization render phase failed, though the HTML artifact exists

For strict compare-contract compliance, the `Hops` column presence in Claude vs. absence in Codex/Gemini would need normalization. The route-string format differences would require parsing to verify semantic equivalence (which they have).
