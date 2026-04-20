{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_add_programs} {hline 2} Add project-local ado directories to the adopath.

{title:Syntax}
{p 4 8 2}{cmd:statareport_add_programs} {it:dir} [{it:dir} {it:...}]
[{cmd:,} {cmdab:pre:pend} {cmdab:qui:et}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:pre:pend}}use {cmd:adopath +} instead of {cmd:adopath ++} (prepend: higher search priority){p_end}
{synopt:{cmdab:qui:et}}suppress the per-path confirmation line{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_add_programs} replaces the usual block{p_end}

{phang2}{cmd:quietly adopath ++ "$dir_project/programs"}{break}
{cmd:quietly adopath ++ "$dir_project/extras"}{p_end}

{pstd}with a one-line equivalent{p_end}

{phang2}{cmd:statareport_add_programs programs extras}{p_end}

{pstd}Each positional argument is resolved as follows:{p_end}

{phang2}* absolute path ({cmd:/...}, {cmd:X:/...}) : used verbatim.{p_end}
{phang2}* relative path                          : joined to the {help here} project root ({cmd:__here_root__}).{p_end}

{pstd}Missing directories trigger a warning and are skipped; {cmd:adopath}
would otherwise silently fail to find anything in them. Run {cmd:here}
once in your master do-file to seed the project root.{p_end}

{title:Examples}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_add_programs programs extras}{p_end}
{phang}{cmd:. statareport_add_programs helpers lib/stata, prepend}{p_end}
{phang}{cmd:. statareport_add_programs "/shared/ado", quiet}{p_end}

{title:Stored results}
{pstd}{cmd:r(paths)}: quoted list of directories actually added{break}
{cmd:r(added)}: count of directories appended to the adopath{break}
{cmd:r(missing)}: count of directories that did not exist and were skipped{p_end}

{title:Also see}
{pstd}{help statareport_add_dir}, {help statareport_add_data}, {help here}, {help adopath}{p_end}
