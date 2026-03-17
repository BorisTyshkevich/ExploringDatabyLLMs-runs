# {{question_title}}

## Overview

This analysis identifies aircraft-flight number combinations that completed the highest number of hops (legs) in a single day. A "hop" represents one segment flown by the same tail number under the same flight number on the same calendar date.

**Result set:** {{row_count}} rows | **Generated:** {{generated_at}}

## Key Findings

{{data_overview_md}}

### Analytical Notes

- **Maximum hop count observed:** All top itineraries share the same maximum of 8 hops per day, indicating this represents a practical ceiling for single-day, single-flight-number utilization in the dataset.
- **Operating pattern vs. one-off:** The repeated appearance of flight numbers WN 3149, WN 154, and WN 2787 across multiple dates with identical or near-identical routing suggests these are **scheduled rotating itineraries**, not ad-hoc repositioning flights.
- **Most recent maximum-hop itinerary:** Southwest WN 366 on 2024-12-01, operating tail N957WN from ISP through BWI, MYR, BNA, VPS, DAL, LAS, OAK to SEA—a transcontinental east-to-west sweep.
- **Route clustering:** WN 3149 shows strong repetition with a consistent CLE→BNA→PNS→HOU→MCI→PHX→BUR→OAK→DEN pattern across January–February 2024. Similarly, WN 154 and WN 2787 each appear on multiple dates with stable routing.

## Result Data

{{result_table_md}}

## Interpretation

The 8-hop ceiling likely reflects Southwest's point-to-point network model, where aircraft rotate through multiple city pairs under a single flight number throughout the day. The route repetition confirms these are **regular operating patterns** rather than irregular charters or ferry flights.