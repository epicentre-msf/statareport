# `quant`

**quant** --- Generate descriptive summaries for numeric variables.


## Syntax

`quant` *varlist* [`if`]`,`
**`out`**`put(`*string*`)` [*options*]

where *varlist* must contain only numeric variables.


**Options**


---

- **`out`**`put(`*string*`)` — destination Stata dataset (required)
- `append` — append results to an existing dataset
- `by(`*varname*`)` — stratify by a labelled categorical variable (max=1)
- `fullresult` — display N, median (IQR), and min/max
- `meanonly` — display N, mean (SD)
- `medianonly` — display median (IQR) and min/max
- `sumonly` — display sum and percentage of total sum
- `format(`*string*`)` — optional global numeric format, used for any statistic without its own option
- **`meanform`**`at(`*string*`)` — numeric format for the mean and SD (default `%9.1f`)
- **`medform`**`at(`*string*`)` — numeric format for the median and IQR (default: the variable's own format)
- **`mxform`**`at(`*string*`)` — numeric format for the min and max (default: the variable's own format)
- `idstart(`*integer*`)` — starting identifier value (default 1)
- `addtotal` — include an overall Total column when `by()` is specified
- `mxsep(`*string*`)` — separator between min and max values (default `/`)
- `mxbrack` — use square brackets around min/max instead of parentheses
- `medsep(`*string*`)` — separator within the IQR (default `;`)
- `medparenth` — use parentheses around the IQR instead of brackets

---



## Description

`quant` generates descriptive summaries for numeric variables and writes
the results to a Stata dataset suitable for table production. The default
display is N, median [IQR] (min/max). Alternative layouts are selected with
`meanonly` (N, mean (SD)), `medianonly` (median [IQR], min/max), or
`sumonly` (sum and percentage relative to the total sum). Output can be
stratified by a single categorical variable with `by()` and optionally
include a total column with `addtotal`.


## Options

> `output(string)` specifies the file path for the resulting Stata
dataset. This option is required.

> `append` appends the current results to an existing dataset instead
of overwriting it.

> `by(varname)` stratifies the summary by the specified labelled
categorical variable. Only one variable is allowed.

> `fullresult` displays the full result layout: N, median (IQR), and
min/max. This is the default when no layout option is specified.

> `meanonly` displays N, mean (SD) only.

> `medianonly` displays median (IQR) and min/max without the count.

> `sumonly` displays the sum and its percentage relative to the total
sum across all observations.

> `format(string)` sets an optional global numeric display format, used for
every statistic that does not have its own per-statistic option below. It has
no default of its own: when omitted, the per-statistic defaults apply.

> `meanformat(string)` sets the numeric display format for the mean and SD.
Precedence: this option, else `format`, else the default `%9.1f`. May be
abbreviated `meanform`.

> `medformat(string)` sets the numeric display format for the median and the
interquartile range (Q1/Q3). Precedence: this option, else `format`, else
**the variable's own display format** (e.g. a `%9.0f` variable prints its
median with no decimals), falling back to `%9.1f` only if that format is somehow
unavailable. Resolved per variable. May be abbreviated `medform`.

> `mxformat(string)` sets the numeric display format for the minimum and
maximum. Precedence: this option, else `format`, else **the variable's own
display format** (falling back to `%9.1f` if unavailable). Resolved per
variable. May be abbreviated `mxform`.

> `idstart(integer)` sets the starting identifier value for the
generated `id` column. Default is 1.

> `addtotal` includes an overall Total column when `by()` is
specified.

> `mxsep(string)` sets the separator between the minimum and maximum
values. Default is `/`.

> `mxbrack` uses square brackets around min/max (e.g., [min/max])
instead of parentheses.

> `medsep(string)` sets the separator within the interquartile range.
Default is `;`.

> `medparenth` uses parentheses around the IQR (e.g., (p25; p75))
instead of square brackets.


## Examples

> `. quant age weight, output("output_tables/quant_summary.dta") by(treatment) addtotal`

> `. quant hemoglobin if visit==1, output("output_tables/hb_baseline.dta") meanonly format(%9.2f)`

> `. quant cost, output("output_tables/cost.dta") sumonly by(region) mxsep("-") medparenth append`

> `. quant age, output("output_tables/age.dta") medformat(%9.0f) meanformat(%9.1f) mxformat(%9.0f)`


## Also see

[`qual`](qual.md), [`kable`](kable.md), [`convert_wisely`](convert_wisely.md)

---

*Source*: [`ado/quant.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/quant.sthlp)
