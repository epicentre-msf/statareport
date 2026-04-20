# `statareport_add_programs`

**statareport_add_programs** --- Add project-local ado directories to the adopath.


## Syntax

`statareport_add_programs` *dir* [*dir* *...*]
[`,` **`pre`**`pend` **`qui`**`et`]



**Options**


---

- **`pre`**`pend` — use `adopath +` instead of `adopath ++` (prepend: higher search priority)
- **`qui`**`et` — suppress the per-path confirmation line

---



## Description

`statareport_add_programs` replaces the usual block

    `quietly adopath ++ "$dir_project/programs"`  
`quietly adopath ++ "$dir_project/extras"`

with a one-line equivalent

    `statareport_add_programs programs extras`

Each positional argument is resolved as follows:

    * absolute path (`/...`, `X:/...`) : used verbatim.
    * relative path                          : joined to the [`here`](here.md) project root (`__here_root__`).

Missing directories trigger a warning and are skipped; `adopath`
would otherwise silently fail to find anything in them. Run `here`
once in your master do-file to seed the project root.


## Examples

> `. here`
> `. statareport_add_programs programs extras`
> `. statareport_add_programs helpers lib/stata, prepend`
> `. statareport_add_programs "/shared/ado", quiet`


## Stored results

`r(paths)`: quoted list of directories actually added  
`r(added)`: count of directories appended to the adopath  
`r(missing)`: count of directories that did not exist and were skipped


## Also see

[`statareport_add_dir`](statareport_add_dir.md), [`statareport_add_data`](statareport_add_data.md), [`here`](here.md), `adopath`

---

*Source*: [`ado/statareport_add_programs.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_add_programs.sthlp)
