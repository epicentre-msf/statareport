{smcl}
{* *! version 1.2.0 20apr2026}
{title:Title}
{pstd}{bf:lastexport} {hline 2} Locate the most recent dated export folder under a parent directory.

{title:Syntax}
{p 4 8 2}{cmd:lastexport}{cmd:,} {cmdab:p:arent(}{it:path}{cmd:)}
[{cmdab:pa:ttern(}{it:str}{cmd:)}
{cmdab:nch:ars(}{it:#}{cmd:)}
{cmdab:str:ict}
{cmdab:qui:et}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:p:arent(}{it:path}{cmd:)}}directory whose dated subfolders are scanned (required){p_end}
{synopt:{cmdab:pa:ttern(}{it:str}{cmd:)}}glob to restrict candidate names (default {cmd:*}){p_end}
{synopt:{cmdab:nch:ars(}{it:#}{cmd:)}}number of characters that make a date name (default {cmd:8}; use {cmd:10} for {cmd:YYYY-MM-DD}){p_end}
{synopt:{cmdab:str:ict}}abort with rc 601 when no dated folder is found (default: warn){p_end}
{synopt:{cmdab:qui:et}}suppress the "latest export date" line{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:lastexport} scans {opt parent()} for subfolders whose names are
dates and returns the one that sorts last. Because zero-padded
{cmd:YYYYMMDD} names sort lexicographically in the same order as they do
chronologically, a plain string comparison yields the most recent export
without parsing dates.{p_end}

{pstd}The typical use is at the top of a master do-file: point at a data
export directory, capture the newest drop, and feed it into
{help statareport_set_data_root}.{p_end}

{title:Name filter}
{pstd}A folder name is accepted when its length matches {opt nchars()}
and, after stripping dashes, it parses as a number. So{p_end}

{phang2}{cmd:20260419}{space 4}-- passes with the default {cmd:nchars(8)}{p_end}
{phang2}{cmd:2026-04-19}{space 2}-- passes with {cmd:nchars(10)} (dashes removed before the number check){p_end}
{phang2}{cmd:april-2026}{space 1}-- rejected (not all digits){p_end}
{phang2}{cmd:99999999}{space 4}-- passes (the command does not validate actual calendar dates){p_end}

{title:Examples}
{phang}Typical pattern inside a master do-file:{p_end}
{phang}{cmd:. lastexport, parent("$dir_onedrive/QC/Dataset_export")}{p_end}
{phang}{cmd:. statareport_set_data_root, path("$dir_onedrive/QC/Dataset_export/`r(latest)'/Stata")}{p_end}

{phang}Accept hyphenated date folders:{p_end}
{phang}{cmd:. lastexport, parent("/data/exports") nchars(10)}{p_end}

{phang}Fail hard when no dated folder exists:{p_end}
{phang}{cmd:. lastexport, parent("$dir_onedrive/QC/Dataset_export") strict}{p_end}

{title:Stored results}
{pstd}{cmd:r(latest)}: the latest dated folder name (empty if none found){break}
{cmd:r(path)}: {cmd:parent()/latest} — empty when no match{break}
{cmd:r(n_matches)}: number of dated folders detected{p_end}

{title:Also see}
{pstd}{help statareport_set_data_root}, {help statareport_load_env}, {help statareport_init_project}{p_end}
