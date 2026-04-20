*! statareport_add_dir -- register a directory as the global $dir_<name>
*!
*! Usage:
*!     statareport_add_dir, name(dofiles) path("do_files")
*!     statareport_add_dir, name(tables)  path("output_tables")
*!     statareport_add_dir, name(lbltables) path("labelled_tables") parent(tables)
*!     statareport_add_dir, name(external) path("/Volumes/share/work") raw
*!
*! Resolution rules (mutually exclusive among raw/root/parent):
*!   default       : join relative paths with the `here' project root
*!                   (Mata __here_root__). This matches how directories
*!                   are usually named inside a statareport project.
*!   parent(n)     : join with $dir_<n> (or $<n> if the name already
*!                   begins with "dir_"). Useful for nested directories
*!                   such as output_tables/labelled_tables.
*!   root(p)       : one-off override; join with the explicit path p.
*!   raw           : no root prepended; the path is used verbatim. Useful
*!                   when the path is already a fully-qualified global
*!                   expansion, e.g. "$dir_onedrive/Shared".
*!
*! Absolute paths ( "/..." or "X:/..." ) pass through untouched regardless
*! of the selected mode.
*!
*! Presence handling:
*!   - If the directory already exists: silently registered.
*!   - If it does not exist and mkdir is passed: the directory is created.
*!   - If it does not exist and optional is passed: registered silently.
*!   - Otherwise: a `display as error' warning is emitted but the command
*!     continues.

capture program drop statareport_add_dir
program define statareport_add_dir, rclass
    version 15
    syntax , NAME(string) PATH(string) ///
        [ROOT(string) RAW PARent(string) MKDir OPTional QUIet]

    // Validate name() -- it becomes part of a Stata global, so reject
    // anything that would break Stata's name parser.
    if (!regexm("`name'", "^[A-Za-z_][A-Za-z0-9_]*$")) {
        display as error ///
            "statareport_add_dir: name() must be a valid Stata identifier, got `name'"
        exit 198
    }

    // Mutually exclusive resolution flags -----------------------------------
    local n_modes = ("`raw'" != "") + (`"`root'"' != "") + (`"`parent'"' != "")
    if (`n_modes' > 1) {
        display as error ///
            "statareport_add_dir: raw, root(), and parent() are mutually exclusive"
        exit 198
    }

    // Normalise separators on the supplied path.
    local raw_path = subinstr(`"`path'"', "\", "/", .)

    // Detect absolute paths so every mode lets them through unchanged.
    local is_abs 0
    if (substr(`"`raw_path'"', 1, 1) == "/") local is_abs 1
    else if (regexm(`"`raw_path'"', "^[A-Za-z]:/")) local is_abs 1

    // Pick the root this call should use ------------------------------------
    local chosen_root ""
    if ("`raw'" != "") {
        local chosen_root ""
    }
    else if (`"`root'"' != "") {
        local chosen_root `"`root'"'
    }
    else if (`"`parent'"' != "") {
        // Allow either "tables" or "dir_tables" to be passed.
        local pname "`parent'"
        if (substr("`pname'", 1, 4) != "dir_") local pname "dir_`pname'"
        local chosen_root `"${`pname'}"'
        if (`"`chosen_root'"' == "") {
            display as error ///
                "statareport_add_dir: parent(`parent') requested but ${`pname'} is empty"
            exit 459
        }
    }
    else {
        // Default: project root via `here'.
        capture mata: st_local("chosen_root", __here_root__)
        if (`"`chosen_root'"' == "") {
            display as error ///
                "statareport_add_dir: no root available (run `here' or pass raw/root/parent)"
            exit 459
        }
    }

    // Build the resolved path -----------------------------------------------
    local resolved `"`raw_path'"'
    if (!`is_abs' & `"`chosen_root'"' != "") {
        local resolved `"`chosen_root'/`raw_path'"'
    }

    // Strip a trailing slash unless the path is just "/".
    if (substr(`"`resolved'"', -1, 1) == "/" & strlen(`"`resolved'"') > 1) {
        local resolved = substr(`"`resolved'"', 1, strlen(`"`resolved'"') - 1)
    }

    // Emit the Stata global --------------------------------------------------
    global dir_`name' `"`resolved'"'

    // Directory existence: mata's direxists() is the cheapest portable check.
    mata: st_local("exists", strofreal(direxists(`"`resolved'"')))

    if (!`exists') {
        if ("`mkdir'" != "") {
            capture mkdir `"`resolved'"'
            if (_rc) {
                display as error ///
                    "statareport_add_dir: failed to mkdir `resolved' (rc = `_rc')"
                exit _rc
            }
            if ("`quiet'" == "") {
                display as text "dir_`name' " as result "-> " as result `"`resolved'"' ///
                    as text "  (created)"
            }
            local exists 1
        }
        else if ("`optional'" == "") {
            display as error ///
                "statareport_add_dir: dir_`name' -> `resolved' (does not exist)"
        }
        else if ("`quiet'" == "") {
            display as text "(dir_`name': optional, not yet present: `resolved')"
        }
    }
    else if ("`quiet'" == "") {
        display as text "dir_`name' " as result "-> " as result `"`resolved'"'
    }

    local mode "project"
    if ("`raw'" != "")              local mode "raw"
    else if (`"`root'"' != "")      local mode "root"
    else if (`"`parent'"' != "")    local mode "parent"

    return local name   `"`name'"'
    return local path   `"`resolved'"'
    return local mode   "`mode'"
    return scalar exists = `exists'
end
