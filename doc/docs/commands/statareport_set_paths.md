# `statareport_set_paths`

**statareport_set_paths** --- Populate the `$file_*` globals consumed by the render pipeline.


## Syntax

`statareport_set_paths``,` **`pref`**`ix(`*string*`)`
[*options*]



**Options**


---

- **`pref`**`ix(`*string*`)` — project shortname baked into every filename (required)
- **`dat`**`e(`*string*`)` — date fragment appended to the docx output (e.g. `20260419`)
- `root(`*string*`)` — project root. If omitted, the Mata cache of [`here`](here.md) is used; otherwise `c(pwd)`
- `variant(`*string*`)` — optional infix. With `variant(listings)`, writes `$file_input_listings` etc
- `dyntex(`*string*`)` — override the auto-derived `$file_dyntex` path
- `input(`*string*`)` — override the auto-derived `$file_input` path
- `header(`*string*`)` — override the auto-derived `$file_header` path
- `output(`*string*`)` — override the auto-derived `$file_output` path
- `reference(`*string*`)` — override the auto-derived `$file_reference` path
- `defaults(`*string*`)` — override the auto-derived `$file_default_options` path
- `label(`*string*`)` — override the auto-derived `$file_label` path
- `graphopts(`*string*`)` — override the auto-derived `$file_graph_opts` path
- **`filt`**`ers(`*string*`)` — override `$file_filters` (space-separated quoted Lua filter paths)
- **`qui`**`et` — suppress the summary message printed to the Results window

---



## Description

`statareport_set_paths` replaces the ~15 hand-written
`global file_*` lines that typically open a statareport render script.
From a single `prefix()` and (optional) `variant()` the command
fills in the full path family that [`knit`](knit.md), [`create_dyntex`](create_dyntex.md), and
[`label_table`](label_table.md) expect:

    `$file_dyntex`{col 32}`<root>/output_md/<stem>-dyn.txt`
    `$file_input`{col 32}`<root>/output_md/<stem>.txt`
    `$file_header`{col 32}`<root>/input_md/header[-<variant>].txt`
    `$file_output`{col 32}`<root>/output_word/<stem>[-<date>].docx`
    `$file_reference`{col 32}`<root>/input_md/custom_reference[-<variant>].docx`
    `$file_default_options`{col 32}`<root>/input_md/default_options[-<variant>].yaml`
    `$file_label`{col 32}`<root>/input_tables/tables_labels[-<variant>].xlsx`
    `$file_graph_opts`{col 32}`<root>/input_tables/shift_graph_input[-<variant>].xlsx`
    `$file_filters`{col 32}`<root>/input_md/{page-orientation,table-breaks,list-tables`.lua}

Here `<stem>` is `<prefix>` or `<prefix>-<variant>`. When
`variant()` is non-empty the globals are suffixed with `_<variant>`
so main and listings can coexist. `$file_filters` is the one global
that is variant-agnostic: it is only written on the `variant("")` call
and reused across variants. Each default filter path is checked on disk
and a warning is printed if any of them are missing.

Individual paths can always be overridden via the dedicated options
(e.g. `label("my_custom_labels.xlsx")`); anything not overridden
follows the convention.


## Root resolution

The command resolves `root()` in this order:
    1. Explicit `root()` argument.
    2. Mata cache populated by [`here`](here.md). Call `here` once at the
top of your master do-file to seed it.
    3. `c(pwd)` (with a warning).


## Stored results

`statareport_set_paths` returns each emitted path under
`r(root)`, `r(variant)`, `r(dyntex)`, `r(input)`,
`r(header)`, `r(output)`, `r(reference)`, `r(defaults)`,
`r(label)`, `r(graphopts)`, and `r(filters)` so callers that
prefer locals over globals can consume them directly. `r(filters)` is
empty on variant calls (the filter pool is only written on the
`variant("")` call).


## Examples

Main report only:
> `. here`
> `. statareport_set_paths, prefix("MyTrial") date("20260419")`
> `. knit using "$file_input", saving("$file_output") replace ///`
> `          reference("$file_reference") prepend("$file_header")`

Main plus listings variant:
> `. here`
> `. statareport_set_paths, prefix("MyTrial") date("$date_export")`
> `. statareport_set_paths, prefix("MyTrial") date("$date_export") variant("listings")`

Overriding one path:
> `. statareport_set_paths, prefix("MyTrial") label("shared/labels_v2.xlsx")`


## Also see

[`here`](here.md), [`knit`](knit.md), [`create_dyntex`](create_dyntex.md), [`label_table`](label_table.md), [`statareport_setup_dirs`](statareport_setup_dirs.md)

---

*Source*: [`ado/statareport_set_paths.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_set_paths.sthlp)
