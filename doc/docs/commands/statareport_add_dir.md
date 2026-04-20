# `statareport_add_dir`

**statareport_add_dir** --- Register a directory as the global `$dir_`*name*.


## Syntax

`statareport_add_dir``,`
**`n`**`ame(`*string*`)` `path(`*string*`)`
[`root(`*string*`)` `raw` **`par`**`ent(`*string*`)`
**`mk`**`dir` **`opt`**`ional` **`qui`**`et`]



**Options**


---

- **`n`**`ame(`*string*`)` — stem appended to `dir_` in the emitted global (required)
- `path(`*string*`)` — directory path (required)
- `root(`*string*`)` — override the default root for this one call
- `raw` — use `path()` verbatim; do not prepend any root
- **`par`**`ent(`*string*`)` — resolve relative to another registered directory (name of an existing `$dir_*` global)
- **`mk`**`dir` — create the directory if it does not yet exist
- **`opt`**`ional` — suppress the "does not exist" warning
- **`qui`**`et` — suppress the "registered" line on success

---



## Description

`statareport_add_dir` is the directory-scoped sibling of
[`statareport_add_data`](statareport_add_data.md). Each call sets the Stata global
`$dir_`*name* to the resolved absolute path. Absolute input paths
pass through untouched; relative paths are resolved by the first matching
rule below:

    * `raw`           -- no root prepended.
    * `root(`*p*`)`      -- prepend *p*.
    * `parent(`*n*`)`    -- prepend `$dir_`*n* (or `$`*n* if the name already starts with `dir_`).
    * (default)           -- prepend `__here_root__` (the [`here`](here.md) project root).

`raw`, `root()`, and `parent()` are mutually exclusive.
Passing more than one aborts with rc 198.

Unlike [`statareport_add_data`](statareport_add_data.md), the default root for
`statareport_add_dir` is the `here` project root, not the data
root -- directories in a statareport project are almost always children
of the repo.


## Examples

A typical project-directory block:
> `. here`
> `. statareport_add_dir, name(dofiles) path("do_files")`
> `. statareport_add_dir, name(tables)  path("output_tables")`
> `. statareport_add_dir, name(figures) path("output_figures")`

Nested directory resolved against an already-registered sibling:
> `. statareport_add_dir, name(lbltables) path("labelled_tables") parent(tables)`
produces `$dir_lbltables = $dir_tables/labelled_tables`.

An external location resolved through a user-defined global:
> `. statareport_add_dir, name(external) path("$dir_onedrive/Shared") raw`

Create the directory if it is missing:
> `. statareport_add_dir, name(logs) path("logs") mkdir`


## Stored results

`r(name)`: supplied name  
`r(path)`: resolved absolute path written to `$dir_`*name*  
`r(mode)`: one of `project`, `raw`, `root`, `parent`  
`r(exists)`: 1 if the directory is present on disk, 0 otherwise


## Also see

[`statareport_add_data`](statareport_add_data.md), [`statareport_set_paths`](statareport_set_paths.md), [`statareport_setup_dirs`](statareport_setup_dirs.md), [`here`](here.md)

---

*Source*: [`ado/statareport_add_dir.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_add_dir.sthlp)
