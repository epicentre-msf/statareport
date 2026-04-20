* ==============================================================================
* test_statareport_set_paths.do -- regression tests for the command that emits
* the $file_* globals and validates that every input file exists.
* ==============================================================================

capture program drop _fresh_dir
program _fresh_dir, rclass
    * Create a unique, empty directory under c(tmpdir) and return its path in
    * r(path). Also cleans any pre-existing directory with the same name.
    args tag
    local stamp = string(clock("`c(current_date)' `c(current_time)'", "DMYhms"), "%21.0f")
    local path  "`c(tmpdir)'/sr_test_`tag'_`stamp'_`=int(1e9*runiform())'"
    * Remove if an earlier run left it behind.
    capture shell rm -rf "`path'"
    quietly mkdir "`path'"
    return local path "`path'"
end

capture program drop _seed_inputs
program _seed_inputs
    args root stem
    quietly {
        cap mkdir "`root'/input_md"
        cap mkdir "`root'/input_tables"
        file open fh using "`root'/input_md/header`stem'.txt", write replace text
        file write fh "# header"  _n
        file close fh
        copy "`root'/input_md/header`stem'.txt" "`root'/input_md/custom_reference`stem'.docx", replace
        copy "`root'/input_md/header`stem'.txt" "`root'/input_md/default_options`stem'.yaml",   replace
        copy "`root'/input_md/header`stem'.txt" "`root'/input_tables/tables_labels`stem'.xlsx", replace
        copy "`root'/input_md/header`stem'.txt" "`root'/input_tables/shift_graph_input`stem'.xlsx", replace
    }
end

start_case "statareport_set_paths: happy path with all inputs present"
    _fresh_dir "happy"
    local root `r(path)'
    _seed_inputs "`root'" ""

    macro drop file_dyntex file_input file_header file_output ///
               file_reference file_default_options file_label file_graph_opts

    statareport_set_paths, prefix("Proj") root("`root'") quiet

    streq, left(`"${file_header}"')          right(`"`root'/input_md/header.txt"')              msg("file_header")
    streq, left(`"${file_reference}"')       right(`"`root'/input_md/custom_reference.docx"')   msg("file_reference")
    streq, left(`"${file_default_options}"') right(`"`root'/input_md/default_options.yaml"')    msg("file_default_options")
    streq, left(`"${file_label}"')           right(`"`root'/input_tables/tables_labels.xlsx"')  msg("file_label")
    streq, left(`"${file_graph_opts}"')      right(`"`root'/input_tables/shift_graph_input.xlsx"') msg("file_graph_opts")
end_case

start_case "statareport_set_paths: missing input files trigger error 601"
    _fresh_dir "missing"
    local root `r(path)'
    quietly mkdir "`root'/input_md"
    file open fh using "`root'/input_md/header.txt", write replace text
    file write fh "# header" _n
    file close fh

    capture statareport_set_paths, prefix("Proj") root("`root'") quiet
    rc_eq, expect(601) msg("missing reference/defaults/label/graphopts -> 601")
end_case

start_case "statareport_set_paths: variant() emits *_listings globals"
    _fresh_dir "variant"
    local root `r(path)'
    _seed_inputs "`root'" ""
    _seed_inputs "`root'" "-listings"

    macro drop file_header_listings file_label_listings

    statareport_set_paths, prefix("Proj") root("`root'") quiet variant("listings")
    streq, left(`"${file_header_listings}"') right(`"`root'/input_md/header-listings.txt"')             msg("file_header_listings")
    streq, left(`"${file_label_listings}"')  right(`"`root'/input_tables/tables_labels-listings.xlsx"') msg("file_label_listings")
end_case

start_case "statareport_set_paths: override via option wins over convention"
    _fresh_dir "override"
    local root `r(path)'
    _seed_inputs "`root'" ""
    file open fh using "`root'/input_md/MY_HEADER.txt", write replace text
    file write fh "# custom" _n
    file close fh

    macro drop file_header
    statareport_set_paths, prefix("Proj") root("`root'") quiet ///
        header("`root'/input_md/MY_HEADER.txt")
    streq, left(`"${file_header}"') right(`"`root'/input_md/MY_HEADER.txt"') msg("header() override wins")
end_case
