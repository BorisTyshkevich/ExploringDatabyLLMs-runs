SELECT iata AS IATA, lat AS Lat, lon AS Lon, city AS City, name AS Name FROM default.airports_bts WHERE iata IN ('ISP','BWI','MYR','BNA','VPS','DAL','LAS','OAK','SEA');
SELECT
    Tail_Number AS `Aircraft ID`,
    Flight_Number_Reporting_Airline AS `Flight Number`,
    Reporting_Airline AS `Carrier`,
    FlightDate AS `Date`,
    arrayStringConcat(
        arrayPushBack(
            arrayMap(x -> x.2, arraySort(groupArray(tuple(DepTime, Origin)))),
            argMax(Dest, DepTime)
        ),
        '-'
    ) AS Route,
    arraySort(groupArray(DepTime)) AS `Actual Departure Times`
FROM default.ontime_v2
WHERE length(Tail_Number) > 0 
  AND DepTime IS NOT NULL 
  AND length(toString(DepTime)) > 0
GROUP BY
    Tail_Number,
    Flight_Number_Reporting_Airline,
    Reporting_Airline,
    FlightDate
ORDER BY
    count() DESC,
    FlightDate DESC
LIMIT 10
