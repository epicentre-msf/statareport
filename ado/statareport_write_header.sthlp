{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_write_header} {hline 2} Generate {cmd:header.txt} from title / subtitle / toggles.

{title:Syntax}
{p 4 8 2}{cmd:statareport_write_header} {cmd:using} {it:filename}[{cmd:,} {it:options}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:title(}{it:str}{cmd:)}}document title (written as YAML {cmd:title:}){p_end}
{synopt:{cmd:subtitle(}{it:str}{cmd:)}}document subtitle; use {cmd:\n} for line breaks inside the YAML block scalar{p_end}
{synopt:{cmd:author(}{it:str}{cmd:)}}author line{p_end}
{synopt:{cmd:toc}}emit {cmd:\tableofcontents} in the body{p_end}
{synopt:{cmdab:list:oftables}}emit {cmd:\listoftables}{p_end}
{synopt:{cmdab:listof:figures}}emit {cmd:\listoffigures}{p_end}
{synopt:{cmd:noyaml}}skip the YAML front-matter block entirely{p_end}
{synopt:{cmdab:rep:lace}}overwrite the destination file{p_end}
{synopt:{cmdab:qui:et}}suppress the "wrote <file>" line{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}Writes a text file consumed by {help knit} (via its {cmd:prepend()}
option or, equivalently, {cmd:statareport_render}). The file has an
optional YAML front-matter block with title/subtitle/author followed by
LaTeX directives for a table of contents and/or list of tables/figures.{p_end}

{pstd}The file is written through Mata so LaTeX macros like
{cmd:\newpage}, {cmd:\listoftables}, and {cmd:\listoffigures} are emitted
verbatim without Stata's macro processor chewing them up.{p_end}

{title:Examples}
{phang}{cmd:. statareport_write_header using "$file_header", ///}{break}
{cmd:      title("Sample trial") ///}{break}
{cmd:      subtitle("Phase III report") author("contributors") ///}{break}
{cmd:      toc listoftables listoffigures replace}{p_end}

{pstd}Subtitle with line breaks (the YAML block scalar preserves them):{p_end}
{phang}{cmd:. statareport_write_header using "$file_header", ///}{break}
{cmd:      title("My trial") ///}{break}
{cmd:      subtitle("Phase III trial in paediatric patients\nwith HAT") ///}{break}
{cmd:      listoftables listoffigures replace}{p_end}

{title:Also see}
{pstd}{help knit}, {help statareport_init_project}, {help statareport_render}{p_end}
