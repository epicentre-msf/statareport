{smcl}
{* *! version 1.0 02jun2026}
{title:Title}
{pstd}{bf:apply_dta_labels} {hline 2} Re-apply translated labels and notes from a flat file onto the original {cmd:.dta} files, writing the result into a sub-directory.

{title:Syntax}
{p 4 8 2}{cmd:apply_dta_labels} [{cmd:,} {it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt folder(string)}}directory holding the original {cmd:.dta} files (default: current directory){p_end}
{synopt:{opt in:file(string)}}translated flat file (default: {cmd:<folder>/var_lbl_folder_en.txt}){p_end}
{synopt:{opt sub:dir(string)}}sub-directory of {opt folder} to write relabelled copies into (default: {cmd:en}){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:apply_dta_labels} is the final step of the label-translation
pipeline. It reads the translated flat file written by
{help translate_dta_labels}, re-opens each original {cmd:.dta} file named in a
{cmd:FILE|} record, applies the translated dataset label, variable labels,
value-label sets and notes, and saves the relabelled copy under
{cmd:<folder>/<subdir>/}. The data are never altered {c -} only the metadata.

{pstd}Notes are dropped and rebuilt in the order they appear in the file so
indices stay consistent. The leading file field on every record is checked
against the current {cmd:FILE|} block; a mismatch stops the run to avoid writing
labels onto the wrong dataset. The text is read with {cmd:macval} so embedded
backticks or apostrophes in a label are treated as literal text rather than
expanded as macros.

{title:Options}
{phang}{opt folder(string)} directory holding the original {cmd:.dta} files.
Defaults to the current working directory. Paths inside the flat file are
resolved relative to it.

{phang}{opt infile(string)} the translated flat file to read. Defaults to
{cmd:var_lbl_folder_en.txt} inside {opt folder}, the default {opt outfile} of
{help translate_dta_labels}.

{phang}{opt subdir(string)} sub-directory of {opt folder} into which the
relabelled copies are saved. Created if needed. Defaults to {cmd:en}.

{title:Examples}
{phang}{cmd:. apply_dta_labels, folder("data/raw")}{p_end}

{phang}{cmd:. apply_dta_labels, folder("data/raw") subdir("english")}{p_end}

{phang}{cmd:. apply_dta_labels, folder("data/raw") infile("labels_en.txt") subdir("en")}{p_end}

{title:Workflow}
{pstd}{cmd:apply_dta_labels} consumes the output of {help translate_dta_labels},
which in turn consumes the output of {help export_dta_labels}:

{p 8 12 2}{cmd:export_dta_labels} {c -} >{c -} {cmd:translate_dta_labels} {c -} >{c -} {cmd:apply_dta_labels}{p_end}

{title:Also see}
{pstd}{help export_dta_labels}, {help translate_dta_labels}{p_end}
