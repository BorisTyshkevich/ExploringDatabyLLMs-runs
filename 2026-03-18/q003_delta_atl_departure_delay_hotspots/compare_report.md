# q003 Experiment Note

## Question

**Delta ATL departure delay hotspots by destination and time block**

Find which Delta departures out of ATL have the worst sustained departure delays at the `(Dest, DepTimeBlk)` level. The query must identify the top 20 hotspot cells ranked by average departure delay, p90 delay, percentage of 15+ minute delays, and flight volume—while also producing monthly trend rows for each qualifying hotspot.

Key requirements:
- Filter to Delta (`IATA_CODE_Reporting_Airline = 'DL'`) departures from ATL with `Cancelled = 0`
- Monthly cell qualification threshold: ≥40 completed flights
- Hotspot qualification threshold: ≥1,000 completed flights across qualifying months
- Final hotspot metrics must be recomputed from raw flights (not averaged from monthly aggregates)
- Output both `hotspot_summary` and `monthly_trend` row types

## Why this question is useful

This question tests several advanced SQL patterns:
1. **Two-stage qualification logic** — monthly cells must meet a threshold before contributing to hotspot metrics
2. **Metric recomputation** — hotspot-level averages and p90 values must come from raw flight data, not from aggregating monthly summaries
3. **Dual row-type output** — a single query must produce both summary rows and supporting trend rows
4. **Multi-key ranking** — the ranking uses a four-column tiebreaker (avg delay, p90, DepDel15Pct, flight count)

It also has practical relevance: ATL is Delta's largest hub, and identifying persistent departure delay patterns by destination and time block helps diagnose operational bottlenecks.

## Experiment setup

- **Day**: `2026-03-18`
- **Question ID**: `q003`
- **Compare contract**: [compare.yaml](https://github.com/boristyshkevich/ExploringDatabyLLMs/blob/main/prompts/q003_delta_atl_departure_delay_hotspots/compare.yaml)

## Result summary

**No runs were recorded for this question on 2026-03-18.**

The compare pipeline detected no experiment runs under `runs/2026-03-18` matching the `q003_delta_atl_departure_delay_hotspots` question slug. The [compare.json](https://github.com/boristyshkevich/ExploringDatabyLLMs-runs/blob/main/2026-03-18/q003_delta_atl_departure_delay_hotspots/compare/compare.json) artifact confirms:

```json
{
  "warnings": ["no runs found under runs/2026-03-18 for q003"],
  "runs": []
}
