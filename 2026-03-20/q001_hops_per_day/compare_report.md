# q001 Experiment Note

## Question

**q001 -- Highest daily hops for one aircraft on one flight number**

Find the highest number of hops (legs) a single aircraft flies in one day under the same flight number. Return the top 10 longest and most recent itineraries with Aircraft ID, Flight Number, Carrier, Date, Route (with every airport), and actual departure times in chronological leg order. Explain whether the maximum hop count is a recurring pattern or a one-off, identify the most recent maximum-hop itinerary, and note any route repetition or clustering in the top 10.

([full prompt](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/report_prompt.md) ·
[visual prompt](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/visual_prompt.md) ·
[compare contract](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q001_hops_per_day/compare.yaml))

## Why this question is useful

This question exercises several non-trivial SQL capabilities at once: self-joining or grouping flight legs by (aircraft, flight number, date), ordering legs chronologically, assembling a textual route from array functions, and ranking the results. It tests whether an LLM can reason about the physical meaning of "hop" in an airline context, handle ClickHouse-specific array manipulation (`groupArray`, `arraySort`, `arrayStringConcat`), and produce an output that is both correct and human-readable. The answer also reveals real operational patterns -- Southwest Airlines' distinctive multi-stop through-flights -- making it a good litmus test for domain insight in the generated report.

## Experiment setup

- **Date:** 2026-03-20
- **Dataset:** `ontime.ontime` (Altinity ClickHouse demo)
- **Runners / models (4 runs total):**
  - `claude/opus` -- run-001
  - `claude/sonnet` -- run-001
  - `codex/gpt-5.4` -- run-001, run-002

Each run independently generated SQL from the prompt, executed it against ClickHouse, then generated a Markdown report and an interactive HTML visualization.

## Result summary

**All four runs agree on the core answer:** the maximum daily hop count is **8**, every top-10 entry belongs to **Southwest Airlines (WN)**, and the same 10 (tail number, flight number, date) tuples appear in every result set. The underlying airports and departure times match across all runs.

The runs differ in column naming, route string formatting, the number of extra analytic columns returned, and whether diverted flights are excluded. Two codex/gpt-5.4 runs finished with `partial` status because their HTML visualizations failed to render, though their SQL execution and report generation completed successfully.

## Full SQL artifacts

### claude / opus
- **run-001:** [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/opus/run-001/query.sql) · [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/opus/run-001/result.json)

### claude / sonnet
- **run-001:** [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/query.sql) · [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/result.json)

### codex / gpt-5.4
- **run-001:** [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql) · [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/result.json)
- **run-002:** [query.sql](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-002/query.sql) · [result.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-002/result.json)

## Real output differences

**Core data is identical across all four runs.** Every run returns 10 rows with Hops = 8, the same tail numbers, flight numbers, dates, and airport sequences. Verified by comparing all 10 `(Tail_Number, Flight_Number, FlightDate)` tuples and route airport lists in each `result.json`.

Differences are limited to formatting and extra columns:

| Aspect | claude/opus | claude/sonnet | codex/gpt-5.4 run-001 | codex/gpt-5.4 run-002 |
| --- | --- | --- | --- | --- |
| Column count | 7 | 7 | 11 | 8 |
| Route format | `ISP-BWI-MYR-…` (dash) | `ISP → BWI → MYR → …` (arrow) | `ISP -> BWI -> …` (arrow, airports only) | `05:43 ISP->BWI \| 08:10 BWI->MYR \| …` (time+leg pairs) |
| Departure times | `5:43, 8:10, …` (H:MM, comma) | `0543 (ISP), 0810 (BWI), …` (HHMM + airport) | `05:43 ISP \| 08:10 BWI \| …` (HH:MM + airport) | embedded in Route column |
| Carrier column name | `IATA_CODE_Reporting_Airline` | `Carrier` | `Carrier` | `Carrier` |
| Extra analytics | none | none | `Max Hops Overall`, `Max Hop Itinerary Count`, `Same-Hops Route Count`, `Route Frequency In Top 10` | `Maximum Hops Observed`, `Maximum-Hop Itinerary Count` |

The codex/gpt-5.4 runs both report `Max Hops Overall` / `Maximum Hops Observed` = 8 and `Max Hop Itinerary Count` / `Maximum-Hop Itinerary Count` = 9,859, providing additional context not present in the Claude runs.

## SQL comparison

All four queries share the same high-level strategy: filter to non-cancelled flights with a valid tail number and departure time, group legs by (tail, flight number, date), count hops, sort descending by hop count then by date, and limit to 10. They diverge in structure, filtering, and route assembly.

**Filtering:**

| Filter | opus | sonnet | codex run-001 | codex run-002 |
| --- | --- | --- | --- | --- |
| `Cancelled = 0` | yes | yes | yes | yes |
| `Diverted = 0` | no | no | yes | yes |
| `DepTime IS NOT NULL` | yes | fallback to `CRSDepTime` | yes | yes |
| `Tail_Number != ''` | yes | yes | yes | yes |
| `Flight_Number != ''` | no | yes | yes | yes |
| Min-hops filter | none | `HAVING length >= 2` | none | none |

The `Diverted = 0` filter in both codex runs excludes diverted flights -- a stricter interpretation that does not affect the top-10 result here but could matter for edge cases. Sonnet's `HAVING length(sorted_legs) >= 2` silently drops single-leg itineraries, which cannot be a "highest hops" candidate anyway.

**Query shape:**

- **opus** uses 3 CTEs: `legs` (flat filter), `counts` (group + ORDER + LIMIT 10), `top_legs` (join back to get individual leg details), then a final GROUP BY to reassemble the route. This two-pass approach (count first, then fetch legs) adds a join but keeps each CTE simple.
- **sonnet** does everything in a single CTE `leg_data` using `groupArray` with inline `arraySort` by departure time, then a final SELECT with array functions. Most compact query (42 lines).
- **codex run-001** uses 4 CTEs (`legs`, `itineraries`, `max_hops`, `scored`) plus a `top10` subquery. It adds scalar subqueries for `Max Hops Overall` and `Max Hop Itinerary Count`, and a window function `count() OVER (PARTITION BY …)` for `Same-Hops Route Count` and `Route Frequency In Top 10`. Most complex query (105 lines).
- **codex run-002** is the most elaborate: it joins `ontime.airports_latest` to obtain UTC offset per origin airport and converts departure times to UTC for chronological sorting. It also uses different column aliases (`TailNum`, `FlightNum`) suggesting a different schema assumption. 102 lines.

**Route assembly:**

All four use `arrayStringConcat` over `groupArray`, but with different formatting. Opus and sonnet produce a linear airport chain; codex run-001 produces the same; codex run-002 embeds departure time and origin->dest per leg into the Route string, losing the separate departure-times column.

## Presentation artifacts

### claude / opus
- **run-001:** [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fclaude%2Fopus%2Frun-001%2Freport.md) · [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/claude/opus/run-001/visual.html)
  - Report includes a narrative "Key Finding" section, a "Most Recent Maximum-Hop Itinerary" highlight, and a "Route Repetition and Clustering" analysis. Correctly identifies all three recurring flight numbers (WN 3149 x4, WN 2787 x3, WN 154 x2). Full data table included.
  - Visual rendered successfully (status: ok).

### claude / sonnet
- **run-001:** [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fclaude%2Fsonnet%2Frun-001%2Freport.md) · [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/claude/sonnet/run-001/visual.html)
  - Report structure is similar to opus: "Maximum Hop Count", "Operating Pattern", "Top 10 Longest Itineraries" table, and "Route Repetition and Clustering". Also correctly identifies the three recurring clusters and explains the point-to-point scheduling strategy.
  - Visual rendered successfully (status: ok).

### codex / gpt-5.4
- **run-001:** [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-001%2Freport.md) · [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html)
  - Report is data-table-forward with a brief preamble. Includes extra columns (`Max Hops Overall`, `Same-Hops Route Count`, etc.). Narrative guidance is present but templated rather than fully fleshed out (e.g. "notable route repetition or clustering is the strongest route repetition or clustering pattern visible across the top 10 rows"). Visual render **failed** (status: partial).
- **run-002:** [report.md](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/md.html?file=2026-03-20%2Fq001_hops_per_day%2Fcodex%2Fgpt-5.4%2Frun-002%2Freport.md) · [visual.html](https://boristyshkevich.github.io/ExploringDatabyLLMs-runs/2026-03-20/q001_hops_per_day/codex/gpt-5.4/run-002/visual.html)
  - Similar table-forward structure to run-001. Route column merges departure times into each leg, making the table wider. Narrative guidance is placeholder-like, not fully expanded. Visual render **failed** (status: partial).

## Execution stats

### claude / opus
- **run-001:** query 4.37 s · 386 M rows read · 4.3 GiB read · 24.9 GiB peak memory · 35 threads · SQL gen 87.0 s · visual gen 313.3 s · total 240 s · status **ok**

### claude / sonnet
- **run-001:** query 7.36 s · 193 M rows read · 3.0 GiB read · 41.2 GiB peak memory · 34 threads · SQL gen 104.0 s · visual gen 352.8 s · total 331 s · status **ok**

### codex / gpt-5.4
- **run-001:** query 19.50 s · 579 M rows read · 5.4 GiB read · 50.1 GiB peak memory · 35 threads · SQL gen 297.2 s · visual gen 645.7 s · total 982 s · status **partial**
- **run-002:** query 32.10 s · 772 M rows read · 12.8 GiB read · 43.9 GiB peak memory · 34 threads · SQL gen 425.2 s · visual gen 636.0 s · total 1099 s · status **partial**

**Performance spread:**

| Metric | Best | Worst | Ratio |
| --- | --- | --- | --- |
| Query time | opus 4.37 s | codex run-002 32.10 s | 7.3x |
| Rows read | sonnet 193 M | codex run-002 772 M | 4.0x |
| Bytes read | sonnet 3.0 GiB | codex run-002 12.8 GiB | 4.2x |
| Peak memory | opus 24.9 GiB | codex run-001 50.1 GiB | 2.0x |
| SQL generation | opus 87.0 s | codex run-002 425.2 s | 4.9x |

Sonnet achieved the lowest row scan (193 M) by doing the grouping and array assembly in a single pass with no join-back, reading each row only once. Opus read 2x more rows due to its two-pass join strategy but still executed fastest (4.37 s) thanks to lower memory overhead (24.9 GiB vs sonnet's 41.2 GiB). Codex run-002's join to `airports_latest` for UTC offsets and its more complex sorting logic drove the highest I/O (772 M rows, 12.8 GiB) and longest query time (32.1 s).

## Takeaway

All four runs produce the correct top-10 answer with identical core data. The question is well-suited for benchmarking because it requires array manipulation, chronological ordering, and domain reasoning -- and every model handled these correctly.

The Claude models (opus, sonnet) were substantially faster in both SQL generation (87-104 s vs 297-425 s) and query execution (4-7 s vs 20-32 s), and both produced fully rendered visualizations. Sonnet's single-pass array strategy yielded the most efficient scan; opus's two-pass join was slightly costlier in I/O but lightest on memory.

The codex/gpt-5.4 runs added useful analytic columns (global max hops, itinerary counts) that the Claude runs did not, showing a tendency to over-deliver on schema. However, both codex runs failed at the visualization render phase, and their report narratives were more templated than the Claude reports, which provided richer domain commentary on Southwest's multi-stop operating model. Codex run-002's decision to join an airport timezone table was creative but unnecessary for the question's requirements, and it doubled the I/O cost compared to run-001.
