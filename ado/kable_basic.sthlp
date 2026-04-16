{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:kable_basic} {hline 2} Lightweight Markdown grid-table exporter using fixed-width spacing.

{title:Syntax}
{p 4 8 2}{cmd:kable_basic}
[{cmd:,} {cmdab:sp:ace(}{it:numlist}{cmd:)}
{cmdab:out:put(}{it:string}{cmd:)}
{cmd:round(}{it:real}{cmd:)}
{cmd:caption(}{it:string}{cmd:)}
{cmd:usevarnames}
{cmd:usevarlabels}
{cmd:nachar(}{it:string}{cmd:)}
{cmdab:foot:note(}{it:string}{cmd:)}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:sp:ace(}{it:numlist}{cmd:)}}column widths in characters; one value per variable or a single value applied to all{p_end}
{synopt:{cmdab:out:put(}{it:string}{cmd:)}}write the Markdown table to the specified file{p_end}
{synopt:{cmd:round(}{it:#}{cmd:)}}rounding increment for numeric variables (default {cmd:0.01}){p_end}
{synopt:{cmd:caption(}{it:string}{cmd:)}}table caption written above the grid table{p_end}
{synopt:{cmd:usevarnames}}use variable names as column headers{p_end}
{synopt:{cmd:usevarlabels}}use variable labels as column headers{p_end}
{synopt:{cmd:nachar(}{it:string}{cmd:)}}string displayed for missing values (default {cmd:-}){p_end}
{synopt:{cmdab:foot:note(}{it:string}{cmd:)}}paragraph appended below the table{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:kable_basic} is a lightweight variant of {help kable} that pads
columns with fixed-width spacing and uses Stata's {cmd:export delimited}
instead of Mata to build Markdown grid tables.  It supports the same core
options as {cmd:kable} (column widths, captions, footnotes, missing-value
characters) but omits the pipe-table option.  Use {cmd:kable} for modern
features; use {cmd:kable_basic} for compatibility with older workflows or
environments where Mata is unavailable.

{title:Options}
{phang}{cmd:space(}{it:numlist}{cmd:)} sets the character width of each column.
Provide one value per variable, or a single value that is replicated for every
column.  When omitted the widths are computed automatically from the data and
header lengths.

{phang}{cmd:output(}{it:string}{cmd:)} specifies a file path for the Markdown
output.  When omitted the table is displayed in the Stata Results window.

{phang}{cmd:round(}{it:#}{cmd:)} sets the rounding increment for numeric
variables.  The default is {cmd:0.01}.

{phang}{cmd:caption(}{it:string}{cmd:)} provides a caption rendered as a
{cmd:Table:} line above the grid table.

{phang}{cmd:usevarnames} forces variable names to be used as column headers
instead of the default behaviour (notes, then labels, then names).

{phang}{cmd:usevarlabels} forces variable labels to be used as column headers.

{phang}{cmd:nachar(}{it:string}{cmd:)} replaces missing values with the
specified string.  The default is {cmd:-}.

{phang}{cmd:footnote(}{it:string}{cmd:)} appends a footnote paragraph after the
table body.

{title:Examples}
{phang}{cmd:. sysuse auto, clear}{break}{cmd:. kable_basic, usevarnames}

{phang}{cmd:. kable_basic, output("output_md/table1.md") caption("Baseline characteristics") footnote("Source: trial database.")}

{phang}{cmd:. kable_basic, space(30) round(0.1) nachar("N/A") usevarlabels}

{title:Also see}
{psee}{help kable}, {help convert_wisely}
