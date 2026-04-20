# `statareport_render`

**statareport_render** --- One-call wrapper for [`create_dyntex`](create_dyntex.md) + `dyntext` + [`knit`](knit.md).


## Syntax

`statareport_render`
[`,` *options*]



**Options**


---

- `variant(`*s*`)` — read `$<global>_`*s* instead of `$<global>` (e.g. `listings`)
- `label(`*str*`)` — override `$file_label`
- `dyntex(`*str*`)` — override `$file_dyntex`
- `input(`*str*`)` — override `$file_input`
- `output(`*str*`)` — override `$file_output`
- `reference(`*str*`)` — override `$file_reference`
- `header(`*str*`)` — override `$file_header` (prepended by pandoc)
- `filters(`*str*`)` — override `$file_filters` (space-separated list of Lua filters)
- `sheet(`*str*`)` — override `$var_sheet_lab` (default `Labels`)
- `tab_dir(`*str*`)` — override `$dir_lbltables`
- `fig_dir(`*str*`)` — override `$dir_figures`
- **`nbin`**`put(`*#*`)` — forwarded to [`create_dyntex`](create_dyntex.md) (limit to first *#* rows)
- `default(`*str*`)` — user-supplied Pandoc defaults YAML (forwarded to [`knit`](knit.md))
- `first(`*str*`)` — Pandoc metadata file (forwarded to knit)
- **`in_h`**`eader(`*str*`)` — Pandoc include-in-header file (forwarded to knit)
- **`pan`**`docloc(`*str*`)` — explicit pandoc binary path (forwarded to knit)
- `toc(`*yes|no*`)` — forwarded to [`knit`](knit.md) (default yes)
- **`num`**`ber_sec(`*yes|no*`)` — forwarded to [`knit`](knit.md) (default yes)
- `from(`*str*`)` — pandoc reader override
- `to(`*str*`)` — pandoc writer override
- `skip_dyntex` — skip stage 1 (use existing `$file_dyntex`)
- `skip_dyntext` — skip stage 2 (use existing `$file_input`)
- `skip_knit` — skip stage 3 (stop after the Markdown is written)
- **`qui`**`et` — suppress the per-stage progress line

---



## Description

`statareport_render` collapses the three-step render tail of a
final do-file into a single command. It reads the `$file_*`,
`$dir_*`, and `$var_*` globals populated by
[`statareport_set_paths`](statareport_set_paths.md), [`statareport_add_dir`](statareport_add_dir.md), and the rest of
the scaffolding commands, then drives [`create_dyntex`](create_dyntex.md),
`dyntext`, and [`knit`](knit.md) in order.

Any single path or option can be overridden per-call; anything not
overridden falls back to the variant-aware global, then the plain global.
For the listings variant the command reads `$file_*_listings` instead
of `$file_*`.


## Examples

Render the main report:
> `. statareport_render`

Render the listings variant, no table of contents:
> `. statareport_render, variant("listings") toc(no)`

Override a single path (custom label sheet name):
> `. statareport_render, sheet("Labels_v2")`

Iterate on the Markdown only, no knit:
> `. statareport_render, skip_knit`


## Stored results

`r(label)`, `r(dyntex)`, `r(input)`, `r(output)`,
`r(reference)`, `r(header)`, `r(filters)`: the resolved paths
actually used this call.


## Also see

[`create_dyntex`](create_dyntex.md), [`knit`](knit.md), [`statareport_set_paths`](statareport_set_paths.md), [`statareport_write_header`](statareport_write_header.md)

---

*Source*: [`ado/statareport_render.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_render.sthlp)
