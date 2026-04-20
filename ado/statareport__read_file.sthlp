{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport__read_file} {hline 2} (internal) echo a text file line-by-line to the Results window.

{title:Syntax}
{p 4 8 2}{cmd:statareport__read_file} {it:filename}
{p_end}

{title:Description}
{pstd}Internal helper used by {help kable} and {help kable_basic} to print a
generated Markdown file to the Results window without being truncated by the
console width. The program has no options and is not intended to be called
directly by end users.

{title:Also see}
{pstd}{help kable}, {help kable_basic}, {help statareport__writenone}{p_end}