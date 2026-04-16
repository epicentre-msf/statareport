{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:statareport_setup_dirs} {hline 2} Create the standard directory scaffold for statareport projects.

{title:Syntax}
{p 4 8 2}{cmd:statareport_setup_dirs}
[{cmd:,} {cmd:root(}{it:string}{cmd:)}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:root(}{it:string}{cmd:)}}root folder under which directories are created (default: current working directory){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_setup_dirs} creates the standard directory scaffold
expected by {cmd:statareport} workflows.  The following eight directories are
created under the root folder: {cmd:input_md}, {cmd:input_tables},
{cmd:output_md}, {cmd:output_tables}, {cmd:output_figures}, {cmd:output_word},
{cmd:logs}, and {cmd:local_datasets}.  Existing directories are left
untouched.  When certain placeholder files are missing the command writes
template files: a CSV template in {cmd:input_tables/}, a Markdown placeholder
in {cmd:input_md/}, and a {cmd:.gitkeep} file in {cmd:logs/}.

{title:Options}
{phang}{cmd:root(}{it:string}{cmd:)} specifies the root folder under which the
directory tree is created.  Path separators are normalised and trailing slashes
are trimmed.  When omitted the current working directory is used.

{title:Examples}
{phang}{cmd:. statareport_setup_dirs}

{phang}{cmd:. statareport_setup_dirs, root("C:/Projects/trial_report")}

{phang}{cmd:. statareport_setup_dirs, root("../my_analysis")}

{title:Also see}
{psee}{help knit}, {help create_dyntex}, {help qual}, {help quant}
