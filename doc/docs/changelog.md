# Changelog

## 1.2.0 — 2026-04-20

### Added

- **`statareport_init_project`** — one-call project scaffold. Creates
  the canonical folder tree, drops a populated
  `do_files/00-final-do-file.do`, stubs `01-07`, and copies the shipped
  Lua filters, reference docx, Excel templates, and pandoc resources
  into `input_md/` and `input_tables/`.
- **`statareport_load_env`** — dotenv loader. Reads
  `.StataEnviron` + OS environment into `$dir_*` globals; primes
  `statareport_set_data_root` when `DATASETS` is set.
- **`statareport_render`** — wraps `create_dyntex` +
  `dyntext` + `knit` into a single call with `variant()`, `skip_*`
  flags, and per-path overrides.
- **`statareport_write_header`** — generates `header.txt` from
  `title()`, `subtitle()`, `author()`, `toc`, `listoftables`,
  `listoffigures`.
- **`statareport_add_dir`** — register `$dir_<name>` with modes
  `project`/`parent`/`root`/`raw` and optional `mkdir`.
- **`statareport_add_data`** / **`statareport_confirm_data`** /
  **`statareport_set_data_root`** — the dataset registration family
  with `$data_<name>` globals and file-existence checks.
- **`statareport_set_paths`** — emit the full `$file_*` family from a
  single `prefix()` + `date()`; `variant("listings")` for the listings
  document.
- **`statareport_add_programs`** — `adopath ++` under the project
  root, positional argument form.
- **`reportdo`** — short alias for `do "$dir_dofiles/<name>.do"`.
- **Shipped resources** under `ressources/`: three Lua filters
  (`list-tables`, `page-orientation`, `table-breaks`), two header
  templates, two defaults YAML examples, two Word reference docs, two
  Excel templates, and `.StataEnviron.example`.

### Changed

- **`knit`**
    - Replaced the broken `include()` option with `prepend()` (maps to
      pandoc `input-files:`). `include_in_header` kept as `in_header()`
      for LaTeX preamble use.
    - Added `filters()`, `from()`, `to()` with defaults matching the
      shipped `default_options.yaml`.
    - Auto-detects pandoc (`command -v pandoc` / `where pandoc`) with
      Homebrew fallbacks on macOS.
    - Now `rclass` — returns `r(output)`, `r(defaults_file)`,
      `r(pandoc)`, `r(input)`.
- **`statareport_setup_dirs`** — also creates `do_files/`,
  `do_files/helpers/`, `programs/`, `output_tables/labelled_tables/`.
- **`kable`** / **`kable_basic`** — delegate to the new
  `statareport__read_file` / `statareport__writenone` helpers so the
  two commands share a single implementation.

### Fixed

- `knit` shell invocation: the old `local command "!"+"pandoc"` pattern
  emitted a literal `+` to the shell, which failed with "command not
  found". Rewritten to build `!"<pandoc>"` inline.
- `knit__write_defaults` `TOC(integer 0 1)` was invalid syntax;
  replaced with `TOC(integer 1)`.
- `convert_wisely.ado` and `add_perc.ado` had malformed
  ``` note `v': `"…''" ``` patterns that left a stray `'"` in every
  column note.
- `create_dyntex.ado` caption escaping used `"\""` which Stata parses
  as literal `\`; rewritten to use `char(34)`.
- `quant.ado` — `sd`/`grp_sum`/`sumonly` blocks now gated on the
  `!emptydb` guard.
- Help files: replaced `{psee}` (invalid) with `{pstd}` across seven
  sthlp files, added missing `{p_end}`, fixed `(numeric)` typesetting.
- Manifest: all new commands, help files, and shipped resources
  registered in `statareport.pkg`.

### Dev tooling

- `tools/smcl-vscode/` — optional VS Code extension (TextMate grammar
  + language configuration) packaged as a `.vsix`.
- `doc/` — MkDocs Material site, regenerated from the shipped `.sthlp`
  files via `doc/build_commands.sh`.
- GitHub Actions workflow publishes the site to GitHub Pages on every
  push to `main`.

---

## Prior releases

See the audit history under `.local/AUDIT_*.md` for a detailed account
of the 2026-02-17 rewrite that preceded this one.
