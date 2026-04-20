# `statareport_write_header`

**statareport_write_header** --- Generate `header.txt` from title / subtitle / toggles.


## Syntax

`statareport_write_header` `using` *filename*[`,` *options*]



**Options**


---

- `title(`*str*`)` — document title (written as YAML `title:`)
- `subtitle(`*str*`)` — document subtitle; use `\n` for line breaks inside the YAML block scalar
- `author(`*str*`)` — author line
- `toc` — emit `\tableofcontents` in the body
- **`list`**`oftables` — emit `\listoftables`
- **`listof`**`figures` — emit `\listoffigures`
- `noyaml` — skip the YAML front-matter block entirely
- **`rep`**`lace` — overwrite the destination file
- **`qui`**`et` — suppress the "wrote <file>" line

---



## Description

Writes a text file consumed by [`knit`](knit.md) (via its `prepend()`
option or, equivalently, `statareport_render`). The file has an
optional YAML front-matter block with title/subtitle/author followed by
LaTeX directives for a table of contents and/or list of tables/figures.

The file is written through Mata so LaTeX macros like
`\newpage`, `\listoftables`, and `\listoffigures` are emitted
verbatim without Stata's macro processor chewing them up.


## Examples

> `. statareport_write_header using "$file_header", ///`  
`      title("Sample trial") ///`  
`      subtitle("Phase III report") author("contributors") ///`  
`      toc listoftables listoffigures replace`

Subtitle with line breaks (the YAML block scalar preserves them):
> `. statareport_write_header using "$file_header", ///`  
`      title("My trial") ///`  
`      subtitle("Phase III trial in paediatric patients\nwith HAT") ///`  
`      listoftables listoffigures replace`


## Also see

[`knit`](knit.md), [`statareport_init_project`](statareport_init_project.md), [`statareport_render`](statareport_render.md)

---

*Source*: [`ado/statareport_write_header.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/statareport_write_header.sthlp)
