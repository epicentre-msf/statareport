*! reportdo -- run `do' on a file inside $dir_dofiles
*!
*! A short alias that removes the $dir_dofiles / .do boilerplate. Instead
*! of
*!
*!     do "$dir_dofiles/01-create-datasets.do"
*!     do "$dir_dofiles/helpers/make_cohort.do"
*!
*! you write
*!
*!     reportdo 01-create-datasets
*!     reportdo helpers/make_cohort
*!
*! Options:
*!     args(...)   additional arguments forwarded to the underlying do
*!     quiet       run via `quietly do'

capture program drop reportdo
program define reportdo, rclass
    version 15
    syntax anything(name=target id="do-file name or relative path") ///
        [, ARGs(string) QUIet]

    if ("$dir_dofiles" == "") {
        display as error ///
            "reportdo: global dir_dofiles is not set. Run statareport_add_dir, name(dofiles) first."
        exit 459
    }

    // If no extension given, append .do.
    local tgt `"`target'"'
    if (length(`"`tgt'"') < 3 | substr(`"`tgt'"', -3, 3) != ".do") {
        local tgt `"`tgt'.do"'
    }

    // Resolve relative to $dir_dofiles unless already absolute.
    local is_abs 0
    if (substr(`"`tgt'"', 1, 1) == "/")            local is_abs 1
    else if (regexm(`"`tgt'"', "^[A-Za-z]:/"))     local is_abs 1

    if (`is_abs') local full `"`tgt'"'
    else          local full `"$dir_dofiles/`tgt'"'

    confirm file `"`full'"'

    if ("`quiet'" == "") {
        do `"`full'"' `args'
    }
    else {
        quietly do `"`full'"' `args'
    }

    return local fn `"`full'"'
end
