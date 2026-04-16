{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:add_perc} {hline 2} Annotate count variables with formatted percentages.

{title:Syntax}
{p 4 8 2}{cmd:add_perc} {varlist}(numeric) [{cmd:if}]{cmd:,}
[{it:options}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:denom:inators(}{it:numlist}{cmd:)}}positive denominators; one value for all variables or one per variable{p_end}
{synopt:{cmd:form(}{it:string}{cmd:)}}display format for percentages (default {cmd:%9.1f}){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:add_perc} replaces each numeric count variable in {it:varlist} with a
string of the form {it:count (percent)}. When {opt denominators()} is omitted
the sample size of the (possibly filtered) dataset is used as the denominator.
Variable labels and notes are preserved on the resulting string variables.

{title:Options}
{phang}{opt denominators(numlist)} specifies one or more positive denominators.
Provide a single value to reuse for all variables or the same number of values
as variables in {it:varlist}.

{phang}{opt form(string)} sets the display format for the calculated percentages.
The default is {cmd:%9.1f}.

{title:Examples}
{phang}{cmd:. add_perc deaths recoveries if sex=="female", denominators(120)}{p_end}

{phang}{cmd:. add_perc n_adverse n_serious, denominators(250 180) form(%9.2f)}{p_end}

{phang}{cmd:. add_perc enrolled}{p_end}

{title:Also see}
{pstd}{help qual}, {help compute_ci}{p_end}
