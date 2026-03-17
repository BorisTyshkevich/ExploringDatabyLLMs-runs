The query is working correctly. The results show:
- 8 hops as the maximum (N=8 legs)
- Route contains 9 airport codes (N+1 = 9), with 8 origins having departure times and the final destination
- Results are ordered by Hops DESC, then FlightDate DESC (most recent first within same hop count)
- All Southwest (WN) aircraft with the highest hop counts

```sql
WITH legs AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        Origin,
        Dest,
        DepTime
    FROM default.ontime_v2
    WHERE Tail_Number != ''
      AND Flight_Number_Reporting_Airline != ''
      AND Cancelled = 0
      AND DepTime IS NOT NULL
),
grouped AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        count() AS Hops,
        arraySort(x -> x.1, groupArray(tuple(DepTime, Origin, Dest))) AS leg_data_sorted
    FROM legs
    GROUP BY Tail_Number, Flight_Number_Reporting_Airline, IATA_CODE_Reporting_Airline, FlightDate
)
SELECT
    Tail_Number,
    Flight_Number_Reporting_Airline,
    IATA_CODE_Reporting_Airline,
    FlightDate,
    Hops,
    arrayStringConcat(
        arrayMap(x -> concat(x.2, '(', lpad(toString(x.1), 4, '0'), ')'), leg_data_sorted),
        ' -> '
    ) || ' -> ' || leg_data_sorted[Hops].3 AS Route
FROM grouped
ORDER BY Hops DESC, FlightDate DESC
LIMIT 10
```
