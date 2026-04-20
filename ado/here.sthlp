{smcl}
{* *! version 0.3.0  16apr2026}{...}
{title:Title}

{p 4 4 2}
{bf:here} {hline 2} cd to project root for portable relative paths


{title:Syntax}

{p 8 17 2}
{cmd:here}
[{cmd:,}
{opt l:evels(#)}
{opt f:rom(path)}
{opt m:arkers(patterns)}
{opt force}
{opt clear}]


{title:Description}

{pstd}
{cmd:here} finds your project root by walking up from the current
directory, then {cmd:cd}s there. After that, every path in your
do-files is a plain relative path from the root.

{pstd}
The first call searches and prints one initialization message.
All subsequent calls reuse the cached root silently. The cache
is a Mata variable ({cmd:__here_root__}), invisible to Stata
globals and safe from accidental overwriting.

{pstd}
Default root markers (first match wins):

{p2colset 9 20 22 2}{...}
{p2col:{cmd:*.stpr}}Stata project file{p_end}
{p2col:{cmd:.git}}Git repository{p_end}
{p2col:{cmd:.here}}Sentinel file{p_end}


{title:Quick start}

        {it:master.do}
        {hline 40}
        {cmd:here}
        {cmd:do code/01_import.do}
        {cmd:do code/02_clean.do}

        {it:code/01_import.do}
        {hline 40}
        {cmd:here}
        {cmd:import delimited data/raw/survey.csv, clear}
        {cmd:save data/clean/survey.dta, replace}

{pstd}
Put {cmd:here} at the top of every do-file. The first one to run
pays a negligible search cost; the rest are free.


{title:Options}

{phang}
{opt levels(#)} max parent directories to climb. Default {cmd:5}.

{phang}
{opt from(path)} override starting directory. Default {cmd:`c(pwd)'}.

{phang}
{opt markers(patterns)} space-separated marker patterns (globs ok).

{phang}
{opt force} re-search even if the cache is set.

{phang}
{opt clear} drop the cache. Use when switching projects mid-session.


{title:Stored results}

{synoptset 18 tabbed}{...}
{synopt:{cmd:r(here)}}project root path{p_end}


{title:How it works}

{pstd}
On the first call, {cmd:here} walks up at most {it:n} directories from
the starting point, checking each for a matching marker (file or
directory). When found, it caches the root in the Mata global
{cmd:__here_root__} and runs {cmd:cd} to that directory. On all
subsequent calls, it reads the cache and {cmd:cd}s directly.

{pstd}
The Mata cache is separate from Stata's global macro namespace, so
{cmd:global here} or any other user macro cannot overwrite it. The
cache survives across nested {cmd:do}-file calls and persists until
{cmd:here, clear}, {cmd:mata: mata clear}, or Stata exits.


{title:Tips}

{pstd}
If your project has no {cmd:.stpr} and no {cmd:.git}, create a
zero-byte sentinel:

{phang2}Terminal: {cmd:touch .here}{p_end}
{phang2}Stata:   {cmd:. shell touch .here}  {it:(Mac/Linux)}{p_end}
{phang2}Stata:   {cmd:. shell type nul > .here}  {it:(Windows)}{p_end}


{title:Author}

{pstd}
Yves Amevoin
{browse "https://akyves.net"}
