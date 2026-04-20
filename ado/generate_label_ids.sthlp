{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:generate_label_ids} {hline 2} Assign sequential numeric labels to variables.

{title:Syntax}
{p 4 8 2}{cmd:generate_label_ids} {varlist}
[{cmd:,} {cmdab:start:ing(}{it:integer}{cmd:)}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:start:ing(}{it:integer}{cmd:)}}integer value at which the sequence begins (default {cmd:1}){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:generate_label_ids} assigns sequential numeric labels to each
variable in {varlist}.  The first variable receives the value specified by
{opt starting()}, the second receives {opt starting()} + 1, and so on.  This
is useful when downstream reporting templates expect unique numeric identifiers
stored in the variable-label metadata (e.g. for cross-referencing table
columns).

{title:Options}
{phang}{cmd:starting(}{it:integer}{cmd:)} sets the integer value at which the
numbering sequence begins.  The value must be non-negative.  If omitted the
default is {cmd:1}.

{title:Examples}
{phang}{cmd:. generate_label_ids age sex weight}{p_end}

{phang}{cmd:. generate_label_ids value1 value2 value3, starting(10)}{p_end}

{phang}{cmd:. ds value*}{break}{cmd:. generate_label_ids `r(varlist)', starting(100)}{p_end}

{title:Also see}
{pstd}{help label_table}, {help qual}, {help quant}{p_end}
