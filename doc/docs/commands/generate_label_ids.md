# `generate_label_ids`

**generate_label_ids** --- Assign sequential numeric labels to variables.


## Syntax

`generate_label_ids` {varlist}
[`,` **`start`**`ing(`*integer*`)`]



**Options**


---

- **`start`**`ing(`*integer*`)` — integer value at which the sequence begins (default `1`)

---



## Description

`generate_label_ids` assigns sequential numeric labels to each
variable in {varlist}.  The first variable receives the value specified by
`starting()`, the second receives `starting()` + 1, and so on.  This
is useful when downstream reporting templates expect unique numeric identifiers
stored in the variable-label metadata (e.g. for cross-referencing table
columns).


## Options

> `starting(`*integer*`)` sets the integer value at which the
numbering sequence begins.  The value must be non-negative.  If omitted the
default is `1`.


## Examples

> `. generate_label_ids age sex weight`

> `. generate_label_ids value1 value2 value3, starting(10)`

> `. ds value*`  `. generate_label_ids `r(varlist)', starting(100)`


## Also see

[`label_table`](label_table.md), [`qual`](qual.md), [`quant`](quant.md)

---

*Source*: [`ado/generate_label_ids.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/generate_label_ids.sthlp)
