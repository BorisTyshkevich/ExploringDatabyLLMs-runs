WITH legs AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        OriginCode,
        DestCode,
        assumeNotNull(CRSDepTime) AS dep_time
    FROM ontime.fact_ontime
    WHERE Tail_Number != ''
      AND Cancelled = 0
      AND CRSDepTime IS NOT NULL
),
grouped AS (
    SELECT
        Tail_Number,
        Flight_Number_Reporting_Airline,
        IATA_CODE_Reporting_Airline,
        FlightDate,
        arraySort((x, y) -> y, groupArray(OriginCode), groupArray(dep_time)) AS sorted_origins,
        arraySort((x, y) -> y, groupArray(DestCode), groupArray(dep_time)) AS sorted_dests,
        count() AS hop_count
    FROM legs
    GROUP BY Tail_Number, Flight_Number_Reporting_Airline, IATA_CODE_Reporting_Airline, FlightDate
    HAVING hop_count >= 2
)
SELECT
    Tail_Number AS "Aircraft ID",
    Flight_Number_Reporting_Airline AS "Flight Number",
    IATA_CODE_Reporting_Airline AS "Carrier",
    FlightDate AS "Date",
    arrayStringConcat(arrayPushBack(sorted_origins, sorted_dests[hop_count]), ' → ') AS "Route",
    hop_count
FROM grouped
ORDER BY hop_count DESC, FlightDate DESC
LIMIT 10
