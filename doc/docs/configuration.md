# Configuration — `.StataEnviron`

Every teammate works in a slightly different environment: different
OneDrive paths, different OS, sometimes different data export drops.
`.StataEnviron` is a gitignored dotenv-style file that captures those
differences so the tracked master do-file stays identical across
machines.

## Why

Without `.StataEnviron` your master do-file ends up with hardcoded
absolute paths like:

```stata
global dir_onedrive "/Users/me/Library/CloudStorage/OneDrive-organization/..."
```

On the next laptop that path is wrong, somebody edits it, and the diff
pollutes every pull request. With `.StataEnviron`:

```
ONEDRIVE=/Users/me/Library/CloudStorage/OneDrive-organization/...
```

is kept **next to** the project (in `.StataEnviron`, gitignored) and
each teammate maintains their own copy. The master do-file just says
`statareport_load_env` and gets whatever the local machine provides.

## File format

A dotenv-style file at the project root. Shell conventions apply:

```bash
# .StataEnviron
# Lines starting with # are comments.
# Blank lines are ignored.

ONEDRIVE=/Users/me/Library/CloudStorage/OneDrive-YourOrg
DATASETS=/Users/me/.../QC/Dataset_export/2026-04/Stata

# Optional shell-style export prefix and quoted values
export MEDDRA="/Users/me/Meddra with spaces"
```

## Key → global mapping

| KEY in file | Stata global emitted |
|-------------|----------------------|
| `ONEDRIVE=…` | `$dir_onedrive` |
| `DATASETS=…` | `$dir_datasets` (also primes `statareport_set_data_root`) |
| `PROJECT=…` | `$dir_project` |
| `MEDDRA=…` | `$dir_meddra` |
| `DIR_FOO=…` | `$dir_foo` (already prefixed — not doubled) |
| `STATAREPORT_BAR=…` | `$dir_statareport_bar` (set `prefix(STATAREPORT_)` to strip) |

By default keys are lowercased; pass `keepcase` to keep the original
casing.

## Loading sources

`statareport_load_env` checks three places, first-wins:

1. **`env()` option** — inline, explicit, wins:
   ```stata
   statareport_load_env, env("ONEDRIVE=/mnt/od DATASETS=/data")
   ```
2. **The env file** — `<project>/.StataEnviron` by default, or
   `file(path)`.
3. **OS environment** — `printenv` / `set` output, filtered to an
   allow-list (`ONEDRIVE`, `DATASETS`, `PROJECT`, and any
   `STATAREPORT_*` key) so unrelated shell variables don't pollute
   your globals. Disable with `noos`.

## Use in practice

Bootstrap a new machine:

```sh
cp .StataEnviron.example .StataEnviron
# edit .StataEnviron with your local paths
```

The master do-file's opening already calls the loader:

```stata
here
statareport_load_env, quiet
statareport_init_project, prefix("MyTrial")     // or whatever bootstrap
```

Anywhere downstream that needs the OneDrive path just uses
`$dir_onedrive` — no more machine-specific hardcoding.

## CI / headless renders

For GitHub Actions or scheduled runs, pass the values inline or via the
OS environment instead of a `.StataEnviron` file:

```yaml
- name: render report
  env:
    STATAREPORT_ONEDRIVE: /tmp/fake_od
    STATAREPORT_DATASETS: /tmp/data
  run: |
    stata -b do do_files/00-final-do-file.do
```

then at the top of the do-file:

```stata
statareport_load_env, prefix("STATAREPORT_") quiet
```

## Gotchas

- The loader does **not** create directories. Paths that don't exist
  are still emitted as globals; the first downstream command that tries
  to use them raises the error.
- Values are passed to Stata verbatim. If your path contains a `$`,
  Stata will macro-expand it. Escape with `\$` or avoid dollar signs
  inside values.
- On Windows the fallback OS-env dump uses `set`, which always outputs
  CRLF. `statareport_load_env` strips the trailing `\r`, but if you're
  hand-authoring `.StataEnviron` on Windows, save it with LF line
  endings.

## See also

- [`statareport_load_env`](commands/statareport_load_env.md) — command reference
- [`statareport_set_data_root`](commands/statareport_set_data_root.md) — the command primed by `DATASETS`
- [`here`](commands/here.md) — what establishes the project root
