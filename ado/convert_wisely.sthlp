{smcl}
{* *! version 1.1.0 17feb2026}
{title:Title}
{pstd}{bf:convert_wisely} {hline 2} Convert variables to strings for reporting while preserving headers.

{title:Syntax}
{p 4 8 2}{cmd:convert_wisely} {varlist} [{cmd:,} {it:options}]
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmd:round(}{it:real}{cmd:)}}rounding increment for numeric variables (default 0.01){p_end}
{synopt:{cmd:usevarnames}}use variable names as stored column headers{p_end}
{synopt:{cmd:usevarlabels}}force variable labels to be used as stored column headers{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:convert_wisely} replaces each variable in {it:varlist} with a string
representation suitable for tabulation. Value-labelled variables are decoded to
their label text, numeric variables are rounded to the specified increment, and
a note is stored on each column so that downstream exporters (such as
{cmd:kable}) can render meaningful headers. The header priority is: stored
variable note, then variable label, then variable name -- unless overridden by
{cmd:usevarnames} or {cmd:usevarlabels}.

{title:Options}
{phang}{opt round(real)} rounding increment applied to numeric variables before
conversion to string. Default is 0.01.

{phang}{opt usevarnames} stores the variable name as the column header note,
regardless of whether a label or existing note is present.

{phang}{opt usevarlabels} forces the variable label to be stored as the column
header note when a label is available, overriding any existing note.

{title:Examples}
{phang}{cmd:. convert_wisely weight height bmi, round(0.1) usevarlabels}{p_end}

{phang}{cmd:. convert_wisely treatment_group sex, usevarnames}{p_end}

{phang}{cmd:. convert_wisely age hemoglobin creatinine, round(0.001)}{p_end}

{title:Also see}
{pstd}{help kable}, {help kable_basic}{p_end}
