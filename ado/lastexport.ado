*! lastexport -- locate the most recent dated export folder under a parent
*!
*! Scans parent() for subfolders whose names are 8-digit dates
*! (YYYYMMDD by convention) and returns the one that sorts last --
*! lexicographic order on YYYYMMDD is the same as chronological order.
*!
*! Typical use is to find the latest data export drop on a shared drive:
*!
*!     lastexport, parent("$dir_onedrive/QC/Dataset_export")
*!     statareport_set_data_root, ///
*!         path("$dir_onedrive/QC/Dataset_export/`r(latest)'/Stata")
*!
*! Options:
*!     parent(path)   directory whose dated subfolders to scan (required)
*!     pattern(str)   glob to restrict candidate names (default "*")
*!     nchars(#)      number of characters that make a date name (default 8,
*!                    i.e. YYYYMMDD). Pass 10 for YYYY-MM-DD.
*!     strict         abort with rc 601 when no dated folder is found
*!     quiet          suppress the "latest export date" line
*!
*! Stored results:
*!     r(latest)      the latest dated folder name (empty if none found)
*!     r(path)        parent()/latest
*!     r(n_matches)   number of dated folders detected

capture program drop lastexport
program define lastexport, rclass
    version 15
    syntax , Parent(string) [PAttern(string) NCHars(integer 8) STRict QUIet]

    if (`"`pattern'"' == "") local pattern "*"

    // confirm the parent exists (directory check via mata direxists)
    mata: st_local("parent_ok", strofreal(direxists(`"`parent'"')))
    if (!`parent_ok') {
        display as error "lastexport: parent() `parent' does not exist"
        exit 601
    }

    local dirs : dir `"`parent'"' dirs `"`pattern'"'

    local latest ""
    local n = 0
    foreach d of local dirs {
        // Accept only names of the configured length that parse as numbers
        // (after stripping dashes). YYYYMMDD -> `d' is already numeric;
        // YYYY-MM-DD -> becomes YYYYMMDD after subinstr and passes.
        if (strlen(`"`d'"') != `nchars') continue
        local probe = subinstr(`"`d'"', "-", "", .)
        capture confirm number `probe'
        if (_rc) continue

        local ++n
        if (`"`d'"' > `"`latest'"') local latest `"`d'"'
    }

    if (`"`latest'"' == "") {
        if ("`strict'" != "") {
            display as error ///
                "lastexport: no dated folder of `nchars' characters found in `parent'"
            exit 601
        }
        if ("`quiet'" == "") {
            display as text "lastexport: no dated folder found under `parent'"
        }
    }
    else if ("`quiet'" == "") {
        display as result "latest export date: `latest'"
    }

    local full ""
    if (`"`latest'"' != "") local full `"`parent'/`latest'"'

    return local latest     `"`latest'"'
    return local path       `"`full'"'
    return scalar n_matches = `n'
end
