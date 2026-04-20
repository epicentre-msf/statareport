# `here`



**here** --- cd to project root for portable relative paths



## Syntax



`here`
[`,`
`l:evels(#)`
`f:rom(path)`
`m:arkers(patterns)`
`force`
`clear`
`nogl:obal`
`gl:name(name)`]



## Description



`here` finds your project root by walking up from the current
directory, then `cd`s there. After that, every path in your
do-files is a plain relative path from the root.


The first call searches and prints one initialization message.
All subsequent calls reuse the cached root silently. The cache
is a Mata variable (`__here_root__`), invisible to Stata
globals and safe from accidental overwriting.


Default root markers (first match wins):

{p2colset 9 20 22 2}
{p2col:`*.stpr`}Stata project file
{p2col:`.git`}Git repository
{p2col:`.here`}Sentinel file



## Quick start


        *master.do*
        ---
        `here`
        `do code/01_import.do`
        `do code/02_clean.do`

        *code/01_import.do*
        ---
        `here`
        `import delimited data/raw/survey.csv, clear`
        `save data/clean/survey.dta, replace`


Put `here` at the top of every do-file. The first one to run
pays a negligible search cost; the rest are free.



## Options


> 
`levels(#)` max parent directories to climb. Default `5`.

> 
`from(path)` override starting directory. Default ``c(pwd)'`.

> 
`markers(patterns)` space-separated marker patterns (globs ok).

> 
`force` re-search even if the cache is set.

> 
`clear` drop the cache. Use when switching projects mid-session.

> 
`noglobal` suppress the `$dir_project` side-effect. By default
`here` emits the root as `$dir_project` so downstream code can
reference it with `$dir_project/...`.

> 
`glname(name)` emit the root under a different global name (e.g.
`glname(project)` writes `$project` instead of
`$dir_project`).



## Stored results


- `r(here)` — project root path



## How it works



On the first call, `here` walks up at most *n* directories from
the starting point, checking each for a matching marker (file or
directory). When found, it caches the root in the Mata global
`__here_root__` and runs `cd` to that directory. On all
subsequent calls, it reads the cache and `cd`s directly.


The Mata cache is separate from Stata's global macro namespace, so
`global here` or any other user macro cannot overwrite it. The
cache survives across nested `do`-file calls and persists until
`here, clear`, `mata: mata clear`, or Stata exits.



## Tips



If your project has no `.stpr` and no `.git`, create a
zero-byte sentinel:

    Terminal: `touch .here`
    Stata:   `. shell touch .here`  *(Mac/Linux)*
    Stata:   `. shell type nul > .here`  *(Windows)*



## Author



Yves Amevoin
{browse "https://akyves.net"}

---

*Source*: [`ado/here.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/here.sthlp)
