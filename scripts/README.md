# Compare Helper Scripts

## `regenerate_compare_push.sh`

Regenerates compare artifacts for one question and pushes them from this repo.

Usage:

```bash
./scripts/regenerate_compare_push.sh q002
./scripts/regenerate_compare_push.sh q003 2026-03-18
```

Arguments:

- `QUESTION`: question id such as `q002`
- `DATE`: optional day in `YYYY-MM-DD` format; defaults to today

Optional environment variables:

- `QFORGE_RUNNER`: compare runner, default `claude`
- `QFORGE_MODEL`: optional model override
- `QFORGE_VERBOSE=1`: pass `-v` to `qforge compare`

The script:

1. runs `qforge compare` from the sibling `ExploringDatabyLLMs` repo
2. stages only compare artifacts for the requested question/day
3. commits them in this repo
4. rebases on `origin/main`
5. pushes to `origin/main`
