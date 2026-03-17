# q001 Experiment Note

## Question

**ID:** `q001`  
**Slug:** `q001_hops_per_day`  
**Title:** Highest daily hops for one aircraft on one flight number

Find the maximum number of legs (hops) that a single aircraft (tail number) flew in a single calendar day while operating under the same flight number. Report the top 10 such itineraries sorted by hop count descending, then by most recent date.

## Why this question is useful

This question tests an LLM's ability to:

1. **Aggregate with temporal constraints** — group by aircraft + flight number + date while counting legs
2. **Reconstruct ordered sequences** — sort legs by departure time to build a coherent route string
3. **Apply domain semantics** — distinguish between same-day repositioning and scheduled multi-leg operations
4. **Handle nullable/empty guards** — filter out cancelled flights and records with missing tail numbers

The results reveal operational patterns like Southwest's multi-stop transcontinental flights that maintain a single flight number across 8+ cities.

## Experiment setup

| Runner | Model | Run Directory |
| --- | --- | --- |
| claude | opus | `runs/2026-03-17/q001_hops_per_day/claude/opus/run-002` |
| codex | gpt-5.4 | `runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001` |
| gemini | gemini-3.1-pro-preview | `runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001` |

All three runs targeted `default.ontime_v2` on the configured ClickHouse MCP endpoint.

## Result summary

**All three runs returned identical logical results**: 10 rows, the same 10 (Aircraft, Flight Number, Carrier, Date) tuples, and equivalent hop counts of 8 for each row. The route airport sequences match across all runs — they identify the same itineraries.

| Runner | Model | Status | Rows | Duration | Read Rows | Memory | Warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| claude | opus | ok | 10 | 7.48 s | 193,061,941 | 42.3 GiB | 0 |
| codex | gpt-5.4 | ok | 10 | 7.65 s | 193,061,941 | 45.4 GiB | 0 |
| gemini | gemini-3.1-pro-preview | ok | 10 | 7.57 s | 230,307,587 | 41.5 GiB | 0 |

Key observations:

- **Fastest:** claude/opus (7.48 s)
- **Lowest read volume:** claude/opus and codex/gpt-5.4 (193.1M rows)
- **Lowest memory:** gemini/gemini-3.1-pro-preview (41.5 GiB)

## Full SQL artifacts

| Runner | Path |
| --- | --- |
| claude/opus | [`query.sql`](./claude/opus/run-002/query.sql) |
| codex/gpt-5.4 | [`query.sql`](./codex/gpt-5.4/run-001/query.sql) |
| gemini/gemini-3.1-pro-preview | [`query.sql`](./gemini/gemini-3.1-pro-preview/run-001/query.sql) |

## Real output differences

**Key columns match exactly.** All three runs identify the same 10 (Aircraft ID, Flight Number, Carrier, Date) combinations with identical hop counts of 8.

**Route format differs** in presentation only:

| Runner | Route Format Example (Row 1) |
| --- | --- |
| claude/opus | `ISP(0543) -> BWI(0810) -> ... -> SEA` |
| codex/gpt-5.4 | `ISP 2024-12-01 05:43 -> BWI 2024-12-01 08:10 -> ... -> SEA` |
| gemini/gemini-3.1-pro-preview | `ISP (543) - BWI (810) - ... - SEA` |

- **Claude** uses 4-digit zero-padded HHMM times in parentheses with `->` delimiters
- **Codex** includes full `YYYY-MM-DD HH:MM` timestamps with `->` delimiters
- **Gemini** uses unpadded integer times in parentheses with `-` delimiters

**Column naming differs:**

| Concept | Claude | Codex | Gemini |
| --- | --- | --- | --- |
| Aircraft | `Tail_Number` | `Aircraft ID` | `TailNum` |
| Flight | `Flight_Number_Reporting_Airline` | `Flight Number` | `FlightNum` |
| Carrier | `IATA_CODE_Reporting_Airline` | `Carrier` | `Carrier` |
| Date | `FlightDate` | `Date` | `FlightDate` |

These alias differences are handled by the compare contract's `header_aliases` mapping and do not affect logical equivalence.

**Codex omits the explicit `Hops` column** from its output (column list: `Aircraft ID, Flight Number, Carrier, Date, Route`). Claude and Gemini both include `Hops = 8` as a dedicated column.

## SQL comparison

All three approaches share the same high-level structure:

1. Filter to non-cancelled flights with valid tail numbers and departure times
2. Group by (tail, flight number, carrier, date)
3. Count legs and sort them chronologically
4. Build a route string from the sorted leg array
5. Order by hops DESC, date DESC, and limit to 10

**Key differences:**

| Aspect | Claude | Codex | Gemini |
| --- | --- | --- | --- |
| CTE style | Two CTEs (`legs`, `grouped`) | Two CTEs (`legs`, `itineraries`) | Inline subquery |
| Diverted filter | Not applied | `Diverted = 0` | Not applied |
| Time representation | Raw `DepTime` integer | Converts to `DateTime` via arithmetic | Sorts via `toFloat64OrZero` cast |
| Leg sorting | `arraySort(x -> x.1, ...)` on `DepTime` | `arraySort(groupArray(...))` on `dep_ts` | `arraySort(x -> toFloat64OrZero(toString(x.3)), ...)` |
| Column names | Uses original column names | Aliases to friendly names | Uses shorter column names |

**Read-row divergence:** Gemini read 230.3M rows vs. 193.1M for Claude/Codex. This 19% increase is likely due to Gemini's `toString(FlightNum) != ''` predicate being less efficient than the others' direct `Flight_Number_Reporting_Airline != ''`.

## Presentation artifacts

### Reports

| Runner | Path | Style |
| --- | --- | --- |
| claude/opus | [`report.md`](./claude/opus/run-002/report.md) | Structured with analytical notes on route repetition and 8-hop ceiling |
| codex/gpt-5.4 | [`report.md`](./codex/gpt-5.4/run-001/report.md) | Table-centric with inline interpretation guidance |
| gemini/gemini-3.1-pro-preview | [`report.md`](./gemini/gemini-3.1-pro-preview/run-001/report.md) | Concise overview with detailed itinerary table |

All three reports correctly highlight:
- Maximum hop count of 8
- Southwest (WN) dominance in high-hop operations
- Route repetition patterns (e.g., WN 3149 CLE→DEN route appearing multiple times)

### Visuals

| Runner | Path | Approach |
| --- | --- | --- |
| claude/opus | [`visual.html`](./claude/opus/run-002/visual.html) | Leaflet map + KPI strip + route table + query ledger (~825 lines) |
| codex/gpt-5.4 | [`visual.html`](./codex/gpt-5.4/run-001/visual.html) | Leaflet map + narrative cards + route sequence table + comparison grid + query ledger (~1357 lines) |
| gemini/gemini-3.1-pro-preview | [`visual.html`](./gemini/gemini-3.1-pro-preview/run-001/visual.html) | Leaflet map + KPI cards + results table + route sequences (~565 lines) |

All three dashboards:
- Fetch data dynamically via MCP OpenAPI with JWE token authentication
- Enrich airport coordinates from `default.airports_bts`
- Render lead itinerary on a Leaflet map
- Include a query ledger tracking primary and enrichment queries
- Degrade gracefully when coordinate enrichment fails

**Visual complexity:** Codex produced the most elaborate dashboard with narrative analysis cards and segment-repetition highlighting. Claude's dashboard is moderately detailed. Gemini's is the most compact.

## Execution stats

| Metric | Claude | Codex | Gemini |
| --- | --- | --- | --- |
| Query duration | 7.48 s | 7.65 s | 7.57 s |
| Read rows | 193,061,941 | 193,061,941 | 230,307,587 |
| Read bytes | 2.65 GB | 2.65 GB | 2.88 GB |
| Memory usage | 45.4 GiB | 48.8 GiB | 44.5 GiB |
| Peak threads | 34 | 34 | 34 |

The ~2% query duration spread across all three is within noise. Gemini's 19% higher read volume did not translate to meaningfully slower execution due to sufficient parallelism.

## Takeaway

All three models produced **semantically identical results** for this aggregation-heavy, sequence-reconstruction query. The same 10 aircraft-flight-date combinations with 8-hop itineraries appear in each output.

**Differences are cosmetic:**
- Column naming and aliasing conventions
- Route string formatting (time format, delimiter style)
- Codex omitted the explicit `Hops` column while Claude and Gemini included it

**Performance is nearly equivalent**, with Gemini reading ~19% more rows due to a less efficient string-cast predicate but achieving comparable execution time.

**Presentation quality varies** by verbosity: Codex generated the most feature-rich dashboard, Claude provided a balanced mid-complexity view, and Gemini delivered a compact implementation. All three correctly visualize the lead itinerary and degrade gracefully without coordinates.

For this question, model choice has no impact on answer correctness. Selection could reasonably favor Claude/Codex for marginally lower read volume or Gemini for lowest memory footprint.
