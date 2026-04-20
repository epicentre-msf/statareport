# Commands

Every command ships a Stata help file too — `help <name>` inside Stata
shows the same content.

## Project scaffolding

| Command | Purpose |
|---------|---------|
| [`here`](here.md) | walk up to the project root, cache in Mata |
| [`statareport_setup_dirs`](statareport_setup_dirs.md) | create the canonical folder layout |
| [`statareport_init_project`](statareport_init_project.md) | full project bootstrap — folders + do-files + resources |
| [`statareport_load_env`](statareport_load_env.md) | load `.StataEnviron` + OS env into `$dir_*` |
| [`statareport_add_dir`](statareport_add_dir.md) | register `$dir_<name>` |
| [`statareport_add_programs`](statareport_add_programs.md) | `adopath ++` under project root |
| [`statareport_set_paths`](statareport_set_paths.md) | emit the full `$file_*` family |
| [`statareport_set_data_root`](statareport_set_data_root.md) | cache the default data directory |
| [`statareport_add_data`](statareport_add_data.md) | register `$data_<name>` and confirm presence |
| [`statareport_confirm_data`](statareport_confirm_data.md) | re-verify every `$data_*` global |
| [`lastexport`](lastexport.md) | find the newest dated export folder (YYYYMMDD) under a parent |
| [`reportdo`](reportdo.md) | `do` a file relative to `$dir_dofiles` |

## Analysis

| Command | Purpose |
|---------|---------|
| [`quant`](quant.md) | quantitative summary tables |
| [`qual`](qual.md) | qualitative frequency tables |
| [`add_perc`](add_perc.md) | annotate count variables with percentages |
| [`compute_ci`](compute_ci.md) | exact Clopper–Pearson binomial CIs |
| [`compute_shift_graphs`](compute_shift_graphs.md) | baseline vs. endpoint scatterplots |
| [`convert_wisely`](convert_wisely.md) | stringify variables while preserving headers |
| [`generate_label_ids`](generate_label_ids.md) | sequential numeric labels for variables |
| [`label_table`](label_table.md) | merge label metadata from Excel |

## Rendering

| Command | Purpose |
|---------|---------|
| [`statareport_render`](statareport_render.md) | one-call wrapper for the full pipeline |
| [`statareport_write_header`](statareport_write_header.md) | regenerate `header.txt` from options |
| [`create_dyntex`](create_dyntex.md) | DynTex control file from Excel captions |
| [`kable`](kable.md) | Mata-driven Pandoc table renderer |
| [`kable_basic`](kable_basic.md) | lightweight table renderer (no Mata) |
| [`knit`](knit.md) | Markdown → docx via Pandoc |

## Internal helpers

- `statareport__apply_order` — sort rows to a user-defined order
- `statareport__read_file` — echo a text file to the Results window
- `statareport__writenone` — write an empty-table placeholder

These are not documented individually in the site because they are
called by `qual`, `quant`, `kable`, and `kable_basic` and rarely used
directly. See the shipped `.sthlp` files for details.
