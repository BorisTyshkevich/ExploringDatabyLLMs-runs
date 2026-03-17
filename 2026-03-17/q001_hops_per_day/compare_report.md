# q001 Experiment Note

## Question

This benchmark asks models to find the top 10 most recent cases where a single aircraft flew the same flight number for the highest number of same-day legs, with routes built in chronological order from actual departure times. The SQL prompt is [prompt.md](https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/prompt.md), the report prompt is [report_prompt.md](https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/report_prompt.md), the visual prompt is [visual_prompt.md](https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/visual_prompt.md), and the compare contract is [compare.yaml](https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/compare.yaml).

## Why this question is useful

This is a good benchmark because it tests more than ranking. The prompt requires chronological itinerary construction, inclusion of the final destination, and consistency between hop count and route length. That makes it easy to detect when a model finds the right records but returns the wrong shape or an incomplete route string.

## Experiment setup

Day: `2026-03-17`.

Runs compared:

- [claude/opus/run-003/query.sql](claude/opus/run-003/query.sql), [claude/opus/run-003/report.md](claude/opus/run-003/report.md), [claude/opus/run-003/visual.html](claude/opus/run-003/visual.html), [claude/opus/run-003/result.json](claude/opus/run-003/result.json)
- [codex/gpt-5.4/run-003/query.sql](codex/gpt-5.4/run-003/query.sql), [codex/gpt-5.4/run-003/report.md](codex/gpt-5.4/run-003/report.md), [codex/gpt-5.4/run-003/visual.html](codex/gpt-5.4/run-003/visual.html), [codex/gpt-5.4/run-003/result.json](codex/gpt-5.4/run-003/result.json)
- [gemini/gemini-3.1-pro-preview/run-003/query.sql](gemini/gemini-3.1-pro-preview/run-003/query.sql), [gemini/gemini-3.1-pro-preview/run-003/report.md](gemini/gemini-3.1-pro-preview/run-003/report.md), [gemini/gemini-3.1-pro-preview/run-003/visual.html](gemini/gemini-3.1-pro-preview/run-003/visual.html), [gemini/gemini-3.1-pro-preview/run-003/result.json](gemini/gemini-3.1-pro-preview/run-003/result.json)

Structured compare source: [compare/compare.json](compare/compare.json).

## Result summary

All three runs returned 10 rows. The 10 key rows are the same across all runs: the same `(Aircraft ID, Flight Number, Carrier, Date)` combinations appear in the same order.

The returned itineraries also point to the same four airport sequences, repeated with the same frequencies in the top 10:

- `CLE-BNA-PNS-HOU-MCI-PHX-BUR-OAK-DEN`: 4 rows
- `MSY-ATL-CMH-BWI-RDU-BNA-DTW-MDW-LAX`: 3 rows
- `ELP-DAL-LIT-ATL-RIC-MDW-MCI-PHX-SAN`: 2 rows
- `ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA`: 1 row

Gemini did not finish cleanly: [compare/compare.json](compare/compare.json) marks the run `partial` with `presentation_render: failed`.

## Full SQL artifacts

- Claude SQL: [claude/opus/run-003/query.sql](claude/opus/run-003/query.sql)
- Codex SQL: [codex/gpt-5.4/run-003/query.sql](codex/gpt-5.4/run-003/query.sql)
- Gemini SQL: [gemini/gemini-3.1-pro-preview/run-003/query.sql](gemini/gemini-3.1-pro-preview/run-003/query.sql)

## Real output differences

The outputs are not identical.

- Claude returns the six-column shape `Aircraft ID, Flight Number, Carrier, Date, Hops, Route` in [claude/opus/run-003/result.json](claude/opus/run-003/result.json). Every row has `Hops = 8`, and `Route` includes departure times plus the final destination.
- Codex returns only five columns in [codex/gpt-5.4/run-003/result.json](codex/gpt-5.4/run-003/result.json): it omits `Hops`. Its `Route` is still time-stamped, but serialized as `HH:MM ORG->DST | ...` rather than the arrow-chain required by the prompt and used by Claude.
- Gemini returns six columns in [gemini/gemini-3.1-pro-preview/run-003/result.json](gemini/gemini-3.1-pro-preview/run-003/result.json), but the sixth column is `Actual Departure Times`, not `Hops`. Its `Route` is reduced to airport codes only, for example `ISP-BWI-MYR-BNA-VPS-DAL-LAS-OAK-SEA`, with the times split into a separate array.

So the main differences are localized and concrete: the row identities match, but `Hops` is missing from Codex and Gemini, and `Route` is serialized differently in all three runs.

## SQL comparison

The SQL shape differences explain the output differences.

- Claude explicitly computes `count() AS Hops`, keeps only grouped rows with `HAVING Hops >= 2`, and builds `Route` from sorted `(DepTime, Origin, Dest)` tuples in [claude/opus/run-003/query.sql](claude/opus/run-003/query.sql).
- Codex orders groups by `count() DESC` but does not project that count as `Hops`; it builds each route leg as `HH:MM ORG->DST` and concatenates legs with ` | ` in [codex/gpt-5.4/run-003/query.sql](codex/gpt-5.4/run-003/query.sql).
- Gemini also orders by `count() DESC` without returning `Hops`; it builds a hyphen-joined airport chain and separately returns `arraySort(groupArray(DepTime)) AS Actual Departure Times` in [gemini/gemini-3.1-pro-preview/run-003/query.sql](gemini/gemini-3.1-pro-preview/run-003/query.sql).

Against the compare contract in [compare.yaml](https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/compare.yaml), Claude is the only run that actually returns both exact-compare columns, `Hops` and `Route`, in the expected shape.

## Presentation artifacts

The report outputs track the result shapes closely.

- Claude’s [claude/opus/run-003/report.md](claude/opus/run-003/report.md) presents the full six-column table including `Hops`.
- Codex’s [codex/gpt-5.4/run-003/report.md](codex/gpt-5.4/run-003/report.md) omits `Hops`, mirroring its result set.
- Gemini’s [gemini/gemini-3.1-pro-preview/run-003/report.md](gemini/gemini-3.1-pro-preview/run-003/report.md) includes `Actual Departure Times` instead of `Hops`, again mirroring its result set.

All three HTML artifacts load Leaflet and include a route/map-oriented presentation: [claude/opus/run-003/visual.html](claude/opus/run-003/visual.html), [codex/gpt-5.4/run-003/visual.html](codex/gpt-5.4/run-003/visual.html), and [gemini/gemini-3.1-pro-preview/run-003/visual.html](gemini/gemini-3.1-pro-preview/run-003/visual.html). Claude’s page is aligned with the saved SQL output and shows `Hops` directly. Codex’s page includes a `Hops` column in the visual table and derives hop count in JavaScript from the parsed `Route` string rather than from the SQL result. Gemini’s page is built around the airport-chain route plus `Actual Departure Times`; despite the file existing, [compare/compare.json](compare/compare.json) records its presentation render phase as failed.

## Execution stats

Verified query-log metrics from [compare/compare.json](compare/compare.json):

- Claude: `18.63 s`, `193,061,941` read rows, `35.1 GiB` peak memory
- Codex: `7.88 s`, `193,061,941` read rows, `45.3 GiB` peak memory
- Gemini: `15.53 s`, `230,307,587` read rows, `48.9 GiB` peak memory

Codex was the fastest successful run, `10.75 s` faster than Claude, with the same read-row volume. Claude used the least memory, `10.2 GiB` less than Codex and `13.8 GiB` less than Gemini. Gemini read `37,245,646` more rows than Claude and Codex, about `19.3%` more.

## Takeaway

This question separated row selection from output fidelity. All three runs found the same top 10 keys and the same repeated airport sequences, so the ranking logic broadly converged. The divergence is in answer shape: Claude returned the prompt-aligned `Hops` plus full chronological route string, while Codex and Gemini dropped `Hops` and reformatted `Route` into different representations. For this benchmark day, Codex won on speed, Claude was the only run that matched the compare contract’s expected output columns, and Gemini remained only partially successful because its presentation render did not finish cleanly.
