{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_set_data_root} {hline 2} Cache the default data directory used by {help statareport_add_data}.

{title:Syntax}
{p 4 8 2}{cmd:statareport_set_data_root}{cmd:,} [{cmd:path(}{it:string}{cmd:)} {cmd:clear} {cmdab:qui:et}]
{p_end}

{synoptset 24 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:path(}{it:string}{cmd:)}}directory that relative dataset paths resolve against{p_end}
{synopt:{cmd:clear}}forget the cached root{p_end}
{synopt:{cmdab:qui:et}}suppress the confirmation message{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_set_data_root} stores {opt path()} in the Mata global
{cmd:__statareport_data_root__}. {help statareport_add_data} consults this
cache whenever it receives a relative path, mirroring the role of
{help here} for the project root. Nothing is validated at set time -- use
{help statareport_confirm_data} to audit the resulting {cmd:$data_*}
globals.{p_end}

{pstd}For derived / intermediate datasets that live {it:inside} the
project repo, the cousin command {help statareport_set_local_data_root}
caches a separate root in {cmd:__statareport_local_data_root__} which
{help statareport_add_data}{cmd:, local} resolves against. The two
caches coexist independently.{p_end}

{title:Examples}
{phang}{cmd:. statareport_set_data_root, path("$dir_datasets")}{p_end}
{phang}{cmd:. statareport_set_data_root, clear}{p_end}

{title:Also see}
{pstd}{help statareport_set_local_data_root}, {help statareport_add_data}, {help statareport_confirm_data}, {help here}, {help statareport_set_paths}{p_end}
