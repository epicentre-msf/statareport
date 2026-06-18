{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:quant} {hline 2} Generate descriptive summaries for numeric variables.

{title:Syntax}
{p 4 8 2}{cmd:quant} {it:varlist} [{cmd:if}]{cmd:,}
{cmdab:out:put(}{it:string}{cmd:)} [{it:options}]
{p_end}
{p 4 8 2}where {it:varlist} must contain only numeric variables.{p_end}

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
{synopt:{cmdab:verti:callayout}}stack N, mean (SD), median [IQR] and min/max on separate lines, opening with a blank line{p_end}
{synopt:{cmd:noline}}with {cmd:verticallayout}, drop the leading blank line{p_end}
{synopt:{cmd:format(}{it:string}{cmd:)}}global numeric format for summaries (default {cmd:%9.1f}){p_end}
{synopt:{cmdab:meanform:at(}{it:string}{cmd:)}}numeric format for the mean and SD (overrides {cmd:format}){p_end}
{synopt:{cmdab:medform:at(}{it:string}{cmd:)}}numeric format for the median and IQR (overrides {cmd:format}){p_end}
{synopt:{cmdab:mxform:at(}{it:string}{cmd:)}}numeric format for the min and max (overrides {cmd:format}){p_end}
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
{cmd:meanonly} (N, mean (SD)), {cmd:medianonly} (median [IQR], min/max),
{cmd:sumonly} (sum and percentage relative to the total sum), or
{cmd:verticallayout} (N, mean (SD), median [IQR] and min/max each on its own
line). Output can be
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

{phang}{opt verticallayout} stacks every statistic on its own line, opening
with a blank line: then N, mean (SD), median [IQR], and (min/max). May be
abbreviated {cmd:verti}. The leading blank line is carried as a {cmd:VBLANKLINE}
sentinel on the cell's first line and turned into a blank line by the
{cmd:table-breaks.lua} pandoc filter at render time, so this layout targets the
docx render pipeline ({help knit} / {help statareport_render}). The leading
blank line is added by default; pair with {cmd:noline} to omit it.

{phang}{opt noline} suppresses the leading blank line of {cmd:verticallayout}
(no {cmd:VBLANKLINE} sentinel is emitted). Has no effect without
{cmd:verticallayout}.

{phang}{opt format(string)} sets the global numeric display format applied to
every statistic. Default is {cmd:%9.1f}.

{phang}{opt meanformat(string)} sets the numeric display format for the mean
and SD. When supplied it takes precedence over {cmd:format}; otherwise the
value of {cmd:format} is used. May be abbreviated {cmd:meanform}.

{phang}{opt medformat(string)} sets the numeric display format for the median
and the interquartile range (Q1/Q3). When supplied it takes precedence over
{cmd:format}; otherwise the value of {cmd:format} is used. May be abbreviated
{cmd:medform}.

{phang}{opt mxformat(string)} sets the numeric display format for the minimum
and maximum. When supplied it takes precedence over {cmd:format}; otherwise the
value of {cmd:format} is used. May be abbreviated {cmd:mxform}.

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

{phang}{cmd:. quant age, output("output_tables/age.dta") medformat(%9.0f) meanformat(%9.1f) mxformat(%9.0f)}{p_end}

{title:Also see}
{pstd}{help qual}, {help kable}, {help convert_wisely}{p_end}
