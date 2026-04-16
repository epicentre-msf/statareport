{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:kable} {hline 2} Export in-memory dataset to a Pandoc Markdown table.

{title:Syntax}
{p 4 8 2}{cmd:kable} [{cmd:,} {it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:space(}{it:numlist}{cmd:)}}column widths in characters; one value per variable or a single value for all{p_end}
{synopt:{cmdab:out:put(}{it:string}{cmd:)}}write the Markdown table to the specified file{p_end}
{synopt:{cmd:round(}{it:real}{cmd:)}}rounding increment for numeric variables (default 0.01){p_end}
{synopt:{cmd:caption(}{it:string}{cmd:)}}table caption placed above the grid{p_end}
{synopt:{cmd:usevarnames}}use variable names as column headers{p_end}
{synopt:{cmd:usevarlabels}}force variable labels to be used as column headers{p_end}
{synopt:{cmd:nachar(}{it:string}{cmd:)}}string to display for missing values (default {cmd:-}){p_end}
{synopt:{cmd:footnote(}{it:string}{cmd:)}}paragraph appended after the table{p_end}
{synopt:{cmd:pipe}}use pipe table format instead of grid table format{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:kable} converts the dataset currently held in memory into a Pandoc
Markdown grid table (or pipe table when {cmd:pipe} is specified). Categorical
variables with value labels are decoded, numeric variables are rounded to the
specified increment, and column headers are derived from stored variable notes
(falling back to labels, then names). Extended missing values ({cmd:.a} through
{cmd:.z}) are detected and replaced with {opt nachar()}. The rendering engine
uses Mata. When {opt output()} is omitted the table is displayed in the Stata
Results window.

{title:Options}
{phang}{opt space(numlist)} sets the column widths in characters. Provide one
value per variable or a single value that is recycled for every column.

{phang}{opt output(string)} writes the Markdown table to the specified file
path. If omitted, the table is printed to the Results window.

{phang}{opt round(real)} rounding increment applied to numeric variables before
display. Default is 0.01.

{phang}{opt caption(string)} a caption placed above the table in the Markdown
output.

{phang}{opt usevarnames} uses variable names as column headers when no stored
notes or labels are available.

{phang}{opt usevarlabels} forces variable labels to be used as column headers,
overriding stored notes.

{phang}{opt nachar(string)} the string used to represent missing values in the
table. Default is {cmd:-}.

{phang}{opt footnote(string)} a paragraph of text appended below the table.

{phang}{opt pipe} produces a pipe-delimited table instead of the default grid
format.

{title:Examples}
{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. kable, usevarnames caption("Auto dataset") output("output_md/table1.md")}{p_end}

{phang}{cmd:. kable, space(15) round(0.1) nachar("N/A") footnote("Source: Stata auto dataset.")}{p_end}

{phang}{cmd:. kable, pipe usevarlabels output("output_md/table_pipe.md") caption("Pipe format example")}{p_end}

{title:Also see}
{pstd}{help kable_basic}, {help convert_wisely}, {help knit}{p_end}
