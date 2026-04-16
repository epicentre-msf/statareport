{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:create_dyntex} {hline 2} Generate a DynTex control file from a labelled Excel sheet.

{title:Syntax}
{p 4 8 2}{cmd:create_dyntex} {cmd:using} {it:filename}{cmd:,}
{cmdab:dyntex_f:ile(}{it:string}{cmd:)}
{cmdab:label_s:heet(}{it:string}{cmd:)}
{cmdab:tab_d:ir(}{it:string}{cmd:)}
{cmdab:fig_d:ir(}{it:string}{cmd:)}
[{cmdab:nbin:put(}{it:numlist}{cmd:)}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:dyntex_f:ile(}{it:string}{cmd:)}}path to the output DynTex file (required){p_end}
{synopt:{cmdab:label_s:heet(}{it:string}{cmd:)}}name of the Excel worksheet containing table/figure instructions (required){p_end}
{synopt:{cmdab:tab_d:ir(}{it:string}{cmd:)}}directory containing {cmd:.dta} table datasets (required){p_end}
{synopt:{cmdab:fig_d:ir(}{it:string}{cmd:)}}directory containing PNG figure files (required){p_end}
{synopt:{cmdab:nbin:put(}{it:numlist}{cmd:)}}limit processing to the first {it:N} rows of the label sheet{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:create_dyntex} reads table and figure instructions from an Excel
worksheet and writes a DynTex control file compatible with Stata's dynamic
document system.  The label sheet must contain the following columns:
{bf:InputID}, {bf:Include}, {bf:Caption}, {bf:Figure}, {bf:FootNote},
{bf:Section}, {bf:Subsection}, and {bf:DisplayMode}.  Rows whose {bf:Include}
column is not set to {cmd:"Yes"} are skipped.  Page orientation switches
between Portrait and Landscape based on {bf:DisplayMode}, and section and
subsection headings are emitted when they change.

{title:Options}
{phang}{cmd:dyntex_file(}{it:string}{cmd:)} specifies the path where the
generated DynTex file will be written.  This file is subsequently consumed by
{cmd:dyndoc} or a similar Stata dynamic document renderer.

{phang}{cmd:label_sheet(}{it:string}{cmd:)} names the Excel worksheet inside
{it:filename} that contains the table/figure metadata.

{phang}{cmd:tab_dir(}{it:string}{cmd:)} is the directory that holds {cmd:.dta}
files referenced by the {bf:InputID} column.  Each table row writes a
{cmd:kable} call that loads {it:tab_dir}/{it:InputID}.dta.

{phang}{cmd:fig_dir(}{it:string}{cmd:)} is the directory containing PNG images
referenced by the {bf:InputID} column.

{phang}{cmd:nbinput(}{it:numlist}{cmd:)} restricts the command to the first
{it:N} rows of the label sheet.  Useful for debugging a subset of outputs.

{title:Examples}
{phang}{cmd:. create_dyntex using "input_tables/labels.xlsx", dyntex_file("output_md/report.txt") label_sheet("Tables") tab_dir("output_tables") fig_dir("output_figures")}

{phang}{cmd:. create_dyntex using "metadata.xlsx", dyntex_file("draft.txt") label_sheet("AllOutputs") tab_dir("tables") fig_dir("figures") nbinput(5)}

{phang}{cmd:. create_dyntex using "labels.xlsx", dyntex_file("output_md/appendix.txt") label_sheet("Appendix") tab_dir("output_tables") fig_dir("output_figures")}

{title:Also see}
{psee}{help kable}, {help knit}, {help label_table}
