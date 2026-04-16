{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:compute_ci} {hline 2} Calculate exact Clopper-Pearson binomial confidence intervals for indicator variables.

{title:Syntax}
{p 4 8 2}{cmd:compute_ci} {varname} [{cmd:if}]{cmd:,}
[{it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:level(}{it:numlist}{cmd:)}}confidence level in percent (default 95){p_end}
{synopt:{cmd:format(}{it:string}{cmd:)}}display format for percentages (default {cmd:%9.2f}){p_end}
{synopt:{cmd:replace}}overwrite an existing {cmd:tab_}{it:varname} variable{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:compute_ci} calculates exact Clopper-Pearson binomial confidence
intervals for a 0/1 indicator variable and stores the result in a new string
variable named {cmd:tab_}{it:varname}. The string takes the form
{it:n (percent%), [lower% - upper%]}. If the output variable already exists,
{cmd:replace} must be specified to overwrite it.

{title:Options}
{phang}{opt level(numlist)} sets the confidence level in percent. Default is 95.
The value must be strictly between 0 and 100.

{phang}{opt format(string)} sets the numeric display format for the point
estimate and interval bounds. Default is {cmd:%9.2f}.

{phang}{opt replace} overwrites an existing {cmd:tab_}{it:varname} variable
instead of issuing an error.

{title:Examples}
{phang}{cmd:. compute_ci treated if site=="A", level(99) replace}{p_end}

{phang}{cmd:. compute_ci cured, format(%5.1f)}{p_end}

{phang}{cmd:. compute_ci response if arm==1, level(90) replace format(%9.3f)}{p_end}

{title:Also see}
{pstd}{help qual}, {help add_perc}{p_end}
