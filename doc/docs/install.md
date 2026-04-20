# Installation

## Requirements

- Stata **15** or newer.
- [Pandoc](https://pandoc.org/) on the PATH (for `knit` / `statareport_render`).
  `brew install pandoc`, `choco install pandoc`, or see Pandoc's install page.

## From GitHub

```stata
net install statareport, from("https://raw.githubusercontent.com/epicentre-msf/statareport/main/") replace
```

The trailing slash matters — Stata appends `stata.toc` and
`statareport.pkg` to the URL. `replace` lets you pull updates over an
existing install.

!!! note "Package in a subfolder"
    If the package is inside a subfolder of the repository:
    ```stata
    net install statareport, from("https://raw.githubusercontent.com/<org>/<repo>/<branch>/<subfolder>/") replace
    ```

## From a local directory

Handy while developing or for offline installs:

```stata
net install statareport, from("/path/to/repo/statareport/") replace
```

## What lands on disk

Stata flattens every file in the manifest into your personal adopath
(e.g. `~/ado/plus/s/`). Commands, help files, and shipped resources all
live there:

```
~/ado/plus/s/
├── *.ado                    # command implementations
├── *.sthlp                  # help files (`help <command>` after install)
├── list-tables.lua          # pandoc Lua filters
├── page-orientation.lua
├── table-breaks.lua
├── custom_reference.docx    # Word styles templates
├── custom_reference-listings.docx
├── header.txt               # pandoc include files
├── header-listings.txt
├── default_options.yaml     # pandoc defaults examples
├── default_options-listings.yaml
├── tables_labels.xlsx       # Excel templates
├── shift_graph_input.xlsx
└── .StataEnviron.example    # dotenv template
```

`statareport_init_project` uses Stata's built-in `findfile` to locate these
and copy them into a new project tree.

## Verifying

```stata
help statareport_init_project
which statareport_render
findfile "list-tables.lua"
```

All three commands should succeed.

## Updating

```stata
adoupdate statareport
```

or

```stata
net install statareport, replace
```

## Uninstalling

```stata
ado uninstall statareport
```
