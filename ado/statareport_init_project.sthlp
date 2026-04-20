{smcl}
{* *! version 1.2.0 19apr2026}
{title:Title}
{pstd}{bf:statareport_init_project} {hline 2} Scaffold a new statareport project (folders, stubs, master do-file).

{title:Syntax}
{p 4 8 2}{cmd:statareport_init_project}{cmd:,} {cmdab:pref:ix(}{it:string}{cmd:)}
[{cmd:root(}{it:string}{cmd:)} {cmdab:rep:lace}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{cmdab:pref:ix(}{it:string}{cmd:)}}project shortname baked into generated filenames (required){p_end}
{synopt:{cmd:root(}{it:string}{cmd:)}}target directory; defaults to the {help here} root, then {cmd:c(pwd)}{p_end}
{synopt:{cmdab:rep:lace}}overwrite existing template files (default: skip){p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:statareport_init_project} turns an empty directory into a
functioning statareport project. It does three things:{p_end}

{phang2}1. Calls {help statareport_setup_dirs} to create the canonical folder
layout ({cmd:do_files}, {cmd:do_files/helpers}, {cmd:programs},
{cmd:input_md}, {cmd:input_tables}, {cmd:output_md}, {cmd:output_tables},
{cmd:output_tables/labelled_tables}, {cmd:output_figures},
{cmd:output_word}, {cmd:local_datasets}, {cmd:logs}).{p_end}

{phang2}2. Writes a populated master do-file at
{cmd:do_files/00-final-do-file.do} that wires {help here},
{help statareport_add_dir}, {help statareport_add_programs},
{help statareport_set_paths}, {help statareport_set_data_root},
{help statareport_add_data}, {help statareport_confirm_data},
{help create_dyntex}, {cmd:dyntext}, and {help knit} into a complete render
pipeline.{p_end}

{phang2}3. Drops minimal stubs at
{cmd:do_files/01-create-datasets.do} through
{cmd:do_files/07-listings.do}, a Pandoc header template at
{cmd:input_md/header.txt}, and Lua filter placeholders
({cmd:list-tables.lua}, {cmd:page-orientation.lua}, {cmd:table-breaks.lua}).{p_end}

{pstd}Existing files are preserved by default -- pass {cmd:replace} to
overwrite them. The command never touches {cmd:output_*} folders or the
user's datasets.{p_end}

{title:Resulting layout}
{pstd}Created under {cmd:<root>/}:{p_end}

{phang2}{cmd:do_files/}           -- master 00-final-do-file.do + step 01-07 stubs + helpers/{p_end}
{phang2}{cmd:programs/}           -- project-local ado files (added to adopath){p_end}
{phang2}{cmd:input_md/}           -- pandoc headers, Lua filters, reference.docx, default YAML{p_end}
{phang2}{cmd:input_tables/}       -- tables_labels.xlsx, shift_graph_input.xlsx{p_end}
{phang2}{cmd:output_md/}          -- generated Markdown (<prefix>-dyn.txt, <prefix>.txt){p_end}
{phang2}{cmd:output_tables/}      -- analysis .dta files; includes labelled_tables/ subfolder{p_end}
{phang2}{cmd:output_figures/}     -- .gph / .png produced by compute_shift_graphs{p_end}
{phang2}{cmd:output_word/}        -- final rendered docx{p_end}
{phang2}{cmd:local_datasets/}     -- derived .dta files used within the project{p_end}
{phang2}{cmd:logs/}               -- Stata log files{p_end}
{phang2}{cmd:.StataEnviron.example} -- copy to {cmd:.StataEnviron} for local paths{p_end}

{title:Examples}
{phang}{cmd:. here}{p_end}
{phang}{cmd:. statareport_init_project, prefix("MyTrial")}{p_end}

{pstd}Into an arbitrary directory:{p_end}
{phang}{cmd:. statareport_init_project, prefix("Trial42") root("/Users/me/projects/trial42")}{p_end}

{pstd}Regenerate the master do-file (overwrites user edits):{p_end}
{phang}{cmd:. statareport_init_project, prefix("MyTrial") replace}{p_end}

{title:Stored results}
{pstd}{cmd:r(root)}: absolute path of the initialised project{break}
{cmd:r(prefix)}: the supplied prefix{p_end}

{title:Also see}
{pstd}{help statareport_setup_dirs}, {help statareport_set_paths}, {help statareport_add_data}, {help statareport_add_dir}, {help statareport_add_programs}, {help here}{p_end}
