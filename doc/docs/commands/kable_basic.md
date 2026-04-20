# `kable_basic`

**kable_basic** --- Lightweight Markdown grid-table exporter using fixed-width spacing.


## Syntax

`kable_basic`
[`,` **`sp`**`ace(`*numlist*`)`
**`out`**`put(`*string*`)`
`round(`*real*`)`
`caption(`*string*`)`
`usevarnames`
`usevarlabels`
`nachar(`*string*`)`
**`foot`**`note(`*string*`)`]



**Options**


---

- **`sp`**`ace(`*numlist*`)` — column widths in characters; one value per variable or a single value applied to all
- **`out`**`put(`*string*`)` — write the Markdown table to the specified file
- `round(`*#*`)` — rounding increment for numeric variables (default `0.01`)
- `caption(`*string*`)` — table caption written above the grid table
- `usevarnames` — use variable names as column headers
- `usevarlabels` — use variable labels as column headers
- `nachar(`*string*`)` — string displayed for missing values (default `-`)
- **`foot`**`note(`*string*`)` — paragraph appended below the table

---



## Description

`kable_basic` is a lightweight variant of [`kable`](kable.md) that pads
columns with fixed-width spacing and uses Stata's `export delimited`
instead of Mata to build Markdown grid tables.  It supports the same core
options as `kable` (column widths, captions, footnotes, missing-value
characters) but omits the pipe-table option.  Use `kable` for modern
features; use `kable_basic` for compatibility with older workflows or
environments where Mata is unavailable.


## Options

> `space(`*numlist*`)` sets the character width of each column.
Provide one value per variable, or a single value that is replicated for every
column.  When omitted the widths are computed automatically from the data and
header lengths.

> `output(`*string*`)` specifies a file path for the Markdown
output.  When omitted the table is displayed in the Stata Results window.

> `round(`*#*`)` sets the rounding increment for numeric
variables.  The default is `0.01`.

> `caption(`*string*`)` provides a caption rendered as a
`Table:` line above the grid table.

> `usevarnames` forces variable names to be used as column headers
instead of the default behaviour (notes, then labels, then names).

> `usevarlabels` forces variable labels to be used as column headers.

> `nachar(`*string*`)` replaces missing values with the
specified string.  The default is `-`.

> `footnote(`*string*`)` appends a footnote paragraph after the
table body.


## Examples

> `. sysuse auto, clear`  `. kable_basic, usevarnames`

> `. kable_basic, output("output_md/table1.md") caption("Baseline characteristics") footnote("Source: trial database.")`

> `. kable_basic, space(30) round(0.1) nachar("N/A") usevarlabels`


## Also see

[`kable`](kable.md), [`convert_wisely`](convert_wisely.md)

---

*Source*: [`ado/kable_basic.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/kable_basic.sthlp)
