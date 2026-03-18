You are writing a rich comparison note for one qforge benchmark question and one experiment day.

Use only verified local artifacts and, if necessary, the configured MCP access for direct validation. Do not invent behavior, metrics, SQL differences, or output differences.

Question context:

- Question ID: `q002`
- Question slug: `q002_top_carrier_by_flights_leadership`
- Question title: `Yearly carrier leadership by completed flights`
- Day: `2026-03-17`

Primary structured compare artifact:

- `compare/compare.json`

Question files:

- SQL question prompt: `https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q002_top_carrier_by_flights_leadership/prompt.md`
- Report prompt: `https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q002_top_carrier_by_flights_leadership/report_prompt.md`
- Visual prompt: `https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q002_top_carrier_by_flights_leadership/visual_prompt.md`
- Compare contract: `https://github.com/BorisTyshkevich/ExploringDatabyLLMs/blob/main/prompts/q002_top_carrier_by_flights_leadership/compare.yaml`

Run directories:

- claude/opus/run-001
- codex/gpt-5.4/run-001
- gemini/gemini-3.1-pro-preview/run-001

Query SQL files:

- claude/opus/run-001/query.sql
- codex/gpt-5.4/run-001/query.sql
- gemini/gemini-3.1-pro-preview/run-001/query.sql

Report Markdown files:

- claude/opus/run-001/report.md
- codex/gpt-5.4/run-001/report.md
- gemini/gemini-3.1-pro-preview/run-001/report.md

Visual HTML files:

- claude/opus/run-001/visual.html
- codex/gpt-5.4/run-001/visual.html
- gemini/gemini-3.1-pro-preview/run-001/visual.html

Result JSON files:

- claude/opus/run-001/result.json
- codex/gpt-5.4/run-001/result.json
- gemini/gemini-3.1-pro-preview/run-001/result.json

Deterministic compare summary:

# qforge Compare Report

- Generated: `2026-03-17T18:13:20Z`
- Day: `2026-03-17`
- Question: `q002`

## q002: Yearly carrier leadership by completed flights

- Status: all runs succeeded.
- Row counts: mismatch (195, 234).
- Fastest successful run: codex/gpt-5.4 at 586 ms.
- Lowest read volume: claude/opus at 921,230,348 rows.
- Lowest memory usage: claude/opus at 346.2 MiB.
| runner | model | status | rows | duration | read rows | memory | warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| claude | opus | ok | 195 | 594 ms | 921,230,348 | 346.2 MiB | 0 |
| codex | gpt-5.4 | ok | 195 | 586 ms | 921,230,348 | 349.7 MiB | 0 |
| gemini | gemini-3.1-pro-preview | ok | 234 | 1.46 s | 1,612,153,109 | 584.9 MiB | 0 |

Your job:

- write one evidence-based Markdown report suitable for `compare_report.md`
- use the real local artifacts above as the source of truth
- verify whether outputs actually differ before claiming they differ
- quantify differences when they exist
- mention performance differences only from verified query-log metrics
- describe SQL-shape differences only when supported by the actual `query.sql` files
- cite `report.md` and `visual.html` artifacts when discussing presentation outputs
- prefer links to local artifacts instead of long pasted SQL
- keep artifact links relative: run artifacts use paths relative to the question directory (e.g., `claude/opus/run-001/report.md`); prompt files use full GitHub URLs
- keep the note concise but complete enough for a blog-style benchmark write-up

Required sections:

1. `# qNNN Experiment Note`
2. `## Question`
3. `## Why this question is useful`
4. `## Experiment setup`
5. `## Result summary`
6. `## Full SQL artifacts`
7. `## Real output differences`
8. `## SQL comparison`
9. `## Presentation artifacts`
10. `## Execution stats`
11. `## Takeaway`

Rules:

- If results are identical, say so explicitly and support that with verified evidence.
- If differences are localized to one field or row type, say that precisely.
- Do not use vague judgments like “better” or “worse” without concrete evidence.
- Do not mention files that you did not verify.
- Return only one fenced Markdown block.

Return exactly this fenced section:

```markdown
# qNNN Experiment Note
...
```