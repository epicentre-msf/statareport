*! statareport_set_data_root -- cache the default directory for $data_* globals
*!
*! Analogue of `here' (which caches the project root) but scoped to the
*! directory that statareport_add_data resolves relative dataset paths
*! against. The value is stored in a Mata global
*! __statareport_data_root__ so no stray Stata global is created.
*!
*! Usage:
*!     statareport_set_data_root, path("$dir_datasets")
*!     statareport_set_data_root, path("/path/to/datasets")
*!     statareport_set_data_root, clear            // forget the cached root
*!
*! Subsequent statareport_add_data calls join relative paths with the
*! cached root; absolute paths are used verbatim. The directory itself is
*! *not* checked on set -- statareport_confirm_data surfaces missing files.

capture program drop statareport_set_data_root
program define statareport_set_data_root, rclass
    version 15
    syntax [, PATH(string) CLEAR QUIet]

    if ("`clear'" != "") {
        capture mata: mata drop __statareport_data_root__
        if ("`quiet'" == "") display as text "(statareport_set_data_root: cleared)"
        exit
    }

    if (`"`path'"' == "") {
        display as error "statareport_set_data_root: specify path() or clear"
        exit 198
    }

    local path = subinstr(`"`path'"', "\", "/", .)
    if (substr(`"`path'"', -1, 1) == "/" & strlen(`"`path'"') > 1) {
        local path = substr(`"`path'"', 1, strlen(`"`path'"') - 1)
    }

    mata: __statareport_data_root__ = st_local("path")

    if ("`quiet'" == "") {
        display as text "(statareport_set_data_root: " as result "`path'" as text ")"
    }

    return local path `"`path'"'
end
