*! statareport_confirm_data -- re-verify every $data_* global points to a file
*!
*! Usage:
*!     statareport_confirm_data
*!     statareport_confirm_data, strict    // abort (rc 601) on any missing
*!     statareport_confirm_data, ignore(local_core local_bio_bas)
*!
*! Equivalent of:
*!     local list_of_data : all globals "data_*"
*!     foreach d of local list_of_data {
*!         capture confirm file "$`d'"
*!         if _rc display as error "`d' not found"
*!     }
*! but with a one-line success message, structured return values, and an
*! ignore() list for datasets that are produced later in the pipeline.
*!
*! Returns:
*!     r(n_total)     : number of $data_* globals scanned
*!     r(n_missing)   : number that point to non-existent files
*!     r(missing)     : space-separated list of offending global names

capture program drop statareport_confirm_data
program define statareport_confirm_data, rclass
    version 15
    syntax [, STRICT IGNORE(string) QUIet]

    local names : all globals "data_*"
    local missing_names ""
    local missing_count = 0
    local total_count : word count `names'

    foreach g of local names {
        // Skip explicitly ignored names (users can stage derived outputs).
        local skip 0
        foreach pat of local ignore {
            if ("`g'" == "data_`pat'" | "`g'" == "`pat'") local skip 1
        }
        if (`skip') continue

        capture confirm file `"${`g'}"'
        if (_rc) {
            display as error "missing: $`g' = ${`g'}"
            local missing_names "`missing_names' `g'"
            local ++missing_count
        }
    }

    if ("`quiet'" == "") {
        if (`missing_count' == 0) {
            display as text "statareport_confirm_data: " ///
                as result "all `total_count' datasets present"
        }
        else {
            display as text "statareport_confirm_data: " ///
                as error "`missing_count'" ///
                as text " of " as result "`total_count'" ///
                as text " datasets missing"
        }
    }

    return local missing    `"`missing_names'"'
    return scalar n_missing = `missing_count'
    return scalar n_total   = `total_count'

    if (`missing_count' > 0 & "`strict'" != "") {
        exit 601
    }
end
