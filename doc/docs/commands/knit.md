# `knit`

**knit** --- Render Markdown to Word documents via Pandoc.


## Syntax

`knit` `using` *filename*
[`,` **`sav`**`ing(`*string*`)`
`replace`
`default(`*string*`)`
`reference(`*string*`)`
`first(`*string*`)`
**`pre`**`pend(`*string*`)`
**`in_h`**`eader(`*string*`)`
**`filt`**`ers(`*string*`)`
`from(`*string*`)`
`to(`*string*`)`
`toc(`*string*`)`
**`number_s`**`ec(`*string*`)`
**`pan`**`docloc(`*string*`)`]



**Options**


---

- **`sav`**`ing(`*string*`)` — destination docx; defaults to the input stem with a `.docx` extension
- `replace` — overwrite an existing output file
- `default(`*string*`)` — user-supplied Pandoc defaults YAML file
- `reference(`*string*`)` — reference Word document used for styling
- `first(`*string*`)` — metadata YAML file (`metadata-file:`)
- **`pre`**`pend(`*string*`)` — file prepended to the document (added to `input-files:` before *filename*)
- **`in_h`**`eader(`*string*`)` — file placed in `include-in-header:` (LaTeX preamble; rarely needed for docx)
- **`filt`**`ers(`*string*`)` — whitespace-separated list of filter paths (typically Lua filters)
- `from(`*string*`)` — pandoc reader; default `markdown+autolink_bare_uris+tex_math_single_backslash+grid_tables+multiline_tables`
- `to(`*string*`)` — pandoc writer; default `docx+native_numbering+styles`
- `toc(`*string*`)` — table of contents toggle (`yes` (default) or `no`)
- **`number_s`**`ec(`*string*`)` — section numbering toggle (`yes` (default) or `no`)
- **`pan`**`docloc(`*string*`)` — explicit path to the Pandoc executable

---



## Description

`knit` wraps Pandoc to render a Markdown file to a Word document.
A Pandoc defaults YAML file is required; supply one via `default()`, or
let the command auto-generate a temporary one that encodes every option
above.

The auto-generated YAML maps each option to the Pandoc key the
user's `ressources/default_options.yaml` template already used:

    `from:`                   <- `from()`
    `to:`                     <- `to()`
    `input-files:`            <- `prepend()` followed by *filename*
    `output-file:`            <- `saving()`
    `reference-doc:`          <- `reference()`
    `metadata-file:`          <- `first()`
    `include-in-header:`      <- `in_header()`
    `filters:`                <- `filters()`
    `table-of-contents:`      <- `toc()`
    `number-sections:`        <- `number_sec()`


## Options

> `saving(`*string*`)` destination Word document. When
omitted the output path is inferred from *filename* with a `.docx`
extension.

> `replace` overwrite an existing output file.

> `default(`*string*`)` user-created Pandoc defaults YAML
file. When provided, knit passes it directly to pandoc and skips
auto-generation.

> `reference(`*string*`)` Word document whose styles are
copied to the output.

> `first(`*string*`)` YAML metadata file (`metadata-file:`).

> `prepend(`*string*`)` file to concatenate ahead of the
main input. The usual statareport value is `$file_header`, which holds
the YAML title block plus `\newpage`, `\listoftables`,
`\listoffigures` directives.

> `in_header(`*string*`)` file inserted at `include-in-header:`.
This is for LaTeX preamble snippets and is typically not needed for docx
output. Prefer `prepend()` unless you know you need the LaTeX form.

> `filters(`*string*`)` one or more filter paths separated
by whitespace. The rendered YAML lists each under `filters:`. Lua
filters are auto-detected by the `.lua` extension.

> `from(`*string*`)` pandoc reader override. The statareport
default keeps grid/multiline tables and TeX-style math intact.

> `to(`*string*`)` pandoc writer override. The default
`docx+native_numbering+styles` yields native Word numbered lists and
semantic style mapping.

> `toc(`*string*`)` `yes` (default) or `no` -- writes
`table-of-contents:` in the defaults YAML.

> `number_sec(`*string*`)` `yes` (default) or `no` --
writes `number-sections:` in the defaults YAML.

> `pandocloc(`*string*`)` explicit path to the pandoc
binary. When omitted the command asks the OS for the pandoc location
(`command -v pandoc` on macOS/Linux or `where pandoc` on Windows),
with Homebrew fallbacks on macOS (`/opt/homebrew/bin/pandoc`,
`/usr/local/bin/pandoc`).


## Examples

> `. knit using "output_md/report.md", replace`

> `. knit using "$file_input", saving("$file_output") replace ///`  
`      reference("$file_reference") prepend("$file_header")`

> `. knit using "$file_input", saving("$file_output") replace ///`  
`      reference("$file_reference") prepend("$file_header") ///`  
`      filters("$dir_project/input_md/page-orientation.lua $dir_project/input_md/table-breaks.lua")`

> `. knit using "draft.md", toc(no) number_sec(no) pandocloc("/usr/local/bin/pandoc") replace`


## Also see

[`statareport_render`](statareport_render.md), [`statareport_write_header`](statareport_write_header.md), [`create_dyntex`](create_dyntex.md), [`kable`](kable.md)

---

*Source*: [`ado/knit.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/knit.sthlp)
