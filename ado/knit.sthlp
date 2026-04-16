{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:knit} {hline 2} Render Markdown to Word documents via Pandoc.

{title:Syntax}
{p 4 8 2}{cmd:knit} {cmd:using} {it:filename}
[{cmd:,} {cmdab:sav:ing(}{it:string}{cmd:)}
{cmd:replace}
{cmd:default(}{it:string}{cmd:)}
{cmd:reference(}{it:string}{cmd:)}
{cmd:first(}{it:string}{cmd:)}
{cmd:toc(}{it:string}{cmd:)}
{cmdab:number_s:ec(}{it:string}{cmd:)}
{cmdab:pan:docloc(}{it:string}{cmd:)}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:sav:ing(}{it:string}{cmd:)}}destination document; defaults to the input stem with a {cmd:.docx} extension{p_end}
{synopt:{cmd:replace}}overwrite an existing output file{p_end}
{synopt:{cmd:default(}{it:string}{cmd:)}}user-supplied Pandoc defaults YAML file{p_end}
{synopt:{cmd:reference(}{it:string}{cmd:)}}reference Word document used for styling{p_end}
{synopt:{cmd:first(}{it:string}{cmd:)}}metadata YAML file merged at render time{p_end}
{synopt:{cmd:toc(}{it:string}{cmd:)}}toggle table of contents; {cmd:yes} (default) or {cmd:no}{p_end}
{synopt:{cmdab:number_s:ec(}{it:string}{cmd:)}}toggle numbered sections; {cmd:yes} (default) or {cmd:no}{p_end}
{synopt:{cmdab:pan:docloc(}{it:string}{cmd:)}}explicit path to the Pandoc executable{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:knit} wraps Pandoc to render a Markdown file to a Word document.
When {opt saving()} is omitted the output filename is derived from the input
file by replacing the extension with {cmd:.docx}.  A Pandoc defaults YAML file
is required; supply one through {opt default()} or let the command generate a
temporary one that encodes the output path, optional reference document,
metadata file, table-of-contents toggle, and section-numbering toggle.  By
default the rendered document includes a table of contents and numbered
sections.

{title:Options}
{phang}{cmd:saving(}{it:string}{cmd:)} specifies the destination Word document.
When omitted the output path is inferred from {it:filename} with a {cmd:.docx}
extension.

{phang}{cmd:replace} permits the command to overwrite an existing output file.
Without this option the command will error if the output file already exists.

{phang}{cmd:default(}{it:string}{cmd:)} supplies a user-created Pandoc defaults
YAML file.  When provided the command passes it directly to Pandoc and skips
auto-generation.

{phang}{cmd:reference(}{it:string}{cmd:)} provides a reference Word document
whose styles (fonts, headings, spacing) are applied to the output.

{phang}{cmd:first(}{it:string}{cmd:)} specifies a metadata YAML file that is
merged into the Pandoc render (e.g. title, author, date fields).

{phang}{cmd:toc(}{it:string}{cmd:)} controls the table of contents.  Accepted
values are {cmd:yes} (default) and {cmd:no}.

{phang}{cmd:number_sec(}{it:string}{cmd:)} controls section numbering.  Accepted
values are {cmd:yes} (default) and {cmd:no}.

{phang}{cmd:pandocloc(}{it:string}{cmd:)} sets the explicit path to the Pandoc
binary.  When omitted the command looks for {cmd:pandoc} on the system PATH
(and checks {cmd:/opt/homebrew/bin/pandoc} on macOS).

{title:Examples}
{phang}{cmd:. knit using "output_md/report.md", replace}

{phang}{cmd:. knit using "output_md/report.md", saving("output_word/report.docx") replace reference("input_md/style.docx") first("input_md/meta.yaml")}

{phang}{cmd:. knit using "draft.md", toc(no) number_sec(no) pandocloc("/usr/local/bin/pandoc") replace}

{title:Also see}
{psee}{help kable}, {help create_dyntex}
