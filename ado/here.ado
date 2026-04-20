*! version 0.3.0  16apr2026
*! here.ado -- cd to project root. Portable relative paths, nothing more.
*!
*! First call:  walks up from c(pwd) to find a root marker, cd's there,
*!              prints one initialization message.
*! Later calls: cd's to the cached root silently.
*! Cache:       Mata global __here_root__  (invisible to Stata globals).
*!
*! Usage:
*!   here
*!   use data/clean.dta, clear       // plain relative path, just works

program define here, rclass
    version 14

    syntax [, Levels(integer 5) From(string) Markers(string) Force Clear]

    // ------------------------------------------------------------------
    // clear: drop the cache and return
    // ------------------------------------------------------------------
    if "`clear'" != "" {
        capture mata: mata drop __here_root__
        display as text "(here: cleared)"
        exit
    }

    // ------------------------------------------------------------------
    // try the Mata cache (silent, no globals in sight)
    // ------------------------------------------------------------------
    local root ""
    if "`force'" == "" {
        capture mata: st_local("root", __here_root__)
    }
    local was_cached = (`"`root'"' != "")

    // ------------------------------------------------------------------
    // first call (or force): walk upward looking for a marker
    // ------------------------------------------------------------------
    if !`was_cached' {

        if `"`markers'"' == "" {
            local markers `"*.stpr .git .here"'
        }
        if `"`from'"' == "" {
            local from `"`c(pwd)'"'
        }

        // normalise separators
        local from = subinstr(`"`from'"', "\", "/", .)
        if substr(`"`from'"', -1, 1) == "/" & length(`"`from'"') > 1 {
            local from = substr(`"`from'"', 1, length(`"`from'"') - 1)
        }

        local current `"`from'"'
        local root ""
        local found_marker ""

        forvalues i = 0/`levels' {
            foreach m of local markers {
                // file match
                local fhits : dir `"`current'"' files `"`m'"'
                if `"`fhits'"' != "" {
                    local root `"`current'"'
                    gettoken found_marker : fhits
                    continue, break
                }
                // directory match (e.g. .git)
                local dhits : dir `"`current'"' dirs `"`m'"'
                if `"`dhits'"' != "" {
                    local root `"`current'"'
                    gettoken found_marker : dhits
                    continue, break
                }
            }
            if `"`root'"' != "" continue, break

            // parent
            local slash = strrpos(`"`current'"', "/")
            if `slash' <= 1 continue, break
            local parent = substr(`"`current'"', 1, `slash' - 1)
            if `"`parent'"' == `"`current'"' continue, break
            local current `"`parent'"'
        }

        if `"`root'"' == "" {
            display as error ///
                "here: no project root found within `levels' levels"
            display as error ///
                "      from: `from'"
            display as error ///
                "      markers: `markers'"
            display as error ///
                "      tip: create a .here file at your project root"
            exit 601
        }

        // cache in Mata (invisible to Stata globals)
        mata: __here_root__ = st_local("root")
    }

    // ------------------------------------------------------------------
    // cd to root
    // ------------------------------------------------------------------
    quietly cd `"`root'"'

    // ------------------------------------------------------------------
    // message: only on first initialization
    // ------------------------------------------------------------------
    if !`was_cached' {
        display as text "(here: " as result `"`root'"' ///
            as text "  [`found_marker'])"
    }

    // ------------------------------------------------------------------
    // return (for programmatic use if ever needed)
    // ------------------------------------------------------------------
    return local here `"`root'"'
end
