# Contributing

## Development workflow

1. Clone the repo and install the package from a local path for
   dogfooding:
   ```stata
   net install statareport, from("/path/to/repo/statareport/") replace
   ```
2. Edit `.ado` and `.sthlp` files under `ado/`.
3. Regenerate the doc site's command pages:
   ```sh
   ./doc/build_commands.sh
   ```
4. Preview the site locally:
   ```sh
   pip install mkdocs-material
   mkdocs serve -f doc/mkdocs.yml
   ```
5. Commit and push. The GitHub Actions workflow publishes the site to
   GitHub Pages on every push to `main`.

## Adding a new command

1. Drop `ado/<name>.ado` and `ado/<name>.sthlp`.
2. Add two `f ado/<name>.ado` and `f ado/<name>.sthlp` entries to
   `statareport.pkg`.
3. Add the command to `doc/mkdocs.yml`'s `nav` under the right
   category.
4. Rerun `./doc/build_commands.sh` — the page is generated from the
   sthlp automatically.
5. If the command is an internal helper users shouldn't see in the
   nav, add its basename to the `SKIP` list in
   `doc/build_commands.sh`.

## Style guide

- Stata help files: `{pstd}` for body paragraphs, `{phang}` for indent,
  `{synopt:…}DESC{p_end}` for option tables. Avoid `{psee}` — it's
  not valid SMCL. Always close with `{p_end}` so the builder can
  detect paragraph ends.
- Option naming: match the other commands in the family. `raw`,
  `project`, `optional`, `quiet`, `replace` are reserved idioms with
  consistent semantics across the package.
- Returns: prefer `rclass` with explicit `return local …` for every
  resolved path. Downstream composition relies on this.
- Error codes: `198` for syntax, `459` for missing state (e.g. `here`
  hasn't run), `601` for missing files.

## Running the audit

The `.local/` folder holds the most recent audit report. Re-auditing
before a release is as simple as re-reading
`.local/AUDIT_2026-04-20.md` and ticking items off — most Priority 1
fixes land in a single commit.

## Bug reports

Open an issue on [GitHub](https://github.com/epicentre-msf/statareport/issues)
with a minimal do-file that reproduces the problem and the version
string from `statareport.pkg` (`d Distribution-Date: …`).
