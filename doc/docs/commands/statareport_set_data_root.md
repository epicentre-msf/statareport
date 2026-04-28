# `statareport_set_data_root`

**statareport_set_data_root** --- Cache the default data directory used by [`statareport_add_data`](statareport_add_data.md).


## Syntax

`statareport_set_data_root``,` [`path(`*string*`)` `clear` **`qui`**`et`]



**Options**


---

- `path(`*string*`)` — directory that relative dataset paths resolve against
- `clear` — forget the cached root
- **`qui`**`et` — suppress the confirmation message

---



## Description

`statareport_set_data_root` stores `path()` in the Mata global
`__statareport_data_root__`. [`statareport_add_data`](statareport_add_data.md) consults this
cache whenever it receives a relative path, mirroring the role of
[`here`](here.md) for the project root. Nothing is validated at set time -- use
[`statareport_confirm_data`](statareport_confirm_data.md) to audit the resulting `$data_*`
globals.

For derived / intermediate datasets that live *inside* the
project repo, the cousin command [`statareport_set_local_data_root`](statareport_set_local_data_root.md)
caches a separate root in `__statareport_local_data_root__` which
[`statareport_add_data`](statareport_add_data.md)`,` `local` resolves against. The two
caches coexist independently.


## Examples

> `. statareport_set_data_root, path("$dir_datasets")`
> `. statareport_set_data_root, clear`


## Also see

[`statareport_set_local_data_root`](statareport_set_local_data_root.md), [`statareport_add_data`](statareport_add_data.md), [`statareport_confirm_data`](statareport_confirm_data.md), [`here`](here.md), [`statareport_set_paths`](statareport_set_paths.md)

---

*Source*: [`ado/statareport_set_data_root.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_set_data_root.sthlp)
