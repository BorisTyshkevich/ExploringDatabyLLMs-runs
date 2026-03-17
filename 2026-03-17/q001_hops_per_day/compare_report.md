# q001 Experiment Note

## Question

`q001_hops_per_day` asks for the top 10 most recent cases where one aircraft flew the same flight number across the most legs in one day, reporting `Aircraft ID`, `Flight Number`, `Carrier`, `Date`, and `Route`, and showing the actual departure time from each origin. The prompt is in [prompt.md](/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/prompt.md), and the compare contract is in [compare.yaml](/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/compare.yaml).

## Why this question is useful

This benchmark is useful because it tests several failure-prone behaviors at once: reconstructing a multi-leg itinerary in chronological order, preserving the final destination in the route string, surfacing hop count correctly, and keeping ties ordered by recency. It also exposes whether a model returns the requested schema versus only a semantically similar variant.

## Experiment setup

This note is based on verified local artifacts only: the structured compare file [compare.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json), the three saved SQL files, the three `result.json` outputs, and the paired [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md), [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md), [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/report.md) and [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html), [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/visual.html) artifacts under the 2026-03-17 run directories.

## Result summary

All three runs returned 10 rows, and the ranked top-10 key set is identical across Claude, Codex, and Gemini when keyed by `Aircraft ID`, `Flight Number`, `Carrier`, and `Date` from their respective [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/result.json), [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/result.json), and [result.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/result.json).

The lead itinerary is the same in all three outputs: aircraft `N957WN`, flight `366`, carrier `WN`, date `2024-12-01`, with an 8-leg path from `ISP` to `SEA`. Claude is the only run that returns `Hops` explicitly for every row.

## Full SQL artifacts

- Claude: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql)
- Codex: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql)
- Gemini: [query.sql](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/query.sql)

## Real output differences

The substantive rows do not differ. After normalizing each `Route` string to just airport sequence, all 10 rows match across all three `result.json` files, row for row.

The differences are localized to representation and schema:

- Claude returns the requested `Hops` column and a fully formatted route string with times and airport sequence.
- Codex omits `Hops` from the saved result schema, but each returned route still encodes 8 segments in `HH:MM ORG->DEST | ...` form.
- Gemini omits `Hops`, compresses `Route` to airport codes only, and adds `Actual Departure Times` as a separate integer array.

So the top-10 itineraries are the same, but the returned columns and route formatting are not.

## SQL comparison

Claude’s SQL uses two CTEs, computes `count() AS Hops`, sorts grouped legs with `arraySort`, and builds a single route string that ends with the final destination. Codex aggregates directly over `ontime_v2`, builds sortable timestamps from `FlightDate` and `DepTime`, formats each leg as `Origin->Dest`, and relies on `count() DESC` in `ORDER BY` instead of selecting `Hops`. Gemini also aggregates directly, builds route text from origins plus `argMax(Dest, DepTime)`, returns `Actual Departure Times`, and orders by `count() DESC` without projecting hop count.

Filter choices also differ in the verified SQL:
- Claude filters `Cancelled = 0`, `DepTime IS NOT NULL`, and nonblank tail number.
- Codex adds `Diverted = 0` and requires a nonblank flight number.
- Gemini does not filter `Cancelled` or `Diverted` in the saved SQL.

## Presentation artifacts

Claude’s [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md) and [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html) present the same six-column schema as its result, including `Hops`. Codex’s [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md) and [visual.html](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html) consistently use the route-string representation and derive hop-related UI from parsed route legs in JavaScript. Gemini’s [report.md](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/report.md) reflects its extra `Actual Departure Times` field, but the run is marked partial in [manifest.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-003/manifest.json) because `presentation_render` failed with metadata `visual_validation_errors: missing footer control block`.

## Execution stats

From [compare.json](/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json):

- Codex was the fastest successful run at 7.885 s query time.
- Claude and Codex read the same 193,061,941 rows; Gemini read 230,307,587 rows.
- Claude used the least memory at 37,714,822,183 bytes (about 35.1 GiB in the deterministic summary).
- Codex used 48,655,491,312 bytes.
- Gemini used 52,466,696,434 bytes and was the only partial run.

## Takeaway

For this question, the three models converged on the same 10 underlying itineraries, including the same lead case and the same airport sequence for every row. The real differences are not in which itineraries were found, but in contract compliance and presentation: Claude is the only run that cleanly returns explicit `Hops`, Codex is materially faster but encodes hop count only indirectly in the route string, and Gemini returns the same itineraries in a different schema and does not finish presentation rendering cleanly.
