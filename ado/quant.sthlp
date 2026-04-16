{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:quant} {hline 2} Generate descriptive summaries for numeric variables.

{title:Syntax}
{p 4 8 2}{cmd:quant} {varlist}(numeric) [{cmd:if}]{cmd:,}
{cmdab:out:put(}{it:string}{cmd:)} [{it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:out:put(}{it:string}{cmd:)}}destination Stata dataset (required){p_end}
{synopt:{cmd:append}}append results to an existing dataset{p_end}
{synopt:{cmd:by(}{it:varname}{cmd:)}}stratify by a labelled categorical variable (max=1){p_end}
{synopt:{cmd:fullresult}}display N, median (IQR), and min/max{p_end}
{synopt:{cmd:meanonly}}display N, mean (SD){p_end}
{synopt:{cmd:medianonly}}display median (IQR) and min/max{p_end}
{synopt:{cmd:sumonly}}display sum and percentage of total sum{p_end}
{synopt:{cmd:format(}{it:string}{cmd:)}}numeric format for summaries (default {cmd:%9.1f}){p_end}
{synopt:{cmd:idstart(}{it:integer}{cmd:)}}starting identifier value (default 1){p_end}
{synopt:{cmd:addtotal}}include an overall Total column when {opt by()} is specified{p_end}
{synopt:{cmd:mxsep(}{it:string}{cmd:)}}separator between min and max values (default {cmd:/}){p_end}
{synopt:{cmd:mxbrack}}use square brackets around min/max instead of parentheses{p_end}
{synopt:{cmd:medsep(}{it:string}{cmd:)}}separator within the IQR (default {cmd:;}){p_end}
{synopt:{cmd:medparenth}}use parentheses around the IQR instead of brackets{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:quant} generates descriptive summaries for numeric variables and writes
the results to a Stata dataset suitable for table production. The default
display is N, median [IQR] (min/max). Alternative layouts are selected with
{cmd:meanonly} (N, mean (SD)), {cmd:medianonly} (median [IQR], min/max), or
{cmd:sumonly} (sum and percentage relative to the total sum). Output can be
stratified by a single categorical variable with {opt by()} and optionally
include a total column with {cmd:addtotal}.

{title:Options}
{phang}{opt output(string)} specifies the file path for the resulting Stata
dataset. This option is required.

{phang}{opt append} appends the current results to an existing dataset instead
of overwriting it.

{phang}{opt by(varname)} stratifies the summary by the specified labelled
categorical variable. Only one variable is allowed.

{phang}{opt fullresult} displays the full result layout: N, median (IQR), and
min/max. This is the default when no layout option is specified.

{phang}{opt meanonly} displays N, mean (SD) only.

{phang}{opt medianonly} displays median (IQR) and min/max without the count.

{phang}{opt sumonly} displays the sum and its percentage relative to the total
sum across all observations.

{phang}{opt format(string)} sets the numeric display format. Default is
{cmd:%9.1f}.

{phang}{opt idstart(integer)} sets the starting identifier value for the
generated {cmd:id} column. Default is 1.

{phang}{opt addtotal} includes an overall Total column when {opt by()} is
specified.

{phang}{opt mxsep(string)} sets the separator between the minimum and maximum
values. Default is {cmd:/}.

{phang}{opt mxbrack} uses square brackets around min/max (e.g., [min/max])
instead of parentheses.

{phang}{opt medsep(string)} sets the separator within the interquartile range.
Default is {cmd:;}.

{phang}{opt medparenth} uses parentheses around the IQR (e.g., (p25; p75))
instead of square brackets.

{title:Examples}
{phang}{cmd:. quant age weight, output("output_tables/quant_summary.dta") by(treatment) addtotal}{p_end}

{phang}{cmd:. quant hemoglobin if visit==1, output("output_tables/hb_baseline.dta") meanonly format(%9.2f)}{p_end}

{phang}{cmd:. quant cost, output("output_tables/cost.dta") sumonly by(region) mxsep("-") medparenth append}{p_end}

{title:Also see}
{pstd}{help qual}, {help kable}, {help convert_wisely}{p_end}
