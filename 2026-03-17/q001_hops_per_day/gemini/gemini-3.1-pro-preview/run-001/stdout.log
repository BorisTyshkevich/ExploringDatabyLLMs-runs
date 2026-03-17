```sql
SELECT
    TailNum,
    FlightNum,
    Carrier,
    FlightDate,
    length(legs) AS Hops,
    arrayStringConcat(
        arrayPushBack(
            arrayMap(x -> concat(x.1, ' (', toString(x.3), ')'), legs),
            tupleElement(legs[-1], 2)
        ),
        ' - '
    ) AS Route
FROM (
    SELECT
        TailNum,
        FlightNum,
        Carrier,
        FlightDate,
        arraySort(x -> toFloat64OrZero(toString(x.3)), groupArray(tuple(Origin, Dest, DepTime))) AS legs
    FROM default.ontime_v2
    WHERE TailNum != ''
      AND toString(FlightNum) != ''
      AND toString(DepTime) != ''
      AND Cancelled = 0
    GROUP BY
        TailNum,
        FlightNum,
        Carrier,
        FlightDate
)
ORDER BY
    Hops DESC,
    FlightDate DESC
LIMIT 10
```
