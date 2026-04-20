# `create_dyntex`

**create_dyntex** --- Generate a DynTex control file from a labelled Excel sheet.


## Syntax

`create_dyntex` `using` *filename*`,`
**`dyntex_f`**`ile(`*string*`)`
**`label_s`**`heet(`*string*`)`
**`tab_d`**`ir(`*string*`)`
**`fig_d`**`ir(`*string*`)`
[**`nbin`**`put(`*numlist*`)`]



**Options**


---

- **`dyntex_f`**`ile(`*string*`)` — path to the output DynTex file (required)
- **`label_s`**`heet(`*string*`)` — name of the Excel worksheet containing table/figure instructions (required)
- **`tab_d`**`ir(`*string*`)` — directory containing `.dta` table datasets (required)
- **`fig_d`**`ir(`*string*`)` — directory containing PNG figure files (required)
- **`nbin`**`put(`*numlist*`)` — limit processing to the first *N* rows of the label sheet

---



## Description

`create_dyntex` reads table and figure instructions from an Excel
worksheet and writes a DynTex control file compatible with Stata's dynamic
document system.  The label sheet must contain the following columns:
**InputID**, **Include**, **Caption**, **Figure**, **FootNote**,
**Section**, **Subsection**, and **DisplayMode**.  Rows whose **Include**
column is not set to `"Yes"` are skipped.  Page orientation switches
between Portrait and Landscape based on **DisplayMode**, and section and
subsection headings are emitted when they change.


## Options

> `dyntex_file(`*string*`)` specifies the path where the
generated DynTex file will be written.  This file is subsequently consumed by
`dyndoc` or a similar Stata dynamic document renderer.

> `label_sheet(`*string*`)` names the Excel worksheet inside
*filename* that contains the table/figure metadata.

> `tab_dir(`*string*`)` is the directory that holds `.dta`
files referenced by the **InputID** column.  Each table row writes a
`kable` call that loads *tab_dir*/*InputID*.dta.

> `fig_dir(`*string*`)` is the directory containing PNG images
referenced by the **InputID** column.

> `nbinput(`*numlist*`)` restricts the command to the first
*N* rows of the label sheet.  Useful for debugging a subset of outputs.


## Examples

> `. create_dyntex using "input_tables/labels.xlsx", dyntex_file("output_md/report.txt") label_sheet("Tables") tab_dir("output_tables") fig_dir("output_figures")`

> `. create_dyntex using "metadata.xlsx", dyntex_file("draft.txt") label_sheet("AllOutputs") tab_dir("tables") fig_dir("figures") nbinput(5)`

> `. create_dyntex using "labels.xlsx", dyntex_file("output_md/appendix.txt") label_sheet("Appendix") tab_dir("output_tables") fig_dir("output_figures")`


## Also see

[`kable`](kable.md), [`knit`](knit.md), [`label_table`](label_table.md)

---

*Source*: [`ado/create_dyntex.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/create_dyntex.sthlp)
