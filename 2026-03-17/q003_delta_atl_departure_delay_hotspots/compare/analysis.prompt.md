You are writing a rich comparison note for one qforge benchmark question and one experiment day.

Use only verified local artifacts and, if necessary, the configured MCP access for direct validation. Do not invent behavior, metrics, SQL differences, or output differences.

Question context:

- Question ID: `q003`
- Question slug: `q003_delta_atl_departure_delay_hotspots`
- Question title: `Delta ATL departure delay hotspots by destination and time block`
- Day: `2026-03-17`

Primary structured compare artifact:

- `/Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/compare/compare.json`

Question files:

- SQL question prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q003_delta_atl_departure_delay_hotspots/prompt.md`
- Report prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q003_delta_atl_departure_delay_hotspots/report_prompt.md`
- Visual prompt: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q003_delta_atl_departure_delay_hotspots/visual_prompt.md`
- Compare contract: `/Users/bvt/work/ExploringDatabyLLMs/prompts/q003_delta_atl_departure_delay_hotspots/compare.yaml`

Run directories:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-002
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/codex/gpt-5.4/run-001
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-002
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-001
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-001

Query SQL files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-002/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/codex/gpt-5.4/run-001/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-002/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-001/query.sql
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-001/query.sql

Report Markdown files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-002/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/codex/gpt-5.4/run-001/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-002/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-001/report.md
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-001/report.md

Visual HTML files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-002/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/codex/gpt-5.4/run-001/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-002/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-001/visual.html
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-001/visual.html

Result JSON files:

- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-002/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/codex/gpt-5.4/run-001/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-002/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/claude/opus/run-001/result.json
- /Users/bvt/work/ExploringDatabyLLMs/runs/2026-03-17/q003_delta_atl_departure_delay_hotspots/gemini/gemini-3.1-pro-preview/run-001/result.json

Deterministic compare summary:

# qforge Compare Report

- Generated: `2026-03-17T13:16:47Z`
- Day: `2026-03-17`
- Question: `q003`
- Warnings: `1`

## q003: Delta ATL departure delay hotspots by destination and time block

- Status: 2 run(s) did not finish cleanly: claude/opus, gemini/gemini-3.1-pro-preview.
- Row counts: mismatch (0, 832).
- Fastest successful run: codex/gpt-5.4 at 1.03 s.
- Lowest read volume: codex/gpt-5.4 at 1,364,087,871 rows.
- Lowest memory usage: claude/opus at 250.7 MiB.
- Warnings: 1.
| runner | model | status | rows | duration | read rows | memory | warnings |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: |
| claude | opus | ok | 832 | 1.28 s | 1,831,679,447 | 250.7 MiB | 0 |
| codex | gpt-5.4 | ok | 832 | 1.03 s | 1,364,087,871 | 292.8 MiB | 0 |
| gemini | gemini-3.1-pro-preview | ok | 832 | 1.11 s | 1,371,628,729 | 479.5 MiB | 0 |
| claude | opus | partial | 832 | 1.38 s | 1,836,238,936 | 231.3 MiB | 0 |
| gemini | gemini-3.1-pro-preview | partial | 0 | 8 ms | 0 | 233.0 KiB | 1 |

### Warnings

- gemini/gemini-3.1-pro-preview: missing result.json

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