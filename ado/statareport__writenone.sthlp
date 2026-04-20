{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport__writenone} {hline 2} (internal) emit an empty-table placeholder to disk.

{title:Syntax}
{p 4 8 2}{cmd:statareport__writenone} {it:filename} {it:caption} {it:footnote}
{p_end}

{title:Description}
{pstd}Internal helper used by {help kable} and {help kable_basic} when the
dataset in memory is empty. Writes a Pandoc-compatible Markdown stub that uses
a custom-style block to render a "None" row in place of the usual table body.
The program has no options and is not intended to be called directly by end
users.

{title:Also see}
{pstd}{help kable}, {help kable_basic}, {help statareport__read_file}{p_end}
