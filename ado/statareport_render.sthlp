{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_render} {hline 2} One-call wrapper for {help create_dyntex} + {help dyntext} + {help knit}.

{title:Syntax}
{p 4 8 2}{cmd:statareport_render}
[{cmd:,} {it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:variant(}{it:s}{cmd:)}}read {cmd:$<global>_}{it:s} instead of {cmd:$<global>} (e.g. {cmd:listings}){p_end}
{synopt:{cmd:label(}{it:str}{cmd:)}}override {cmd:$file_label}{p_end}
{synopt:{cmd:dyntex(}{it:str}{cmd:)}}override {cmd:$file_dyntex}{p_end}
{synopt:{cmd:input(}{it:str}{cmd:)}}override {cmd:$file_input}{p_end}
{synopt:{cmd:output(}{it:str}{cmd:)}}override {cmd:$file_output}{p_end}
{synopt:{cmd:reference(}{it:str}{cmd:)}}override {cmd:$file_reference}{p_end}
{synopt:{cmd:header(}{it:str}{cmd:)}}override {cmd:$file_header} (prepended by pandoc){p_end}
{synopt:{cmd:filters(}{it:str}{cmd:)}}override {cmd:$file_filters} (space-separated list of Lua filters){p_end}
{synopt:{cmd:sheet(}{it:str}{cmd:)}}override {cmd:$var_sheet_lab} (default {cmd:Labels}){p_end}
{synopt:{cmd:tab_dir(}{it:str}{cmd:)}}override {cmd:$dir_lbltables}{p_end}
{synopt:{cmd:fig_dir(}{it:str}{cmd:)}}override {cmd:$dir_figures}{p_end}
{synopt:{cmdab:nbin:put(}{it:#}{cmd:)}}forwarded to {help create_dyntex} (limit to first {it:#} rows){p_end}
{synopt:{cmd:default(}{it:str}{cmd:)}}user-supplied Pandoc defaults YAML (forwarded to {help knit}){p_end}
{synopt:{cmd:first(}{it:str}{cmd:)}}Pandoc metadata file (forwarded to knit){p_end}
{synopt:{cmdab:in_h:eader(}{it:str}{cmd:)}}Pandoc include-in-header file (forwarded to knit){p_end}
{synopt:{cmdab:pan:docloc(}{it:str}{cmd:)}}explicit pandoc binary path (forwarded to knit){p_end}
{synopt:{cmd:toc(}{it:yes|no}{cmd:)}}forwarded to {help knit} (default yes){p_end}
{synopt:{cmdab:num:ber_sec(}{it:yes|no}{cmd:)}}forwarded to {help knit} (default yes){p_end}
{synopt:{cmd:from(}{it:str}{cmd:)}}pandoc reader override{p_end}
{synopt:{cmd:to(}{it:str}{cmd:)}}pandoc writer override{p_end}
{synopt:{cmd:skip_dyntex}}skip stage 1 (use existing {cmd:$file_dyntex}){p_end}
{synopt:{cmd:skip_dyntext}}skip stage 2 (use existing {cmd:$file_input}){p_end}
{synopt:{cmd:skip_knit}}skip stage 3 (stop after the Markdown is written){p_end}
{synopt:{cmdab:qui:et}}suppress the per-stage progress line{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_render} collapses the three-step render tail of a
final do-file into a single command. It reads the {cmd:$file_*},
{cmd:$dir_*}, and {cmd:$var_*} globals populated by
{help statareport_set_paths}, {help statareport_add_dir}, and the rest of
the scaffolding commands, then drives {help create_dyntex},
{help dyntext}, and {help knit} in order.{p_end}

{pstd}Any single path or option can be overridden per-call; anything not
overridden falls back to the variant-aware global, then the plain global.
For the listings variant the command reads {cmd:$file_*_listings} instead
of {cmd:$file_*}.{p_end}

{title:Examples}
{pstd}Render the main report:{p_end}
{phang}{cmd:. statareport_render}{p_end}

{pstd}Render the listings variant, no table of contents:{p_end}
{phang}{cmd:. statareport_render, variant("listings") toc(no)}{p_end}

{pstd}Override a single path (custom label sheet name):{p_end}
{phang}{cmd:. statareport_render, sheet("Labels_v2")}{p_end}

{pstd}Iterate on the Markdown only, no knit:{p_end}
{phang}{cmd:. statareport_render, skip_knit}{p_end}

{title:Stored results}
{pstd}{cmd:r(label)}, {cmd:r(dyntex)}, {cmd:r(input)}, {cmd:r(output)},
{cmd:r(reference)}, {cmd:r(header)}, {cmd:r(filters)}: the resolved paths
actually used this call.{p_end}

{title:Also see}
{pstd}{help create_dyntex}, {help knit}, {help statareport_set_paths}, {help statareport_write_header}{p_end}
