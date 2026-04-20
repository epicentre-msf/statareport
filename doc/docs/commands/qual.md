# `qual`

**qual** --- Produce publication-ready frequency tables for categorical variables.


## Syntax

`qual` {varlist} [`if`]`,`
**`out`**`put(`*string*`)` [*options*]



**Options**


---

- **`out`**`put(`*string*`)` — destination Stata dataset (required)
- `format(`*string*`)` — format for percentages (default `%9.1f`)
- `append` — append results to an existing output file
- `by(`*varname*`)` — stratify by a labelled categorical variable (max=1)
- `addtotal` — include a Total column when using `by()`
- `idstart(`*integer*`)` — starting value for the `id` column (default 1)
- `pct(`*string*`)` — percentage type: `col` (default) or `row`

---



## Description

`qual` summarises binary or categorical indicator variables into a tidy
Stata dataset ready for publication. Counts and percentages are computed and
written to the file specified by `output()`. Results can be stratified by a
single `by()` variable and optionally include a `Total` column.
Column percentages (`pct(col)`) compute the share within each by-group,
while row percentages (`pct(row)`) compute shares across by-groups for each
category.


## Options

> `output(string)` specifies the file path for the resulting Stata
dataset. This option is required.

> `format(string)` sets the display format for computed percentages.
Default is `%9.1f`.

> `append` appends the current results to an existing output file
instead of overwriting it.

> `by(varname)` stratifies the frequency table by the specified labelled
categorical variable. Only one variable is allowed.

> `addtotal` adds a Total column that aggregates across all levels of
the `by()` variable.

> `idstart(integer)` sets the starting value for the generated `id`
column. Default is 1.

> `pct(string)` selects the percentage type. `col` (the default)
computes column percentages within each by-group. `row` computes row
percentages across by-groups.


## Examples

> `. qual adverse_event grade*, output("output_tables/ae_summary.dta") by(site) addtotal`

> `. qual sex smoking, output("output_tables/demographics.dta") format(%9.2f) idstart(10)`

> `. qual outcome if visit==4, output("output_tables/outcome.dta") by(arm) pct(row) append`


## Also see

[`quant`](quant.md), [`kable`](kable.md), [`convert_wisely`](convert_wisely.md)

---

*Source*: [`ado/qual.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/qual.sthlp)
