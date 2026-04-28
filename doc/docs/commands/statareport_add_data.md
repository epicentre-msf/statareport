# `statareport_add_data`

**statareport_add_data** --- Register a .dta file as the global `$data_`*name* and confirm its presence.


## Syntax

`statareport_add_data``,`
**`n`**`ame(`*string*`)` `path(`*string*`)`
[`root(`*string*`)` `raw` **`pro`**`ject` **`loc`**`al`
**`opt`**`ional` **`qui`**`et`]



**Options**


---

- **`n`**`ame(`*string*`)` — stem appended to `data_` in the emitted global (required)
- `path(`*string*`)` — path to the dataset (required)
- `root(`*string*`)` — override the cached data root for this one call
- `raw` — use `path()` verbatim; do not prepend any root
- **`pro`**`ject` — resolve relative paths against the [`here`](here.md) project root instead of the data root
- **`loc`**`al` — resolve relative paths against the [`statareport_set_local_data_root`](statareport_set_local_data_root.md) cache instead of the data root
- **`opt`**`ional` — the dataset may not exist yet; suppress the missing-file warning
- **`qui`**`et` — suppress the "registered" line on success

---



## Description

`statareport_add_data` is the per-dataset counterpart of
[`statareport_set_paths`](statareport_set_paths.md). Each call:

    1. Resolves `path()` according to the mode below.
    2. Sets the Stata global `$data_`*name* to the resolved path.
    3. Runs `confirm file` against the path. A missing file triggers
a warning unless `optional` is specified.


## Resolution modes

`path()` is normalised (backslashes to forward slashes), and
absolute paths (`/...`, `X:/...`) are always used verbatim. For a
relative path the root is chosen by the first matching rule:

    * `raw`           -- no root prepended; the path is used as-is.
    * `root(`*p*`)`      -- use *p* just for this call.
    * `project`       -- join with `__here_root__` (the [`here`](here.md) cache).
    * `local`         -- join with `__statareport_local_data_root__` (the [`statareport_set_local_data_root`](statareport_set_local_data_root.md) cache).
    * (default)           -- join with `__statareport_data_root__` (the [`statareport_set_data_root`](statareport_set_data_root.md) cache).

The modes are mutually exclusive: specifying more than one among
`raw`, `project`, `local`, and `root()` aborts with rc 198.
Specifying `project` when [`here`](here.md) has not run, or `local`
when [`statareport_set_local_data_root`](statareport_set_local_data_root.md) has not been called, aborts
with rc 459.


## Examples

Bulk registration with a shared data root:
> `. here`
> `. statareport_set_data_root, path("$dir_datasets")`
> `. statareport_add_data, name(preselection)   path("preselection_visit.dta")`
> `. statareport_add_data, name(blood_sampling) path("blood_sampling_for_pk.dta")`

An already-qualified path (OneDrive global, raw mode):
> `. statareport_add_data, name(meddra) path("$dir_onedrive/Meddra/meddra_codes.dta") raw`

A derived dataset that lives inside the project repo (resolved
against [`here`](here.md) instead of the data root):
> `. statareport_add_data, name(local_core) ///`
> `      path("local_datasets/core.dta") project optional`

Many derived datasets sharing the same project-local folder
(set the local root once, then pass bare filenames):
> `. statareport_set_local_data_root`
> `. statareport_add_data, name(core)     path("core.dta")     local optional`
> `. statareport_add_data, name(ae_coded) path("ae_coded.dta") local optional`


## Stored results

`r(name)`: supplied name  
`r(path)`: resolved absolute path written to `$data_`*name*  
`r(mode)`: one of `raw`, `root`, `project`, `local`, `data`  
`r(missing)`: 1 if `confirm file` failed, 0 otherwise


## Also see

[`statareport_set_data_root`](statareport_set_data_root.md), [`statareport_set_local_data_root`](statareport_set_local_data_root.md), [`statareport_confirm_data`](statareport_confirm_data.md), [`statareport_set_paths`](statareport_set_paths.md), [`here`](here.md)

---

*Source*: [`ado/statareport_add_data.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_add_data.sthlp)
