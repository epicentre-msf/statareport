*! statareport_set_paths -- populate the $file_* globals for a statareport run
*!
*! Writes the set of globals that the render pipeline consumes:
*!   $file_dyntex          $file_input            $file_header
*!   $file_output          $file_reference        $file_default_options
*!   $file_label           $file_graph_opts       $file_filters
*!
*! Each path global is derived from a naming convention:
*!   <root>/<folder>/<prefix>[-<variant>]-<role>.<ext>
*!
*! $file_filters is not variant-aware -- the same Lua filter pool is
*! reused across the main report and any variant (e.g. listings). It
*! defaults to the three mandatory filters shipped by statareport under
*! <root>/input_md/ (page-orientation.lua, table-breaks.lua,
*! list-tables.lua) -- a warning is printed for each missing one -- plus
*! resize-figures.lua (forces report-figure size). The resize filter uses
*! the project-local copy when present, else the copy shipped on the
*! adopath, and is silently skipped only if neither can be found.
*!
*! Variants support the "main vs listings" split used in the project
*! workflow: call the command once with variant("") and again with
*! variant("listings") and the per-variant global family is emitted.
*!
*! Root resolution
*! ---------------
*! root() wins. Otherwise the command looks up the Mata global populated by
*! `here` (`__here_root__`). Otherwise it falls back to `c(pwd)`.
*!
*! Overrides
*! ---------
*! Individual files can be overridden via options named after the global
*! suffix: dyntex(), input(), header(), output(), reference(), defaults(),
*! label(), graphopts(), filters(). Anything not overridden follows the
*! convention.

capture program drop statareport_set_paths
program define statareport_set_paths, rclass
    version 15

    syntax , PREFIX(string) ///
        [DATE(string) ROOT(string) VARIANT(string) ///
         DYNTEX(string) INPUT(string) HEADER(string) OUTPUT(string) ///
         REFERENCE(string) DEFAULTS(string) LABEL(string) GRAPHOPTS(string) ///
         FILTers(string) ///
         QUIet]

    // -------------------------------------------------------------------
    // Resolve root: root() > mata __here_root__ > c(pwd)
    // -------------------------------------------------------------------
    if ("`root'" == "") {
        capture mata: st_local("root", __here_root__)
        if ("`root'" == "") {
            local root "`c(pwd)'"
            if ("`quiet'" == "") {
                display as text ///
                    "(statareport_set_paths: no root() and no `here' cache; defaulting to cwd)"
            }
        }
    }
    local root = subinstr("`root'", "\", "/", .)
    if (substr("`root'", -1, 1) == "/" & strlen("`root'") > 1) {
        local root = substr("`root'", 1, strlen("`root'") - 1)
    }

    // -------------------------------------------------------------------
    // Build the variant infix used in every generated filename.
    //   variant("")         -> infix is empty (main report)
    //   variant("listings") -> infix is "-listings"
    // -------------------------------------------------------------------
    local variant = trim("`variant'")
    local vsuf ""
    if ("`variant'" != "") local vsuf "-`variant'"

    // Global name suffix used when emitting the globals.
    //   variant("")         -> suffix is empty     ->  $file_input
    //   variant("listings") -> suffix is "_listings" ->  $file_input_listings
    local gsuf ""
    if ("`variant'" != "") local gsuf "_`variant'"

    // Date fragment appended to the docx filename (so runs don't clobber).
    local date_frag ""
    if ("`date'" != "") local date_frag "-`date'"

    // Short alias the user can read in messages.
    local stem "`prefix'`vsuf'"

    // -------------------------------------------------------------------
    // Apply the naming convention, then let the user's override win.
    // Layout matches `statareport_setup_dirs`.
    // -------------------------------------------------------------------
    local _dyntex    "`root'/output_md/`stem'-dyn.txt"
    local _input     "`root'/output_md/`stem'.txt"
    local _header    "`root'/input_md/header`vsuf'.txt"
    local _output    "`root'/output_word/`stem'`date_frag'.docx"
    local _reference "`root'/input_md/custom_reference`vsuf'.docx"
    local _defaults  "`root'/input_md/default_options`vsuf'.yaml"
    local _label     "`root'/input_tables/tables_labels`vsuf'.xlsx"
    local _graphopts "`root'/input_tables/shift_graph_input`vsuf'.xlsx"

    if ("`dyntex'"    != "") local _dyntex    "`dyntex'"
    if ("`input'"     != "") local _input     "`input'"
    if ("`header'"    != "") local _header    "`header'"
    if ("`output'"    != "") local _output    "`output'"
    if ("`reference'" != "") local _reference "`reference'"
    if ("`defaults'"  != "") local _defaults  "`defaults'"
    if ("`label'"     != "") local _label     "`label'"
    if ("`graphopts'" != "") local _graphopts "`graphopts'"

    // -------------------------------------------------------------------
    // Validate input files. Output files (dyntex, input, output) are
    // created by the render pipeline so they are not checked here.
    // -------------------------------------------------------------------
    local _bad 0
    foreach role in header reference defaults label graphopts {
        local _p "`_`role''"
        capture confirm file "`_p'"
        if (_rc) {
            display as error ///
                "statareport_set_paths: `role' file not found: `_p'"
            local _bad 1
        }
    }
    if (`_bad') exit 601

    // -------------------------------------------------------------------
    // Emit the globals.
    // -------------------------------------------------------------------
    global file_dyntex`gsuf'          "`_dyntex'"
    global file_input`gsuf'           "`_input'"
    global file_header`gsuf'          "`_header'"
    global file_output`gsuf'          "`_output'"
    global file_reference`gsuf'       "`_reference'"
    global file_default_options`gsuf' "`_defaults'"
    global file_label`gsuf'           "`_label'"
    global file_graph_opts`gsuf'      "`_graphopts'"

    // -------------------------------------------------------------------
    // Pandoc Lua filter pool ($file_filters).
    //
    // Variant-agnostic: the same filter list serves the main report and
    // every variant, so only write it on the non-variant call (gsuf="").
    // Explicit filters() bypasses the default + the missing-file warning.
    // A missing default is reported (not fatal) so a misconfigured project
    // surfaces here rather than as a cryptic pandoc error 3 stages later.
    // -------------------------------------------------------------------
    local _filters ""
    if ("`gsuf'" == "") {
        if (`"`filters'"' != "") {
            local _filters `"`filters'"'
        }
        else {
            local _fp_page  "`root'/input_md/page-orientation.lua"
            local _fp_break "`root'/input_md/table-breaks.lua"
            local _fp_list  "`root'/input_md/list-tables.lua"
            local _filters `""`_fp_page'" "`_fp_break'" "`_fp_list'""'

            foreach fp in "`_fp_page'" "`_fp_break'" "`_fp_list'" {
                capture confirm file "`fp'"
                if (_rc) {
                    display as error ///
                        "statareport_set_paths: WARNING -- Lua filter missing: `fp'"
                }
            }

            // resize-figures.lua forces the physical size of report figures so
            // they don't render full-width. Prefer the project-local (editable)
            // copy; if this project predates the filter, fall back to the copy
            // shipped on the adopath so it still applies automatically. Only
            // append it when it resolves to a real file -- a missing filter
            // would otherwise abort pandoc, and unlike the three above it is not
            // considered mandatory.
            local _fp_resize "`root'/input_md/resize-figures.lua"
            capture confirm file "`_fp_resize'"
            if (_rc) {
                capture findfile resize-figures.lua
                if (!_rc) local _fp_resize `"`r(fn)'"'
                else      local _fp_resize ""
            }
            if (`"`_fp_resize'"' != "") ///
                local _filters `"`_filters' "`_fp_resize'""'
        }
        global file_filters `"`_filters'"'
    }

    // -------------------------------------------------------------------
    // Return the same values so callers can script without globals.
    // -------------------------------------------------------------------
    return local root      "`root'"
    return local variant   "`variant'"
    return local dyntex    "`_dyntex'"
    return local input     "`_input'"
    return local header    "`_header'"
    return local output    "`_output'"
    return local reference "`_reference'"
    return local defaults  "`_defaults'"
    return local label     "`_label'"
    return local graphopts "`_graphopts'"
    return local filters   `"`_filters'"'

    if ("`quiet'" == "") {
        display as text "statareport_set_paths: " as result "`stem'" ///
            as text " (root: " as result "`root'" as text ")"
        display as text "  $file_dyntex`gsuf'          = " as result "${file_dyntex`gsuf'}"
        display as text "  $file_input`gsuf'           = " as result "${file_input`gsuf'}"
        display as text "  $file_header`gsuf'          = " as result "${file_header`gsuf'}"
        display as text "  $file_output`gsuf'          = " as result "${file_output`gsuf'}"
        display as text "  $file_reference`gsuf'       = " as result "${file_reference`gsuf'}"
        display as text "  $file_default_options`gsuf' = " as result "${file_default_options`gsuf'}"
        display as text "  $file_label`gsuf'           = " as result "${file_label`gsuf'}"
        display as text "  $file_graph_opts`gsuf'      = " as result "${file_graph_opts`gsuf'}"
        if ("`gsuf'" == "") {
            // Escape \$ on the LHS: $file_filters expands to a quoted
            // list, which would corrupt the surrounding string literal.
            display as text "  \$file_filters              = " as result `"${file_filters}"'
        }
    }
end
