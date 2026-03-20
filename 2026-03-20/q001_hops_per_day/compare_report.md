# q001 Experiment Note

## Question

`q001` asks for the highest number of same-day hops flown by a single aircraft on a single flight number, with the result ordered to show the top 10 longest and most recent itineraries. The prompt requires the route to preserve chronological leg order and to include the final destination airport.

## Why this question is useful

This is a good benchmark for itinerary reconstruction rather than simple aggregation. A correct answer has to group by aircraft, flight number, carrier, and date, then rebuild each day’s leg sequence in departure order and emit a route string whose airport count matches the hop count.

## Experiment setup

I verified the local structured comparison artifact `compare.json`, the question prompt and compare contract, and all three local run artifacts (`query.sql`, `result.json`, `report.md`, `visual.html`) for:
- claude / opus / run-001
- claude / sonnet / run-001
- codex / gpt-5.4 / run-001

The compare contract keys on aircraft, flight number, carrier, and date, and compares `Hops` plus `Route` exactly after header alias normalization. `compare.json` reports 10 rows for every run and marks `codex/gpt-5.4/run-001` as `partial` because `presentation_render` failed. No verified `system.query_log` metrics were available for any run because all three runs hit the same privilege error.

## Result summary

All three runs returned the same 10 itineraries on the compare-contract fields after alias normalization. Every row has `Hops = 8`, all rows are for carrier `WN`, and the top 10 collapse into four route patterns: one route appears 4 times, one appears 3 times, one appears 2 times, and one appears once.

The most recent maximum-hop itinerary is the same in every run: aircraft `N957WN`, flight `366`, carrier `WN`, date `2024-12-01`, route `ISP ... SEA`, with 8 hops.

## Full SQL artifacts

### claude / opus
- `run-001`: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/opus/run-001/query.sql), [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/opus/run-001/result.json)

### claude / sonnet
- `run-001`: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/query.sql), [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/result.json)

### codex / gpt-5.4
- `run-001`: [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql), [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/result.json)

## Real output differences

There is no real difference in the returned top-10 itinerary set on the compare-contract columns. I verified that all 10 normalized keys match across runs and that the route airport sequences are identical row by row.

The differences are presentation-level:
- `Route` formatting differs only by separator: opus uses hyphens, sonnet uses `→`, codex uses `->`.
- Departure timelines encode the same leg chronology differently: opus shows times only, sonnet shows `HHMM (Origin)`, codex shows `HH:MM Origin` separated by `|`.
- codex adds four extra analytical columns not present in the other result sets: `Max Hops Overall`, `Max Hop Itinerary Count`, `Same-Hops Route Count`, and `Route Frequency In Top 10`.

## SQL comparison

All three queries solve the same core task but with different SQL shapes:
- Opus uses three CTEs (`legs`, `counts`, `top_legs`), limits to the top 10 grouped itineraries first, then rebuilds routes from the selected legs. It filters `Cancelled = 0`, `DepTime IS NOT NULL`, and non-empty tail numbers.
- Sonnet uses one aggregation CTE (`leg_data`) with `groupArray` plus `arraySort`, and falls back from `DepTime` to `CRSDepTime` via `coalesce`. It formats the route with arrows and includes origin airport codes inside the departure string.
- Codex uses five CTEs (`legs`, `itineraries`, `max_hops`, `scored`, `top10`), converts `DepTime` into a sortable timestamp, filters `Diverted = 0` in addition to `Cancelled = 0`, and computes the extra repetition metrics returned in the final schema.

Despite those SQL-shape differences, the three queries converge to the same top-10 itineraries.

## Presentation artifacts

### claude / opus
- `run-001`: [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fclaude%2Fopus%2Frun-001%2Freport.md) gives a direct narrative answer: max hops = 8, the latest itinerary is `WN 366` on `2024-12-01`, and the repeated-route pattern is summarized explicitly.
- `run-001`: [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/claude/opus/run-001/visual.html) is a token-gated dashboard with KPI cards, a route map, route-detail panel, top-10 table, query ledger, and CSV export.

### claude / sonnet
- `run-001`: [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fclaude%2Fsonnet%2Frun-001%2Freport.md) also answers the report prompt directly, with the clearest route formatting in the narrative and table.
- `run-001`: [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/visual.html) is another token-gated dashboard, similar in structure to opus but with slightly richer route-detail styling and a dedicated “Route Repeats in Top 10” KPI.

### codex / gpt-5.4
- `run-001`: [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-001%2Freport.md) mostly republishes the result table and explains how to interpret the derived columns, but it is less directly written as a narrative answer to the report prompt.
- `run-001`: [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html) is the most elaborate UI of the three, adding a hero section, filter controls, repetition context, and richer selected-row detail; however, `compare.json` still marks this run `partial` because `presentation_render` failed.

## Execution stats

### claude / opus
- `run-001`: status `ok`; 10 rows returned; warning only: query-log metrics could not be fetched because `system.query_log` access was denied.

### claude / sonnet
- `run-001`: status `ok`; 10 rows returned; warning only: query-log metrics could not be fetched because `system.query_log` access was denied.

### codex / gpt-5.4
- `run-001`: status `partial`; 10 rows returned; `sql_generation`, `sql_execution`, and `presentation_generation` were `ok`, but `presentation_render` failed; query-log metrics were also unavailable because `system.query_log` access was denied.

## Takeaway

For `q001`, the benchmark result is stable across all three runs: the same 10 itineraries, the same maximum of 8 hops, and the same repeated Southwest route patterns. The meaningful differences here are not data correctness but packaging: SQL structure, schema verbosity, report quality, and the fact that the codex run produced the richest saved artifacts while still failing the render phase recorded in `compare.json`.
