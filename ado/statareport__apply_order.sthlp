{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:statareport__apply_order} {hline 2} Sort rows in a preferred order.

{title:Syntax}
{p 4 8 2}{cmd:statareport__apply_order}{cmd:,}
{cmd:order(}{it:string}{cmd:)}
[{cmd:match(}{it:string}{cmd:)}
{cmd:strict}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:order(}{it:string}{cmd:)}}space-separated list defining the desired row order (required){p_end}
{synopt:{cmd:match(}{it:string}{cmd:)}}variable whose values are matched against the order list (default {cmd:"variable"}){p_end}
{synopt:{cmd:strict}}error if any item in the order list is missing from the data{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport__apply_order} is an internal utility used by
{help qual} and {help quant} to sort the rows of a dataset in a preferred
order.  The command matches each item in {opt order()} against the values of
the variable specified by {opt match()} (default {cmd:"variable"}) and assigns
sort positions accordingly.  Rows that do not match any item in the order list
retain their relative order but are pushed to the bottom of the dataset.  When
{opt strict} is specified the command throws an error if any order item is
absent from the data.

{title:Options}
{phang}{cmd:order(}{it:string}{cmd:)} provides the space-separated list of
values that defines the desired sort order.  The first item appears as the
first row, the second item as the second row, and so on.

{phang}{cmd:match(}{it:string}{cmd:)} identifies the variable whose values are
compared with the items in {opt order()}.  If omitted the command defaults to
the variable named {cmd:variable}.

{phang}{cmd:strict} causes the command to exit with an error if any item
listed in {opt order()} has no matching row in the dataset.  Without this
option unmatched items are silently ignored.

{title:Examples}
{phang}{cmd:. statareport__apply_order, order("age sex weight height")}

{phang}{cmd:. statareport__apply_order, order("site1 site2 site3") match(site_name) strict}

{phang}{cmd:. statareport__apply_order, order("adverse_event grade severity") match(variable)}

{title:Also see}
{psee}{help qual}, {help quant}
