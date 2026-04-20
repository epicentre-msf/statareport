*! statareport_render -- one-call wrapper for create_dyntex + dyntext + knit
*!
*! Replaces the three-step tail of a typical final do-file
*!
*!     create_dyntex using "$file_label", dyntex_file("$file_dyntex") ///
*!         label_sheet("$var_sheet_lab") tab_dir("$dir_lbltables") ///
*!         fig_dir("$dir_figures")
*!     dyntext "$file_dyntex", saving("$file_input") replace
*!     knit using "$file_input", saving("$file_output") replace ///
*!         reference("$file_reference") prepend("$file_header") ///
*!         filters("$file_filters")
*!
*! with
*!
*!     statareport_render
*!     statareport_render, variant("listings") toc(no)
*!
*! The command reads the $file_* / $dir_* / $var_* globals set by the
*! other statareport_* helpers and pipes them through the three stages.
*! Any option can be overridden per-call.
*!
*! Resolution order for each file:
*!     explicit option (e.g. output("...")) >
*!     $<global>_<variant>    when variant() is non-empty >
*!     $<global>
*!
*! Options:
*!     variant(s)       read $<global>_<s> instead of $<global> (e.g. "listings")
*!     label(...)       override $file_label
*!     dyntex(...)      override $file_dyntex
*!     input(...)       override $file_input
*!     output(...)      override $file_output
*!     reference(...)   override $file_reference
*!     header(...)      override $file_header (prepended to pandoc input-files)
*!     filters(...)     override $file_filters
*!     default(...)     override $file_default_options (user-supplied YAML)
*!     first(...)       pandoc metadata-file (forwarded to knit)
*!     in_header(...)   pandoc include-in-header (forwarded to knit)
*!     pandocloc(...)   explicit path to pandoc (forwarded to knit)
*!     sheet(...)       override $var_sheet_lab       (label-sheet name)
*!     tab_dir(...)     override $dir_lbltables       (labelled .dta folder)
*!     fig_dir(...)     override $dir_figures
*!     nbinput(n)       forwarded to create_dyntex    (limit to first n rows)
*!     toc(yes|no)      forwarded to knit             (default: yes)
*!     number_sec(yn)   forwarded to knit             (default: yes)
*!     from(...)        forwarded to knit             (see `help knit`)
*!     to(...)          forwarded to knit
*!     skip_dyntex      skip the create_dyntex step (use existing $file_dyntex)
*!     skip_dyntext     skip the dyntext step (use existing $file_input)
*!     skip_knit        skip the knit step (stop after dyntext)

capture program drop statareport_render
program define statareport_render, rclass
    version 15

    syntax [, VARiant(string) ///
        LABel(string) DYNTEX(string) INPUT(string) OUTPUT(string) ///
        REFERENCE(string) HEADer(string) FILTers(string) ///
        DEFAULT(string) FIRST(string) IN_header(string) PANdocloc(string) ///
        SHEET(string) TAB_dir(string) FIG_dir(string) NBINput(integer -1) ///
        TOC(string) NUMBER_sec(string) FROM(string) TO(string) ///
        SKIP_dyntex SKIP_dyntext SKIP_knit ///
        QUIet ]

    // Guard against the "nothing to do" case
    if ("`skip_dyntex'" != "" & "`skip_dyntext'" != "" & "`skip_knit'" != "") {
        display as error ///
            "statareport_render: every stage is skipped -- nothing to do"
        exit 198
    }

    // -------------------------------------------------------------------
    // Resolve each path: explicit option > variant global > plain global
    // -------------------------------------------------------------------
    local v "`variant'"
    local gsuf ""
    if ("`v'" != "") local gsuf "_`v'"

    local _label     = cond(`"`label'"'     != "", `"`label'"',     `"${file_label`gsuf'}"')
    local _dyntex    = cond(`"`dyntex'"'    != "", `"`dyntex'"',    `"${file_dyntex`gsuf'}"')
    local _input     = cond(`"`input'"'     != "", `"`input'"',     `"${file_input`gsuf'}"')
    local _output    = cond(`"`output'"'    != "", `"`output'"',    `"${file_output`gsuf'}"')
    local _reference = cond(`"`reference'"' != "", `"`reference'"', `"${file_reference`gsuf'}"')
    local _header    = cond(`"`header'"'    != "", `"`header'"',    `"${file_header`gsuf'}"')

    // filters has no _listings variant by default -- reuse the main pool
    local _filters   = cond(`"`filters'"'   != "", `"`filters'"',   `"${file_filters}"')

    local _default   = cond(`"`default'"'   != "", `"`default'"',   `"${file_default_options`gsuf'}"')

    // first()/in_header()/pandocloc() have no project-wide global defaults --
    // they're pass-through knobs for advanced pandoc tuning.
    local _first     `"`first'"'
    local _inhdr     `"`in_header'"'
    local _pandoc    `"`pandocloc'"'

    local _sheet     = cond(`"`sheet'"'     != "", `"`sheet'"',     `"${var_sheet_lab}"')
    if (`"`_sheet'"' == "") local _sheet "Labels"

    local _tab_dir   = cond(`"`tab_dir'"'   != "", `"`tab_dir'"',   `"${dir_lbltables}"')
    local _fig_dir   = cond(`"`fig_dir'"'   != "", `"`fig_dir'"',   `"${dir_figures}"')

    // -------------------------------------------------------------------
    // Validate the minimal set of paths needed for each stage.
    // -------------------------------------------------------------------
    if ("`skip_dyntex'" == "") {
        if (`"`_label'"'   == "") exit_error "label path (pass label() or set $file_label)"
        if (`"`_dyntex'"'  == "") exit_error "dyntex path (pass dyntex() or set $file_dyntex)"
        if (`"`_tab_dir'"' == "") exit_error "labelled-tables dir (pass tab_dir() or set $dir_lbltables)"
        if (`"`_fig_dir'"' == "") exit_error "figures dir (pass fig_dir() or set $dir_figures)"
    }
    if ("`skip_dyntext'" == "") {
        if (`"`_dyntex'"' == "") exit_error "dyntex path (pass dyntex() or set $file_dyntex)"
        if (`"`_input'"'  == "") exit_error "input md path (pass input() or set $file_input)"
    }
    if ("`skip_knit'" == "") {
        if (`"`_input'"'  == "") exit_error "input md path (pass input() or set $file_input)"
        if (`"`_output'"' == "") exit_error "output docx path (pass output() or set $file_output)"
    }

    // -------------------------------------------------------------------
    // Stage 1: create_dyntex
    // -------------------------------------------------------------------
    if ("`skip_dyntex'" == "") {
        if ("`quiet'" == "") display as text "[1/3] create_dyntex -> " as result `"`_dyntex'"'
        local nbopt ""
        if (`nbinput' >= 0) local nbopt `"nbinput(`nbinput')"'
        create_dyntex using `"`_label'"', ///
            dyntex_file(`"`_dyntex'"') label_sheet(`"`_sheet'"') ///
            tab_dir(`"`_tab_dir'"') fig_dir(`"`_fig_dir'"') `nbopt'
    }

    // -------------------------------------------------------------------
    // Stage 2: dyntext (compile DynTex to Markdown)
    // -------------------------------------------------------------------
    if ("`skip_dyntext'" == "") {
        if ("`quiet'" == "") display as text "[2/3] dyntext    -> " as result `"`_input'"'
        dyntext `"`_dyntex'"', saving(`"`_input'"') replace
    }

    // -------------------------------------------------------------------
    // Stage 3: knit
    // -------------------------------------------------------------------
    if ("`skip_knit'" == "") {
        if ("`quiet'" == "") display as text "[3/3] knit       -> " as result `"`_output'"'

        local knit_opts ""
        if (`"`_reference'"' != "") local knit_opts `"`knit_opts' reference(`"`_reference'"')"'
        if (`"`_header'"'    != "") local knit_opts `"`knit_opts' prepend(`"`_header'"')"'
        if (`"`_filters'"'   != "") local knit_opts `"`knit_opts' filters(`"`_filters'"')"'

        // Only honour the auto-YAML path when the user supplied one explicitly
        // via default() -- otherwise let knit generate its own tempfile from
        // the other options. If we passed the statareport_set_paths-derived
        // default always, any of the other options (filters, prepend, ...)
        // would be ignored when that YAML exists on disk.
        if (`"`default'"'    != "") local knit_opts `"`knit_opts' default(`"`_default'"')"'
        if (`"`_first'"'     != "") local knit_opts `"`knit_opts' first(`"`_first'"')"'
        if (`"`_inhdr'"'     != "") local knit_opts `"`knit_opts' in_header(`"`_inhdr'"')"'
        if (`"`_pandoc'"'    != "") local knit_opts `"`knit_opts' pandocloc(`"`_pandoc'"')"'
        if (`"`toc'"'        != "") local knit_opts `"`knit_opts' toc(`"`toc'"')"'
        if (`"`number_sec'"' != "") local knit_opts `"`knit_opts' number_sec(`"`number_sec'"')"'
        if (`"`from'"'       != "") local knit_opts `"`knit_opts' from(`"`from'"')"'
        if (`"`to'"'         != "") local knit_opts `"`knit_opts' to(`"`to'"')"'

        knit using `"`_input'"', saving(`"`_output'"') replace `knit_opts'
    }

    return local label     `"`_label'"'
    return local dyntex    `"`_dyntex'"'
    return local input     `"`_input'"'
    return local output    `"`_output'"'
    return local reference `"`_reference'"'
    return local header    `"`_header'"'
    return local filters   `"`_filters'"'
    return local default   `"`_default'"'
    return local first     `"`_first'"'
    return local in_header `"`_inhdr'"'
    return local pandocloc `"`_pandoc'"'
end

capture program drop exit_error
program define exit_error
    args msg
    display as error "statareport_render: missing `msg'"
    exit 459
end
