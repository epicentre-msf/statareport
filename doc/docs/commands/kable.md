# `kable`

**kable** --- Export in-memory dataset to a Pandoc Markdown table.


## Syntax

`kable` [`,` *options*]



**Options**


---

- `space(`*numlist*`)` — column widths in characters; one value per variable or a single value for all
- **`out`**`put(`*string*`)` — write the Markdown table to the specified file
- `round(`*real*`)` — rounding increment for numeric variables (default 0.01)
- `caption(`*string*`)` — table caption placed above the grid
- `usevarnames` — use variable names as column headers
- `usevarlabels` — force variable labels to be used as column headers
- `nachar(`*string*`)` — string to display for missing values (default `-`)
- `footnote(`*string*`)` — paragraph appended after the table
- `pipe` — use pipe table format instead of grid table format

---



## Description

`kable` converts the dataset currently held in memory into a Pandoc
Markdown grid table (or pipe table when `pipe` is specified). Categorical
variables with value labels are decoded, numeric variables are rounded to the
specified increment, and column headers are derived from stored variable notes
(falling back to labels, then names). Extended missing values (`.a` through
`.z`) are detected and replaced with `nachar()`. The rendering engine
uses Mata. When `output()` is omitted the table is displayed in the Stata
Results window.


## Options

> `space(numlist)` sets the column widths in characters. Provide one
value per variable or a single value that is recycled for every column.

> `output(string)` writes the Markdown table to the specified file
path. If omitted, the table is printed to the Results window.

> `round(real)` rounding increment applied to numeric variables before
display. Default is 0.01.

> `caption(string)` a caption placed above the table in the Markdown
output.

> `usevarnames` uses variable names as column headers when no stored
notes or labels are available.

> `usevarlabels` forces variable labels to be used as column headers,
overriding stored notes.

> `nachar(string)` the string used to represent missing values in the
table. Default is `-`.

> `footnote(string)` a paragraph of text appended below the table.

> `pipe` produces a pipe-delimited table instead of the default grid
format.


## Examples

> `. sysuse auto, clear`
> `. kable, usevarnames caption("Auto dataset") output("output_md/table1.md")`

> `. kable, space(15) round(0.1) nachar("N/A") footnote("Source: Stata auto dataset.")`

> `. kable, pipe usevarlabels output("output_md/table_pipe.md") caption("Pipe format example")`


## Also see

[`kable_basic`](kable_basic.md), [`convert_wisely`](convert_wisely.md), [`knit`](knit.md)

---

*Source*: [`ado/kable.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/kable.sthlp)
