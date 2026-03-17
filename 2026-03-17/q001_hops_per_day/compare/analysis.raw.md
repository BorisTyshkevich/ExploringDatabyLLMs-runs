Now I have all the necessary artifacts to write the comparison report. Let me compile the findings.

```markdown
# q001 Experiment Note

## Question

**ID:** q001  
**Slug:** q001_hops_per_day  
**Title:** Highest daily hops for one aircraft on one flight number

Find the highest number of hops per day for a single aircraft using the same flight number. Report Aircraft ID, Flight Number, Carrier, Date, Route. For the longest trip, show the actual departure time from each origin. Find the top 10 longest and most recent itineraries.

## Why this question is useful

This question tests an LLM's ability to:

1. Aggregate flight legs into itineraries using grouping by tail number, flight number, carrier, and date
2. Construct chronologically ordered route strings with embedded departure times
3. Handle array functions for sorting and concatenation
4. Apply multi-column ordering (hop count descending, then date descending) for tie-breaking

The pattern reveals whether the model can reason about flight connectivity and produce human-readable route sequences from raw leg data.

## Experiment setup

- **Day:** 2026-03-17
- **Dataset:** ontime_v2
- **Runners compared:**
  - claude/opus (run-003)
  - codex/gpt-5.4 (run-003)
- **Compare contract key columns:** Aircraft ID, Flight Number, Carrier, Date
- **Compare contract value columns:** Hops (exact), Route (exact)

## Result summary

Both runs succeeded and returned **10 rows** each. The same 10 itineraries appear in both result sets with **identical key values** (Aircraft ID, Flight Number, Carrier, Date). All 10 rows have a hop count of **8**.

**Critical difference:** Claude/opus outputs an explicit `Hops` column (value: 8 for all rows). Codex/gpt-5.4 omits the `Hops` column entirely—hop count must be derived by parsing the Route string.

Route string formats differ cosmetically:
- Claude: `05:43 ISP → 08:10 BWI → ... → SEA` (arrow separator, final destination appended without time)
- Codex: `05:43 ISP->BWI | 08:10 BWI->MYR | ... | 20:41 OAK->SEA` (pipe separator, each leg shows origin->dest)

Both formats contain the same airports and departure times; semantic content is equivalent.

## Full SQL artifacts

| Runner | Model | Query SHA256 (first 12) | Path |
|--------|-------|-------------------------|------|
| claude | opus | `2492ca7cdad0` | [query.sql](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/query.sql) |
| codex | gpt-5.4 | `77f74fe85563` | [query.sql](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/query.sql) |

## Real output differences

### Column presence

| Column | claude/opus | codex/gpt-5.4 |
|--------|-------------|---------------|
| Aircraft ID | ✓ | ✓ |
| Flight Number | ✓ | ✓ |
| Carrier | ✓ | ✓ |
| Date | ✓ | ✓ |
| Hops | ✓ | ✗ |
| Route | ✓ | ✓ |

### Row-by-row key match

All 10 rows match on the compare contract key columns (Aircraft ID, Flight Number, Carrier, Date). Both result sets identify the same itineraries in the same order:

| Rank | Aircraft ID | Flight Number | Carrier | Date |
|------|-------------|---------------|---------|------|
| 1 | N957WN | 366 | WN | 2024-12-01 |
| 2 | N7835A | 3149 | WN | 2024-02-18 |
| 3 | N429WN | 3149 | WN | 2024-01-28 |
| 4 | N228WN | 3149 | WN | 2024-01-21 |
| 5 | N569WN | 3149 | WN | 2024-01-14 |
| 6 | N7742B | 154 | WN | 2023-04-30 |
| 7 | N929WN | 154 | WN | 2023-04-16 |
| 8 | N8631A | 2787 | WN | 2022-10-23 |
| 9 | N8809L | 2787 | WN | 2022-10-02 |
| 10 | N8811L | 2787 | WN | 2022-09-25 |

### Route string comparison (row 1 example)

**Claude/opus:**
```
05:43 ISP → 08:10 BWI → 10:20 MYR → 11:42 BNA → 14:01 VPS → 16:43 DAL → 18:28 LAS → 20:41 OAK → SEA
```

**Codex/gpt-5.4:**
```
05:43 ISP->BWI | 08:10 BWI->MYR | 10:20 MYR->BNA | 11:42 BNA->VPS | 14:01 VPS->DAL | 16:43 DAL->LAS | 18:28 LAS->OAK | 20:41 OAK->SEA
```

Same airports, same times, different formatting. Both contain 8 legs and 9 airports.

## SQL comparison

### Structural differences

| Aspect | claude/opus | codex/gpt-5.4 |
|--------|-------------|---------------|
| CTE usage | 2 CTEs (`flight_legs`, `grouped`) | Inline groupArray in SELECT |
| Hops column | Explicit `count() AS Hops` | Implicit via `ORDER BY count() DESC` |
| Route construction | `arrayStringConcat` with `→` separator, appends final dest | `arrayStringConcat` with ` \| ` separator, each leg shows origin->dest |
| Time formatting | Manual `lpad(toString(x.1 DIV 100), 2, '0')` arithmetic | `formatDateTime(...)` on constructed DateTime |
| Filter conditions | `Cancelled = 0`, `DepTime IS NOT NULL`, `Tail_Number != ''` | Same plus `Diverted = 0`, `Flight_Number_Reporting_Airline != ''` |
| Minimum hops filter | `HAVING Hops >= 2` | None (relies on ORDER BY count()) |

### Ordering

- **Claude:** `ORDER BY Hops DESC, FlightDate DESC`
- **Codex:** `ORDER BY count() DESC, FlightDate DESC, max(departure_datetime) DESC`

Codex adds a third tiebreaker (latest departure time), but this does not affect the top 10 ordering in this dataset.

## Presentation artifacts

### Report files

| Runner | Path | Notes |
|--------|------|-------|
| claude/opus | [report.md](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/report.md) | 64 lines, includes Hops column in table, analytical commentary |
| codex/gpt-5.4 | [report.md](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/report.md) | 27 lines, omits Hops column, briefer commentary |

Claude's report explicitly shows the Hops value per row; Codex's does not.

### Visual HTML files

| Runner | Path | Lines | Mode | Features |
|--------|------|-------|------|----------|
| claude/opus | [visual.html](runs/2026-03-17/q001_hops_per_day/claude/opus/run-003/visual.html) | 781 | Dynamic | KPIs, Leaflet map, results table, query ledger, CSV export |
| codex/gpt-5.4 | [visual.html](runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-003/visual.html) | 1668 | Dynamic | KPIs, Leaflet map, route clustering analysis, carrier filter, repeat-only toggle, results table, query ledger, CSV export |

Both dashboards are dynamic (require JWE token execution). Codex's HTML is significantly larger (1668 vs 781 lines) and includes additional interactive features: carrier filtering, repeat-only toggle, and route clustering analysis.

## Execution stats

| Metric | claude/opus | codex/gpt-5.4 | Delta |
|--------|-------------|---------------|-------|
| Query duration | 18.63 s | 7.88 s | codex 2.4× faster |
| Read rows | 193,061,941 | 193,061,941 | identical |
| Read bytes | 2,650,424,488 | 2,654,458,009 | +0.15% codex |
| Result rows | 10 | 10 | identical |
| Memory usage | 35.1 GiB | 45.3 GiB | claude 22% lower |
| Peak threads | 34 | 34 | identical |

Codex executes 2.4× faster but uses 29% more memory. Both scan the same number of rows.

## Takeaway

Both models correctly identify the same top 10 highest-hop itineraries from the ontime_v2 dataset. The key difference is schema completeness: Claude/opus produces an explicit `Hops` column as specified in the prompt, while Codex/gpt-5.4 omits it, forcing consumers to parse the Route string to derive hop count.

Route formatting is cosmetically different but semantically equivalent. Codex's query executes faster due to a simpler inline aggregation pattern, but at the cost of higher memory usage and missing the requested Hops output column. Claude's approach is more verbose (2 CTEs) but adheres more closely to the prompt's column requirements.

For benchmark correctness under the compare contract, Claude/opus would pass the `Hops` exact-match requirement; Codex/gpt-5.4 would fail because the column is absent.
```
