# `statareport_set_local_data_root`

**statareport_set_local_data_root** --- Cache a project-local data directory used by [`statareport_add_data`](statareport_add_data.md)`,` `local`.


## Syntax

`statareport_set_local_data_root` [`,` `path(`*string*`)` `clear` **`mk`**`dir` **`qui`**`et`]



**Options**


---

- `path(`*string*`)` — directory used as the local data root. Default: `local_datasets`
- `clear` — forget the cached root
- **`mk`**`dir` — create the directory if it does not yet exist
- **`qui`**`et` — suppress the confirmation message

---



## Description

`statareport_set_local_data_root` is the cousin of
[`statareport_set_data_root`](statareport_set_data_root.md) for derived or intermediate datasets
that live *inside* the project repository -- typically the
`local_datasets/` folder created by [`statareport_setup_dirs`](statareport_setup_dirs.md).
The resolved path is stored in the Mata global
`__statareport_local_data_root__`, kept separate from the external
data root so a project can reference both at once: a shared dataset
export *and* a working folder under version control.

[`statareport_add_data`](statareport_add_data.md) consults this cache only when invoked
with the new `local` option (see below). Existing modes
(`raw`, `project`, `root()`, default) are unchanged.


## Resolution rules

`path()` is normalised (backslashes to forward slashes), and:

    * Absolute paths (`/...`, `X:/...`) are stored verbatim.
    * Relative paths are joined with `__here_root__` (the [`here`](here.md) cache). When `here` has not yet run, `c(pwd)` is used and a note is printed.
    * When `path()` is omitted the stem `local_datasets` is used so the command Just Works in a freshly scaffolded project.

Nothing is verified at set time unless `mkdir` is given, in
which case a missing directory is created (rc 693 / EEXIST is treated
as success). Use [`statareport_confirm_data`](statareport_confirm_data.md) to audit the
resulting `$data_*` globals once datasets are registered.


## Examples

Default (`<here>/local_datasets`) inside a freshly initialised project:
> `. here`
> `. statareport_set_local_data_root`

Custom folder, materialise it:
> `. statareport_set_local_data_root, path("derived") mkdir`

Absolute path (e.g. a shared scratch volume):
> `. statareport_set_local_data_root, path("/Volumes/scratch/`c(username)'/trial")`

Forget the cache:
> `. statareport_set_local_data_root, clear`

Pair with [`statareport_add_data`](statareport_add_data.md)`,` `local` to write
short, root-anchored paths:
> `. statareport_set_local_data_root`
> `. statareport_add_data, name(core)        path("core.dta")           local optional`
> `. statareport_add_data, name(ae_coded)    path("ae_coded.dta")       local optional`


## Stored results

`r(path)`: resolved absolute path stored in `__statareport_local_data_root__`


## Also see

[`statareport_set_data_root`](statareport_set_data_root.md), [`statareport_add_data`](statareport_add_data.md), [`statareport_confirm_data`](statareport_confirm_data.md), [`statareport_setup_dirs`](statareport_setup_dirs.md), [`here`](here.md)

---

*Source*: [`ado/statareport_set_local_data_root.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_set_local_data_root.sthlp)
