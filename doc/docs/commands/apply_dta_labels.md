# `apply_dta_labels`

**apply_dta_labels** --- Re-apply translated labels and notes from a flat file onto the original `.dta` files, writing the result into a sub-directory.


## Syntax

`apply_dta_labels` [`,` *options*]



**Options**


---

- `folder(string)` — directory holding the original `.dta` files (default: current directory)
- `in:file(string)` — translated flat file (default: `<folder>/var_lbl_folder_en.txt`)
- `sub:dir(string)` — sub-directory of `folder` to write relabelled copies into (default: `en`)

---



## Description

`apply_dta_labels` is the final step of the label-translation
pipeline. It reads the translated flat file written by
[`translate_dta_labels`](translate_dta_labels.md), re-opens each original `.dta` file named in a
`FILE|` record, applies the translated dataset label, variable labels,
value-label sets and notes, and saves the relabelled copy under
`<folder>/<subdir>/`. The data are never altered {c -} only the metadata.

Notes are dropped and rebuilt in the order they appear in the file so
indices stay consistent. The leading file field on every record is checked
against the current `FILE|` block; a mismatch stops the run to avoid writing
labels onto the wrong dataset. The text is read with `macval` so embedded
backticks or apostrophes in a label are treated as literal text rather than
expanded as macros.


## Options

> `folder(string)` directory holding the original `.dta` files.
Defaults to the current working directory. Paths inside the flat file are
resolved relative to it.

> `infile(string)` the translated flat file to read. Defaults to
`var_lbl_folder_en.txt` inside `folder`, the default `outfile` of
[`translate_dta_labels`](translate_dta_labels.md).

> `subdir(string)` sub-directory of `folder` into which the
relabelled copies are saved. Created if needed. Defaults to `en`.


## Examples

> `. apply_dta_labels, folder("data/raw")`

> `. apply_dta_labels, folder("data/raw") subdir("english")`

> `. apply_dta_labels, folder("data/raw") infile("labels_en.txt") subdir("en")`


## Workflow

`apply_dta_labels` consumes the output of [`translate_dta_labels`](translate_dta_labels.md),
which in turn consumes the output of [`export_dta_labels`](export_dta_labels.md):

`export_dta_labels` {c -} >{c -} `translate_dta_labels` {c -} >{c -} `apply_dta_labels`


## Also see

[`export_dta_labels`](export_dta_labels.md), [`translate_dta_labels`](translate_dta_labels.md)

---

*Source*: [`ado/apply_dta_labels.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/apply_dta_labels.sthlp)
