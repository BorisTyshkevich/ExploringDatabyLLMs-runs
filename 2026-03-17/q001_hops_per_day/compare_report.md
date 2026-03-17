# q001 Experiment Note

## Question

`q001` asks for the highest number of same-flight-number hops completed by a single aircraft in one day, returning the top 10 longest and most recent itineraries with route detail and actual departure ordering, per the benchmark prompt in [prompt.md](/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/prompt.md) and compare contract in [compare.yaml](/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/compare.yaml).

## Why this question is useful

This question stresses whether a system can reconstruct a same-day multi-leg itinerary correctly instead of just counting rows. It combines grouping by aircraft, flight number, carrier, and date with ordered route assembly, and the prompt explicitly requires the route text to preserve full leg order and final destination. That makes it useful for testing both SQL correctness and output-shaping discipline.

## Experiment setup

The primary structured source was [compare.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json). I also verified each run’s SQL, result JSON, report markdown, and visual HTML:

- Claude: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql), [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/result.json), [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html)
- Codex: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql), [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/result.json), [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html)
- Gemini: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/query.sql), [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/result.json), [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/report.md), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/visual.html)

## Result summary

All three runs returned 10 rows, and the 10 `(Aircraft ID, Flight Number, Carrier, Date)` keys match exactly across Claude, Codex, and Gemini. The most recent top itinerary is the same in every run: `N957WN`, flight `366`, carrier `WN`, date `2024-12-01`, with an 8-leg route from `ISP` to `SEA`.

Using the explicit `Hops` column in Claude’s result and the verified leg/departure counts in the other two outputs, the maximum hop count is `8`. The top 10 rows contain 4 distinct route signatures: one appears 4 times (`CLE-BNA-PNS-HOU-MCI-PHX-BUR-OAK-DEN`), one appears 3 times (`MSY-ATL-CMH-BWI-RDU-BNA-DTW-MDW-LAX`), one appears 2 times (`ELP-DAL-LIT-ATL-RIC-MDW-MCI-PHX-SAN`), and one appears once (`ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA`).

## Full SQL artifacts

The full SQL is best read directly in the saved artifacts:

- [Claude SQL](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql)
- [Codex SQL](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql)
- [Gemini SQL](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/query.sql)

## Real output differences

The row identities and route semantics are the same across all three result sets. After normalizing each route string to an airport sequence, every row’s airport path matches exactly across Claude, Codex, and Gemini.

The real differences are in schema and formatting:

- Claude returns the contract-shaped columns `Aircraft ID, Flight Number, Carrier, Date, Hops, Route` in [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/result.json).
- Codex omits `Hops` and formats `Route` as time-stamped leg pairs separated by `|`, for example `05:43 ISP->BWI | ... | 20:41 OAK->SEA`, in [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/result.json).
- Gemini omits `Hops`, shortens `Route` to airport codes only such as `ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA`, and adds `Actual Departure Times` as an array, in [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/result.json).

So the differences are localized to output shape and route-string rendering, not to which 10 itineraries were found.

## SQL comparison

Claude’s SQL uses two CTEs, explicitly computes `count() AS Hops`, sorts grouped legs by `DepTime`, and renders the route as a timestamped airport chain ending with the final destination. It filters `Cancelled = 0`, `DepTime IS NOT NULL`, and nonempty tail number.

Codex’s SQL is a single grouped query with a `WITH groupArray(...) AS legs` expression. It also sorts legs chronologically, but it renders each leg as `HH:MM ORG->DST`, omits `Hops` from the `SELECT`, and adds `Diverted = 0` plus a nonempty flight-number filter.

Gemini’s saved `query.sql` contains two statements: an airport-enrichment lookup against `default.airports_bts`, then the main itinerary query. The main query groups by `Reporting_Airline`, emits airport-only `Route` text plus `Actual Departure Times`, omits both `Hops` and cancellation/diversion filters, and does not include times directly in the route string.

## Presentation artifacts

The markdown reports mirror those result-shape differences:

- [Claude report](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md) includes `Hops` and reproduces the fully formatted route chain.
- [Codex report](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md) drops `Hops` and presents the route as pipe-separated legs.
- [Gemini report](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/report.md) adds `Actual Departure Times` and keeps the route as airport-code chains.

All three [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html), and [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-004/visual.html) contain a Leaflet-based “Lead Itinerary Map” and `default.airports_bts` enrichment logic. The difference is execution status: [compare.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json) marks Claude and Codex as `presentation_render: ok`, but Gemini as `presentation_render: failed`, so Gemini’s HTML artifact exists but its rendered output did not complete cleanly in this run.

## Execution stats

Per verified query-log metrics in [compare.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json):

- Codex was the fastest successful run at `7.88 s`, versus `18.63 s` for Claude and `15.53 s` for Gemini.
- Claude and Codex both read `193,061,941` rows; Gemini read `230,307,587`, which is `37,245,646` more rows, about `19.3%` higher.
- Claude used the least memory at `35.1 GiB`; Codex used `45.3 GiB` (`+10.2 GiB`), and Gemini used `48.9 GiB` (`+13.7 GiB` versus Claude).
- Gemini is the only run with non-clean status: overall `partial`, specifically `presentation_render: failed`.

## Takeaway

For `q001`, the substantive query result is stable across all three systems: same 10 keys, same lead itinerary, same route sequences after normalization, and the same maximum of 8 hops. The benchmark differences on this day are not about which itineraries were discovered; they are about contract adherence and presentation shape. Claude is the only run that returns the requested `Hops` field directly, Codex is the fastest but still omits `Hops`, and Gemini returns the same itinerary set in a different schema while also failing the final presentation render step.
