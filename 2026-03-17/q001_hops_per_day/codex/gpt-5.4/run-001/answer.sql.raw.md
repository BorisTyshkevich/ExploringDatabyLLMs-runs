```sql
WITH legs AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        Origin,
        Dest,
        toDateTime(FlightDate) + toIntervalMinute(if(DepTime = 2400, 1440, intDiv(DepTime, 100) * 60 + (DepTime % 100))) AS dep_ts
    FROM default.ontime_v2
    WHERE Cancelled = 0
      AND Diverted = 0
      AND Tail_Number != ''
      AND Flight_Number_Reporting_Airline != ''
      AND IATA_CODE_Reporting_Airline != ''
      AND DepTime IS NOT NULL
),
itineraries AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        count() AS hops,
        arraySort(groupArray((dep_ts, Origin, Dest))) AS ordered_legs,
        max(dep_ts) AS max_dep_ts
    FROM legs
    GROUP BY
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate
)
SELECT
    Tail_Number AS `Aircraft ID`,
    Flight_Number_Reporting_Airline AS `Flight Number`,
    IATA_CODE_Reporting_Airline AS Carrier,
    FlightDate AS Date,
    concat(
        arrayStringConcat(arrayMap(x -> concat(x.2, ' ', formatDateTime(x.1, '%Y-%m-%d %H:%i')), ordered_legs), ' -> '),
        ' -> ',
        ordered_legs[length(ordered_legs)].3
    ) AS Route
FROM itineraries
ORDER BY hops DESC, FlightDate DESC, max_dep_ts DESC
LIMIT 10
```