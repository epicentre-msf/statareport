{smcl}
{* *! version 1.0.0 28apr2026}
{title:Title}
{pstd}{bf:statareport_set_local_data_root} {hline 2} Cache a project-local data directory used by {help statareport_add_data}{cmd:, local}.

{title:Syntax}
{p 4 8 2}{cmd:statareport_set_local_data_root} [{cmd:,} {cmd:path(}{it:string}{cmd:)} {cmd:clear} {cmdab:mk:dir} {cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:path(}{it:string}{cmd:)}}directory used as the local data root. Default: {cmd:local_datasets}{p_end}
{synopt:{cmd:clear}}forget the cached root{p_end}
{synopt:{cmdab:mk:dir}}create the directory if it does not yet exist{p_end}
{synopt:{cmdab:qui:et}}suppress the confirmation message{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_set_local_data_root} is the cousin of
{help statareport_set_data_root} for derived or intermediate datasets
that live {it:inside} the project repository -- typically the
{cmd:local_datasets/} folder created by {help statareport_setup_dirs}.
The resolved path is stored in the Mata global
{cmd:__statareport_local_data_root__}, kept separate from the external
data root so a project can reference both at once: a shared dataset
export {it:and} a working folder under version control.{p_end}

{pstd}{help statareport_add_data} consults this cache only when invoked
with the new {cmd:local} option (see below). Existing modes
({cmd:raw}, {cmd:project}, {cmd:root()}, default) are unchanged.{p_end}

{title:Resolution rules}
{pstd}{opt path()} is normalised (backslashes to forward slashes), and:{p_end}
{phang2}* Absolute paths ({cmd:/...}, {cmd:X:/...}) are stored verbatim.{p_end}
{phang2}* Relative paths are joined with {cmd:__here_root__} (the {help here} cache). When {cmd:here} has not yet run, {cmd:c(pwd)} is used and a note is printed.{p_end}
{phang2}* When {opt path()} is omitted the stem {cmd:local_datasets} is used so the command Just Works in a freshly scaffolded project.{p_end}

{pstd}Nothing is verified at set time unless {cmd:mkdir} is given, in
which case a missing directory is created (rc 693 / EEXIST is treated
as success). Use {help statareport_confirm_data} to audit the
resulting {cmd:$data_*} globals once datasets are registered.{p_end}

{title:Examples}
{pstd}Default ({cmd:<here>/local_datasets}) inside a freshly initialised project:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_set_local_data_root}{p_end}

{pstd}Custom folder, materialise it:{p_end}
{phang}{cmd:. statareport_set_local_data_root, path("derived") mkdir}{p_end}

{pstd}Absolute path (e.g. a shared scratch volume):{p_end}
{phang}{cmd:. statareport_set_local_data_root, path("/Volumes/scratch/`c(username)'/trial")}{p_end}

{pstd}Forget the cache:{p_end}
{phang}{cmd:. statareport_set_local_data_root, clear}{p_end}

{pstd}Pair with {help statareport_add_data}{cmd:, local} to write
short, root-anchored paths:{p_end}
{phang}{cmd:. statareport_set_local_data_root}{p_end}
{phang}{cmd:. statareport_add_data, name(core)        path("core.dta")           local optional}{p_end}
{phang}{cmd:. statareport_add_data, name(ae_coded)    path("ae_coded.dta")       local optional}{p_end}

{title:Stored results}
{pstd}{cmd:r(path)}: resolved absolute path stored in {cmd:__statareport_local_data_root__}{p_end}

{title:Also see}
{pstd}{help statareport_set_data_root}, {help statareport_add_data}, {help statareport_confirm_data}, {help statareport_setup_dirs}, {help here}{p_end}
