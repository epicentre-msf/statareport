# `reportdo`

**reportdo** --- Shortcut for `do` on a file inside `$dir_dofiles`.


## Syntax

`reportdo` *name*
[`,` **`arg`**`s(`*string*`)` **`qui`**`et`]



**Options**


---

- **`arg`**`s(`*string*`)` — extra arguments passed to the underlying `do`
- **`qui`**`et` — run via `quietly do`

---



## Description

`reportdo` is a one-token wrapper around `do`. It resolves
*name* against `$dir_dofiles` (set by
[`statareport_add_dir`](statareport_add_dir.md)`, name(dofiles)`), appends `.do` if you
omit the extension, and forwards extra arguments when
`args()` is given.

Absolute paths (starting with `/` or `X:/`) are executed
verbatim, so the command remains useful outside the `do_files/`
folder.


## Examples

> `. reportdo 01-create-datasets`
> `. reportdo helpers/make_cohort`
> `. reportdo 06-safety, quiet`
> `. reportdo compile_report, args("2026-04-19 listings")`


## Also see

[`statareport_add_dir`](statareport_add_dir.md), [`statareport_init_project`](statareport_init_project.md), `do`

---

*Source*: [`ado/reportdo.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/reportdo.sthlp)
