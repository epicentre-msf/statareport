# `label_table`

**label_table** --- Merge human-readable labels from Excel onto a Stata dataset.


## Syntax

`label_table``,`
**`tab_f`**`ile(`*string*`)`
**`label_f`**`ile(`*string*`)`
**`tab_i`**`d(`*string*`)`
[**`label_n`**`ame(`*string*`)`
**`value_n`**`ame(`*string*`)`
**`drop_v`**`alue(`*string*`)`]



**Options**


---

- **`tab_f`**`ile(`*string*`)` — path to the Stata dataset to label (required)
- **`label_f`**`ile(`*string*`)` — Excel workbook containing the label mapping (required)
- **`tab_i`**`d(`*string*`)` — worksheet name that holds the id/label mapping (required)
- **`label_n`**`ame(`*string*`)` — note attached to the `label` column
- **`value_n`**`ame(`*string*`)` — note propagated to all `value*` columns
- **`drop_v`**`alue(`*string*`)` — drop rows whose `value` matches this string
- `keepid` — retain the `id` column in the output dataset

---



## Description

`label_table` merges human-readable labels from an Excel workbook
onto a Stata dataset.  Both the dataset and the Excel sheet must contain an
`id` column.  The Excel sheet must also contain a `label` column.
Duplicate ids in the label sheet are dropped before the merge.  After merging
the command keeps only `label` and `value*` variables, sorted by
`order` (if present) or `id`.  Optional notes can be attached to the
`label` and `value*` columns for downstream use by [`kable`](kable.md) or
[`kable_basic`](kable_basic.md).

### Ordering and hiding rows via `order`

When the Excel sheet contains an `order` column:

- rows are sorted by `order` (ascending)
- rows whose `order` cell is **blank** (empty string or missing number)
  are **dropped** from the final labelled table

That second behavior is the supported way to hide a computed row from
the report: clear its `order` cell in Excel and re-render. The
underlying `quant` / `qual` output is untouched, so the analysis is
still complete — the Excel sheet just controls what makes it into the
published table.


## Options

> `tab_file(`*string*`)` specifies the path to the Stata
dataset that needs labelling.

> `label_file(`*string*`)` specifies the Excel workbook
containing the label mapping.

> `tab_id(`*string*`)` names the worksheet inside the Excel
workbook that holds the id-to-label mapping.

> `label_name(`*string*`)` attaches a note to the `label`
variable.  This note is used by [`kable`](kable.md) as a column header.

> `value_name(`*string*`)` attaches a note to every
`value*` variable.

> `drop_value(`*string*`)` drops rows whose `value`
variable matches the specified string (case sensitive after trimming).

> `keepid` retains the `id` column alongside `label` and
`value*` in the output dataset. By default only `label` and
`value*` are kept, which is the format consumed by [`kable`](kable.md).


## Examples

> `. label_table, tab_file("output_tables/ae_summary.dta") label_file("input_tables/labels.xlsx") tab_id("AE")`

> `. label_table, tab_file("output_tables/demographics.dta") label_file("input_tables/labels.xlsx") tab_id("DM") label_name("Characteristic") value_name("N (%)")`

> `. label_table, tab_file("output_tables/lab_results.dta") label_file("input_tables/labels.xlsx") tab_id("LAB") drop_value("NA")`

> `. label_table, tab_file("output_tables/ae.dta") label_file("input_tables/labels.xlsx") tab_id("AE") keepid`


## Also see

[`qual`](qual.md), [`quant`](quant.md), [`create_dyntex`](create_dyntex.md)

---

*Source*: [`ado/label_table.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/label_table.sthlp)
