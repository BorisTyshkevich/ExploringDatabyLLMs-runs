# q001 Experiment Note

## Question

**q001 -- Highest daily hops for one aircraft on one flight number**

Find the top 10 cases where a single aircraft (tail number) flew the most legs in one day under the same flight number. Return the aircraft ID, flight number, carrier, date, reconstructed route, and hop count.

## Why this question is useful

This question stress-tests an LLM's ability to aggregate multi-leg flight segments into ordered itineraries. It requires grouping by (tail number, flight number, date), sorting legs chronologically by departure time, concatenating airport codes into a readable route string, and ranking the results by hop count and recency. The route-construction step is especially revealing -- it forces the model to choose between `groupArray` with sorting versus self-joins, and to correctly include both origin and destination airports without duplication.

## Experiment setup

- **Date**: 2026-03-23
- **Dataset**: Altinity OnTime (`ontime.fact_ontime`, ClickHouse)
- **Prompt**: [report_prompt.md](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/report_prompt.md)
- **Visual prompt**: [visual_prompt.md](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/visual_prompt.md)
- **Compare contract**: [compare.yaml](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/compare.yaml)
- **Runners**: claude/opus (run-001), claude/sonnet (run-001), codex/gpt-5.4 (run-001)

## Result summary

All three runs succeeded and returned **the same 10 rows** with identical values for Aircraft ID, Flight Number, Carrier, Date, and hop_count. Every row is a Southwest Airlines (WN) flight with 8 hops. The top result in all runs is N957WN / WN 366 on 2024-12-01 with the route ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA.

The **only difference** across the three result sets is the route-string delimiter:

| Run | Route delimiter | Example |
|---|---|---|
| claude/opus | hyphen (`-`) | `ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA` |
| claude/sonnet | spaced arrow (` -> `) | `ISP -> BWI -> MYR -> BNA -> VPS -> DAL -> LAS -> OAK -> SEA` |
| codex/gpt-5.4 | compact arrow (`->`) | `ISP->BWI->MYR->BNA->VPS->DAL->LAS->OAK->SEA` |

The underlying airport sequences are identical in all 10 rows across all three runs.

## Full SQL artifacts

### claude / opus
- **run-001**: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/opus/run-001/query.sql) | [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/opus/run-001/result.json)

### claude / sonnet
- **run-001**: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/query.sql) | [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/result.json)

### codex / gpt-5.4
- **run-001**: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql) | [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/result.json)

## Real output differences

The 10 result rows are **data-identical** across all three runs. Every row matches on Aircraft ID, Flight Number, Carrier, Date, and hop_count. The only difference is in the `Route` string formatting:

| Row | Opus Route (excerpt) | Sonnet Route (excerpt) | GPT-5.4 Route (excerpt) |
| --- | --- | --- | --- |
| 1 | `ISP-BWI-MYR-...` | `ISP -> BWI -> MYR -> ...` | `ISP->BWI->MYR->...` |

This is a cosmetic delimiter difference. The airport sequences themselves are identical in every row. No differences exist in any other column.

## SQL comparison

All three queries use a CTE-based approach with `groupArray` to collect legs, sort them chronologically, and reconstruct the route string. Key structural differences:

| Aspect | claude/opus | claude/sonnet | codex/gpt-5.4 |
|---|---|---|---|
| CTEs | 2 (`legs`, `grouped`) | 1 (`sorted`) | 2 (`leg_rows`, `itineraries`) |
| Column names used | `Tail_Number`, `Flight_Number_Reporting_Airline`, `IATA_CODE_Reporting_Airline` | same as opus | `TailNum`, `FlightNum`, `Carrier` |
| Cancel/divert filter | `Cancelled = 0` | `Cancelled = 0` | `Cancelled = 0 AND Diverted = 0` |
| Empty-tail filter | `Tail_Number != ''` and `Flight_Number_Reporting_Airline != ''` | `Tail_Number != ''` | `TailNum != ''` and `FlightNum != ''` |
| Dep-time sort key | `assumeNotNull(CRSDepTime)` | `assumeNotNull(CRSDepTime)` | `ifNull(DepTime, CRSDepTime)` converted to DateTime |
| HAVING threshold | `hop_count >= 2` | none (implicit via ranking) | `length(ordered_legs) > 1` |
| Route construction | `arrayPushBack` origin array + last dest, hyphen join | `arrayConcat([first origin], dest array)`, spaced arrow join | `arrayStringConcat` origins + `concat` last dest, compact arrow join |
| ORDER BY tiebreakers | `hop_count DESC, FlightDate DESC` | `hop_count DESC, FlightDate DESC` | `hop_count DESC, Date DESC, Aircraft ID, Flight Number` |

Despite these differences in filtering, column aliases, and sort tiebreakers, all three queries arrive at the same top-10 result set because the highest-hop rows (8 hops each) are unambiguous regardless of whether diverted flights or single-hop entries are included. GPT-5.4's query is the most defensive (excludes diverted flights, requires non-empty FlightNum) but reads ~22% more bytes (3.23 GB vs 2.65 GB) due to its additional `DepTime` column access.

## Presentation artifacts

### claude / opus
- **run-001**:
  - [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fclaude%2Fopus%2Frun-001%2Freport.md) -- Flat table with a one-paragraph analytical note about Southwest's point-to-point model.
  - [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/claude/opus/run-001/visual.html) -- Leaflet map dashboard with serif/sans-serif design system and KPI strip.

### claude / sonnet
- **run-001**:
  - [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fclaude%2Fsonnet%2Frun-001%2Freport.md) -- Includes a titled "Top 10 Longest Itineraries" section with a full Markdown table and an analytical takeaway paragraph discussing hub-and-spoke routing strategies.
  - [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/claude/sonnet/run-001/visual.html) -- Leaflet map dashboard with sky-colored header border accent.

### codex / gpt-5.4
- **run-001**:
  - [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-23%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-001%2Freport.md) -- Compact table followed by a brief one-sentence takeaway about repeat operating patterns.
  - [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-23/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html) -- Leaflet map dashboard with radial-gradient background and SRI integrity attribute on Leaflet CSS.

All three dashboards follow the shared visual prompt's color palette and layout conventions but differ in header treatment and CSS layering.

## Execution stats

| Provider / Model | Run | Status | Query time | Rows read | Bytes read | Peak memory | SQL gen | Visual gen | Total duration |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| claude / opus | run-001 | ok | 7.54 s | 193,061,941 | 2.65 GB | 42.8 GiB | 87.3 s | 207.7 s | 313 s |
| claude / sonnet | run-001 | ok | 7.42 s | 193,061,941 | 2.65 GB | 42.5 GiB | 96.3 s | 546.8 s | 661 s |
| codex / gpt-5.4 | run-001 | ok | 7.55 s | 193,061,941 | 3.23 GB | 41.3 GiB | 84.2 s | 438.6 s | 541 s |

Query execution times are nearly identical (7.42--7.55 s), confirming the three SQL variants hit the same scan volume. The dominant cost difference is in visual generation: Opus produced its dashboard in 208 s -- 2.6x faster than GPT-5.4 (439 s) and 2.6x faster than Sonnet (547 s) -- driving Opus to the shortest total wall-clock time at 313 s. GPT-5.4 read 22% more bytes (3.23 GB vs 2.65 GB) due to its additional `DepTime` column access, though this did not measurably affect query latency.

## Takeaway

All three models correctly solved this multi-leg itinerary reconstruction problem and returned identical top-10 rows. The only output difference is a cosmetic route-separator character. SQL approaches diverged in CTE structure, column-name conventions, and filter strictness (GPT-5.4 additionally excludes diverted flights), but these differences did not change the result. Opus delivered the fastest end-to-end run at 313 s, driven primarily by its 2.6x visual-generation speed advantage over the other two models.
