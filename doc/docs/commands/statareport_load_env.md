# `statareport_load_env`

**statareport_load_env** --- Load environment-style KEY=VALUE pairs into `$dir_*` globals.


## Syntax

`statareport_load_env`
[`,` `file(`*path*`)`
`env(`*str*`)`
**`pre`**`fix(`*str*`)`
**`keep`**`case`
`noos`
**`qui`**`et`]



**Options**


---

- `file(`*path*`)` — path to a dotenv-style file; default `<project-root>/.StataEnviron`
- `env(`*str*`)` — inline `KEY=VALUE` pairs, space-separated
- **`pre`**`fix(`*str*`)` — only load keys starting with this prefix (stripped from the emitted global name)
- **`keep`**`case` — preserve the original key case in the global name (default: lowercase)
- `noos` — skip the OS-env fallback (`printenv` / `set`)
- **`qui`**`et` — suppress the per-key summary line

---



## Description

`statareport_load_env` is the "configuration loader" at the top of
a statareport master do-file. It reads `KEY=VALUE` pairs from three
places -- an inline option, a `.StataEnviron` file at the project
root, and the operating-system environment -- and exposes each one as
the Stata global `$dir_`*key* (lowercased unless `keepcase`
is passed).

The typical use is to keep machine-specific paths out of the
repository: you ship a `.StataEnviron.example` with placeholders,
each teammate copies it to `.StataEnviron` and fills in their own
OneDrive / data-export paths.


## Lookup order

    1. `env()` -- explicit, wins over file and OS.
    2. `file()` -- defaults to `<here-root>/.StataEnviron`. Key`=`value per line, shell comments (`#`) allowed, optional `export` prefix, quoted values accepted.
    3. OS environment -- `printenv` (POSIX) or `set` (Windows). Only an allow-list (`ONEDRIVE`, `DATASETS`, `PROJECT`) plus any `STATAREPORT_*` key are read; unrelated shell variables are ignored.


## Key-to-global mapping

Every key *K* becomes `$dir_`*k* (lowercased). A prefix
of `dir_` in the key is kept as-is, so both `ONEDRIVE=...` and
`DIR_ONEDRIVE=...` land in `$dir_onedrive`. Examples:

    `ONEDRIVE=/Users/me/OneDrive`{space 4}-> `$dir_onedrive`
    `DATASETS=/data/trial/Stata`{space 5}-> `$dir_datasets`
    `STATAREPORT_FOO=/etc/foo`{space 5}-> `$dir_foo` (when `prefix(STATAREPORT_)`)

When `DATASETS` is set, the command also primes
[`statareport_set_data_root`](statareport_set_data_root.md) with that value so that subsequent
[`statareport_add_data`](statareport_add_data.md) calls resolve relative paths correctly.


## Example .StataEnviron

> `# project-level config (gitignored)`
> `ONEDRIVE=/Users/me/Library/CloudStorage/OneDrive-Shared`
> `DATASETS=/Users/me/OneDrive/QC/Dataset_export/2026-04/Stata`
> `# PROJECT=...    # optional, falls back to `here' if omitted`


## Examples

> Typical master do-file opener:
> `. here`
> `. statareport_load_env`
> `. statareport_init_project, prefix("MyTrial")   // uses $dir_onedrive etc.`

> Explicit file, quiet:
> `. statareport_load_env, file("config/ci.env") quiet`

> Inline:
> `. statareport_load_env, env("ONEDRIVE=/mnt/od DATASETS=/data")`

> With prefix to pull only STATAREPORT_* keys:
> `. statareport_load_env, prefix(STATAREPORT_)`


## Stored results

`r(loaded)`: space-separated list of globals that were set  
`r(n_loaded)`: count of globals emitted  
`r(source)`: `file`, `env`, `os`, `mixed`, or `none`  
`r(file)`: resolved path of the env file (whether it existed or not)


## Also see

[`here`](here.md), [`statareport_set_data_root`](statareport_set_data_root.md), [`statareport_init_project`](statareport_init_project.md)

---

*Source*: [`ado/statareport_load_env.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_load_env.sthlp)
