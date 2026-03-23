Now I have all the data. Here is the report:

```markdown
# q001 Experiment Note

## Question

**q001 — Highest daily hops for one aircraft on one flight number**

Find the top 10 cases where a single aircraft (tail number) operated the most legs in one day under a single flight number. Return the aircraft ID, flight number, carrier, date, reconstructed route, and hop count.

## Why this question is useful

This question stress-tests an LLM's ability to (1) group flight legs by a composite key (tail + flight number + date), (2) order legs chronologically within each group, (3) reconstruct a human-readable route string from origin/destination arrays, and (4) rank by an aggregate. It exercises array manipulation, tuple sorting, and string concatenation — ClickHouse idioms that are easy to get subtly wrong.

## Experiment setup

- **Dataset:** Altinity OnTime (ClickHouse `ontime.fact_ontime`, ~193 M rows)
- **Day:** 2026-03-23
- **Runners / models:**
  - `claude/opus` (run-001)
  - `claude/sonnet` (run-001)
  - `codex/gpt-5.4` (run-001)
- Each runner independently generated SQL from the same prompt, executed it against the same ClickHouse instance, and then generated a Markdown report and an interactive HTML dashboard.

## Result summary

All three runs succeeded and returned **identical data**: 10 rows, all Southwest Airlines (WN), each with a hop count of 8. The same aircraft IDs, flight numbers, dates, and airport sequences appear in every result. The only cosmetic difference is the **Route separator**: the two Claude runs use ` → ` (space-arrow-space), while codex/gpt-5.4 uses `→` (no spaces).

## Full SQL artifacts

### claude / opus
- **run-001:** [`query.sql`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/opus/run-001/query.sql) · [`result.json`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/opus/run-001/result.json)

### claude / sonnet
- **run-001:** [`query.sql`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/query.sql) · [`result.json`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/result.json)

### codex / gpt-5.4
- **run-001:** [`query.sql`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql) · [`result.json`](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/result.json)

## Real output differences

The data rows are **identical** across all three runs in every column except `Route` formatting:

| Row | claude/opus & claude/sonnet Route | codex/gpt-5.4 Route |
| --- | --- | --- |
| 1 | ISP → BWI → MYR → BNA → VPS → DAL → LAS → OAK → SEA | ISP→BWI→MYR→BNA→VPS→DAL→LAS→OAK→SEA |
| (all) | spaces around `→` | no spaces around `→` |

This is purely a formatting choice in the `arrayStringConcat` separator argument (`' → '` vs. building the string with `concat` and `'→'`). All 10 Aircraft IDs, Flight Numbers, Carriers, Dates, airport sequences, and hop counts match exactly.

## SQL comparison

All three queries follow the same high-level pattern: filter to non-cancelled flights with a valid tail number, group by (tail, flight number, carrier, date), sort legs chronologically, reconstruct the route, and rank by hop count descending. Key structural differences:

| Aspect | claude/opus | claude/sonnet | codex/gpt-5.4 |
| --- | --- | --- | --- |
| CTE count | 2 (`legs`, `grouped`) | 1 (`sorted`) | 2 (`leg_rows`, `itineraries`) |
| Column names used | `Tail_Number`, `Flight_Number_Reporting_Airline` | same | `TailNum`, `FlightNum`, `Carrier` (short aliases) |
| Cancelled filter | `Cancelled = 0` | `Cancelled = 0` | `Cancelled = 0 AND Diverted = 0` |
| CRSDepTime null guard | `CRSDepTime IS NOT NULL` in WHERE + `assumeNotNull()` | implicit via `assumeNotNull()` in `groupArray(tuple(...))` | `ifNull(DepTime, CRSDepTime)` — prefers actual over scheduled |
| Leg sorting | `arraySort` with two parallel `groupArray` calls | `groupArray(tuple(...))` sorted by tuple element | `groupArray(tuple(...))` sorted by computed `dep_ts` |
| Route construction | `arrayStringConcat(arrayPushBack(sorted_origins, sorted_dests[hop_count]), ' → ')` | `arrayStringConcat(arrayConcat([legs[1].1], arrayMap(t -> t.2, legs)), ' → ')` | `concat(arrayStringConcat(arrayMap(…), '→'), '→', last_dest)` |
| HAVING clause | `hop_count >= 2` | none (top-10 naturally filters) | `length(ordered_legs) > 1` |
| Secondary sort | `FlightDate DESC` | `FlightDate DESC` | `Date DESC, Aircraft ID, Flight Number` (additional tiebreakers) |

Despite these structural differences, all three queries scan the same 193 M rows and produce the same 10-row result.

## Presentation artifacts

### claude / opus
- **run-001:** [`report.md`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fclaude%2Fopus%2Frun-001%2Freport.md) · [`visual.html`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/claude/opus/run-001/visual.html) (763 lines)
  - Report includes a full data table and a narrative paragraph about Southwest's point-to-point network.
  - Dashboard uses a Leaflet map with the shared design-system palette.

### claude / sonnet
- **run-001:** [`report.md`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fclaude%2Fsonnet%2Frun-001%2Freport.md) · [`visual.html`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/visual.html) (1 265 lines)
  - Report adds an "Analytical Takeaway" section and a "Top 10 Longest Itineraries" sub-heading.
  - Dashboard is the largest of the Claude pair, also Leaflet-based, with a sky-blue accent border on the header.

### codex / gpt-5.4
- **run-001:** [`report.md`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-001%2Freport.md) · [`visual.html`](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html) (1 558 lines)
  - Report is the most concise in narrative, with a one-sentence closing remark.
  - Dashboard is the longest HTML file; uses a radial-gradient background and includes an SRI integrity hash on the Leaflet CSS import.

## Execution stats

| Provider / Model | Run | Status | Query time | Rows read | Bytes read | Peak memory | SQL gen time | Visual gen time | Total duration |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| claude/opus | run-001 | ok | 20.07 s | 193,061,941 | 2.65 GB | 28.1 GiB | 92.10 s | 221.04 s | 351 s |
| claude/sonnet | run-001 | ok | 7.42 s | 193,061,941 | 2.65 GB | 42.5 GiB | 96.34 s | 546.76 s | 661 s |
| codex/gpt-5.4 | run-001 | ok | 7.55 s | 193,061,941 | 3.23 GB | 41.3 GiB | 84.22 s | 438.56 s | 541 s |

The biggest performance spread is in **query execution time**: claude/opus took 20.07 s — roughly 2.7× slower than the other two (~7.4–7.6 s) — while using the least memory (28.1 GiB vs. 41–43 GiB). The opus query's two-CTE design with parallel `groupArray` calls and explicit `HAVING` filter likely changed the ClickHouse execution plan. On the generation side, codex/gpt-5.4 was fastest at SQL generation (84 s), while claude/opus produced the visual dashboard in less than half the time of sonnet (221 s vs. 547 s), giving opus the shortest total wall-clock time at 351 s.

## Takeaway

All three models correctly solved the multi-hop flight-number question, producing identical top-10 rows. The SQL strategies diverged in CTE structure, column aliasing, null handling, and route-string construction, yet converged on the same result — a strong signal that the question is unambiguous enough for reliable cross-model comparison. The only data-level difference is cosmetic (arrow spacing in the Route column). Performance-wise, the trade-off between query speed and memory footprint is notable: opus ran slower but leaner, while sonnet and gpt-5.4 ran faster queries at higher memory cost. For presentation, opus generated the most compact dashboard in the least time; sonnet's was the most elaborate but took the longest to produce.
```
