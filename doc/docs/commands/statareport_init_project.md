# `statareport_init_project`

**statareport_init_project** --- Scaffold a new statareport project (folders, stubs, master do-file).


## Syntax

`statareport_init_project``,` **`pref`**`ix(`*string*`)`
[`root(`*string*`)` **`rep`**`lace`]



**Options**


---

- **`pref`**`ix(`*string*`)` — project shortname baked into generated filenames (required)
- `root(`*string*`)` — target directory; defaults to the [`here`](here.md) root, then `c(pwd)`
- **`rep`**`lace` — overwrite existing template files (default: skip)

---



## Description

`statareport_init_project` turns an empty directory into a
functioning statareport project. It does three things:

    1. Calls [`statareport_setup_dirs`](statareport_setup_dirs.md) to create the canonical folder
layout (`do_files`, `do_files/helpers`, `programs`,
`input_md`, `input_tables`, `output_md`, `output_tables`,
`output_tables/labelled_tables`, `output_figures`,
`output_word`, `local_datasets`, `logs`).

    2. Writes a populated master do-file at
`do_files/00-final-do-file.do` that wires [`here`](here.md),
[`statareport_add_dir`](statareport_add_dir.md), [`statareport_add_programs`](statareport_add_programs.md),
[`statareport_set_paths`](statareport_set_paths.md), [`statareport_set_data_root`](statareport_set_data_root.md),
[`statareport_add_data`](statareport_add_data.md), [`statareport_confirm_data`](statareport_confirm_data.md),
[`create_dyntex`](create_dyntex.md), `dyntext`, and [`knit`](knit.md) into a complete render
pipeline.

    3. Drops minimal stubs at
`do_files/01-create-datasets.do` through
`do_files/07-listings.do`, a Pandoc header template at
`input_md/header.txt`, and Lua filter placeholders
(`list-tables.lua`, `page-orientation.lua`, `table-breaks.lua`).

Existing files are preserved by default -- pass `replace` to
overwrite them. The command never touches `output_*` folders or the
user's datasets.


## Resulting layout

Created under `<root>/`:

    `do_files/`           -- master 00-final-do-file.do + step 01-07 stubs + helpers/
    `programs/`           -- project-local ado files (added to adopath)
    `input_md/`           -- pandoc headers, Lua filters, reference.docx, default YAML
    `input_tables/`       -- tables_labels.xlsx, shift_graph_input.xlsx
    `output_md/`          -- generated Markdown (<prefix>-dyn.txt, <prefix>.txt)
    `output_tables/`      -- analysis .dta files; includes labelled_tables/ subfolder
    `output_figures/`     -- .gph / .png produced by compute_shift_graphs
    `output_word/`        -- final rendered docx
    `local_datasets/`     -- derived .dta files used within the project
    `logs/`               -- Stata log files
    `.StataEnviron.example` -- copy to `.StataEnviron` for local paths


## Examples

> `. here`
> `. statareport_init_project, prefix("MyTrial")`

Into an arbitrary directory:
> `. statareport_init_project, prefix("Trial42") root("/Users/me/projects/trial42")`

Regenerate the master do-file (overwrites user edits):
> `. statareport_init_project, prefix("MyTrial") replace`


## Stored results

`r(root)`: absolute path of the initialised project  
`r(prefix)`: the supplied prefix


## Also see

[`statareport_setup_dirs`](statareport_setup_dirs.md), [`statareport_set_paths`](statareport_set_paths.md), [`statareport_add_data`](statareport_add_data.md), [`statareport_add_dir`](statareport_add_dir.md), [`statareport_add_programs`](statareport_add_programs.md), [`here`](here.md)

---

*Source*: [`ado/statareport_init_project.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_init_project.sthlp)
