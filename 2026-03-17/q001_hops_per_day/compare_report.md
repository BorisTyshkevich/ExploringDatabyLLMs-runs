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
