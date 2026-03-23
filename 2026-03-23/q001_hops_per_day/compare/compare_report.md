# q001 Experiment Note

## Question

**q001 — Highest daily hops for one aircraft on one flight number**

Find routes with the highest number of hops per day for a single aircraft using the same flight number. Return the top 10 longest and most recent itineraries with Aircraft ID, Flight Number, Carrier, Date, Route (arrow-delimited), and hop_count.

## Why this question is useful

This question stress-tests an LLM's ability to aggregate multi-leg flight segments into ordered itineraries. It requires grouping by (tail number, flight number, date), sorting legs chronologically by departure time, concatenating airport codes into a readable route string, and ranking the results by hop count and recency. The route-construction step is especially revealing — it forces the model to choose between `groupArray` with sorting versus self-joins, and to correctly include both origin and destination airports without duplication.

## Experiment setup

- **Date**: 2026-03-23
- **Dataset**: Altinity OnTime (ClickHouse)
- **Prompt**: [report_prompt.md](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/report_prompt.md)
- **Visual prompt**: [visual_prompt.md](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/visual_prompt.md)
- **Compare contract**: [compare.yaml](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/compare.yaml)
- **Runners**: claude/sonnet (run-001), codex/gpt-5.4 (run-001)

## Result summary

Both runs succeeded, returned 10 rows each, and produced **identical data rows** — the same 10 aircraft/flight-number/date combinations, all with `hop_count = 8`, all Southwest (WN), in the same order. The only difference in the result data is cosmetic: the Route column delimiter. Claude uses ` → ` (spaces around the arrow) while Codex uses `→` (no spaces).

## Full SQL artifacts

### claude / sonnet

- **run-001**: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/query.sql)

### codex / gpt-5.4

- **run-001**: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql)

## Real output differences

The 10 result rows are **data-identical** across both runs. Every row matches on Aircraft ID, Flight Number, Carrier, Date, and hop_count. The only difference is in the `Route` string formatting:

| Row | Claude Route (excerpt) | Codex Route (excerpt) |
| --- | --- | --- |
| 1 | `ISP → BWI → MYR → …` | `ISP→BWI→MYR→…` |

This is a cosmetic delimiter-spacing difference (`' → '` vs `'→'`). Both are valid given the prompt rule requiring `→` as the delimiter. The airport sequences themselves are identical in every row.

No differences exist in any other column.

## SQL comparison

Both queries use a CTE-based approach with `groupArray` to collect legs, sort them chronologically, and reconstruct the route string. Key structural differences:

| Aspect | Claude / sonnet | Codex / gpt-5.4 |
| --- | --- | --- |
| Column names used | `Tail_Number`, `Flight_Number_Reporting_Airline`, `IATA_CODE_Reporting_Airline` | `TailNum`, `FlightNum`, `Carrier` |
| Departure-time source | `CRSDepTime` (scheduled) via `assumeNotNull()` | `ifNull(DepTime, CRSDepTime)` (actual, falling back to scheduled) |
| Cancelled filter | `Cancelled = 0` | `Cancelled = 0` AND `Diverted = 0` |
| Empty-tail filter | `Tail_Number != ''` | `TailNum != ''` AND `FlightNum != ''` AND dep-time IS NOT NULL |
| HAVING clause | none (includes single-leg entries, filtered by ORDER+LIMIT) | `HAVING length(ordered_legs) > 1` (excludes single-hop rows) |
| Route delimiter | `' → '` (spaced) | `'→'` (compact) |
| ORDER BY tiebreak | `hop_count DESC, FlightDate DESC` | `hop_count DESC, Date DESC, Aircraft ID, Flight Number` |

Despite these differences in filtering, column aliases, and sort tiebreakers, both queries arrive at the same top-10 result set because the highest-hop rows (8 hops each) are identical regardless of whether diverted flights or single-hop entries are included. Codex's query is slightly more defensive (excludes diverted flights, requires non-empty FlightNum) but reads ~22% more bytes (3.23 GB vs 2.65 GB), likely due to the extra `DepTime` column access.

## Presentation artifacts

### claude / sonnet

- **run-001**:
  - [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fclaude%2Fsonnet%2Frun-001%2Freport.md) — Includes a titled section "Top 10 Longest Itineraries" with a full Markdown table and an analytical takeaway paragraph discussing hub-and-spoke routing strategies.
  - [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/visual.html) — 1,265 lines; includes Leaflet map integration, KPI strip, and styled header with serif title font.

### codex / gpt-5.4

- **run-001**:
  - [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-001%2Freport.md) — More compact; presents the same data table without a section heading, followed by a brief one-sentence takeaway.
  - [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html) — 1,558 lines; also uses Leaflet and the shared dashboard palette but with a radial-gradient hero section and SRI integrity attribute on the Leaflet CSS.

Both dashboards follow the shared visual prompt's color palette and layout conventions. Claude's is more concise in HTML; Codex's is longer with more decorative CSS layering.

## Execution stats

| Provider / Model | Run | Status | Query time | Rows read | Bytes read | Peak memory | SQL gen | Visual gen | Total duration |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| claude / sonnet | run-001 | ok | 7.42 s | 193,061,941 | 2.65 GB | 42.5 GiB | 96.3 s | 546.8 s | 661 s |
| codex / gpt-5.4 | run-001 | ok | 7.55 s | 193,061,941 | 3.23 GB | 41.3 GiB | 84.2 s | 438.6 s | 541 s |

Query execution is nearly identical (7.42 s vs 7.55 s, both scanning 193 M rows). Codex read 22% more bytes (3.23 GB vs 2.65 GB) — consistent with its extra `DepTime` column access — but used slightly less peak memory (41.3 vs 42.5 GiB). Codex was faster overall (541 s vs 661 s), driven primarily by faster visual generation (438.6 s vs 546.8 s).

## Takeaway

Both models correctly solved this multi-leg itinerary reconstruction problem and returned identical top-10 rows. The only output difference is cosmetic arrow spacing in the Route string. The SQL strategies diverge in defensiveness (Codex adds diverted-flight and empty-field guards, Claude keeps it simpler) but converge on the same answer. Performance is close; Codex finished the full pipeline ~2 minutes faster, mostly due to quicker visual generation, while Claude's query was marginally more I/O-efficient.
