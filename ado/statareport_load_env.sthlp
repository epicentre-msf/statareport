{smcl}
{* *! version 1.2.0 20apr2026}
{title:Title}
{pstd}{bf:statareport_load_env} {hline 2} Load environment-style KEY=VALUE pairs into {cmd:$dir_*} globals.

{title:Syntax}
{p 4 8 2}{cmd:statareport_load_env}
[{cmd:,} {cmd:file(}{it:path}{cmd:)}
{cmd:env(}{it:str}{cmd:)}
{cmdab:pre:fix(}{it:str}{cmd:)}
{cmdab:keep:case}
{cmd:noos}
{cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:file(}{it:path}{cmd:)}}path to a dotenv-style file; default {cmd:<project-root>/.StataEnviron}{p_end}
{synopt:{cmd:env(}{it:str}{cmd:)}}inline {cmd:KEY=VALUE} pairs, space-separated{p_end}
{synopt:{cmdab:pre:fix(}{it:str}{cmd:)}}only load keys starting with this prefix (stripped from the emitted global name){p_end}
{synopt:{cmdab:keep:case}}preserve the original key case in the global name (default: lowercase){p_end}
{synopt:{cmd:noos}}skip the OS-env fallback ({cmd:printenv} / {cmd:set}){p_end}
{synopt:{cmdab:qui:et}}suppress the per-key summary line{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_load_env} is the "configuration loader" at the top of
a statareport master do-file. It reads {cmd:KEY=VALUE} pairs from three
places -- an inline option, a {cmd:.StataEnviron} file at the project
root, and the operating-system environment -- and exposes each one as
the Stata global {cmd:$dir_}{it:key} (lowercased unless {opt keepcase}
is passed).{p_end}

{pstd}The typical use is to keep machine-specific paths out of the
repository: you ship a {cmd:.StataEnviron.example} with placeholders,
each teammate copies it to {cmd:.StataEnviron} and fills in their own
OneDrive / data-export paths.{p_end}

{title:Lookup order}
{phang2}1. {opt env()} -- explicit, wins over file and OS.{p_end}
{phang2}2. {opt file()} -- defaults to {cmd:<here-root>/.StataEnviron}. Key{cmd:=}value per line, shell comments ({cmd:#}) allowed, optional {cmd:export} prefix, quoted values accepted.{p_end}
{phang2}3. OS environment -- {cmd:printenv} (POSIX) or {cmd:set} (Windows). Only an allow-list ({cmd:ONEDRIVE}, {cmd:DATASETS}, {cmd:PROJECT}) plus any {cmd:STATAREPORT_*} key are read; unrelated shell variables are ignored.{p_end}

{title:Key-to-global mapping}
{pstd}Every key {it:K} becomes {cmd:$dir_}{it:k} (lowercased). A prefix
of {cmd:dir_} in the key is kept as-is, so both {cmd:ONEDRIVE=...} and
{cmd:DIR_ONEDRIVE=...} land in {cmd:$dir_onedrive}. Examples:{p_end}

{phang2}{cmd:ONEDRIVE=/Users/me/OneDrive}{space 4}-> {cmd:$dir_onedrive}{p_end}
{phang2}{cmd:DATASETS=/data/trial/Stata}{space 5}-> {cmd:$dir_datasets}{p_end}
{phang2}{cmd:STATAREPORT_FOO=/etc/foo}{space 5}-> {cmd:$dir_foo} (when {cmd:prefix(STATAREPORT_)}){p_end}

{pstd}When {cmd:DATASETS} is set, the command also primes
{help statareport_set_data_root} with that value so that subsequent
{help statareport_add_data} calls resolve relative paths correctly.{p_end}

{title:Example .StataEnviron}
{phang}{cmd:# project-level config (gitignored)}{p_end}
{phang}{cmd:ONEDRIVE=/Users/me/Library/CloudStorage/OneDrive-Shared}{p_end}
{phang}{cmd:DATASETS=/Users/me/OneDrive/QC/Dataset_export/2026-04/Stata}{p_end}
{phang}{cmd:# PROJECT=...    # optional, falls back to `here' if omitted}{p_end}

{title:Examples}
{phang}Typical master do-file opener:{p_end}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_load_env}{p_end}
{phang}{cmd:. statareport_init_project, prefix("MyTrial")   // uses $dir_onedrive etc.}{p_end}

{phang}Explicit file, quiet:{p_end}
{phang}{cmd:. statareport_load_env, file("config/ci.env") quiet}{p_end}

{phang}Inline:{p_end}
{phang}{cmd:. statareport_load_env, env("ONEDRIVE=/mnt/od DATASETS=/data")}{p_end}

{phang}With prefix to pull only STATAREPORT_* keys:{p_end}
{phang}{cmd:. statareport_load_env, prefix(STATAREPORT_)}{p_end}

{title:Stored results}
{pstd}{cmd:r(loaded)}: space-separated list of globals that were set{break}
{cmd:r(n_loaded)}: count of globals emitted{break}
{cmd:r(source)}: {cmd:file}, {cmd:env}, {cmd:os}, {cmd:mixed}, or {cmd:none}{break}
{cmd:r(file)}: resolved path of the env file (whether it existed or not){p_end}

{title:Also see}
{pstd}{help here}, {help statareport_set_data_root}, {help statareport_init_project}{p_end}
