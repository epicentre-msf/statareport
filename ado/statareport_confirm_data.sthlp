{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_confirm_data} {hline 2} Re-verify that every {cmd:$data_*} global points to an existing file.

{title:Syntax}
{p 4 8 2}{cmd:statareport_confirm_data}
[{cmd:,} {cmd:strict} {cmd:ignore(}{it:namelist}{cmd:)} {cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:strict}}exit with rc 601 when any file is missing{p_end}
{synopt:{cmd:ignore(}{it:namelist}{cmd:)}}global names (with or without the {cmd:data_} prefix) to skip{p_end}
{synopt:{cmdab:qui:et}}suppress the summary line on success{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}Replaces the ad-hoc loop{p_end}

{phang2}{cmd:local list_of_data : all globals "data_*"}{break}
{cmd:foreach d of local list_of_data {c -(}}{break}
{cmd:    capture confirm file "${c 96}d${c 39}"}{break}
{cmd:    if _rc display as error "${c 96}d${c 39} not found"}{break}
{cmd:{c )-}}{p_end}

{pstd}with a structured, scriptable version: each missing file is
reported, {cmd:r(n_missing)}/{cmd:r(n_total)}/{cmd:r(missing)} are
returned, and {cmd:strict} promotes any failure to an error exit.{p_end}

{pstd}Derived datasets that are produced later in the pipeline can be
skipped with {cmd:ignore()}. Either form is accepted:{p_end}

{phang2}{cmd:ignore(local_core local_bio_bas)}{p_end}
{phang2}{cmd:ignore(data_local_core data_local_bio_bas)}{p_end}

{title:Examples}
{phang}{cmd:. statareport_confirm_data}{p_end}
{phang}{cmd:. statareport_confirm_data, ignore(local_core local_aecoded local_zscore)}{p_end}
{phang}{cmd:. statareport_confirm_data, strict}   // abort the run if anything is missing{p_end}

{title:Stored results}
{pstd}{cmd:r(n_total)}: number of {cmd:$data_*} globals scanned{break}
{cmd:r(n_missing)}: count of globals whose file could not be confirmed{break}
{cmd:r(missing)}: space-separated list of those global names{p_end}

{title:Also see}
{pstd}{help statareport_set_data_root}, {help statareport_add_data}, {help statareport_set_paths}{p_end}
