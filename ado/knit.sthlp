{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:knit} {hline 2} Render Markdown to Word documents via Pandoc.

{title:Syntax}
{p 4 8 2}{cmd:knit} {cmd:using} {it:filename}
[{cmd:,} {cmdab:sav:ing(}{it:string}{cmd:)}
{cmd:replace}
{cmd:default(}{it:string}{cmd:)}
{cmd:reference(}{it:string}{cmd:)}
{cmd:first(}{it:string}{cmd:)}
{cmdab:pre:pend(}{it:string}{cmd:)}
{cmdab:in_h:eader(}{it:string}{cmd:)}
{cmdab:filt:ers(}{it:string}{cmd:)}
{cmd:from(}{it:string}{cmd:)}
{cmd:to(}{it:string}{cmd:)}
{cmd:toc(}{it:string}{cmd:)}
{cmdab:number_s:ec(}{it:string}{cmd:)}
{cmdab:pan:docloc(}{it:string}{cmd:)}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:sav:ing(}{it:string}{cmd:)}}destination docx; defaults to the input stem with a {cmd:.docx} extension{p_end}
{synopt:{cmd:replace}}overwrite an existing output file{p_end}
{synopt:{cmd:default(}{it:string}{cmd:)}}user-supplied Pandoc defaults YAML file{p_end}
{synopt:{cmd:reference(}{it:string}{cmd:)}}reference Word document used for styling{p_end}
{synopt:{cmd:first(}{it:string}{cmd:)}}metadata YAML file ({cmd:metadata-file:}){p_end}
{synopt:{cmdab:pre:pend(}{it:string}{cmd:)}}file prepended to the document (added to {cmd:input-files:} before {it:filename}){p_end}
{synopt:{cmdab:in_h:eader(}{it:string}{cmd:)}}file placed in {cmd:include-in-header:} (LaTeX preamble; rarely needed for docx){p_end}
{synopt:{cmdab:filt:ers(}{it:string}{cmd:)}}whitespace-separated list of filter paths (typically Lua filters){p_end}
{synopt:{cmd:from(}{it:string}{cmd:)}}pandoc reader; default {cmd:markdown+autolink_bare_uris+tex_math_single_backslash+grid_tables+multiline_tables}{p_end}
{synopt:{cmd:to(}{it:string}{cmd:)}}pandoc writer; default {cmd:docx+native_numbering+styles}{p_end}
{synopt:{cmd:toc(}{it:string}{cmd:)}}table of contents toggle ({cmd:yes} (default) or {cmd:no}){p_end}
{synopt:{cmdab:number_s:ec(}{it:string}{cmd:)}}section numbering toggle ({cmd:yes} (default) or {cmd:no}){p_end}
{synopt:{cmdab:pan:docloc(}{it:string}{cmd:)}}explicit path to the Pandoc executable{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:knit} wraps Pandoc to render a Markdown file to a Word document.
A Pandoc defaults YAML file is required; supply one via {opt default()}, or
let the command auto-generate a temporary one that encodes every option
above.{p_end}

{pstd}The auto-generated YAML maps each option to the Pandoc key the
user's {cmd:ressources/default_options.yaml} template already used:{p_end}

{phang2}{cmd:from:}                   <- {opt from()}{p_end}
{phang2}{cmd:to:}                     <- {opt to()}{p_end}
{phang2}{cmd:input-files:}            <- {opt prepend()} followed by {it:filename}{p_end}
{phang2}{cmd:output-file:}            <- {opt saving()}{p_end}
{phang2}{cmd:reference-doc:}          <- {opt reference()}{p_end}
{phang2}{cmd:metadata-file:}          <- {opt first()}{p_end}
{phang2}{cmd:include-in-header:}      <- {opt in_header()}{p_end}
{phang2}{cmd:filters:}                <- {opt filters()}{p_end}
{phang2}{cmd:table-of-contents:}      <- {opt toc()}{p_end}
{phang2}{cmd:number-sections:}        <- {opt number_sec()}{p_end}

{title:Options}
{phang}{cmd:saving(}{it:string}{cmd:)} destination Word document. When
omitted the output path is inferred from {it:filename} with a {cmd:.docx}
extension.

{phang}{cmd:replace} overwrite an existing output file.

{phang}{cmd:default(}{it:string}{cmd:)} user-created Pandoc defaults YAML
file. When provided, knit passes it directly to pandoc and skips
auto-generation.

{phang}{cmd:reference(}{it:string}{cmd:)} Word document whose styles are
copied to the output.

{phang}{cmd:first(}{it:string}{cmd:)} YAML metadata file ({cmd:metadata-file:}).

{phang}{cmd:prepend(}{it:string}{cmd:)} file to concatenate ahead of the
main input. The usual statareport value is {cmd:$file_header}, which holds
the YAML title block plus {cmd:\newpage}, {cmd:\listoftables},
{cmd:\listoffigures} directives.

{phang}{cmd:in_header(}{it:string}{cmd:)} file inserted at {cmd:include-in-header:}.
This is for LaTeX preamble snippets and is typically not needed for docx
output. Prefer {opt prepend()} unless you know you need the LaTeX form.

{phang}{cmd:filters(}{it:string}{cmd:)} one or more filter paths separated
by whitespace. The rendered YAML lists each under {cmd:filters:}. Lua
filters are auto-detected by the {cmd:.lua} extension.

{phang}{cmd:from(}{it:string}{cmd:)} pandoc reader override. The statareport
default keeps grid/multiline tables and TeX-style math intact.

{phang}{cmd:to(}{it:string}{cmd:)} pandoc writer override. The default
{cmd:docx+native_numbering+styles} yields native Word numbered lists and
semantic style mapping.

{phang}{cmd:toc(}{it:string}{cmd:)} {cmd:yes} (default) or {cmd:no} -- writes
{cmd:table-of-contents:} in the defaults YAML.

{phang}{cmd:number_sec(}{it:string}{cmd:)} {cmd:yes} (default) or {cmd:no} --
writes {cmd:number-sections:} in the defaults YAML.

{phang}{cmd:pandocloc(}{it:string}{cmd:)} explicit path to the pandoc
binary. When omitted the command asks the OS for the pandoc location
({cmd:command -v pandoc} on macOS/Linux or {cmd:where pandoc} on Windows),
with Homebrew fallbacks on macOS ({cmd:/opt/homebrew/bin/pandoc},
{cmd:/usr/local/bin/pandoc}).

{title:Examples}
{phang}{cmd:. knit using "output_md/report.md", replace}{p_end}

{phang}{cmd:. knit using "$file_input", saving("$file_output") replace ///}{break}
{cmd:      reference("$file_reference") prepend("$file_header")}{p_end}

{phang}{cmd:. knit using "$file_input", saving("$file_output") replace ///}{break}
{cmd:      reference("$file_reference") prepend("$file_header") ///}{break}
{cmd:      filters("$dir_project/input_md/page-orientation.lua $dir_project/input_md/table-breaks.lua")}{p_end}

{phang}{cmd:. knit using "draft.md", toc(no) number_sec(no) pandocloc("/usr/local/bin/pandoc") replace}{p_end}

{title:Also see}
{pstd}{help statareport_render}, {help statareport_write_header}, {help create_dyntex}, {help kable}{p_end}
