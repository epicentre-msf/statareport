{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_set_paths} {hline 2} Populate the {cmd:$file_*} globals consumed by the render pipeline.

{title:Syntax}
{p 4 8 2}{cmd:statareport_set_paths}{cmd:,} {cmdab:pref:ix(}{it:string}{cmd:)}
[{it:options}]
{p_end}

{synoptset 28 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:pref:ix(}{it:string}{cmd:)}}project shortname baked into every filename (required){p_end}
{synopt:{cmdab:dat:e(}{it:string}{cmd:)}}date fragment appended to the docx output (e.g. {cmd:20260419}){p_end}
{synopt:{cmd:root(}{it:string}{cmd:)}}project root. If omitted, the Mata cache of {help here} is used; otherwise {cmd:c(pwd)}{p_end}
{synopt:{cmd:variant(}{it:string}{cmd:)}}optional infix. With {cmd:variant(listings)}, writes {cmd:$file_input_listings} etc{p_end}
{synopt:{cmd:dyntex(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_dyntex} path{p_end}
{synopt:{cmd:input(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_input} path{p_end}
{synopt:{cmd:header(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_header} path{p_end}
{synopt:{cmd:output(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_output} path{p_end}
{synopt:{cmd:reference(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_reference} path{p_end}
{synopt:{cmd:defaults(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_default_options} path{p_end}
{synopt:{cmd:label(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_label} path{p_end}
{synopt:{cmd:graphopts(}{it:string}{cmd:)}}override the auto-derived {cmd:$file_graph_opts} path{p_end}
{synopt:{cmdab:qui:et}}suppress the summary message printed to the Results window{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_set_paths} replaces the ~15 hand-written
{cmd:global file_*} lines that typically open a statareport render script.
From a single {opt prefix()} and (optional) {opt variant()} the command
fills in the full path family that {help knit}, {help create_dyntex}, and
{help label_table} expect:{p_end}

{phang2}{cmd:$file_dyntex}{col 32}{cmd:<root>/output_md/<stem>-dyn.txt}{p_end}
{phang2}{cmd:$file_input}{col 32}{cmd:<root>/output_md/<stem>.txt}{p_end}
{phang2}{cmd:$file_header}{col 32}{cmd:<root>/input_md/header[-<variant>].txt}{p_end}
{phang2}{cmd:$file_output}{col 32}{cmd:<root>/output_word/<stem>[-<date>].docx}{p_end}
{phang2}{cmd:$file_reference}{col 32}{cmd:<root>/input_md/custom_reference[-<variant>].docx}{p_end}
{phang2}{cmd:$file_default_options}{col 32}{cmd:<root>/input_md/default_options[-<variant>].yaml}{p_end}
{phang2}{cmd:$file_label}{col 32}{cmd:<root>/input_tables/tables_labels[-<variant>].xlsx}{p_end}
{phang2}{cmd:$file_graph_opts}{col 32}{cmd:<root>/input_tables/shift_graph_input[-<variant>].xlsx}{p_end}

{pstd}Here {cmd:<stem>} is {cmd:<prefix>} or {cmd:<prefix>-<variant>}. When
{opt variant()} is non-empty the globals are suffixed with {cmd:_<variant>}
so main and listings can coexist.{p_end}

{pstd}Individual paths can always be overridden via the dedicated options
(e.g. {cmd:label("my_custom_labels.xlsx")}); anything not overridden
follows the convention.{p_end}

{title:Root resolution}
{pstd}The command resolves {opt root()} in this order:{p_end}
{phang2}1. Explicit {opt root()} argument.{p_end}
{phang2}2. Mata cache populated by {help here}. Call {cmd:here} once at the
top of your master do-file to seed it.{p_end}
{phang2}3. {cmd:c(pwd)} (with a warning).{p_end}

{title:Stored results}
{pstd}{cmd:statareport_set_paths} returns each emitted path under
{cmd:r(root)}, {cmd:r(variant)}, {cmd:r(dyntex)}, {cmd:r(input)},
{cmd:r(header)}, {cmd:r(output)}, {cmd:r(reference)}, {cmd:r(defaults)},
{cmd:r(label)}, and {cmd:r(graphopts)} so callers that prefer locals over
globals can consume them directly.{p_end}

{title:Examples}
{pstd}Main report only:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_set_paths, prefix("MyTrial") date("20260419")}{p_end}
{phang}{cmd:. knit using "$file_input", saving("$file_output") replace ///}{p_end}
{phang}{cmd:          reference("$file_reference") prepend("$file_header")}{p_end}

{pstd}Main plus listings variant:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_set_paths, prefix("MyTrial") date("$date_export")}{p_end}
{phang}{cmd:. statareport_set_paths, prefix("MyTrial") date("$date_export") variant("listings")}{p_end}

{pstd}Overriding one path:{p_end}
{phang}{cmd:. statareport_set_paths, prefix("MyTrial") label("shared/labels_v2.xlsx")}{p_end}

{title:Also see}
{pstd}{help here}, {help knit}, {help create_dyntex}, {help label_table}, {help statareport_setup_dirs}{p_end}
