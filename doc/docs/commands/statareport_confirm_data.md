# `statareport_confirm_data`

**statareport_confirm_data** --- Re-verify that every `$data_*` global points to an existing file.


## Syntax

`statareport_confirm_data`
[`,` `strict` `ignore(`*namelist*`)` **`qui`**`et`]



**Options**


---

- `strict` — exit with rc 601 when any file is missing
- `ignore(`*namelist*`)` — global names (with or without the `data_` prefix) to skip
- **`qui`**`et` — suppress the summary line on success

---



## Description

Replaces the ad-hoc loop

    `local list_of_data : all globals "data_*"`  
`foreach d of local list_of_data {c -(`}  
`    capture confirm file "${c 96`d${c 39}"}  
`    if _rc display as error "${c 96`d${c 39} not found"}  
`{c )-`}

with a structured, scriptable version: each missing file is
reported, `r(n_missing)`/`r(n_total)`/`r(missing)` are
returned, and `strict` promotes any failure to an error exit.

Derived datasets that are produced later in the pipeline can be
skipped with `ignore()`. Either form is accepted:

    `ignore(local_core local_bio_bas)`
    `ignore(data_local_core data_local_bio_bas)`


## Examples

> `. statareport_confirm_data`
> `. statareport_confirm_data, ignore(local_core local_aecoded local_zscore)`
> `. statareport_confirm_data, strict`   // abort the run if anything is missing


## Stored results

`r(n_total)`: number of `$data_*` globals scanned  
`r(n_missing)`: count of globals whose file could not be confirmed  
`r(missing)`: space-separated list of those global names


## Also see

[`statareport_set_data_root`](statareport_set_data_root.md), [`statareport_add_data`](statareport_add_data.md), [`statareport_set_paths`](statareport_set_paths.md)

---

*Source*: [`ado/statareport_confirm_data.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_confirm_data.sthlp)
