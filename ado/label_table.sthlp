{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:label_table} {hline 2} Merge human-readable labels from Excel onto a Stata dataset.

{title:Syntax}
{p 4 8 2}{cmd:label_table}{cmd:,}
{cmdab:tab_f:ile(}{it:string}{cmd:)}
{cmdab:label_f:ile(}{it:string}{cmd:)}
{cmdab:tab_i:d(}{it:string}{cmd:)}
[{cmdab:label_n:ame(}{it:string}{cmd:)}
{cmdab:value_n:ame(}{it:string}{cmd:)}
{cmdab:drop_v:alue(}{it:string}{cmd:)}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:tab_f:ile(}{it:string}{cmd:)}}path to the Stata dataset to label (required){p_end}
{synopt:{cmdab:label_f:ile(}{it:string}{cmd:)}}Excel workbook containing the label mapping (required){p_end}
{synopt:{cmdab:tab_i:d(}{it:string}{cmd:)}}worksheet name that holds the id/label mapping (required){p_end}
{synopt:{cmdab:label_n:ame(}{it:string}{cmd:)}}note attached to the {cmd:label} column{p_end}
{synopt:{cmdab:value_n:ame(}{it:string}{cmd:)}}note propagated to all {cmd:value*} columns{p_end}
{synopt:{cmdab:drop_v:alue(}{it:string}{cmd:)}}drop rows whose {cmd:value} matches this string{p_end}
{synopt:{cmdab:keepid}}retain the {cmd:id} column in the output dataset{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:label_table} merges human-readable labels from an Excel workbook
onto a Stata dataset.  Both the dataset and the Excel sheet must contain an
{cmd:id} column.  The Excel sheet must also contain a {cmd:label} column.
Duplicate ids in the label sheet are dropped before the merge.  After merging
the command keeps only {cmd:label} and {cmd:value*} variables, sorted by
{cmd:order} (if present) or {cmd:id}.  Optional notes can be attached to the
{cmd:label} and {cmd:value*} columns for downstream use by {help kable} or
{help kable_basic}.

{title:Options}
{phang}{cmd:tab_file(}{it:string}{cmd:)} specifies the path to the Stata
dataset that needs labelling.

{phang}{cmd:label_file(}{it:string}{cmd:)} specifies the Excel workbook
containing the label mapping.

{phang}{cmd:tab_id(}{it:string}{cmd:)} names the worksheet inside the Excel
workbook that holds the id-to-label mapping.

{phang}{cmd:label_name(}{it:string}{cmd:)} attaches a note to the {cmd:label}
variable.  This note is used by {help kable} as a column header.

{phang}{cmd:value_name(}{it:string}{cmd:)} attaches a note to every
{cmd:value*} variable.

{phang}{cmd:drop_value(}{it:string}{cmd:)} drops rows whose {cmd:value}
variable matches the specified string (case sensitive after trimming).

{phang}{cmd:keepid} retains the {cmd:id} column alongside {cmd:label} and
{cmd:value*} in the output dataset. By default only {cmd:label} and
{cmd:value*} are kept, which is the format consumed by {help kable}.

{title:Examples}
{phang}{cmd:. label_table, tab_file("output_tables/ae_summary.dta") label_file("input_tables/labels.xlsx") tab_id("AE")}{p_end}

{phang}{cmd:. label_table, tab_file("output_tables/demographics.dta") label_file("input_tables/labels.xlsx") tab_id("DM") label_name("Characteristic") value_name("N (%)")}{p_end}

{phang}{cmd:. label_table, tab_file("output_tables/lab_results.dta") label_file("input_tables/labels.xlsx") tab_id("LAB") drop_value("NA")}{p_end}

{phang}{cmd:. label_table, tab_file("output_tables/ae.dta") label_file("input_tables/labels.xlsx") tab_id("AE") keepid}{p_end}

{title:Also see}
{pstd}{help qual}, {help quant}, {help create_dyntex}{p_end}
