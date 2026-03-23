The report has been written to `compare_report.md`. Here's what it covers:

- **Identical results**: Both runs return the same 10 rows (all Southwest, 8 hops each). The only data difference is cosmetic arrow spacing in Route (`' → '` vs `'→'`).
- **SQL divergence**: Claude uses simpler filtering; Codex adds guards for diverted flights, empty flight numbers, and null departure times — but both converge on the same answer.
- **Performance**: Near-identical query times (~7.4–7.5 s, 193M rows). Codex reads 22% more bytes (extra `DepTime` column) but finishes the full pipeline ~2 min faster due to quicker visual generation.
