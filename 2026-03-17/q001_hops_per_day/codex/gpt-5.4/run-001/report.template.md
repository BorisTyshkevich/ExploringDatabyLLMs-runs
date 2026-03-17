# {{question_title}}

Generated from `result.json` at {{generated_at}} with {{row_count}} rows across {{columns_csv}}.

The lead row in {{result_table_md}} represents the maximum daily hop count because the saved SQL orders itineraries by hop count first, then by the most recent operating date and departure sequence. Use that first row to identify whether the longest same-flight-number day looks like a repeated operating pattern or a one-off itinerary among the other top results.

{{data_overview_md}}

Use {{result_table_md}} to highlight the single most recent itinerary among the maximum-hop rows, including carrier, flight number, date, aircraft ID, and the full route string. Then compare the remaining rows for repeated full-route patterns, recurring carrier and flight-number combinations, and airport clustering across the top 10 longest itineraries.