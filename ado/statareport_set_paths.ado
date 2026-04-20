*! statareport_set_paths -- populate the $file_* globals for a statareport run
*!
*! Writes the set of globals that the render pipeline consumes:
*!   $file_dyntex          $file_input            $file_header
*!   $file_output          $file_reference        $file_default_options
*!   $file_label           $file_graph_opts
*!
*! Each global is derived from a naming convention:
*!   <root>/<folder>/<prefix>[-<variant>]-<role>.<ext>
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
*! label(), graphopts(). Anything not overridden follows the convention.

capture program drop statareport_set_paths
program define statareport_set_paths, rclass
    version 15

    syntax , PREFIX(string) ///
        [DATE(string) ROOT(string) VARIANT(string) ///
         DYNTEX(string) INPUT(string) HEADER(string) OUTPUT(string) ///
         REFERENCE(string) DEFAULTS(string) LABEL(string) GRAPHOPTS(string) ///
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
    }
end
