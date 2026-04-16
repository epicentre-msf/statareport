/*
Create the standard directory structure used by the statareport package.

Usage
-----
{cmd:statareport_setup_dirs [, root(path)]}

If {opt root()} is omitted the directories are created relative to the current
working directory. Existing folders are left untouched. Placeholder CSV/MD files
are written when missing.
*/

capture program drop statareport_setup_dirs
program define statareport_setup_dirs
    version 15
    syntax [, ROOT(string)]

    local root "`root'"
    if ("`root'" == "") local root "."

    * normalise path separators and trim trailing slash
    local root = subinstr("`root'", "\\", "/", .)
    if (substr("`root'", strlen("`root'"), 1) == "/" & strlen("`root'") > 1) {
        local root = substr("`root'", 1, strlen("`root'") - 1)
    }

    local folders "input_md input_tables output_md output_tables output_figures output_word logs local_datasets"

    foreach d of local folders {
        local target "`root'/`d'"
        capture mkdir "`target'"
        if (_rc == 0) {
            display as text "Created directory: `target'"
        }
        else if (_rc != 602 & _rc != 0) {
            display as error "statareport_setup_dirs: unable to create `target' (rc = `_rc')"
            exit _rc
        }
    }

    * Placeholder files -------------------------------------------------------
    local table_labels "`root'/input_tables/table_labels_template.csv"
    if (!fileexists("`table_labels'")) {
        tempname fh_labels
        file open `fh_labels' using "`table_labels'", write text replace
        file write `fh_labels' "id,label,value1,value2" _n
        file write `fh_labels' "001,Example label,123,456" _n
        file close `fh_labels'
        display as text "Wrote template: `table_labels'"
    }

    local custom_ref "`root'/input_md/custom_reference_placeholder.md"
    if (!fileexists("`custom_ref'")) {
        tempname fh_ref
        file open `fh_ref' using "`custom_ref'", write text replace
        file write `fh_ref' "---" _n
        file write `fh_ref' "title: \"Custom reference placeholder\"" _n
        file write `fh_ref' "---" _n
        file write `fh_ref' _n
        file write `fh_ref' "Add project-specific narrative or YAML metadata here." _n
        file close `fh_ref'
        display as text "Wrote placeholder: `custom_ref'"
    }

    local log_keep "`root'/logs/.gitkeep"
    if (!fileexists("`log_keep'")) {
        tempname fh_log
        file open `fh_log' using "`log_keep'", write text replace
        file close `fh_log'
    }

    display as result "Directory scaffold ready under `root'"
end
