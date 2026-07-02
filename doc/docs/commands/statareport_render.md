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
- **`caption_l`**`abel(`*w*`)` — word that replaces `Table` in captions (default `proper(`*s*`)`)
- **`list_t`**`itle(`*t*`)` — heading that replaces `List of Tables` (default `List of proper(`*s*`)`)
- **`norel`**`abel` — disable the variant caption/list relabeling
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


## Variant relabeling

When `variant(`*s*`)` is set the finished document is relabeled into the
variant's own vocabulary: every `Table N` caption becomes `*S* N` and the
`List of Tables` heading becomes `List of *S*` (*S* title-cased). So
`variant("listings")` yields `Listings 1: ...` captions and a
`List of Listings` at the top instead of `Table`/`List of Tables`. Table
numbering and the list itself are unchanged — only the visible words differ —
and figures keep saying `Figure`. Set `caption_label()` and/or `list_title()`
to choose the two strings explicitly, or `norelabel` to leave the document
exactly as pandoc produced it. The rewrite is done by [`knit`](knit.md) on the
rendered `.docx` (see knit's `caption_label()`).


## Examples

Render the main report:
> `. statareport_render`

Render the listings variant (captions become `Listings N`, with a `List of Listings` at the top), no table of contents:
> `. statareport_render, variant("listings") toc(no)`

Same, but keep pandoc's `Table`/`List of Tables` wording:
> `. statareport_render, variant("listings") toc(no) norelabel`

Override a single path (custom label sheet name):
> `. statareport_render, sheet("Labels_v2")`

Iterate on the Markdown only, no knit:
> `. statareport_render, skip_knit`


## Stored results

`r(label)`, `r(dyntex)`, `r(input)`, `r(output)`,
`r(reference)`, `r(header)`, `r(filters)`: the resolved paths
actually used this call. `r(caption_label)`, `r(list_title)`: the relabeling
strings applied (empty when `norelabel` or no variant).


## Also see

[`create_dyntex`](create_dyntex.md), [`knit`](knit.md), [`statareport_set_paths`](statareport_set_paths.md), [`statareport_write_header`](statareport_write_header.md)

---

*Source*: [`ado/statareport_render.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_render.sthlp)
