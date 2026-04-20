{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:reportdo} {hline 2} Shortcut for {cmd:do} on a file inside {cmd:$dir_dofiles}.

{title:Syntax}
{p 4 8 2}{cmd:reportdo} {it:name}
[{cmd:,} {cmdab:arg:s(}{it:string}{cmd:)} {cmdab:qui:et}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:arg:s(}{it:string}{cmd:)}}extra arguments passed to the underlying {cmd:do}{p_end}
{synopt:{cmdab:qui:et}}run via {cmd:quietly do}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:reportdo} is a one-token wrapper around {cmd:do}. It resolves
{it:name} against {cmd:$dir_dofiles} (set by
{help statareport_add_dir}{cmd:, name(dofiles)}), appends {cmd:.do} if you
omit the extension, and forwards extra arguments when
{opt args()} is given.{p_end}

{pstd}Absolute paths (starting with {cmd:/} or {cmd:X:/}) are executed
verbatim, so the command remains useful outside the {cmd:do_files/}
folder.{p_end}

{title:Examples}
{phang}{cmd:. reportdo 01-create-datasets}{p_end}
{phang}{cmd:. reportdo helpers/make_cohort}{p_end}
{phang}{cmd:. reportdo 06-safety, quiet}{p_end}
{phang}{cmd:. reportdo compile_report, args("2026-04-19 listings")}{p_end}

{title:Also see}
{pstd}{help statareport_add_dir}, {help statareport_init_project}, {help do}{p_end}
