{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_add_dir} {hline 2} Register a directory as the global {cmd:$dir_}{it:name}.

{title:Syntax}
{p 4 8 2}{cmd:statareport_add_dir}{cmd:,}
{cmdab:n:ame(}{it:string}{cmd:)} {cmd:path(}{it:string}{cmd:)}
[{cmd:root(}{it:string}{cmd:)} {cmdab:raw} {cmdab:par:ent(}{it:string}{cmd:)}
{cmdab:mk:dir} {cmdab:opt:ional} {cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:n:ame(}{it:string}{cmd:)}}stem appended to {cmd:dir_} in the emitted global (required){p_end}
{synopt:{cmd:path(}{it:string}{cmd:)}}directory path (required){p_end}
{synopt:{cmd:root(}{it:string}{cmd:)}}override the default root for this one call{p_end}
{synopt:{cmdab:raw}}use {opt path()} verbatim; do not prepend any root{p_end}
{synopt:{cmdab:par:ent(}{it:string}{cmd:)}}resolve relative to another registered directory (name of an existing {cmd:$dir_*} global){p_end}
{synopt:{cmdab:mk:dir}}create the directory if it does not yet exist{p_end}
{synopt:{cmdab:opt:ional}}suppress the "does not exist" warning{p_end}
{synopt:{cmdab:qui:et}}suppress the "registered" line on success{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_add_dir} is the directory-scoped sibling of
{help statareport_add_data}. Each call sets the Stata global
{cmd:$dir_}{it:name} to the resolved absolute path. Absolute input paths
pass through untouched; relative paths are resolved by the first matching
rule below:{p_end}

{phang2}* {cmd:raw}           -- no root prepended.{p_end}
{phang2}* {cmd:root(}{it:p}{cmd:)}      -- prepend {it:p}.{p_end}
{phang2}* {cmd:parent(}{it:n}{cmd:)}    -- prepend {cmd:$dir_}{it:n} (or {cmd:$}{it:n} if the name already starts with {cmd:dir_}).{p_end}
{phang2}* (default)           -- prepend {cmd:__here_root__} (the {help here} project root).{p_end}

{pstd}{cmd:raw}, {cmd:root()}, and {cmd:parent()} are mutually exclusive.
Passing more than one aborts with rc 198.{p_end}

{pstd}Unlike {help statareport_add_data}, the default root for
{cmd:statareport_add_dir} is the {cmd:here} project root, not the data
root -- directories in a statareport project are almost always children
of the repo.{p_end}

{title:Examples}
{pstd}A typical project-directory block:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_add_dir, name(dofiles) path("do_files")}{p_end}
{phang}{cmd:. statareport_add_dir, name(tables)  path("output_tables")}{p_end}
{phang}{cmd:. statareport_add_dir, name(figures) path("output_figures")}{p_end}

{pstd}Nested directory resolved against an already-registered sibling:{p_end}
{phang}{cmd:. statareport_add_dir, name(lbltables) path("labelled_tables") parent(tables)}{p_end}
{pstd}produces {cmd:$dir_lbltables = $dir_tables/labelled_tables}.{p_end}

{pstd}An external location resolved through a user-defined global:{p_end}
{phang}{cmd:. statareport_add_dir, name(external) path("$dir_onedrive/Shared") raw}{p_end}

{pstd}Create the directory if it is missing:{p_end}
{phang}{cmd:. statareport_add_dir, name(logs) path("logs") mkdir}{p_end}

{title:Stored results}
{pstd}{cmd:r(name)}: supplied name{break}
{cmd:r(path)}: resolved absolute path written to {cmd:$dir_}{it:name}{break}
{cmd:r(mode)}: one of {cmd:project}, {cmd:raw}, {cmd:root}, {cmd:parent}{break}
{cmd:r(exists)}: 1 if the directory is present on disk, 0 otherwise{p_end}

{title:Also see}
{pstd}{help statareport_add_data}, {help statareport_set_paths}, {help statareport_setup_dirs}, {help here}{p_end}
