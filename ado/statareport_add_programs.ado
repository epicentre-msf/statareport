*! statareport_add_programs -- adopath ++ one or more subdirectories of the
*! project root (the `here' cache). Replaces ad-hoc blocks like
*!
*!     quietly adopath ++ "$dir_project/programs"
*!     quietly adopath ++ "$dir_project/extras"
*!
*! with
*!
*!     statareport_add_programs programs extras
*!
*! Behaviour:
*!   - Each positional argument is a directory path.
*!   - Relative paths are joined to the `here' root (Mata __here_root__).
*!     Absolute paths ("/..." or "X:/...") pass through unchanged.
*!   - prepend switches to `adopath +' (higher search priority).
*!   - Missing directories trigger a warning but do not abort; adopath
*!     would silently fail to find any ado in them.
*!
*! Options:
*!   prepend   use `adopath +' instead of `adopath ++'
*!   quiet     suppress the per-path confirmation

capture program drop statareport_add_programs
program define statareport_add_programs, rclass
    version 15
    syntax anything(name=paths id="program directory list") ///
        [, PREpend QUIet]

    if (`"`paths'"' == "") {
        display as error "statareport_add_programs: supply at least one path"
        exit 198
    }

    // Resolve the project root from `here's Mata cache.
    local root ""
    capture mata: st_local("root", __here_root__)
    if (`"`root'"' == "") {
        display as error ///
            "statareport_add_programs: no project root (run `here' first)"
        exit 459
    }

    local op "++"
    if ("`prepend'" != "") local op "+"

    local added 0
    local missing 0
    local added_paths ""

    foreach p of local paths {
        // Absolute path?
        local is_abs 0
        if (substr(`"`p'"', 1, 1) == "/")            local is_abs 1
        else if (regexm(`"`p'"', "^[A-Za-z]:/"))     local is_abs 1

        if (`is_abs') local target `"`p'"'
        else          local target `"`root'/`p'"'

        // Strip trailing slash (but keep a bare "/")
        if (substr(`"`target'"', -1, 1) == "/" & strlen(`"`target'"') > 1) {
            local target = substr(`"`target'"', 1, strlen(`"`target'"') - 1)
        }

        mata: st_local("exists", strofreal(direxists(`"`target'"')))
        if (!`exists') {
            display as error ///
                "statareport_add_programs: `target' does not exist; skipping"
            local ++missing
            continue
        }

        quietly adopath `op' "`target'"

        if ("`quiet'" == "") {
            display as text "adopath `op' " as result `"`target'"'
        }
        local added_paths `"`added_paths' `"`target'"'"'
        local ++added
    }

    return local paths    `"`added_paths'"'
    return scalar added   = `added'
    return scalar missing = `missing'
end
