*! statareport_init_project -- bootstrap a new statareport project
*!
*! Creates the canonical folder layout, drops a populated master do-file
*! (00-final-do-file.do) that uses the statareport_* commands, and copies
*! the pandoc resources (Lua filters, reference docx, Excel templates,
*! defaults yaml, header.txt) into the project's input folders.
*!
*! Usage:
*!     statareport_init_project, prefix("MyTrial")
*!     statareport_init_project, prefix("MyTrial") title("My trial") ///
*!         subtitle("Phase III report") author("contributors") ///
*!         listoftables listoffigures
*!
*! Options:
*!     prefix()        project shortname baked into filenames (required)
*!     root()          target directory; defaults to `here' root, then c(pwd)
*!     title()         document title written into input_md/header.txt
*!     subtitle()      document subtitle (use \n for line breaks)
*!     author()        author line
*!     toc             emit \tableofcontents in header.txt body
*!     listoftables    emit \listoftables
*!     listoffigures   emit \listoffigures
*!     replace         overwrite existing template files (default: skip)

capture program drop statareport_init_project
program define statareport_init_project, rclass
    version 15
    syntax , PREFIX(string) ///
        [ROOT(string) TITLE(string) SUBTITLE(string) AUTHOR(string) ///
         TOC LISToftables LISTOFfigures REPlace]

    // 1. Resolve root -----------------------------------------------------
    if ("`root'" == "") {
        capture mata: st_local("root", __here_root__)
        if ("`root'" == "") {
            local root "`c(pwd)'"
            display as text "(statareport_init_project: no `here' root; using cwd: `root')"
        }
    }
    local root = subinstr("`root'", "\", "/", .)
    if (substr("`root'", -1, 1) == "/" & strlen("`root'") > 1) {
        local root = substr("`root'", 1, strlen("`root'") - 1)
    }

    // 2. Folder scaffold --------------------------------------------------
    statareport_setup_dirs, root("`root'")

    local overwrite = ("`replace'" != "")

    // 3. Master final do-file --------------------------------------------
    statareport_init__write_final, prefix("`prefix'") ///
        dst("`root'/do_files/00-final-do-file.do") overwrite(`overwrite')

    // 4. Step do-files 01-07 (small stubs) -------------------------------
    statareport_init__write_step, num(01) title("Create derived datasets") ///
        dst("`root'/do_files/01-create-datasets.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(02) title("Patient dispositions") ///
        dst("`root'/do_files/02-patients-dispositions.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(03) title("Baseline tables") ///
        dst("`root'/do_files/03-baseline.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(04) title("Adherence tables") ///
        dst("`root'/do_files/04-adherence.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(05) title("Efficacy tables") ///
        dst("`root'/do_files/05-efficacy.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(06) title("Safety tables") ///
        dst("`root'/do_files/06-safety.do") overwrite(`overwrite') prefix("`prefix'")
    statareport_init__write_step, num(07) title("Listings") ///
        dst("`root'/do_files/07-listings.do") overwrite(`overwrite') prefix("`prefix'")

    statareport_init__write_gitkeep, dst("`root'/do_files/helpers/.gitkeep") overwrite(`overwrite')
    statareport_init__write_gitkeep, dst("`root'/programs/.gitkeep")          overwrite(`overwrite')

    // 5. Copy shipped resources into input_md/ and input_tables/ ---------
    statareport_init__copy_resource, src("list-tables.lua")     dst("`root'/input_md/list-tables.lua")     overwrite(`overwrite')
    statareport_init__copy_resource, src("page-orientation.lua") dst("`root'/input_md/page-orientation.lua") overwrite(`overwrite')
    statareport_init__copy_resource, src("table-breaks.lua")    dst("`root'/input_md/table-breaks.lua")    overwrite(`overwrite')
    statareport_init__copy_resource, src("custom_reference.docx") dst("`root'/input_md/custom_reference.docx") overwrite(`overwrite')
    statareport_init__copy_resource, src("custom_reference-listings.docx") dst("`root'/input_md/custom_reference-listings.docx") overwrite(`overwrite')
    statareport_init__copy_resource, src("default_options.yaml") dst("`root'/input_md/default_options.yaml") overwrite(`overwrite')
    statareport_init__copy_resource, src("default_options-listings.yaml") dst("`root'/input_md/default_options-listings.yaml") overwrite(`overwrite')
    statareport_init__copy_resource, src("tables_labels.xlsx")  dst("`root'/input_tables/tables_labels.xlsx")   overwrite(`overwrite')
    statareport_init__copy_resource, src("shift_graph_input.xlsx") dst("`root'/input_tables/shift_graph_input.xlsx") overwrite(`overwrite')
    statareport_init__copy_resource, src(".StataEnviron.example") dst("`root'/.StataEnviron.example") overwrite(`overwrite')

    // 6. Header files: generate from options if title() supplied;
    //    otherwise copy the shipped template verbatim.
    local header_main     "`root'/input_md/header.txt"
    local header_listings "`root'/input_md/header-listings.txt"

    if (`"`title'"' != "") {
        if (`overwrite' | !fileexists("`header_main'")) {
            statareport_write_header using "`header_main'", ///
                title(`"`title'"') subtitle(`"`subtitle'"') author(`"`author'"') ///
                `toc' `listoftables' `listoffigures' replace quiet
            display as text "wrote " as result "`header_main'"
        }
        if (`overwrite' | !fileexists("`header_listings'")) {
            statareport_write_header using "`header_listings'", ///
                title(`"`title' -- listings"') subtitle(`"`subtitle'"') ///
                author(`"`author'"') `toc' `listoftables' `listoffigures' replace quiet
            display as text "wrote " as result "`header_listings'"
        }
    }
    else {
        statareport_init__copy_resource, src("header.txt")          dst("`header_main'")      overwrite(`overwrite')
        statareport_init__copy_resource, src("header-listings.txt") dst("`header_listings'")  overwrite(`overwrite')
    }

    // 7. Summary ---------------------------------------------------------
    display as result ///
        "statareport_init_project: project `prefix' initialised under " ///
        as text "`root'"
    display as text "Next steps:"
    display as text "  1. Edit " as result "input_tables/tables_labels.xlsx" ///
        as text " with the captions for your tables and figures."
    display as text "  2. Edit " as result "do_files/00-final-do-file.do" ///
        as text " to list your datasets."
    display as text "  3. Populate 01-07 do-files with your analysis."
    display as text "  4. Run 00-final-do-file.do to render the report."

    return local root   "`root'"
    return local prefix "`prefix'"
end

// =====================================================================
// Sub-programs
// =====================================================================

capture program drop statareport_init__copy_resource
program define statareport_init__copy_resource
    syntax , SRC(string) DST(string) OVERWRITE(integer)
    if (!`overwrite' & fileexists("`dst'")) {
        display as text "(skipping existing " as result "`dst'" as text ")"
        exit
    }
    capture findfile "`src'"
    if (_rc) {
        display as error ///
            "statareport_init_project: resource `src' not found on adopath (package installed?)"
        exit
    }
    capture copy "`r(fn)'" "`dst'", replace
    if (_rc) {
        display as error ///
            "statareport_init_project: failed to copy `src' -> `dst' (rc = `_rc')"
        exit _rc
    }
    display as text "copied " as result "`src'" as text " -> " as result "`dst'"
end

capture program drop statareport_init__write_final
program define statareport_init__write_final
    syntax , PREFIX(string) DST(string) OVERWRITE(integer)
    if (!`overwrite' & fileexists("`dst'")) {
        display as text "(skipping existing " as result "`dst'" as text ")"
        exit
    }
    mata: statareport_init_final("`prefix'", "`dst'")
    display as text "wrote " as result "`dst'"
end

capture program drop statareport_init__write_step
program define statareport_init__write_step
    syntax , NUM(string) TITLE(string) DST(string) OVERWRITE(integer) PREFIX(string)
    if (!`overwrite' & fileexists("`dst'")) {
        display as text "(skipping existing " as result "`dst'" as text ")"
        exit
    }
    mata: statareport_init_step("`prefix'", "`num'", "`title'", "`dst'")
    display as text "wrote " as result "`dst'"
end

capture program drop statareport_init__write_gitkeep
program define statareport_init__write_gitkeep
    syntax , DST(string) OVERWRITE(integer)
    if (!`overwrite' & fileexists("`dst'")) exit
    tempname fh
    capture file close `fh'
    file open `fh' using "`dst'", write replace
    file close `fh'
end

// =====================================================================
// Mata helpers
// =====================================================================
capture mata mata drop statareport_init_final()
capture mata mata drop statareport_init_step()
capture mata mata drop statareport_init_emit()

mata:
void statareport_init_emit(string rowvector lines, string scalar dst)
{
    real scalar fh, i
    if (fileexists(dst)) unlink(dst)
    fh = fopen(dst, "w")
    for (i = 1; i <= cols(lines); i++) fput(fh, lines[i])
    fclose(fh)
}

void statareport_init_final(string scalar prefix, string scalar dst)
{
    string rowvector L
    L = (
        "********************************************************************************",
        "* " + prefix + ": final do-file (generated by statareport_init_project)",
        "*",
        "* Run top-to-bottom to (re)generate the project's Word report. Sections 1-4",
        "* are project configuration; 5 runs the analysis; 6 renders the docx.",
        "********************************************************************************",
        "",
        "clear all",
        "set more off",
        "version 15",
        "",
        "********************************************************************************",
        "* 1. Project root (sets the Mata cache __here_root__)",
        "********************************************************************************",
        "here",
        "",
        "********************************************************************************",
        "* 2. Load machine-specific paths from .StataEnviron (gitignored)",
        "*",
        "* Copy .StataEnviron.example -> .StataEnviron and fill in the blanks.",
        "* Keys become $dir_<key> (lowercased): ONEDRIVE -> $dir_onedrive, etc.",
        "* DATASETS additionally primes statareport_set_data_root.",
        "********************************************************************************",
        "statareport_load_env, quiet",
        "",
        "********************************************************************************",
        "* 3. Directory globals ($dir_*)",
        "********************************************************************************",
        "statareport_add_dir, name(dofiles)   path(\"do_files\")",
        "statareport_add_dir, name(input_md)  path(\"input_md\")",
        "statareport_add_dir, name(tables)    path(\"output_tables\")",
        "statareport_add_dir, name(lbltables) path(\"labelled_tables\") parent(tables) mkdir",
        "statareport_add_dir, name(figures)   path(\"output_figures\")",
        "",
        "********************************************************************************",
        "* 4. Program directories (adopath)",
        "********************************************************************************",
        "statareport_add_programs programs extras",
        "",
        "********************************************************************************",
        "* 5. Report file paths and datasets",
        "********************************************************************************",
        "* --- 5a. Export date for the docx filename ---------------------------------",
        "local today: display %tdCCYYNNDD date(c(current_date), \"DMY\")",
        "global date_export `today'",
        "",
        "* --- 5b. Report-level paths ($file_*) --------------------------------------",
        "statareport_set_paths, prefix(\"" + prefix + "\") date(\"$date_export\")",
        "statareport_set_paths, prefix(\"" + prefix + "\") date(\"$date_export\") variant(\"listings\")",
        "",
        "* --- 5c. Header document (title / subtitle / lists) ------------------------",
        "* Regenerate the YAML + body of $file_header whenever the study title",
        "* changes. Delete this block to keep a hand-edited header.txt instead.",
        "* statareport_write_header using \"$file_header\", replace ///",
        "*     title(\"" + prefix + " trial\") ///",
        "*     subtitle(\"Phase III report\") ///",
        "*     author(\"Report\") toc listoftables listoffigures",
        "",
        "* --- 5d. Where the raw trial datasets live ---------------------------------",
        "* Typical pattern: lastexport, parent(\"$dir_onedrive/QC/Dataset_export\")",
        "* then statareport_set_data_root, path(\"...Dataset_export/`r(latest)'/Stata\")",
        "statareport_set_data_root, path(\"local_datasets\")     // TODO: point at your data export",
        "",
        "* --- 5d-bis. Where the project-local / derived datasets live --------------",
        "* The cousin command primes a separate cache (__statareport_local_data_root__)",
        "* used by statareport_add_data, local. Default folder is local_datasets/.",
        "statareport_set_local_data_root",
        "",
        "* --- 5e. Register datasets ($data_*) ---------------------------------------",
        "* Default mode resolves relative paths under the data root. Use `raw' for",
        "* paths that already contain a fully-qualified global, `project' for",
        "* derived datasets inside the repo, `local' for derived datasets sharing",
        "* the local data root, and `optional' for files produced later.",
        "statareport_add_data, name(preselection)   path(\"preselection_visit.dta\")",
        "statareport_add_data, name(demo)           path(\"demog.dta\")",
        "statareport_add_data, name(vital_signs)    path(\"vital_signs.dta\")",
        "statareport_add_data, name(adverse_events) path(\"adverse_events.dta\")",
        "* statareport_add_data, name(meddra) path(\"$dir_onedrive/Meddra/meddra_codes.dta\") raw",
        "statareport_add_data, name(local_core) path(\"core.dta\") local optional",
        "",
        "statareport_confirm_data, ignore(local_core)",
        "",
        "* --- 5f. Pandoc Lua filters pulled into this report ------------------------",
        "global file_filters `\"\"$dir_input_md/page-orientation.lua\" \"$dir_input_md/table-breaks.lua\" \"$dir_input_md/list-tables.lua\"\"'",
        "",
        "global var_sheet_lab \"Labels\"    // sheet name inside $file_label",
        "",
        "********************************************************************************",
        "* 6. Analysis pipeline",
        "********************************************************************************",
        "reportdo 01-create-datasets",
        "reportdo 02-patients-dispositions",
        "reportdo 03-baseline",
        "* reportdo 04-adherence",
        "* reportdo 05-efficacy",
        "reportdo 06-safety",
        "* reportdo 07-listings",
        "",
        "********************************************************************************",
        "* 7. Render the Word document",
        "*",
        "* statareport_render drives create_dyntex + dyntext + knit in one call,",
        "* reading the $file_* / $dir_* / $var_* globals set above. Override any",
        "* individual piece via the matching option (label(), output(), ...).",
        "********************************************************************************",
        "statareport_render",
        "",
        "* Listings variant (uncomment when you want it):",
        "* statareport_render, variant(\"listings\") toc(no)",
        ""
    )
    statareport_init_emit(L, dst)
}

void statareport_init_step(string scalar prefix, string scalar num,
                           string scalar title, string scalar dst)
{
    string rowvector L
    L = (
        "********************************************************************************",
        "* " + prefix + " -- step " + num + ": " + title,
        "*",
        "* This do-file is called from 00-final-do-file.do. Populate it with the",
        "* analysis code that produces the tables/figures required by section " + title + ".",
        "********************************************************************************",
        "",
        "// TODO: implement step " + num + ".",
        ""
    )
    statareport_init_emit(L, dst)
}
end
