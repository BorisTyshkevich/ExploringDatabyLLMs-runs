# Highest daily hops for one aircraft on one flight number

## Overview

This analysis identifies aircraft-flight number combinations that completed the highest number of hops (legs) in a single day. A "hop" represents one segment flown by the same tail number under the same flight number on the same calendar date.

**Result set:** 10 rows | **Generated:** 2026-03-17T13:15:21Z

## Key Findings

- Rows returned: 10
- Generated at: 2026-03-17T13:15:21Z
- Columns: Tail_Number, Flight_Number_Reporting_Airline, IATA_CODE_Reporting_Airline, FlightDate, Hops, Route
- First row snapshot: Tail_Number=N957WN, Flight_Number_Reporting_Airline=366, IATA_CODE_Reporting_Airline=WN

### Analytical Notes

- **Maximum hop count observed:** All top itineraries share the same maximum of 8 hops per day, indicating this represents a practical ceiling for single-day, single-flight-number utilization in the dataset.
- **Operating pattern vs. one-off:** The repeated appearance of flight numbers WN 3149, WN 154, and WN 2787 across multiple dates with identical or near-identical routing suggests these are **scheduled rotating itineraries**, not ad-hoc repositioning flights.
- **Most recent maximum-hop itinerary:** Southwest WN 366 on 2024-12-01, operating tail N957WN from ISP through BWI, MYR, BNA, VPS, DAL, LAS, OAK to SEA—a transcontinental east-to-west sweep.
- **Route clustering:** WN 3149 shows strong repetition with a consistent CLE→BNA→PNS→HOU→MCI→PHX→BUR→OAK→DEN pattern across January–February 2024. Similarly, WN 154 and WN 2787 each appear on multiple dates with stable routing.

## Result Data

| Tail_Number | Flight_Number_Reporting_Airline | IATA_CODE_Reporting_Airline | FlightDate | Hops | Route |
| --- | --- | --- | --- | --- | --- |
| N957WN | 366 | WN | 2024-12-01T00:00:00Z | 8 | ISP(0543) -> BWI(0810) -> MYR(1020) -> BNA(1142) -> VPS(1401) -> DAL(1643) -> LAS(1828) -> OAK(2041) -> SEA |
| N7835A | 3149 | WN | 2024-02-18T00:00:00Z | 8 | CLE(0621) -> BNA(0801) -> PNS(1007) -> HOU(1234) -> MCI(1514) -> PHX(1747) -> BUR(1902) -> OAK(2117) -> DEN |
| N429WN | 3149 | WN | 2024-01-28T00:00:00Z | 8 | CLE(0618) -> BNA(0800) -> PNS(1012) -> HOU(1239) -> MCI(1515) -> PHX(1756) -> BUR(1859) -> OAK(2059) -> DEN |
| N228WN | 3149 | WN | 2024-01-21T00:00:00Z | 8 | CLE(0620) -> BNA(0810) -> PNS(1017) -> HOU(1237) -> MCI(1510) -> PHX(1800) -> BUR(1903) -> OAK(2102) -> DEN |
| N569WN | 3149 | WN | 2024-01-14T00:00:00Z | 8 | CLE(0625) -> BNA(0805) -> PNS(1011) -> HOU(1241) -> MCI(1607) -> PHX(1909) -> BUR(2006) -> OAK(2156) -> DEN |
| N7742B | 154 | WN | 2023-04-30T00:00:00Z | 8 | ELP(0627) -> DAL(0939) -> LIT(1124) -> ATL(1434) -> RIC(1656) -> MDW(1831) -> MCI(2040) -> PHX(2246) -> SAN |
| N929WN | 154 | WN | 2023-04-16T00:00:00Z | 8 | ELP(0622) -> DAL(0941) -> LIT(1122) -> ATL(1433) -> RIC(1659) -> MDW(1832) -> MCI(2041) -> PHX(2226) -> SAN |
| N8631A | 2787 | WN | 2022-10-23T00:00:00Z | 8 | MSY(0608) -> ATL(0944) -> CMH(1156) -> BWI(1354) -> RDU(1553) -> BNA(1729) -> DTW(2045) -> MDW(2149) -> LAX |
| N8809L | 2787 | WN | 2022-10-02T00:00:00Z | 8 | MSY(0610) -> ATL(0917) -> CMH(1142) -> BWI(1355) -> RDU(1536) -> BNA(1716) -> DTW(2040) -> MDW(2147) -> LAX |
| N8811L | 2787 | WN | 2022-09-25T00:00:00Z | 8 | MSY(0601) -> ATL(0918) -> CMH(1141) -> BWI(1347) -> RDU(1539) -> BNA(1724) -> DTW(2112) -> MDW(2242) -> LAX |

## Interpretation

The 8-hop ceiling likely reflects Southwest's point-to-point network model, where aircraft rotate through multiple city pairs under a single flight number throughout the day. The route repetition confirms these are **regular operating patterns** rather than irregular charters or ferry flights.