The comparison report has been written to `compare_report.md`. Here's the key finding:

**All four runs agree on the core answer** — 8 max hops, all Southwest Airlines, same 10 tuples — so the differences are in SQL strategy, formatting, and performance:

- **Claude opus** was fastest at query execution (4.37 s) and lowest memory (24.9 GiB)
- **Claude sonnet** had the most efficient scan (193M rows) via a single-pass array strategy
- **Codex gpt-5.4** runs added extra analytic columns but were 5–7× slower in query time, and both failed at visual rendering (`partial` status)
- Report quality: Claude runs produced richer narrative; codex reports were more templated
