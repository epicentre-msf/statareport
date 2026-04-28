{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_add_data} {hline 2} Register a .dta file as the global {cmd:$data_}{it:name} and confirm its presence.

{title:Syntax}
{p 4 8 2}{cmd:statareport_add_data}{cmd:,}
{cmdab:n:ame(}{it:string}{cmd:)} {cmd:path(}{it:string}{cmd:)}
[{cmd:root(}{it:string}{cmd:)} {cmdab:raw} {cmdab:pro:ject} {cmdab:loc:al}
{cmdab:opt:ional} {cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:n:ame(}{it:string}{cmd:)}}stem appended to {cmd:data_} in the emitted global (required){p_end}
{synopt:{cmd:path(}{it:string}{cmd:)}}path to the dataset (required){p_end}
{synopt:{cmd:root(}{it:string}{cmd:)}}override the cached data root for this one call{p_end}
{synopt:{cmdab:raw}}use {opt path()} verbatim; do not prepend any root{p_end}
{synopt:{cmdab:pro:ject}}resolve relative paths against the {help here} project root instead of the data root{p_end}
{synopt:{cmdab:loc:al}}resolve relative paths against the {help statareport_set_local_data_root} cache instead of the data root{p_end}
{synopt:{cmdab:opt:ional}}the dataset may not exist yet; suppress the missing-file warning{p_end}
{synopt:{cmdab:qui:et}}suppress the "registered" line on success{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_add_data} is the per-dataset counterpart of
{help statareport_set_paths}. Each call:{p_end}

{phang2}1. Resolves {opt path()} according to the mode below.{p_end}
{phang2}2. Sets the Stata global {cmd:$data_}{it:name} to the resolved path.{p_end}
{phang2}3. Runs {cmd:confirm file} against the path. A missing file triggers
a warning unless {cmd:optional} is specified.{p_end}

{title:Resolution modes}
{pstd}{cmd:path()} is normalised (backslashes to forward slashes), and
absolute paths ({cmd:/...}, {cmd:X:/...}) are always used verbatim. For a
relative path the root is chosen by the first matching rule:{p_end}

{phang2}* {cmd:raw}           -- no root prepended; the path is used as-is.{p_end}
{phang2}* {cmd:root(}{it:p}{cmd:)}      -- use {it:p} just for this call.{p_end}
{phang2}* {cmd:project}       -- join with {cmd:__here_root__} (the {help here} cache).{p_end}
{phang2}* {cmd:local}         -- join with {cmd:__statareport_local_data_root__} (the {help statareport_set_local_data_root} cache).{p_end}
{phang2}* (default)           -- join with {cmd:__statareport_data_root__} (the {help statareport_set_data_root} cache).{p_end}

{pstd}The modes are mutually exclusive: specifying more than one among
{cmd:raw}, {cmd:project}, {cmd:local}, and {cmd:root()} aborts with rc 198.
Specifying {cmd:project} when {help here} has not run, or {cmd:local}
when {help statareport_set_local_data_root} has not been called, aborts
with rc 459.{p_end}

{title:Examples}
{pstd}Bulk registration with a shared data root:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_set_data_root, path("$dir_datasets")}{p_end}
{phang}{cmd:. statareport_add_data, name(preselection)   path("preselection_visit.dta")}{p_end}
{phang}{cmd:. statareport_add_data, name(blood_sampling) path("blood_sampling_for_pk.dta")}{p_end}

{pstd}An already-qualified path (OneDrive global, raw mode):{p_end}
{phang}{cmd:. statareport_add_data, name(meddra) path("$dir_onedrive/Meddra/meddra_codes.dta") raw}{p_end}

{pstd}A derived dataset that lives inside the project repo (resolved
against {help here} instead of the data root):{p_end}
{phang}{cmd:. statareport_add_data, name(local_core) ///}{p_end}
{phang}{cmd:      path("local_datasets/core.dta") project optional}{p_end}

{pstd}Many derived datasets sharing the same project-local folder
(set the local root once, then pass bare filenames):{p_end}
{phang}{cmd:. statareport_set_local_data_root}{p_end}
{phang}{cmd:. statareport_add_data, name(core)     path("core.dta")     local optional}{p_end}
{phang}{cmd:. statareport_add_data, name(ae_coded) path("ae_coded.dta") local optional}{p_end}

{title:Stored results}
{pstd}{cmd:r(name)}: supplied name{break}
{cmd:r(path)}: resolved absolute path written to {cmd:$data_}{it:name}{break}
{cmd:r(mode)}: one of {cmd:raw}, {cmd:root}, {cmd:project}, {cmd:local}, {cmd:data}{break}
{cmd:r(missing)}: 1 if {cmd:confirm file} failed, 0 otherwise{p_end}

{title:Also see}
{pstd}{help statareport_set_data_root}, {help statareport_set_local_data_root}, {help statareport_confirm_data}, {help statareport_set_paths}, {help here}{p_end}
