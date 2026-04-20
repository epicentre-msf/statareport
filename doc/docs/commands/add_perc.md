# `add_perc`

**add_perc** --- Annotate count variables with formatted percentages.


## Syntax

`add_perc` *varlist* [`if`] [`,` *options*]

where *varlist* must contain only numeric count variables.


**Options**


---

- **`denom`**`inators(`*numlist*`)` — positive denominators; one value for all variables or one per variable
- `form(`*string*`)` — display format for percentages (default `%9.1f`)

---



## Description

`add_perc` replaces each numeric count variable in *varlist* with a
string of the form *count (percent)*. When `denominators()` is omitted
the sample size of the (possibly filtered) dataset is used as the denominator.
Variable labels and notes are preserved on the resulting string variables.


## Options

> `denominators(numlist)` specifies one or more positive denominators.
Provide a single value to reuse for all variables or the same number of values
as variables in *varlist*.

> `form(string)` sets the display format for the calculated percentages.
The default is `%9.1f`.


## Examples

> `. add_perc deaths recoveries if sex=="female", denominators(120)`

> `. add_perc n_adverse n_serious, denominators(250 180) form(%9.2f)`

> `. add_perc enrolled`


## Also see

[`qual`](qual.md), [`compute_ci`](compute_ci.md)

---

*Source*: [`ado/add_perc.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/add_perc.sthlp)
