Both files written. Here's a summary:

**`query.sql`** — Groups legs by aircraft (`Tail_Number`), flight number, carrier, and date. Uses `arraySort` to order legs chronologically by scheduled departure time, then builds the `Route` string by concatenating all origin codes plus the final destination with `→` delimiters. Returns top 10 by hop count (descending), then most recent date.

**Results** — All top 10 itineraries have 8 hops, exclusively Southwest Airlines (WN). Flight numbers like 3149 (CLE→DEN), 154 (ELP→SAN), and 2787 (MSY→LAX) each traverse 8 cities coast-to-coast in a single day using the same flight number on different aircraft.
