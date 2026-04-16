{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:compute_shift_graphs} {hline 2} Create paired baseline vs post-baseline scatterplots with reference lines.

{title:Syntax}
{p 4 8 2}{cmd:compute_shift_graphs} {varname}(numeric) [{cmd:if}]{cmd:,}
{cmdab:evar:iable(}{it:varname}{cmd:)} {cmdab:eval:ue(}{it:integer}{cmd:)} {cmdab:base:value(}{it:integer}{cmd:)}
{cmdab:name(}{it:string}{cmd:)} {cmdab:id:variable(}{it:varname}{cmd:)} {cmdab:output:dir(}{it:string}{cmd:)}
{cmdab:suf:fix(}{it:string}{cmd:)} {cmdab:conf:igfile(}{it:string}{cmd:)}
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:evar:iable(}{it:varname}{cmd:)}}numeric visit indicator identifying baseline and analysis records (required){p_end}
{synopt:{cmdab:eval:ue(}{it:integer}{cmd:)}}value of {opt evariable()} marking the analysis visit (required){p_end}
{synopt:{cmdab:base:value(}{it:integer}{cmd:)}}value of {opt evariable()} marking the baseline visit (required){p_end}
{synopt:{cmdab:name(}{it:string}{cmd:)}}identifier used to select the configuration row (required){p_end}
{synopt:{cmdab:id:variable(}{it:varname}{cmd:)}}unique identifier for individuals (required){p_end}
{synopt:{cmdab:output:dir(}{it:string}{cmd:)}}directory for storing generated {cmd:.gph} and PNG files (required; created if missing){p_end}
{synopt:{cmdab:suf:fix(}{it:string}{cmd:)}}suffix appended to the graph filenames (required){p_end}
{synopt:{cmdab:conf:igfile(}{it:string}{cmd:)}}Excel file with columns {cmd:parameter}, {cmd:name}, {cmd:units}, {cmd:lln}, {cmd:uln} (required){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:compute_shift_graphs} plots paired laboratory or biomarker values at
baseline and a specified post-baseline visit as a scatterplot with LLN (lower
limit of normal) and ULN (upper limit of normal) reference lines. The
configuration is read from an Excel file that must contain columns
{cmd:parameter}, {cmd:name}, {cmd:units}, {cmd:lln}, and {cmd:uln}. Matching
succeeds when {cmd:parameter} equals the measurement variable name or when
{cmd:name} matches the value supplied in {opt name()}. All options are required.

{pstd}Each graph is saved as both a Stata graph ({cmd:.gph}) and a PNG file
using the stem {cmd:<parameter>_<evalue>_<suffix>} inside {opt outputdir()}.

{title:Options}
{phang}{opt evariable(varname)} specifies the numeric variable that identifies
visits (e.g., a visit number). Required.

{phang}{opt evalue(integer)} the value of {opt evariable()} that marks the
post-baseline analysis visit. Required.

{phang}{opt basevalue(integer)} the value of {opt evariable()} that marks the
baseline visit. Required.

{phang}{opt name(string)} an identifier that selects the correct row from the
configuration file. Required.

{phang}{opt idvariable(varname)} the variable containing a unique identifier for
each individual (e.g., patient ID). Required.

{phang}{opt outputdir(string)} the directory where graph files are saved. The
directory is created if it does not already exist. Required.

{phang}{opt suffix(string)} a string appended to each graph filename to
distinguish different analyses. Required.

{phang}{opt configfile(string)} path to the Excel configuration file. The file
must contain one row per parameter with columns {cmd:parameter}, {cmd:name},
{cmd:units}, {cmd:lln}, and {cmd:uln}. Required.

{title:Examples}
{phang}{cmd:. compute_shift_graphs alt, evar(visit) evalue(4) basevalue(0) name("ALT") idvariable(patient_id) outputdir("output_figures") suffix("wk4") configfile("input_md/shift_graphs_inputs.xlsx")}{p_end}

{phang}{cmd:. compute_shift_graphs creatinine if arm==1, evar(visitnum) evalue(8) basevalue(1) name("CREAT") idvariable(subjid) outputdir("output_figures/lab") suffix("wk8_arm1") configfile("config/lab_limits.xlsx")}{p_end}

{title:Also see}
{pstd}{help create_dyntex}, {help knit}{p_end}
