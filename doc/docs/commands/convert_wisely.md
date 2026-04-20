# `convert_wisely`

**convert_wisely** --- Convert variables to strings for reporting while preserving headers.


## Syntax

`convert_wisely` {varlist} [`,` *options*]



**Options**


---

- `round(`*real*`)` — rounding increment for numeric variables (default 0.01)
- `usevarnames` — use variable names as stored column headers
- `usevarlabels` — force variable labels to be used as stored column headers

---



## Description

`convert_wisely` replaces each variable in *varlist* with a string
representation suitable for tabulation. Value-labelled variables are decoded to
their label text, numeric variables are rounded to the specified increment, and
a note is stored on each column so that downstream exporters (such as
`kable`) can render meaningful headers. The header priority is: stored
variable note, then variable label, then variable name -- unless overridden by
`usevarnames` or `usevarlabels`.


## Options

> `round(real)` rounding increment applied to numeric variables before
conversion to string. Default is 0.01.

> `usevarnames` stores the variable name as the column header note,
regardless of whether a label or existing note is present.

> `usevarlabels` forces the variable label to be stored as the column
header note when a label is available, overriding any existing note.


## Examples

> `. convert_wisely weight height bmi, round(0.1) usevarlabels`

> `. convert_wisely treatment_group sex, usevarnames`

> `. convert_wisely age hemoglobin creatinine, round(0.001)`


## Also see

[`kable`](kable.md), [`kable_basic`](kable_basic.md)

---

*Source*: [`ado/convert_wisely.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/convert_wisely.sthlp)
