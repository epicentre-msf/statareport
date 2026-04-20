# Qualitative tables

[`qual`](commands/qual.md) turns binary (0/1) or dummy indicators into a
publication-ready frequency table: **N (percentage)** per indicator,
optionally stratified by a categorical variable.

All examples use `sysuse auto`.

## Minimal example

The `auto` dataset ships with numeric variables. Create a few 0/1
indicators to tabulate:

```stata
sysuse auto, clear

gen heavy  = weight > 3000 if !missing(weight)
gen cheap  = price  < 5000 if !missing(price)
gen thirsty = mpg   < 20   if !missing(mpg)

label var heavy   "Heavy (> 3,000 lbs)"
label var cheap   "Cheap (< $5,000)"
label var thirsty "Thirsty (< 20 mpg)"

qual heavy cheap thirsty, output("output_tables/auto_qual.dta")
```

The saved dataset has four columns — `variable`, `label`, `value`, `id`.
Each `value` cell holds `N (percentage)`:

=== "Formatted"

    | variable | label                 | value          | id |
    |----------|-----------------------|----------------|----|
    | heavy    | Heavy (> 3,000 lbs)   | `39 (52.7)`    | 1  |
    | cheap    | Cheap (< $5,000)      | `37 (50.0)`    | 2  |
    | thirsty  | Thirsty (< 20 mpg)    | `35 (47.3)`    | 3  |

=== "Source"

    ```markdown
    | variable | label               | value     | id |
    |----------|---------------------|-----------|----|
    | heavy    | Heavy (> 3,000 lbs) | 39 (52.7) | 1  |
    | cheap    | Cheap (< $5,000)    | 37 (50.0) | 2  |
    | thirsty  | Thirsty (< 20 mpg)  | 35 (47.3) | 3  |
    ```

## Label it before rendering

Pair with an Excel sheet (`auto_qual`) to replace variable names with
publication labels:

```stata
label_table, tab_file("output_tables/auto_qual.dta") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_qual") ///
             label_name("Characteristic") ///
             value_name("Total \n (N = 74)")
save "output_tables/auto_qual.dta", replace
```

Minimum Excel sheet:

=== "Formatted"

    | id | label                | order |
    |----|----------------------|-------|
    | 1  | Heavy (> 3,000 lbs)  | 1     |
    | 2  | Cheap (< $5,000)     | 2     |
    | 3  | Thirsty (< 20 mpg)   | 3     |

=== "Source"

    ```markdown
    | id | label                | order |
    |----|----------------------|-------|
    | 1  | Heavy (> 3,000 lbs)  | 1     |
    | 2  | Cheap (< $5,000)     | 2     |
    | 3  | Thirsty (< 20 mpg)   | 3     |
    ```

!!! tip "Reorder or hide rows from Excel"
    The `order` column drives row order in the labelled output. Clear
    the cell for a row to drop it from the report — `qual` still
    computes it, but `label_table` filters it out. See
    [Tables overview — Reordering and hiding rows](tables_overview.md#reordering-and-hiding-rows-edit-excel-not-stata).

!!! warning "`save` after `label_table`"
    `label_table` modifies the dataset in memory only. Re-save before
    `kable` — otherwise `use "`out'", clear` reloads the unlabelled
    version.

## Render

```stata
use "output_tables/auto_qual.dta", clear
kable, caption("Car characteristics")
```

renders (verified on `sysuse auto`):

=== "Formatted"

    | Characteristic      | Total<br>(N = 74) |
    |---------------------|---|
    | Heavy (> 3,000 lbs) | 39 (52.7) |
    | Cheap (< $5,000)    | 37 (50.0) |
    | Thirsty (< 20 mpg)  | 35 (47.3) |

=== "Raw (what kable writes)"

    ```text
    Table: Car characteristics


    +---------------------+-----------+
    | Characteristic      | Total     |
    |                     | (N = 74)  |
    +:====================+==========:+
    | Heavy (> 3,000 lbs) | 39 (52.7) |
    +---------------------+-----------+
    | Cheap (< $5,000)    | 37 (50.0) |
    +---------------------+-----------+
    | Thirsty (< 20 mpg)  | 35 (47.3) |
    +---------------------+-----------+
    ```

(`39/74 = 52.7%`, `37/74 = 50.0%`, `35/74 = 47.3%`.)

## Stratify with `by()`

```stata
qual heavy cheap thirsty, ///
    output("output_tables/auto_qual_by.dta") by(foreign) addtotal

label_table, tab_file("output_tables/auto_qual_by.dta") ///
             label_file("input_tables/tables_labels.xlsx") ///
             tab_id("auto_qual") ///
             label_name("Characteristic")
save "output_tables/auto_qual_by.dta", replace

use "output_tables/auto_qual_by.dta", clear
kable, caption("Car characteristics by origin")
```

Each level of `foreign` becomes a `value_*` column; `addtotal` appends
the overall column. Verified output:

=== "Formatted"

    | Characteristic      | Domestic<br>(N = 52) | Foreign<br>(N = 22) | Total<br>(N = 74) |
    |---------------------|---|---|---|
    | Heavy (> 3,000 lbs) | 37 (71.2) | 2 (9.1)  | 39 (52.7) |
    | Cheap (< $5,000)    | 29 (55.8) | 8 (36.4) | 37 (50.0) |
    | Thirsty (< 20 mpg)  | 30 (57.7) | 5 (22.7) | 35 (47.3) |

=== "Raw (what kable writes)"

    ```text
    Table: Car characteristics by origin


    +---------------------+-----------+----------+-----------+
    | Characteristic      | Domestic  | Foreign  | Total     |
    |                     | (N = 52)  | (N = 22) | (N = 74)  |
    +:====================+==========:+=========:+==========:+
    | Heavy (> 3,000 lbs) | 37 (71.2) | 2 (9.1)  | 39 (52.7) |
    +---------------------+-----------+----------+-----------+
    | Cheap (< $5,000)    | 29 (55.8) | 8 (36.4) | 37 (50.0) |
    +---------------------+-----------+----------+-----------+
    | Thirsty (< 20 mpg)  | 30 (57.7) | 5 (22.7) | 35 (47.3) |
    +---------------------+-----------+----------+-----------+
    ```

Each row totals correctly: `37 + 2 = 39`, `29 + 8 = 37`, `30 + 5 = 35`.

## Column vs row percentages

The default (`pct(col)`) computes the share *within* each by-group — how
many Domestic cars are heavy, out of all Domestic cars. `pct(row)`
computes the share *across* by-groups — of all heavy cars, how many are
Domestic.

```stata
qual heavy cheap thirsty, output("auto_row.dta") by(foreign) pct(row) addtotal
```

Row-percent example (heavy row, `37 + 2 = 39` total): Domestic
`37 (94.9)`, Foreign `2 (5.1)`, Total `39 (100.0)`.

!!! warning
    `pct(row)` requires the indicators to be 0/1. `qual` errors out if
    any variable contains values outside `{0, 1, missing}`.

## Tabulate-style: one categorical, many dummies

For a single categorical variable, use `tabulate ..., gen()` first:

```stata
tabulate rep78, generate(rep_)
qual rep_*, output("auto_rep.dta") by(foreign) addtotal pct(row)
```

Each `rep_#` indicator becomes a row in the table; `pct(row)` gives the
distribution across `foreign` for each repair score.

## Formatting and appending

=== "Formatted"

    | option         | default | effect                                            |
    |----------------|---------|---------------------------------------------------|
    | `format()`     | `%9.1f` | display format for percentages                    |
    | `addtotal`     | off     | include overall column when `by()` is specified   |
    | `pct()`        | `col`   | `col` (within-group) or `row` (across groups)     |
    | `idstart(n)`   | `1`     | starting value for the `id` column                |

=== "Source"

    ```markdown
    | option       | default | effect                                          |
    |--------------|---------|-------------------------------------------------|
    | `format()`   | `%9.1f` | display format for percentages                  |
    | `addtotal`   | off     | include overall column when `by()` is specified |
    | `pct()`      | `col`   | `col` (within-group) or `row` (across groups)   |
    | `idstart(n)` | `1`     | starting value for the `id` column              |
    ```

As with `quant`, multiple `qual` calls can feed the same dataset with
`append` and distinct `idstart()` values — see
[Complex tables](tables_complex.md).

## See also

- [`qual` reference](commands/qual.md)
- [Quantitative tables](tables_quant.md)
- [Complex tables](tables_complex.md)
- [`label_table`](commands/label_table.md) · [`kable`](commands/kable.md)
