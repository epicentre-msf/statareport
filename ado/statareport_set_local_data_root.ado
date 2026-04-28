*! statareport_set_local_data_root -- cache the project-local data directory
*!
*! Cousin of statareport_set_data_root, but scoped to derived /
*! intermediate datasets that live *inside* the project repo (typically
*! the local_datasets/ folder created by statareport_setup_dirs).
*!
*! The cached path is stored in the Mata global
*! __statareport_local_data_root__ -- separate from
*! __statareport_data_root__ so a project can simultaneously point at
*! an external data export (set_data_root) AND a local working folder
*! (this command). statareport_add_data, local resolves relative paths
*! against this cache.
*!
*! Usage:
*!     statareport_set_local_data_root                          // <here>/local_datasets
*!     statareport_set_local_data_root, path("derived")         // <here>/derived
*!     statareport_set_local_data_root, path("../shared")       // joined with <here>
*!     statareport_set_local_data_root, path("/abs/path")       // verbatim
*!     statareport_set_local_data_root, mkdir                   // create if missing
*!     statareport_set_local_data_root, clear                   // forget the cache
*!
*! Resolution rules:
*!   - Absolute paths ("/...", "<letter>:/...") are stored verbatim.
*!   - Relative paths are joined with the `here' Mata cache
*!     (__here_root__) when available; otherwise with c(pwd) and a
*!     note is printed (unless quiet).
*!   - When path() is omitted, the conventional stem "local_datasets"
*!     is used so the command Just Works inside an initialised project.
*!
*! The directory itself is *not* checked unless `mkdir' is given (in
*! which case it is created if missing). Use statareport_confirm_data
*! to audit the resulting $data_* globals once datasets are registered.

capture program drop statareport_set_local_data_root
program define statareport_set_local_data_root, rclass
    version 15
    syntax [, PATH(string) CLEAR MKdir QUIet]

    // 1. Clear ----------------------------------------------------------------
    if ("`clear'" != "") {
        if (`"`path'"' != "" | "`mkdir'" != "") {
            display as error ///
                "statareport_set_local_data_root: clear is exclusive with path()/mkdir"
            exit 198
        }
        capture mata: mata drop __statareport_local_data_root__
        if ("`quiet'" == "") display as text "(statareport_set_local_data_root: cleared)"
        exit
    }

    // 2. Default to the canonical scaffold folder when path() is omitted ----
    if (`"`path'"' == "") local path "local_datasets"

    // 3. Normalise separators and trim a trailing slash ---------------------
    local path = subinstr(`"`path'"', "\", "/", .)
    if (substr(`"`path'"', -1, 1) == "/" & strlen(`"`path'"') > 1) {
        local path = substr(`"`path'"', 1, strlen(`"`path'"') - 1)
    }

    // 4. Detect absolute paths ("/foo" or "X:/foo") -------------------------
    local is_abs 0
    if (substr(`"`path'"', 1, 1) == "/") local is_abs 1
    else if (regexm(`"`path'"', "^[A-Za-z]:/")) local is_abs 1

    // 5. Resolve against the `here' root for relative paths ------------------
    local resolved `"`path'"'
    if (!`is_abs') {
        local hereroot ""
        capture mata: st_local("hereroot", __here_root__)
        if (`"`hereroot'"' != "") {
            local resolved `"`hereroot'/`path'"'
        }
        else {
            local cwd = subinstr(`"`c(pwd)'"', "\", "/", .)
            local resolved `"`cwd'/`path'"'
            if ("`quiet'" == "") {
                display as text ///
                    "(statareport_set_local_data_root: no `here' root cached; using cwd)"
            }
        }
    }

    // 6. Optionally materialise the directory -------------------------------
    //    rc 693 ("directory already exists") is treated as success.
    if ("`mkdir'" != "") {
        capture mkdir `"`resolved'"'
        if (_rc & _rc != 693) {
            display as error ///
                "statareport_set_local_data_root: cannot create `resolved' (rc = `_rc')"
            exit _rc
        }
    }

    // 7. Cache the resolved path in Mata ------------------------------------
    mata: __statareport_local_data_root__ = st_local("resolved")

    if ("`quiet'" == "") {
        display as text "(statareport_set_local_data_root: " ///
            as result `"`resolved'"' as text ")"
    }

    return local path `"`resolved'"'
end
