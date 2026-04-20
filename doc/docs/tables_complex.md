# Complex tables

Real reports rarely need just one `quant` or one `qual`. The common
patterns:

1. **Mix quantitative and qualitative rows** in a single table (e.g.
   demographics — age as a median, sex as counts).
2. **Stack sub-sections** with a blank spacer row and a section header.
3. **Fan out across many variables** in a loop (e.g. one table per
   laboratory parameter).

All three rely on the same idea: `append` + `idstart()` keeps the output
in one `.dta`, and a single Excel sheet labels every row at once. This
page walks through all three, using `sysuse auto`.

## 1. Mixed demographics-style table

Goal: one table combining numeric summaries (price, mpg, weight) and
categorical indicators (heavy car, foreign-made), stratified by origin.

```stata
sysuse auto, clear

gen heavy   = weight > 3000 if !missing(weight)
gen cheap   = price  < 5000 if !missing(price)
gen thirsty = mpg    < 20   if !missing(mpg)
label var heavy   "Heavy (> 3,000 lbs)"
label var cheap   "Cheap (< $5,000)"
label var thirsty "Thirsty (< 20 mpg)"

local out "output_tables/auto_mix.dta"

* 1a -- numeric rows, ids 1..3, %9.0f for clean integers
quant price mpg weight, output("`out'") by(foreign) addtotal idstart(1) format(%9.0f)

* 1b -- categorical rows, ids 10..12
qual  heavy cheap thirsty, output("`out'") append by(foreign) addtotal idstart(10)

* 2 -- label (one sheet, "auto_mix", covers both batches)
label_table, tab_file("`out'") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_mix") ///
             label_name("Characteristic")
save "`out'", replace

* 3 -- render
use "`out'", clear
kable, caption("Car characteristics by origin")
```

The `auto_mix` sheet:

| id | label                | order |
|----|----------------------|-------|
| 1  | Price                | 1     |
| 2  | Mileage (mpg)        | 2     |
| 3  | Weight (lbs.)        | 3     |
| 10 | Heavy (> 3,000 lbs)  | 4     |
| 11 | Cheap (< $5,000)     | 5     |
| 12 | Thirsty (< 20 mpg)   | 6     |

Rendered (verified on `sysuse auto`):

```
Table: Car characteristics by origin


+---------------------+---------------------+---------------------+--------------------------+
| Characteristic      | Domestic            | Foreign             | Total                    |
|                     | (N = 52)            | (N = 22)            | (N = 74)                 |
+:====================+====================:+====================:+=========================:+
| Price               | 4782  [4184 ; 6234] | 5759  [4499 ; 7140] | 74,  5006  [4195 ; 6342] |
|                     | (3291 / 15906)      | (3748 / 12990)      | (3291 / 15906)           |
+---------------------+---------------------+---------------------+--------------------------+
| Mileage (mpg)       | 19  [16 ; 22]       | 24  [21 ; 28]       | 74,  20  [18 ; 25]       |
|                     | (12 / 34)           | (14 / 41)           | (12 / 41)                |
+---------------------+---------------------+---------------------+--------------------------+
| Weight (lbs.)       | 3360  [2790 ; 3730] | 2180  [2020 ; 2650] | 74,  3190  [2240 ; 3600] |
|                     | (1800 / 4840)       | (1760 / 3420)       | (1760 / 4840)            |
+---------------------+---------------------+---------------------+--------------------------+
| Heavy (> 3,000 lbs) | 37 (71.2)           | 2 (9.1)             | 39 (52.7)                |
+---------------------+---------------------+---------------------+--------------------------+
| Cheap (< $5,000)    | 29 (55.8)           | 8 (36.4)            | 37 (50.0)                |
+---------------------+---------------------+---------------------+--------------------------+
| Thirsty (< 20 mpg)  | 30 (57.7)           | 5 (22.7)            | 35 (47.3)                |
+---------------------+---------------------+---------------------+--------------------------+
```

Row totals check: `37 + 2 = 39` (heavy), `29 + 8 = 37` (cheap),
`30 + 5 = 35` (thirsty). Dom+For `N`: `52 + 22 = 74` (Total).

!!! tip "Why the gap in ids?"
    `idstart(1)` for `quant` and `idstart(10)` for `qual` leaves headroom.
    If you later add a 4th numeric row, it takes id 4; Excel doesn't need
    re-renumbering. Use whatever gaps feel natural (5, 10, 100).

## 2. Control what ships — use the `order` column

The same `.dta` can serve several variants of the same table. The
`quant` / `qual` calls stay as they are; the Excel `order` column
decides what appears in the report and in what sequence.

Recap of the mechanic (full discussion in
[Tables overview](tables_overview.md#reordering-and-hiding-rows-edit-excel-not-stata)):

- `order = <number>` → row shown at that position
- `order` blank → row dropped from the labelled output

Say you want a shorter variant of the mixed demographics table from
§ 1 — price and the three binary indicators only, with `cheap` first.
Change nothing in Stata; edit the `auto_mix` sheet:

| id | label                | order |
|----|----------------------|-------|
| 1  | Price                | 1     |
| 2  | Mileage (mpg)        |       |  ← hidden
| 3  | Weight (lbs.)        |       |  ← hidden
| 10 | Heavy (> 3,000 lbs)  | 3     |
| 11 | Cheap (< $5,000)     | 2     |  ← moved above Heavy
| 12 | Thirsty (< 20 mpg)   | 4     |

Re-run the render step and the labelled table contains exactly four
rows (Price, Cheap, Heavy, Thirsty) in that order. The underlying
`auto_mix.dta` still has all six rows — only the labelled dataset
reflects the edit.

!!! tip "Two reports from one computation"
    Keep a long master sheet (`auto_mix_full`) and a short variant
    (`auto_mix_exec`) in the same workbook. Swap `tab_id()` between
    calls to produce an executive summary and a full appendix from the
    same `quant`/`qual` run.

## 3. Fan out in a loop

When the same analysis runs across many variables (e.g. every lab
parameter), the pattern from the project code is:

```stata
local params "price mpg weight headroom trunk length"

foreach v of local params {
    local vl = lower("`v'")
    local out "output_tables/auto_`vl'.dta"

    preserve
        quant `v', output("`out'") by(foreign) addtotal             idstart(1)
        quant `v', output("`out'") by(foreign) addtotal append      idstart(2) meanonly

        label_table, tab_file("`out'") ///
                     label_file("input_tables/tables_labels.xlsx") ///
                     tab_id("auto_params") ///
                     label_name("Statistic")
        save "`out'", replace
    restore
}
```

One sheet (`auto_params`) labels **all** of the per-parameter `.dta`s —
because `label_table` merges by the `id` column, not by variable name,
the same sheet is reusable for every file. The downstream
[`create_dyntex`](commands/create_dyntex.md) call enumerates each file
and emits one `kable` block per parameter.

!!! note "Special-casing one variable"
    Real workflows often need one parameter to use a different sheet.
    Branch on the variable name and switch `tab_id()`:
    ```stata
    if ("`vl'" == "price") {
        label_table, ..., tab_id("auto_price_special") ...
    }
    else {
        label_table, ..., tab_id("auto_params") ...
    }
    ```

## Checklist

When appending, the things that bite you most:

- [ ] Ids are **globally unique** across the dataset. Bump `idstart()`
      on every append.
- [ ] Every id you emit has a row in the Excel sheet — otherwise the
      row survives the merge but with a blank `label` and shows as an
      empty first cell.
- [ ] The `by()` variable is the same across every append (same levels,
      same labels). Different `by()` levels → different `value_*`
      columns → mismatched columns after merge.
- [ ] You save the dataset **after** `label_table` if other code reads
      it later (`label_table` writes to the dataset in memory; `save
      "`out'", replace` persists).

## See also

- [Quantitative tables](tables_quant.md)
- [Qualitative tables](tables_qual.md)
- [`label_table`](commands/label_table.md) · [`kable`](commands/kable.md)
- [`create_dyntex`](commands/create_dyntex.md) — how tables get into the
  rendered docx
