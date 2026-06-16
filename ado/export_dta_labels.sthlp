{smcl}
{* *! version 1.1 16jun2026}
{title:Title}
{pstd}{bf:export_dta_labels} {hline 2} Export dataset, variable and value labels plus notes from every {cmd:.dta} in a folder into a pipe-delimited flat file.

{title:Syntax}
{p 4 8 2}{cmd:export_dta_labels} [{cmd:,} {it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt folder(string)}}directory holding the {cmd:.dta} files (default: current directory){p_end}
{synopt:{opt out:file(string)}}flat file to write (default: {cmd:<folder>/var_lbl_folder.txt}){p_end}
{synopt:{opt pat:tern(string)}}one or more space-separated glob patterns to match (default: {cmd:*.dta}){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:export_dta_labels} is the first step of the label-translation
pipeline. It opens every {cmd:.dta} file in {opt folder} in turn and writes one
record per line to a single pipe-delimited text file. Each record carries a tag
identifying what it describes, so the free text can later be translated and
re-applied without touching the data themselves.

{pstd}The record types written are:

{p 8 12 2}{cmd:FILE|}{it:<file>} {hline 1} marks the start of a file's block{p_end}
{p 8 12 2}{cmd:DTALBL|}{it:<file>}{cmd:|}{it:<dataset label>}{p_end}
{p 8 12 2}{cmd:VARLBL|}{it:<file>}{cmd:|}{it:<var>}{cmd:|}{it:<variable label>}{p_end}
{p 8 12 2}{cmd:VALSET|}{it:<file>}{cmd:|}{it:<set>}{cmd:|}{it:<code>}{cmd:|}{it:<value label>}{p_end}
{p 8 12 2}{cmd:DTANOTE|}{it:<file>}{cmd:|}{it:<idx>}{cmd:|}{it:<note>}{p_end}
{p 8 12 2}{cmd:VARNOTE|}{it:<file>}{cmd:|}{it:<var>}{cmd:|}{it:<idx>}{cmd:|}{it:<note>}{p_end}

{pstd}On every record the only free text is the last field. Carriage returns and
line feeds inside a label are collapsed to spaces so each record stays on a
single line. Lines beginning with {cmd:#} are header comments that document the
format. The original {cmd:.dta} files are opened read-only and never modified.

{title:Options}
{phang}{opt folder(string)} directory that is scanned for {cmd:*.dta} files.
Defaults to the current working directory.

{phang}{opt outfile(string)} path of the flat file to create. Defaults to
{cmd:var_lbl_folder.txt} inside {opt folder}. The file is overwritten if it
exists.

{phang}{opt pattern(string)} restricts the scan to files matching one or more
space-separated glob patterns. Wildcards {cmd:*} and {cmd:?} are supported (as
in Stata's {cmd:dir} extended macro function); character classes and
{cmd:**} are not. Defaults to {cmd:*.dta}. To export only files whose name
starts with a prefix, use e.g. {cmd:pattern("survey_*.dta")}; to match several
families at once, list them: {cmd:pattern("survey_*.dta census_*.dta")}.
Overlapping matches are de-duplicated.

{title:Examples}
{phang}{cmd:. export_dta_labels, folder("data/raw")}{p_end}

{phang}{cmd:. export_dta_labels, folder("data/raw") outfile("labels.txt")}{p_end}

{phang}{cmd:. export_dta_labels, folder("data/raw") pattern("survey_*.dta")}{p_end}

{title:Workflow}
{pstd}{cmd:export_dta_labels} produces the input for {help translate_dta_labels},
whose output is consumed by {help apply_dta_labels}:

{p 8 12 2}{cmd:export_dta_labels} {c -} >{c -} {cmd:translate_dta_labels} {c -} >{c -} {cmd:apply_dta_labels}{p_end}

{title:Also see}
{pstd}{help translate_dta_labels}, {help apply_dta_labels}{p_end}
