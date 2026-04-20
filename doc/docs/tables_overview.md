# Tables

`statareport` builds every table in three steps:

| Step | Command | Output |
|---|---|---|
| 1. Compute | [`quant`](commands/quant.md) / [`qual`](commands/qual.md) | `.dta` with `variable`, `label`, `value*`, `id` columns |
| 2. Label | [`label_table`](commands/label_table.md) | same `.dta`, with human-readable labels merged from Excel |
| 3. Render | [`kable`](commands/kable.md) | a Pandoc Markdown grid table |

```mermaid
flowchart LR
    A[raw data] --> B[quant / qual]
    B --> C[label_table]
    C --> D[kable]
    D --> E[pandoc .docx]
```


## Example

Using the built-in `auto` dataset:

```stata
sysuse auto, clear

* 1 -- compute (format %9.0f = integers; drop it for one-decimal default)
quant price mpg weight, ///
    output("output_tables/auto_quant.dta") ///
    by(foreign) addtotal format(%9.0f)

* 2 -- label (reads sheet "auto_quant" from the Excel workbook)
label_table, tab_file("output_tables/auto_quant.dta") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_quant") ///
             label_name("Characteristic")
save "output_tables/auto_quant.dta", replace

* 3 -- render
use "output_tables/auto_quant.dta", clear
kable, caption("Price, mileage and weight by origin")
```

The rendered grid (verified on `sysuse auto`):

```
Table: Price, mileage and weight by origin


+----------------+---------------------+---------------------+--------------------------+
| Characteristic | Domestic            | Foreign             | Total                    |
|                | (N = 52)            | (N = 22)            | (N = 74)                 |
+:===============+====================:+====================:+=========================:+
| Price          | 4782  [4184 ; 6234] | 5759  [4499 ; 7140] | 74,  5006  [4195 ; 6342] |
|                | (3291 / 15906)      | (3748 / 12990)      | (3291 / 15906)           |
+----------------+---------------------+---------------------+--------------------------+
| Mileage (mpg)  | 19  [16 ; 22]       | 24  [21 ; 28]       | 74,  20  [18 ; 25]       |
|                | (12 / 34)           | (14 / 41)           | (12 / 41)                |
+----------------+---------------------+---------------------+--------------------------+
| Weight (lbs.)  | 3360  [2790 ; 3730] | 2180  [2020 ; 2650] | 74,  3190  [2240 ; 3600] |
|                | (1800 / 4840)       | (1760 / 3420)       | (1760 / 4840)            |
+----------------+---------------------+---------------------+--------------------------+
```

!!! note "`save` after `label_table`"
    `label_table` rewrites the in-memory dataset (drops `variable`/`id`,
    reorders by `order`, attaches notes) but does **not** write it back
    to disk. Re-save before `kable` — otherwise `use "`out'", clear`
    reloads the unlabelled version.

!!! note "Format"
    Default format is `%9.1f`, which appends `.0` to every integer
    (`4184.0`, `3291.0`, ...). `format(%9.0f)` gives the clean integer
    output above; switch to it for price/weight/counts, keep the default
    for continuous measures that actually have decimals.

Without the `label_table` step, the first column would show raw variable
names (`price`, `mpg`, `weight`) and the first two columns would be
`Variables` / `Variables labels` — useful for debugging, not for a report.

## The `id` column and the Excel sheet

Every row produced by `quant` / `qual` has an `id`. The Excel workbook
holds one sheet per table, keyed by the same `id`. `label_table` reads
the sheet and merges it onto the dataset.

Minimum layout of a sheet (here `auto_quant`):

| id | label           | order |
|----|-----------------|-------|
| 1  | Price           | 1     |
| 2  | Mileage (mpg)   | 2     |
| 3  | Weight (lbs.)   | 3     |

Required columns are `id` and `label`; `order` is optional and, when
present, drives the row order of the final table. `label_table` drops the
`variable` column, keeps `label` and `value*`, and attaches column-header
notes from `label_name()` and `value_name()`, which [`kable`](commands/kable.md)
reads when rendering.

!!! tip "One workbook per report"
    `statareport_init_project` drops an editable `tables_labels.xlsx`
    into `input_tables/`. Add one sheet per table; the sheet name is
    what you pass to `tab_id()`.

## Reordering and hiding rows — edit Excel, not Stata

The `order` column is the single knob that controls what reaches the
rendered table. Two rules:

1. **Reorder a row** — change its `order` number. `label_table` sorts
   by `order` ascending, so `order = 1` appears first.
2. **Hide a row** — clear its `order` cell (leave it blank).
   `label_table` drops any row whose `order` is blank from the labelled
   output.

This means the underlying `quant` / `qual` computation never changes.
The dataset at `output_tables/...dta` still contains every row you
computed. Only the **labelled** dataset produced by `label_table` — the
one `kable` actually renders — reflects the `order` edits.

Example — suppress the `Mileage (mpg)` row without touching Stata code:

| id | label           | order |
|----|-----------------|-------|
| 1  | Price           | 1     |
| 2  | Mileage (mpg)   |       |  ← blank: row dropped from the report
| 3  | Weight (lbs.)   | 2     |

Move `Weight` above `Price`? Swap the order values:

| id | label           | order |
|----|-----------------|-------|
| 1  | Price           | 2     |
| 2  | Mileage (mpg)   | 3     |
| 3  | Weight (lbs.)   | 1     |

!!! tip "Leave gaps in your `order` numbers"
    Number rows `10, 20, 30, ...` instead of `1, 2, 3`. Inserting a new
    row later is then a matter of picking `15` without renumbering
    anything.

## When to use which command

- **`quant`** — numeric variables you want to summarise (N, median, IQR,
  min/max, or mean / SD). See [Quantitative tables](tables_quant.md).
- **`qual`** — 0/1 indicators or `tabulate ..., gen()` dummies you want
  counts and percentages for. See [Qualitative tables](tables_qual.md).
- **Both, in one table** — append with `idstart()`. See
  [Complex tables](tables_complex.md).

## Next

- [Quantitative tables](tables_quant.md)
- [Qualitative tables](tables_qual.md)
- [Complex tables](tables_complex.md)
