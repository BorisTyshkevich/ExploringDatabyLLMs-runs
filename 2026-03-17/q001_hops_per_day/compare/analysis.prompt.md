You are writing a rich comparison note for one qforge benchmark question and one experiment day.

Use only verified local artifacts and, if necessary, the configured MCP access for direct validation. Do not invent behavior, metrics, SQL differences, or output differences.

Question context:

- Question ID: `q001`
- Question slug: `q001_hops_per_day`
- Question title: `Highest daily hops for one aircraft on one flight number`
- Day: `2026-03-17`

Primary structured compare artifact:

- `/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/compare/compare.json`

Question files:

- SQL question prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/prompt.md`
- Report prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/report_prompt.md`
- Visual prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/visual_prompt.md`
- Compare contract: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q001_hops_per_day/compare.yaml`

Run directories:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-002
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001

Query SQL files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-002/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001/query.sql

Report Markdown files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-002/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001/report.md

Visual HTML files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-002/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001/visual.html

Result JSON files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/claude/opus/run-002/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/codex/gpt-5.4/run-001/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q001_hops_per_day/gemini/gemini-3.1-pro-preview/run-001/result.json

Deterministic compare summary:

# qforge Compare Report

- Generated: `2026-03-17T13:59:52Z`
- Day: `2026-03-17`
- Question: `q001`

## q001: Highest daily hops for one aircraft on one flight number

- Status: all runs succeeded.
- Row counts: all runs returned 10 rows.
- Fastest successful run: claude/opus at 7.48 s.
- Lowest read volume: claude/opus at 193,061,941 rows.
- Lowest memory usage: gemini/gemini-3.1-pro-preview at 41.5 GiB.
| runner | model | status | rows | duration | read rows | memory | warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| claude | opus | ok | 10 | 7.48 s | 193,061,941 | 42.3 GiB | 0 |
| codex | gpt-5.4 | ok | 10 | 7.65 s | 193,061,941 | 45.4 GiB | 0 |
| gemini | gemini-3.1-pro-preview | ok | 10 | 7.57 s | 230,307,587 | 41.5 GiB | 0 |

Your job:

- write one evidence-based Markdown report suitable for `compare_report.md`
- use the real local artifacts above as the source of truth
- verify whether outputs actually differ before claiming they differ
- quantify differences when they exist
- mention performance differences only from verified query-log metrics
- describe SQL-shape differences only when supported by the actual `query.sql` files
- cite `report.md` and `visual.html` artifacts when discussing presentation outputs
- prefer links to local artifacts instead of long pasted SQL
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