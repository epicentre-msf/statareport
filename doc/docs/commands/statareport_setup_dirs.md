# `statareport_setup_dirs`

**statareport_setup_dirs** --- Create the standard directory scaffold for statareport projects.


## Syntax

`statareport_setup_dirs`
[`,` `root(`*string*`)`]



**Options**


---

- `root(`*string*`)` — root folder under which directories are created (default: current working directory)

---



## Description

`statareport_setup_dirs` creates the standard directory scaffold
expected by `statareport` workflows.  The following eight directories are
created under the root folder: `input_md`, `input_tables`,
`output_md`, `output_tables`, `output_figures`, `output_word`,
`logs`, and `local_datasets`.  Existing directories are left
untouched.  When certain placeholder files are missing the command writes
template files: a CSV template in `input_tables/`, a Markdown placeholder
in `input_md/`, and a `.gitkeep` file in `logs/`.


## Options

> `root(`*string*`)` specifies the root folder under which the
directory tree is created.  Path separators are normalised and trailing slashes
are trimmed.  When omitted the current working directory is used.


## Examples

> `. statareport_setup_dirs`

> `. statareport_setup_dirs, root("C:/Projects/trial_report")`

> `. statareport_setup_dirs, root("../my_analysis")`


## Also see

[`knit`](knit.md), [`create_dyntex`](create_dyntex.md), [`qual`](qual.md), [`quant`](quant.md)

---

*Source*: [`ado/statareport_setup_dirs.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_setup_dirs.sthlp)
