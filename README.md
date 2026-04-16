# statareport

A distributable Stata package that bundles custom ado-files for automated report generation, table building, and document rendering.

## Contents

- `statareport.pkg`: package manifest for `net install`
- `stata.toc`: table of contents for `net describe`
- `ado/`: all ado-programs and their help files
- `examples/`: example do-files and sample data

## Commands

| Command | Description |
|---------|-------------|
| `quant` | Quantitative summary tables (median, mean, min/max, sums) |
| `qual` | Qualitative frequency tables with column or row percentages |
| `kable` | Render data as Pandoc Markdown grid or pipe table (Mata) |
| `kable_basic` | Lightweight Markdown grid table (no Mata) |
| `convert_wisely` | Convert variables to strings preserving headers |
| `add_perc` | Annotate count variables with percentages |
| `compute_ci` | Exact binomial confidence intervals |
| `compute_shift_graphs` | Baseline-vs-endpoint shift scatterplots |
| `create_dyntex` | Generate DynTex files from Excel configuration |
| `knit` | Render Markdown to Word via Pandoc |
| `label_table` | Merge label metadata from Excel |
| `generate_label_ids` | Assign sequential numeric labels to variables |
| `statareport_setup_dirs` | Create project directory scaffold |
| `statareport__apply_order` | (Internal) Sort rows to match user-defined order |

## Installation

After hosting this folder on GitHub, install from Stata with:

```
net install statareport, from("https://raw.githubusercontent.com/<org>/<repo>/<branch>/package-acozi") replace
```

Update `<org>`, `<repo>`, and `<branch>` with the appropriate repository path. The `replace` option ensures existing files are updated when you publish new versions.

## Getting help

After installation, type `help <command>` in Stata for documentation and examples:

```
help quant
help kable
help qual
```

## Updating the package

1. Edit or add ado-files in `source/`.
2. Copy or sync the updates into `ado/`.
3. Update version info or listing in `statareport.pkg` as needed.
4. Commit and push the changes to GitHub.
