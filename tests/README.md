# statareport tests

Stata do-file test suite for the package. No test framework — just
`assert` wrapped in tiny helpers that track pass/fail counts.

## Running

From the repo root:

```bash
cd tests
/Applications/StataNow/StataBE.app/Contents/MacOS/statabe -b do run_all.do
```

On macOS always invoke the binary via its **lowercase** path
(`statabe`, not `StataBE`). The uppercase launch triggers Cocoa GUI
alerts even in batch mode.

The runner writes `run_all.log`; the last block of the log reports:

```
TOTAL PASSED: <N> assertions
```

or

```
TOTAL FAILED (<failed> / <total>)
```

The process exits with `r(9)` when anything failed, suitable for CI.

## Layout

| File | Covers |
|---|---|
| `_helpers.do`            | `eq` / `streq` / `substr_in` / `rc_eq` / `start_case` / `end_case` |
| `run_all.do`             | sets adopath to `../ado`, sources helpers, runs each test file |
| `test_quant.do`          | numeric summaries on `sysuse auto` |
| `test_qual.do`           | categorical frequencies + `pct(row)` validation |
| `test_label_table.do`    | Excel merge, sort by `order`, blank-`order` drop |
| `test_convert_wisely.do` | `%format` regression + note-preservation round-trip |
| `test_statareport_set_paths.do` | `$file_*` globals + required-input validation |
| `test_kable_pipeline.do` | end-to-end quant+qual → label → kable markdown |

## Adding tests

Wrap a block in `start_case "..."` / `end_case`. Use options-based
helpers; the tokenizer breaks on anything trickier:

```stata
start_case "my case"
    eq, expr("2 + 2 == 4")                 msg("math works")
    streq, left("a") right("a")            msg("a equals a")
    substr_in, haystack("xyz") needle("y") msg("y in xyz")
    capture confirm file "nope.dta"
    rc_eq, expect(601)                     msg("missing file -> 601")
end_case
```

`eq` takes a condition string (what you'd pass to `assert`). `rc_eq`
reads the just-executed `_rc`, so the convention is:

```stata
capture <command>
rc_eq, expect(<n>) msg("...")
```
