# `lastexport`

**lastexport** --- Locate the most recent dated export folder under a parent directory.


## Syntax

`lastexport``,` **`p`**`arent(`*path*`)`
[**`pa`**`ttern(`*str*`)`
**`nch`**`ars(`*#*`)`
**`str`**`ict`
**`qui`**`et`]



**Options**


---

- **`p`**`arent(`*path*`)` — directory whose dated subfolders are scanned (required)
- **`pa`**`ttern(`*str*`)` — glob to restrict candidate names (default `*`)
- **`nch`**`ars(`*#*`)` — number of characters that make a date name (default `8`; use `10` for `YYYY-MM-DD`)
- **`str`**`ict` — abort with rc 601 when no dated folder is found (default: warn)
- **`qui`**`et` — suppress the "latest export date" line

---



## Description

`lastexport` scans `parent()` for subfolders whose names are
dates and returns the one that sorts last. Because zero-padded
`YYYYMMDD` names sort lexicographically in the same order as they do
chronologically, a plain string comparison yields the most recent export
without parsing dates.

The typical use is at the top of a master do-file: point at a data
export directory, capture the newest drop, and feed it into
[`statareport_set_data_root`](statareport_set_data_root.md).


## Name filter

A folder name is accepted when its length matches `nchars()`
and, after stripping dashes, it parses as a number. So

    `20260419`{space 4}-- passes with the default `nchars(8)`
    `2026-04-19`{space 2}-- passes with `nchars(10)` (dashes removed before the number check)
    `april-2026`{space 1}-- rejected (not all digits)
    `99999999`{space 4}-- passes (the command does not validate actual calendar dates)


## Examples

> Typical pattern inside a master do-file:
> `. lastexport, parent("$dir_onedrive/QC/Dataset_export")`
> `. statareport_set_data_root, path("$dir_onedrive/QC/Dataset_export/`r(latest)'/Stata")`

> Accept hyphenated date folders:
> `. lastexport, parent("/data/exports") nchars(10)`

> Fail hard when no dated folder exists:
> `. lastexport, parent("$dir_onedrive/QC/Dataset_export") strict`


## Stored results

`r(latest)`: the latest dated folder name (empty if none found)  
`r(path)`: `parent()/latest` — empty when no match  
`r(n_matches)`: number of dated folders detected


## Also see

[`statareport_set_data_root`](statareport_set_data_root.md), [`statareport_load_env`](statareport_load_env.md), [`statareport_init_project`](statareport_init_project.md)

---

*Source*: [`ado/lastexport.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/lastexport.sthlp)
