/*
Generate a DynTex control file from a labelled Excel sheet.

Required columns in the label sheet:
- InputID      : identifier used to locate the table/figure file.
- Include      : set to "Yes" (case insensitive) for rows that should appear.
- Figure       : "Yes" to include an image, anything else assumes a table.
- Caption      : caption text.
- FootNote     : optional footnote text.
- Section      : optional level 1 heading.
- Subsection   : optional level 2 heading.
- Subsubsection: optional level 3 heading. This column is itself optional --
                 label sheets created before it existed still work; when it is
                 absent no level-3 headings are emitted.
- DisplayMode  : "Portrait" or "Landscape" to switch page orientation.

The command writes a DynTex file that Stata's dynamic document machinery can
consume.

Option {opt quiet} suppresses the per-item progress messages (sections,
subsections, figures, tables and the completion note) printed while the DynTex
file is built. Errors are always shown.
*/

capture program drop create_dyntex
program create_dyntex
    version 15
    syntax using/ , DYNTEX_file(string) LABEL_sheet(string) TAB_dir(string) ///
        FIG_dir(string) [NBINput(numlist > 0 integer max=1) QUIet]

    confirm file "`using'"

    // Whether to print per-item progress messages (suppressed by quiet).
    local verbose = ("`quiet'" == "")
    // Prefix for the noisy data steps (import/save) so quiet is truly silent.
    local qui ""
    if ("`quiet'" != "") local qui "quietly"

    // Prepare destination file ------------------------------------------------
    capture file close _dyntex
    file open _dyntex using "`dyntex_file'", write replace
    file write _dyntex "<<dd_version : 1>>" _n _n

    // Import label sheet ------------------------------------------------------
    tempfile labels
    `qui' import excel using "`using'", sheet("`label_sheet'") firstrow clear

    foreach required in InputID Include Caption Figure FootNote Section Subsection DisplayMode {
        capture confirm variable `required'
        if (_rc) {
            display as error "create_dyntex: label sheet lacks required column '`required''"
            file close _dyntex
            exit 111
        }
    }

    // Subsubsection (level-3 heading, ###) is optional for backward
    // compatibility with label sheets created before it existed. When the
    // column is absent, no level-3 headings are emitted.
    capture confirm variable Subsubsection
    local has_subsubsection = (_rc == 0)

    // Coerce every label-sheet column to string. tostring refuses already-string
    // variables, so loop and skip those.
    foreach col of varlist _all {
        capture confirm string variable `col'
        if (_rc) {
            quietly tostring `col', replace force
        }
    }

    quietly replace InputID   = trim(InputID)
    quietly replace Include   = lower(trim(Include))
    quietly replace Section   = trim(Section)
    quietly replace Subsection = trim(Subsection)
    if (`has_subsubsection') quietly replace Subsubsection = trim(Subsubsection)
    quietly replace Caption   = trim(Caption)
    quietly replace FootNote  = trim(FootNote)
    quietly replace DisplayMode = trim(DisplayMode)
    quietly replace Figure    = lower(trim(Figure))

    gen long __order = _n
    if ("`nbinput'" != "") {
        quietly keep in 1/`nbinput'
    }
    quietly drop if missing(InputID)
    quietly drop if Include == "no"

    if (_N == 0) {
        file close _dyntex
        display as error "create_dyntex: no entries marked for inclusion"
        exit 498
    }

    `qui' save "`labels'", replace

    // Emit content ------------------------------------------------------------
    local current_section ""
    local current_subsection ""
    local current_subsubsection ""
    local current_mode "Portrait"

    use "`labels'", clear
    sort __order
    local total = _N

    forvalues row = 1/`total' {
        local id         = InputID[`row']
        local caption    = Caption[`row']
        local footnote   = FootNote[`row']
        local caption    = trim("`caption'")
        local footnote   = trim("`footnote'")
        if ("`caption'" == "") local caption "`id'"
        // Escape embedded double-quotes for safe inclusion in the DynTex output.
        // Use subinstr() with char(34) to avoid fragile backslash-quote literals.
        local caption_clean  = subinstr(`"`caption'"',  char(34), "\" + char(34), .)
        local footnote_clean = subinstr(`"`footnote'"', char(34), "\" + char(34), .)
        local section    = Section[`row']
        local subsection = Subsection[`row']
        local subsubsection = ""
        if (`has_subsubsection') local subsubsection = Subsubsection[`row']
        local display    = DisplayMode[`row']
        local isfigure   = Figure[`row']


        // Page orientation -----------------------------------------------------
        local newmode ""
        if ("`display'" != "") {
            if (lower("`display'") == "landscape") local newmode "Landscape"
            else if (lower("`display'") == "portrait") local newmode "Portrait"
        }

        if ("`newmode'" != "" & "`newmode'" != "`current_mode'") {
            file write _dyntex "\Begin`newmode'" _n _n
            local current_mode "`newmode'"
            if (`verbose') display as result "▶️ Page mode changed to `current_mode'"
        }

        // Section headers ------------------------------------------------------
        if ("`section'" != "" & "`section'" != "`current_section'") {
            local current_section "`section'"
            file write _dyntex "# `current_section'" _n _n
            if (`verbose') display as result "Section: `current_section'"
        }

        if ("`subsection'" != "" & "`subsection'" != "`current_subsection'") {
            local current_subsection "`subsection'"
            file write _dyntex "## `current_subsection'" _n _n
            if (`verbose') display as result "  Subsection: `current_subsection'"
        }

        if ("`subsubsection'" != "" & "`subsubsection'" != "`current_subsubsection'") {
            local current_subsubsection "`subsubsection'"
            file write _dyntex "### `current_subsubsection'" _n _n
            if (`verbose') display as result "    Subsubsection: `current_subsubsection'"
        }

        // Content --------------------------------------------------------------
        if (substr("`isfigure'", 1, 1) == "y") {
            if (`verbose') display as result "  Figure `id'"
            file write _dyntex `"::: {custom-style="center"}"' _n
            file write _dyntex "![`caption_clean'](`fig_dir'/`id'.png)" _n _n
            file write _dyntex ":::" _n _n
        }
        else {
            // The footnote is emitted below as its own custom-style="footnote"
            // block so it picks up the footnote paragraph style from the
            // reference docx. It is intentionally NOT forwarded to kable's
            // footnote() option, which would append a plain, unstyled paragraph
            // to the table markdown instead.
            if (`verbose') display as result "  Table `id'"
            file write _dyntex "<<dd_do: nocommands>>" _n
            file write _dyntex `"quietly use "`tab_dir'/`id'.dta", clear"' _n
            file write _dyntex `" capture kable, space(90) cap("`caption_clean'") out("temp.md")"' _n
            file write _dyntex "<</dd_do>>" _n _n
            file write _dyntex `"<<dd_include: "temp.md">>"' _n _n
        }

        // Footnote (figures and tables): wrap in a custom-style="footnote"
        // fenced div so pandoc applies the reference docx's "footnote" paragraph
        // style in the output -- the same mechanism used for the figure block
        // above. A bare paragraph would render with the default body style.
        if ("`footnote_clean'" != "") {
            file write _dyntex `"::: {custom-style="footnote"}"' _n
            file write _dyntex "`footnote_clean'" _n
            file write _dyntex ":::" _n _n
        }
    }

    if ("`current_mode'" != "Portrait") {
        file write _dyntex "\BeginPortrait" _n
    }

    file close _dyntex
    if (`verbose') display as result "✅ Created dyntex instructions in `dyntex_file'"
end
