*! statareport_add_data -- register a .dta file as the global $data_<name>
*!
*! Usage:
*!     statareport_add_data, name(preselection) path("preselection_visit.dta")
*!     statareport_add_data, name(meddra)       path("Meddra/codes.dta") raw
*!     statareport_add_data, name(local_core)   path("local_datasets/core.dta") project optional
*!
*! Resolution rules (mutually exclusive):
*!   default   : join relative paths with the Mata cache set by
*!               statareport_set_data_root (__statareport_data_root__).
*!   project   : join relative paths with the Mata cache set by
*!               `here' (__here_root__). Useful for derived datasets that
*!               live inside the project repo.
*!   raw       : use the path verbatim, no prepending at all. Useful for
*!               paths that already resolve via user-defined globals such
*!               as $dir_onedrive.
*!   root(...) : one-off override of the default root.
*!
*! Absolute paths are always used verbatim regardless of which option you
*! pick, so you can sprinkle `raw' / `project' liberally without breaking
*! lines that pass a fully-qualified path.
*!
*! File-existence behaviour:
*!   - By default a missing file is flagged with a `display as error' line
*!     but the command does not abort.
*!   - optional declares that the dataset may not be present yet (e.g.
*!     local derived datasets produced later in the pipeline) and
*!     suppresses the warning.
*!   - statareport_confirm_data provides a `strict' option to escalate any
*!     missing file into an error.

capture program drop statareport_add_data
program define statareport_add_data, rclass
    version 15
    syntax , NAME(string) PATH(string) ///
        [ROOT(string) RAW PROject OPTional QUIet]

    // Validate name() -- it becomes part of a Stata global, so reject
    // anything that would break Stata's name parser.
    if (!regexm("`name'", "^[A-Za-z_][A-Za-z0-9_]*$")) {
        display as error ///
            "statareport_add_data: name() must be a valid Stata identifier, got `name'"
        exit 198
    }

    // Mutually exclusive resolution flags -----------------------------------
    local n_modes = ("`raw'" != "") + ("`project'" != "") + (`"`root'"' != "")
    if (`n_modes' > 1) {
        display as error "statareport_add_data: raw, project, and root() are mutually exclusive"
        exit 198
    }

    // Normalise the path separators once ------------------------------------
    local raw_path = subinstr(`"`path'"', "\", "/", .)

    // Detect absolute path (starts with "/" or "<letter>:/") so every mode
    // lets an absolute input pass through untouched.
    local is_abs 0
    if (substr(`"`raw_path'"', 1, 1) == "/") local is_abs 1
    else if (regexm(`"`raw_path'"', "^[A-Za-z]:/")) local is_abs 1

    // Pick the root this call should use ------------------------------------
    local chosen_root ""
    if ("`raw'" != "") {
        local chosen_root ""                         // explicit: no root at all
    }
    else if (`"`root'"' != "") {
        local chosen_root `"`root'"'
    }
    else if ("`project'" != "") {
        capture mata: st_local("chosen_root", __here_root__)
        if (`"`chosen_root'"' == "") {
            display as error "statareport_add_data: project option set but `here' has not run"
            exit 459
        }
    }
    else {
        capture mata: st_local("chosen_root", __statareport_data_root__)
    }

    // Resolve -----------------------------------------------------------------
    local resolved `"`raw_path'"'
    if (!`is_abs' & `"`chosen_root'"' != "") {
        local resolved `"`chosen_root'/`raw_path'"'
    }

    // Emit the Stata global --------------------------------------------------
    global data_`name' `"`resolved'"'

    // Presence check: warn unless optional -----------------------------------
    capture confirm file `"`resolved'"'
    local missing = _rc

    if (`missing' & "`optional'" == "") {
        display as error "statareport_add_data: data_`name' -> `resolved' (not found)"
    }
    else if ("`quiet'" == "") {
        if (`missing') {
            display as text "(data_`name': optional, not yet present: `resolved')"
        }
        else {
            display as text "data_`name' " as result "-> " as result `"`resolved'"'
        }
    }

    return local name    `"`name'"'
    return local path    `"`resolved'"'
    return local mode    "`=cond("`raw'"!="","raw",cond("`project'"!="","project",cond(`"`root'"'!="","root","data")))'"
    return scalar missing = `missing'
end
