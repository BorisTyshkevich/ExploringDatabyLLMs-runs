I have verified all the relevant artifacts. The compare.json confirms there are no runs for this question on this day. Let me now write the comparison report.

```markdown
# q002 Experiment Note

## Question

**q002_top_carrier_by_flights_leadership** — *Yearly carrier leadership by completed flights*

Determine which `Reporting_Airline` flew the most completed flights in each calendar year, and identify where leadership changed most sharply.

## Why this question is useful

This question tests an LLM's ability to:

- Apply multi-level aggregation (carrier-year totals within yearly totals)
- Use window functions for ranking, share calculation, and year-over-year comparisons
- Implement conditional logic to detect leadership transitions
- Produce a dual-purpose result set supporting both tabular analysis and visual dashboards
- Handle edge cases such as the first year having no prior leader for comparison

The question exercises CTE design, deterministic ordering, and the generation of derived metrics like share gap and share change in percentage points.

## Experiment setup

- **Day:** 2026-03-18
- **Compare contract:** [`compare.yaml`](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q002_top_carrier_by_flights_leadership/compare.yaml)
- **Key columns:** `Year`, `Reporting_Airline`
- **Exact-match columns:** `RankInYear`, `CompletedFlights`, `LeaderReportingAirline`, `RunnerUpReportingAirline`, `LeaderChanged`
- **Numeric tolerance columns:** `SharePct` (±0.02), `LeaderShareGapPctPts` (±0.02), `LeaderShareChangePctPts` (±0.02)
- **Row filter:** `RowType = 'carrier_year'` with `RankInYear ≤ 5`

## Result summary

**No runs were recorded for q002 on 2026-03-18.**

The compare pipeline generated the following warning:

> `no runs found under runs/2026-03-18 for q002`

Without any model runs, there are no results to compare, no SQL artifacts to analyze, and no presentation outputs to review.

## Full SQL artifacts

*No runs available.*

## Real output differences

*No runs available — nothing to compare.*

## SQL comparison

*No SQL files were generated for this day.*

## Presentation artifacts

*No runs available.*

## Execution stats

*No execution metrics were recorded.*

## Takeaway

The 2026-03-18 experiment day contains no runs for question q002. This may indicate:

- The experiment batch did not include q002 on this date
- A pipeline or scheduling issue prevented runs from executing
- Runs were executed but not persisted to the expected directory structure

To produce a meaningful comparison, re-run the experiment for q002 with at least one model configuration, or select a different experiment day that includes completed runs for this question.
```
