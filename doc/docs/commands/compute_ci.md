# `compute_ci`

**compute_ci** --- Calculate exact Clopper-Pearson binomial confidence intervals for indicator variables.


## Syntax

`compute_ci` {varname} [`if`]`,`
[*options*]



**Options**


---

- `level(`*numlist*`)` — confidence level in percent (default 95)
- `format(`*string*`)` — display format for percentages (default `%9.2f`)
- `replace` — overwrite an existing `tab_`*varname* variable

---



## Description

`compute_ci` calculates exact Clopper-Pearson binomial confidence
intervals for a 0/1 indicator variable and stores the result in a new string
variable named `tab_`*varname*. The string takes the form
*n (percent%), [lower% - upper%]*. If the output variable already exists,
`replace` must be specified to overwrite it.


## Options

> `level(numlist)` sets the confidence level in percent. Default is 95.
The value must be strictly between 0 and 100.

> `format(string)` sets the numeric display format for the point
estimate and interval bounds. Default is `%9.2f`.

> `replace` overwrites an existing `tab_`*varname* variable
instead of issuing an error.


## Examples

> `. compute_ci treated if site=="A", level(99) replace`

> `. compute_ci cured, format(%5.1f)`

> `. compute_ci response if arm==1, level(90) replace format(%9.3f)`


## Also see

[`qual`](qual.md), [`add_perc`](add_perc.md)

---

*Source*: [`ado/compute_ci.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/compute_ci.sthlp)
