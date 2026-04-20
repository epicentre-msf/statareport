# Quantitative tables

[`quant`](commands/quant.md) summarises numeric variables into a
publication-ready `.dta`. The default layout is **N, median [IQR],
(min / max)**; switch with `meanonly`, `medianonly`, or `sumonly`.

All examples use `sysuse auto`.

## Minimal example

```stata
sysuse auto, clear

quant price mpg weight, output("output_tables/auto_quant.dta")
```

The saved dataset has four columns (default format `%9.1f`):

=== "Formatted"

    | variable | label            | value                                                 | id |
    |----------|------------------|-------------------------------------------------------|----|
    | price    | Price            | `74, 5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0)`  | 1  |
    | mpg      | Mileage (mpg)    | `74, 20.0 [18.0 ; 25.0] \n (12.0 / 41.0)`             | 2  |
    | weight   | Weight (lbs.)    | `74, 3190.0 [2240.0 ; 3600.0] \n (1760.0 / 4840.0)`   | 3  |

=== "Source"

    ```markdown
    | variable | label         | value                                             | id |
    |----------|---------------|---------------------------------------------------|----|
    | price    | Price         | 74, 5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0) | 1  |
    | mpg      | Mileage (mpg) | 74, 20.0 [18.0 ; 25.0] \n (12.0 / 41.0)           | 2  |
    | weight   | Weight (lbs.) | 74, 3190.0 [2240.0 ; 3600.0] \n (1760.0 / 4840.0) | 3  |
    ```

The embedded `\n` becomes a real line break when `kable` renders the cell.

## Label it before rendering

The raw output shows raw variable names. Run [`label_table`](commands/label_table.md)
to replace them with the human-readable labels from
`tables_labels.xlsx` (sheet `auto_quant`).

```stata
label_table, tab_file("output_tables/auto_quant.dta") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_quant") ///
             label_name("Characteristic") ///
             value_name("Total \n (N = 74)")
save "output_tables/auto_quant.dta", replace
```

Minimum Excel sheet:

=== "Formatted"

    | id | label          | order |
    |----|----------------|-------|
    | 1  | Price          | 1     |
    | 2  | Mileage (mpg)  | 2     |
    | 3  | Weight (lbs.)  | 3     |

=== "Source"

    ```markdown
    | id | label          | order |
    |----|----------------|-------|
    | 1  | Price          | 1     |
    | 2  | Mileage (mpg)  | 2     |
    | 3  | Weight (lbs.)  | 3     |
    ```

!!! tip "Reorder or hide rows from Excel"
    The `order` column drives row order in the labelled output. Clear
    the cell for a row to drop it from the report — `quant` still
    computes it, but `label_table` filters it out. See
    [Tables overview — Reordering and hiding rows](tables_overview.md#reordering-and-hiding-rows-edit-excel-not-stata).

!!! warning "`save` after `label_table`"
    `label_table` edits the in-memory dataset (drops `variable`/`id`,
    reorders by `order`, attaches notes) but does not write to disk.
    Re-save before `kable` — otherwise `use "`out'", clear` reloads the
    unlabelled version.

After labelling, `label_table` keeps only `label` and `value*`, attaches
`label_name()` as a column-header note on `label`, and propagates
`value_name()` to every `value*`.

## Render

```stata
use "output_tables/auto_quant.dta", clear
kable, caption("Price, mileage and weight")
```

renders (verified output at default format `%9.1f`):

=== "Formatted"

    | Characteristic | Total<br>(N = 74) |
    |----------------|---|
    | Price          | 74, 5006.5<br>[4195.0 ; 6342.0]<br>(3291.0 / 15906.0) |
    | Mileage (mpg)  | 74, 20.0<br>[18.0 ; 25.0]<br>(12.0 / 41.0) |
    | Weight (lbs.)  | 74, 3190.0<br>[2240.0 ; 3600.0]<br>(1760.0 / 4840.0) |

=== "Raw (what kable writes)"

    ```text
    Table: Price, mileage and weight


    +----------------+--------------------------------+
    | Characteristic | Total                          |
    |                | (N = 74)                       |
    +:===============+===============================:+
    | Price          | 74,  5006.5  [4195.0 ; 6342.0] |
    |                | (3291.0 / 15906.0)             |
    +----------------+--------------------------------+
    | Mileage (mpg)  | 74,  20.0  [18.0 ; 25.0]       |
    |                | (12.0 / 41.0)                  |
    +----------------+--------------------------------+
    | Weight (lbs.)  | 74,  3190.0  [2240.0 ; 3600.0] |
    |                | (1760.0 / 4840.0)              |
    +----------------+--------------------------------+
    ```

The trailing `.0` comes from `%9.1f`. Integer variables (price, weight,
counts) read more cleanly with `format(%9.0f)`, shown in the next
section.

## Stratify with `by()`

```stata
quant price mpg weight, ///
    output("output_tables/auto_quant_by.dta") ///
    by(foreign) addtotal format(%9.0f)

label_table, tab_file("output_tables/auto_quant_by.dta") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_quant") ///
             label_name("Characteristic")
save "output_tables/auto_quant_by.dta", replace

use "output_tables/auto_quant_by.dta", clear
kable, caption("Price, mileage and weight by origin")
```

Each level of `foreign` becomes a `value_*` column with its own
`(N = …)` header; `addtotal` appends an overall column. Verified
output:

=== "Formatted"

    | Characteristic | Domestic<br>(N = 52) | Foreign<br>(N = 22) | Total<br>(N = 74) |
    |----------------|---|---|---|
    | Price          | 4782<br>[4184 ; 6234]<br>(3291 / 15906) | 5759<br>[4499 ; 7140]<br>(3748 / 12990) | 74, 5006<br>[4195 ; 6342]<br>(3291 / 15906) |
    | Mileage (mpg)  | 19<br>[16 ; 22]<br>(12 / 34)            | 24<br>[21 ; 28]<br>(14 / 41)            | 74, 20<br>[18 ; 25]<br>(12 / 41)            |
    | Weight (lbs.)  | 3360<br>[2790 ; 3730]<br>(1800 / 4840)  | 2180<br>[2020 ; 2650]<br>(1760 / 3420)  | 74, 3190<br>[2240 ; 3600]<br>(1760 / 4840)  |

=== "Raw (what kable writes)"

    ```text
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

!!! note
    Within-group cells drop the `N,` prefix — each column header
    already says `(N = …)`. The Total column keeps it for symmetry with
    the non-stratified layout.

!!! warning "`%9.0f` rounds halves"
    Domestic MPG median is `19` (truly 19); Foreign MPG median shows
    `24` but is actually `24.5` — `%9.0f` rounds it. Use the default
    `%9.1f` when half-integer medians matter.

## Display modes

```stata
quant price mpg, output("auto_mean.dta") meanonly           // N, mean (SD)
quant price mpg, output("auto_med.dta")  medianonly         // median [IQR] \n (min/max)
quant price,     output("auto_sum.dta")  sumonly by(foreign) addtotal   // sum (% of total sum)
```

Verified on `sysuse auto`:

=== "Formatted"

    | mode         | rendered cell (on `price`)                               |
    |--------------|----------------------------------------------------------|
    | *(default)*  | `74, 5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0)`     |
    | `meanonly`   | `74, 6165.3 (2949.5)`                                    |
    | `medianonly` | `5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0)`         |
    | `sumonly`    | Domestic `315766.0 (69.2)`, Foreign `140463.0 (30.8)`, Total `456229.0 (100.0)` |

=== "Source"

    ```markdown
    | mode         | rendered cell (on `price`)                                                     |
    |--------------|--------------------------------------------------------------------------------|
    | *(default)*  | 74, 5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0)                             |
    | `meanonly`   | 74, 6165.3 (2949.5)                                                            |
    | `medianonly` | 5006.5 [4195.0 ; 6342.0] \n (3291.0 / 15906.0)                                 |
    | `sumonly`    | Domestic 315766.0 (69.2), Foreign 140463.0 (30.8), Total 456229.0 (100.0)      |
    ```

## Formatting knobs

=== "Formatted"

    | option | default | effect |
    |---|---|---|
    | `format()` | `%9.1f` | any Stata numeric format |
    | `mxsep()` | `/` | min/max separator |
    | `mxbrack` | off | use `[min/max]` instead of `(min/max)` |
    | `medsep()` | `;` | IQR separator |
    | `medparenth` | off | use `(p25; p75)` instead of `[p25; p75]` |

=== "Source"

    ```markdown
    | option       | default | effect |
    |--------------|---------|--------|
    | `format()`   | `%9.1f` | any Stata numeric format |
    | `mxsep()`    | `/`     | min/max separator |
    | `mxbrack`    | off     | use `[min/max]` instead of `(min/max)` |
    | `medsep()`   | `;`     | IQR separator |
    | `medparenth` | off     | use `(p25; p75)` instead of `[p25; p75]` |
    ```

```stata
quant price mpg, output("auto_fmt.dta") ///
    format(%9.0f) mxsep("-") mxbrack medparenth
```

## Appending with `idstart()`

Each row gets an `id` starting at `idstart(1)`. When you append a second
batch, bump `idstart` so ids stay unique — this lets one Excel sheet
label both batches:

```stata
quant price mpg, output("mix.dta") idstart(1)
quant weight,    output("mix.dta") append idstart(10)
```

The [Complex tables](tables_complex.md) page shows this combined with
`qual`.

## See also

- [`quant` reference](commands/quant.md)
- [Qualitative tables](tables_qual.md)
- [Complex tables](tables_complex.md)
- [`label_table`](commands/label_table.md) · [`kable`](commands/kable.md)
