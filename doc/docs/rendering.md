# Rendering pipeline

The report goes from labelled datasets to a Word document in three
stages. [`statareport_render`](commands/statareport_render.md) wraps all
three in one call.

```
┌────────────────────┐   ┌──────────────────┐   ┌────────────────┐
│ tables_labels.xlsx │   │ $file_dyntex     │   │ $file_input    │
│ + labelled .dta    │──▶│ (DynTex control  │──▶│ (Markdown)     │──▶ docx
│ + figures          │   │  file)           │   │                │
└────────────────────┘   └──────────────────┘   └────────────────┘
  create_dyntex            dyntext                 knit
```

## Stage 1 — `create_dyntex`

Reads a sheet of captions from `$file_label` and emits a DynTex control
file at `$file_dyntex`:

```stata
create_dyntex using "$file_label", dyntex_file("$file_dyntex") ///
    label_sheet("$var_sheet_lab") tab_dir("$dir_lbltables") ///
    fig_dir("$dir_figures")
```

Each row in the Excel sheet produces either a table block (which emits
a `kable` call) or a figure block (which emits a Markdown image link).
Rows with `Include != "Yes"` are skipped. Orientation changes
(Portrait/Landscape) and section headings are honoured.

## Stage 2 — `dyntext`

Stata's built-in `dyntext` command compiles the DynTex control file into
a plain Markdown document. Every `<<dd_do>>` block runs its embedded
Stata code; every `<<dd_include>>` inlines a Markdown fragment. The
result is `$file_input`.

## Stage 3 — `knit`

Calls Pandoc with a defaults YAML to produce the docx:

```stata
knit using "$file_input", saving("$file_output") replace ///
    reference("$file_reference") prepend("$file_header") ///
    filters("$file_filters")
```

## Pandoc defaults YAML — what `knit` writes

`knit` auto-generates a temporary defaults YAML from its options unless
you pass one via `default()`. Mapping:

| `knit` option | `$file_*` global | Pandoc YAML key |
|---------------|-------------------|-----------------|
| `using` | `$file_input` | first entry of `input-files:` (or `input-file:` when no prepend) |
| `prepend()` | `$file_header` | *first* entry of `input-files:` |
| `saving()` | `$file_output` | `output-file:` |
| `reference()` | `$file_reference` | `reference-doc:` |
| `filters()` | `$file_filters` | `filters:` (one entry per token) |
| `first()` | — | `metadata-file:` |
| `in_header()` | — | `include-in-header:` (LaTeX preamble) |
| `default()` | `$file_default_options` | *is the YAML* |
| `from()` | — | `from:` |
| `to()` | — | `to:` |
| `toc()` | — | `table-of-contents:` |
| `number_sec()` | — | `number-sections:` |

### Default readers / writers

- `from: markdown+autolink_bare_uris+tex_math_single_backslash+grid_tables+multiline_tables`
- `to: docx+native_numbering+styles`

Override with `from()` / `to()` if your project needs different
pandoc extensions.

### `prepend()` vs `in_header()`

- **`prepend()`** points at a file that Pandoc *concatenates* in front
  of the main input. The project's `header.txt` (YAML title block +
  `\listoftables` / `\listoffigures`) is prepended this way, which is
  why the lists render inside the docx body.
- **`in_header()`** maps to `include-in-header:` — Pandoc places the
  file's contents in the output's LaTeX preamble. Rarely useful for
  docx output.

## Locating Pandoc

`knit` auto-detects pandoc:

1. `pandocloc()` if explicitly set.
2. `command -v pandoc` (POSIX) or `where pandoc` (Windows).
3. macOS Homebrew fallbacks: `/opt/homebrew/bin/pandoc`,
   `/usr/local/bin/pandoc`.
4. Literal `pandoc` on the system PATH.

## Regenerating `header.txt`

Use [`statareport_write_header`](commands/statareport_write_header.md)
whenever the study title or front-matter toggles change:

```stata
statareport_write_header using "$file_header", replace ///
    title("Sample trial") ///
    subtitle("Phase III report in paediatric HAT\n(protocol v3, Apr 2026)") ///
    author("contributors") toc listoftables listoffigures
```

The file gets a YAML front-matter block followed by `\newpage`,
`\tableofcontents`, `\listoftables`, `\listoffigures` directives
depending on the flags.

## Listings variant

Every `$file_*` global has a `_listings` twin so main and listings
documents coexist. `statareport_render`'s `variant()` reads the twins:

```stata
statareport_render                           // main
statareport_render, variant("listings") toc(no)
```

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| `pandoc: cannot find file` | Wrong `$file_input` / `$file_header`. Check `statareport_render`'s `[3/3] knit ->` line. |
| Tables not populated in docx | `list-tables.lua` missing from `filters()`. Add `$dir_input_md/list-tables.lua`. |
| Landscape page not switching | `page-orientation.lua` missing from `filters()`. |
| `option include() not allowed` | Old help-file example — use `prepend()` instead. |
| `option default() specified but file not found` | The YAML path was explicit but the file doesn't exist. Either supply a real file or omit `default()` to let knit auto-generate. |

## See also

- [`statareport_render`](commands/statareport_render.md)
- [`statareport_write_header`](commands/statareport_write_header.md)
- [`knit`](commands/knit.md)
- [`create_dyntex`](commands/create_dyntex.md)
- [`kable`](commands/kable.md)
