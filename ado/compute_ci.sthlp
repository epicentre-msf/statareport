{smcl}
{* *! version 2.0.0 21may2026}
{title:Title}
{pstd}{bf:compute_ci} {hline 2} Binomial confidence intervals for indicator variables, written to a publication-ready table.

{title:Syntax}
{p 4 8 2}{cmd:compute_ci} {varlist} [{cmd:if}]{cmd:,}
{opt out:put(string)}
[{it:options}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt out:put(string)}}output dataset for the table (required){p_end}
{synopt:{cmd:method(}{it:string}{cmd:)}}interval method: {cmd:exact}, {cmd:wald}, {cmd:wilson}, {cmd:agresti}, or {cmd:jeffreys} (default {cmd:exact}){p_end}
{synopt:{cmd:level(}{it:numlist}{cmd:)}}confidence level in percent (default 95){p_end}
{synopt:{cmd:format(}{it:string}{cmd:)}}display format for percentages (default {cmd:%9.2f}){p_end}
{synopt:{cmd:append}}append the table to an existing {opt output()} dataset{p_end}
{synopt:{cmd:by(}{it:varname}{cmd:)}}compute intervals within each level of a categorical variable{p_end}
{synopt:{cmd:addtotal}}with {cmd:by()}, also add an overall (Total) column{p_end}
{synopt:{cmd:idstart(}{it:integer}{cmd:)}}first row id (default 1){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:compute_ci} calculates binomial confidence intervals for one or more
0/1 indicator variables and writes the result to an output dataset, following
the same workflow as {help quant} and {help qual}: one row per variable with the
columns {cmd:variable}, {cmd:label} and {cmd:value}, ready for {help label_table}
and {help kable}. Each {cmd:value} cell takes the form
{it:n (percent%), [lower% - upper%]}.

{pstd}With {opt by()}, one {cmd:value_}{it:level} column is produced per level of
the categorical variable; {cmd:addtotal} appends an overall {cmd:value} (Total)
column. The interval method is selected with {opt method()} and defaults to the
exact (Clopper-Pearson) interval.

{title:Options}
{phang}{opt output(string)} is required and names the dataset the table is saved
to. With {cmd:append} the table is added to the rows already in {opt output()}.

{phang}{opt method(string)} selects the interval method, mirroring
{helpb ci:ci proportions}: {cmd:exact} (Clopper-Pearson, the default),
{cmd:wald}, {cmd:wilson}, {cmd:agresti} (Agresti-Coull), or {cmd:jeffreys}.

{phang}{opt level(numlist)} sets the confidence level in percent. Default is 95.
The value must be strictly between 0 and 100.

{phang}{opt format(string)} sets the numeric display format for the percentage
and interval bounds. Default is {cmd:%9.2f}.

{phang}{opt append} appends this table to an existing {opt output()} dataset
instead of overwriting it. The file must already exist.

{phang}{opt by(varname)} computes a separate interval within each level of a
labelled categorical variable, producing one {cmd:value_}{it:level} column per
level.

{phang}{opt addtotal} adds an overall (Total) {cmd:value} column when {cmd:by()}
is specified.

{phang}{opt idstart(integer)} sets the id assigned to the first row (default 1),
so appended tables can keep a continuous id sequence.

{title:Examples}
{phang}{cmd:. compute_ci treated cured, output("ci.dta")}{p_end}

{phang}{cmd:. compute_ci response, output("ci.dta") method(jeffreys) level(90)}{p_end}

{phang}{cmd:. compute_ci heavy cheap, output("ci.dta") by(foreign) addtotal}{p_end}

{phang}{cmd:. compute_ci relapse, output("ci.dta") append idstart(5)}{p_end}

{title:Also see}
{pstd}{help qual}, {help quant}, {help label_table}, {help add_perc}{p_end}
