{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:qual} {hline 2} Produce publication-ready frequency tables for categorical variables.

{title:Syntax}
{p 4 8 2}{cmd:qual} {varlist} [{cmd:if}]{cmd:,}
{cmdab:out:put(}{it:string}{cmd:)} [{it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:out:put(}{it:string}{cmd:)}}destination Stata dataset (required){p_end}
{synopt:{cmd:format(}{it:string}{cmd:)}}format for percentages (default {cmd:%9.1f}){p_end}
{synopt:{cmd:append}}append results to an existing output file{p_end}
{synopt:{cmd:by(}{it:varname}{cmd:)}}stratify by a labelled categorical variable (max=1){p_end}
{synopt:{cmd:addtotal}}include a Total column when using {opt by()}{p_end}
{synopt:{cmd:idstart(}{it:integer}{cmd:)}}starting value for the {cmd:id} column (default 1){p_end}
{synopt:{cmd:pct(}{it:string}{cmd:)}}percentage type: {cmd:col} (default) or {cmd:row}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:qual} summarises binary or categorical indicator variables into a tidy
Stata dataset ready for publication. Counts and percentages are computed and
written to the file specified by {opt output()}. Results can be stratified by a
single {opt by()} variable and optionally include a {cmd:Total} column.
Column percentages ({cmd:pct(col)}) compute the share within each by-group,
while row percentages ({cmd:pct(row)}) compute shares across by-groups for each
category.

{title:Options}
{phang}{opt output(string)} specifies the file path for the resulting Stata
dataset. This option is required.

{phang}{opt format(string)} sets the display format for computed percentages.
Default is {cmd:%9.1f}.

{phang}{opt append} appends the current results to an existing output file
instead of overwriting it.

{phang}{opt by(varname)} stratifies the frequency table by the specified labelled
categorical variable. Only one variable is allowed.

{phang}{opt addtotal} adds a Total column that aggregates across all levels of
the {opt by()} variable.

{phang}{opt idstart(integer)} sets the starting value for the generated {cmd:id}
column. Default is 1.

{phang}{opt pct(string)} selects the percentage type. {cmd:col} (the default)
computes column percentages within each by-group. {cmd:row} computes row
percentages across by-groups.

{title:Examples}
{phang}{cmd:. qual adverse_event grade*, output("output_tables/ae_summary.dta") by(site) addtotal}{p_end}

{phang}{cmd:. qual sex smoking, output("output_tables/demographics.dta") format(%9.2f) idstart(10)}{p_end}

{phang}{cmd:. qual outcome if visit==4, output("output_tables/outcome.dta") by(arm) pct(row) append}{p_end}

{title:Also see}
{pstd}{help quant}, {help kable}, {help convert_wisely}{p_end}
