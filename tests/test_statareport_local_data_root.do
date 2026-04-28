* ==============================================================================
* test_statareport_local_data_root.do -- regression tests for the new local data
* root cache and the matching `local' option of statareport_add_data.
* ==============================================================================

* Several cases below `cd' into a temp directory and run `here'. Save the
* test-suite cwd up front so we can restore it at the end -- otherwise
* run_all.do's subsequent `do test_*.do' calls fail to find their target.
local _suite_cwd_lroot `"`c(pwd)'"'

capture program drop _fresh_dir
program _fresh_dir, rclass
    args tag
    local stamp = string(clock("`c(current_date)' `c(current_time)'", "DMYhms"), "%21.0f")
    local path  "`c(tmpdir)'/sr_test_`tag'_`stamp'_`=int(1e9*runiform())'"
    capture shell rm -rf "`path'"
    quietly mkdir "`path'"
    return local path "`path'"
end

capture program drop _drop_caches
program _drop_caches
    capture mata: mata drop __here_root__
    capture mata: mata drop __statareport_data_root__
    capture mata: mata drop __statareport_local_data_root__
end

capture program drop _seed_dta
program _seed_dta
    args dst
    quietly {
        clear
        set obs 1
        gen byte placeholder = 1
        save `"`dst'"', replace
    }
end

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: defaults to <here>/local_datasets"
    _drop_caches
    _fresh_dir "lroot_default"
    local root `r(path)'
    quietly mkdir "`root'/local_datasets"
    file open fh using "`root'/.here", write replace text
    file close fh

    quietly cd "`root'"
    quietly here
    * On macOS `cd' resolves /var/folders -> /private/var/folders, so the
    * post-cd pwd is the canonical form `here' actually cached.
    local root_canon = subinstr(`"`c(pwd)'"', "\", "/", .)

    statareport_set_local_data_root, quiet
    local got ""
    mata: st_local("got", __statareport_local_data_root__)
    streq, left(`"`got'"') right(`"`root_canon'/local_datasets"') ///
        msg("default path resolves to <here>/local_datasets")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: relative path joined with `here'"
    _drop_caches
    _fresh_dir "lroot_rel"
    local root `r(path)'
    quietly mkdir "`root'/derived_xyz"
    file open fh using "`root'/.here", write replace text
    file close fh

    quietly cd "`root'"
    quietly here
    local root_canon = subinstr(`"`c(pwd)'"', "\", "/", .)

    statareport_set_local_data_root, path("derived_xyz") quiet
    local got ""
    mata: st_local("got", __statareport_local_data_root__)
    streq, left(`"`got'"') right(`"`root_canon'/derived_xyz"') ///
        msg("relative path joined with __here_root__")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: absolute path stored verbatim"
    _drop_caches
    _fresh_dir "lroot_abs"
    local root `r(path)'

    statareport_set_local_data_root, path(`"`root'"') quiet
    local got ""
    mata: st_local("got", __statareport_local_data_root__)
    streq, left(`"`got'"') right(`"`root'"') ///
        msg("absolute path stored verbatim")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: trailing slash is trimmed"
    _drop_caches
    _fresh_dir "lroot_slash"
    local root `r(path)'

    statareport_set_local_data_root, path(`"`root'/"') quiet
    local got ""
    mata: st_local("got", __statareport_local_data_root__)
    streq, left(`"`got'"') right(`"`root'"') ///
        msg("trailing slash stripped from absolute path")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: mkdir creates a missing directory"
    _drop_caches
    _fresh_dir "lroot_mkdir"
    local root `r(path)'
    file open fh using "`root'/.here", write replace text
    file close fh

    quietly cd "`root'"
    quietly here

    statareport_set_local_data_root, path("brand_new") mkdir quiet
    * Re-attempt mkdir: rc 693 ("already exists") proves the dir was created.
    capture mkdir "`root'/brand_new"
    rc_eq, expect(693) msg("brand_new directory was created by mkdir")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: clear forgets the cache"
    _drop_caches
    _fresh_dir "lroot_clear"
    local root `r(path)'

    statareport_set_local_data_root, path(`"`root'"') quiet
    statareport_set_local_data_root, clear quiet

    local got "SENTINEL"
    capture mata: st_local("got", __statareport_local_data_root__)
    streq, left(`"`got'"') right("SENTINEL") ///
        msg("__statareport_local_data_root__ dropped after clear")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root: clear is exclusive with path()"
    _drop_caches
    capture statareport_set_local_data_root, path("foo") clear
    rc_eq, expect(198) msg("clear + path() rejected with rc 198")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_add_data, local: joins path with the local root"
    _drop_caches
    _fresh_dir "addloc_ok"
    local root `r(path)'
    quietly mkdir "`root'/local_datasets"
    _seed_dta "`root'/local_datasets/core.dta"

    statareport_set_local_data_root, path(`"`root'/local_datasets"') quiet

    macro drop data_core
    statareport_add_data, name(core) path("core.dta") local quiet
    local got_mode    = "`r(mode)'"
    local got_missing = r(missing)
    streq, left(`"${data_core}"') right(`"`root'/local_datasets/core.dta"') ///
        msg("relative path joined with __statareport_local_data_root__")
    streq, left("`got_mode'") right("local") msg("r(mode) reports local")
    eq, expr("`got_missing' == 0")           msg("file is present, missing=0")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_add_data, local: errors when local root not set"
    _drop_caches
    capture statareport_add_data, name(orphan) path("foo.dta") local optional
    rc_eq, expect(459) ///
        msg("local without statareport_set_local_data_root -> rc 459")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_add_data, local: absolute path bypasses the local root"
    _drop_caches
    _fresh_dir "addloc_abs"
    local root `r(path)'
    quietly mkdir "`root'/elsewhere"
    _seed_dta "`root'/elsewhere/raw.dta"

    statareport_set_local_data_root, path(`"`root'/local_datasets"') quiet

    macro drop data_raw
    statareport_add_data, name(raw) path(`"`root'/elsewhere/raw.dta"') local quiet
    streq, left(`"${data_raw}"') right(`"`root'/elsewhere/raw.dta"') ///
        msg("absolute path passed through verbatim under local mode")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_add_data: raw, project, local, root() are mutually exclusive"
    _drop_caches
    capture statareport_add_data, name(x) path("a.dta") raw local
    rc_eq, expect(198) msg("raw + local rejected")

    capture statareport_add_data, name(x) path("a.dta") project local
    rc_eq, expect(198) msg("project + local rejected")

    capture statareport_add_data, name(x) path("a.dta") root("/r") local
    rc_eq, expect(198) msg("root() + local rejected")
end_case

* ------------------------------------------------------------------------------
start_case "statareport_set_local_data_root and statareport_set_data_root coexist"
    _drop_caches
    _fresh_dir "coexist"
    local root `r(path)'
    quietly mkdir "`root'/external"
    quietly mkdir "`root'/local_datasets"
    _seed_dta "`root'/external/ext.dta"
    _seed_dta "`root'/local_datasets/loc.dta"

    statareport_set_data_root,       path(`"`root'/external"')        quiet
    statareport_set_local_data_root, path(`"`root'/local_datasets"') quiet

    macro drop data_ext data_loc
    statareport_add_data, name(ext) path("ext.dta")        quiet         // default mode
    statareport_add_data, name(loc) path("loc.dta") local  quiet         // local mode

    streq, left(`"${data_ext}"') right(`"`root'/external/ext.dta"') ///
        msg("default mode uses external data root")
    streq, left(`"${data_loc}"') right(`"`root'/local_datasets/loc.dta"') ///
        msg("local mode uses local data root, independently")
end_case

* ------------------------------------------------------------------------------
* Restore the suite cwd so subsequent test files in run_all.do can resolve
* their own paths.
quietly cd `"`_suite_cwd_lroot'"'
