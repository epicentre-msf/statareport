# `compute_ci`

**compute_ci** --- Binomial confidence intervals for indicator variables, written to a publication-ready table.


## Syntax

`compute_ci` {varlist} [`if`]`,`
`output(string)`
[*options*]



**Options**


---

- `output(`*string*`)` — output dataset for the table (required)
- `method(`*string*`)` — interval method: `exact`, `wald`, `wilson`, `agresti`, or `jeffreys` (default `exact`)
- `level(`*numlist*`)` — confidence level in percent (default 95)
- `format(`*string*`)` — display format for percentages (default `%9.2f`)
- `append` — append the table to an existing `output()` dataset
- `by(`*varname*`)` — compute intervals within each level of a categorical variable
- `addtotal` — with `by()`, also add an overall (Total) column
- `idstart(`*integer*`)` — first row id (default 1)

---



## Description

`compute_ci` calculates binomial confidence intervals for one or more 0/1
indicator variables and writes the result to an output dataset, following the
same workflow as [`quant`](quant.md) and [`qual`](qual.md): one row per variable
with the columns `variable`, `label` and `value`, ready for
[`label_table`](label_table.md) and [`kable`](kable.md). Each `value` cell takes
the form *n (percent%), [lower% - upper%]*.

With `by()`, one `value_`*level* column is produced per level of the categorical
variable; `addtotal` appends an overall `value` (Total) column. The interval
method is selected with `method()` and defaults to the exact (Clopper-Pearson)
interval.


## Options

> `output(string)` is required and names the dataset the table is saved to. With
`append` the table is added to the rows already in `output()`.

> `method(string)` selects the interval method, mirroring `ci proportions`:
`exact` (Clopper-Pearson, the default), `wald`, `wilson`, `agresti`
(Agresti-Coull), or `jeffreys`.

> `level(numlist)` sets the confidence level in percent. Default is 95.
The value must be strictly between 0 and 100.

> `format(string)` sets the numeric display format for the percentage and
interval bounds. Default is `%9.2f`.

> `append` appends this table to an existing `output()` dataset instead of
overwriting it. The file must already exist.

> `by(varname)` computes a separate interval within each level of a labelled
categorical variable, producing one `value_`*level* column per level.

> `addtotal` adds an overall (Total) `value` column when `by()` is specified.

> `idstart(integer)` sets the id assigned to the first row (default 1), so
appended tables can keep a continuous id sequence.


## Examples

> `. compute_ci treated cured, output("ci.dta")`

> `. compute_ci response, output("ci.dta") method(jeffreys) level(90)`

> `. compute_ci heavy cheap, output("ci.dta") by(foreign) addtotal`

> `. compute_ci relapse, output("ci.dta") append idstart(5)`


## Also see

[`qual`](qual.md), [`quant`](quant.md), [`label_table`](label_table.md), [`add_perc`](add_perc.md)

---

*Source*: [`ado/compute_ci.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/compute_ci.sthlp)
