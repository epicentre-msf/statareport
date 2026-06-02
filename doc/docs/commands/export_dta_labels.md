# `export_dta_labels`

**export_dta_labels** --- Export dataset, variable and value labels plus notes from every `.dta` in a folder into a pipe-delimited flat file.


## Syntax

`export_dta_labels` [`,` *options*]



**Options**


---

- `folder(string)` — directory holding the `.dta` files (default: current directory)
- `out:file(string)` — flat file to write (default: `<folder>/var_lbl_folder.txt`)

---



## Description

`export_dta_labels` is the first step of the label-translation
pipeline. It opens every `.dta` file in `folder` in turn and writes one
record per line to a single pipe-delimited text file. Each record carries a tag
identifying what it describes, so the free text can later be translated and
re-applied without touching the data themselves.

The record types written are:

`FILE|`*<file>* --- marks the start of a file's block
`DTALBL|`*<file>*`|`*<dataset label>*
`VARLBL|`*<file>*`|`*<var>*`|`*<variable label>*
`VALSET|`*<file>*`|`*<set>*`|`*<code>*`|`*<value label>*
`DTANOTE|`*<file>*`|`*<idx>*`|`*<note>*
`VARNOTE|`*<file>*`|`*<var>*`|`*<idx>*`|`*<note>*

On every record the only free text is the last field. Carriage returns and
line feeds inside a label are collapsed to spaces so each record stays on a
single line. Lines beginning with `#` are header comments that document the
format. The original `.dta` files are opened read-only and never modified.


## Options

> `folder(string)` directory that is scanned for `*.dta` files.
Defaults to the current working directory.

> `outfile(string)` path of the flat file to create. Defaults to
`var_lbl_folder.txt` inside `folder`. The file is overwritten if it
exists.


## Examples

> `. export_dta_labels, folder("data/raw")`

> `. export_dta_labels, folder("data/raw") outfile("labels.txt")`


## Workflow

`export_dta_labels` produces the input for [`translate_dta_labels`](translate_dta_labels.md),
whose output is consumed by [`apply_dta_labels`](apply_dta_labels.md):

`export_dta_labels` {c -} >{c -} `translate_dta_labels` {c -} >{c -} `apply_dta_labels`


## Also see

[`translate_dta_labels`](translate_dta_labels.md), [`apply_dta_labels`](apply_dta_labels.md)

---

*Source*: [`ado/export_dta_labels.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/export_dta_labels.sthlp)
