`visual.html` is written (764 lines). The dashboard includes:

- **Header** with title and analytical subtitle
- **KPI strip** (5 cards): Tail Number, Flight Number, Date, Hop Count, Route Repetition — anchored to the #1-ranked itinerary
- **Leaflet map** present from initial render, with degraded-state messaging before/if enrichment fails; route segments drawn with numbered midpoint labels, origin/destination highlighted in red, intermediate stops in navy
- **Legend** below the map
- **Route Sequence & Details panel** showing airport badge chain, stop count, coordinate info, and repeated-segment analysis
- **Itinerary table** with clickable rows — active row gets a distinct blue highlight vs hover; clicking redraws the map and route panel for that itinerary
- **Airport coordinate enrichment** via a single query to `dim_airports`, cached and reused for all row selections
- **Query ledger** with collapsible SQL for both the primary query and the enrichment query
- **CSV export** button
- **Footer** with JWE token input, forget button, SQL textarea, and fetch control
