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
- DisplayMode  : "Portrait" or "Landscape" to switch page orientation.

The command writes a DynTex file that Stata's dynamic document machinery can
consume.
*/

capture program drop create_dyntex
program create_dyntex
    version 15
    syntax using/ , DYNTEX_file(string) LABEL_sheet(string) TAB_dir(string) ///
        FIG_dir(string) [NBINput(numlist > 0 integer max=1)]

    confirm file "`using'"

    // Prepare destination file ------------------------------------------------
    capture file close _dyntex
    file open _dyntex using "`dyntex_file'", write replace
    file write _dyntex "<<dd_version : 1>>" _n _n

    // Import label sheet ------------------------------------------------------
    tempfile labels
    import excel using "`using'", sheet("`label_sheet'") firstrow clear

    foreach required in InputID Include Caption Figure FootNote Section Subsection DisplayMode {
        capture confirm variable `required'
        if (_rc) {
            display as error "create_dyntex: label sheet lacks required column '`required''"
            file close _dyntex
            exit 111
        }
    }

    quietly tostring *, replace
    quietly replace InputID   = trim(InputID)
    quietly replace Include   = lower(trim(Include))
    quietly replace Section   = trim(Section)
    quietly replace Subsection = trim(Subsection)
    quietly replace Caption   = trim(Caption)
    quietly replace FootNote  = trim(FootNote)
    quietly replace DisplayMode = trim(DisplayMode)
    quietly replace Figure    = lower(trim(Figure))

    gen long __order = _n
    if ("`nbinput'" != "") {
        quietly keep in 1/`nbinput'
    }
    quietly drop if missing(InputID) | Include == ""
    quietly drop if Include == "no"

    if (_N == 0) {
        file close _dyntex
        display as error "create_dyntex: no entries marked for inclusion"
        exit 498
    }

    save "`labels'", replace

    // Emit content ------------------------------------------------------------
    local current_section ""
    local current_subsection ""
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
        local caption_clean : subinstr local caption "\"", "\\\"", .
        local footnote_clean : subinstr local footnote "\"", "\\\"", .
        local section    = Section[`row']
        local subsection = Subsection[`row']
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
            display as result "▶️ Page mode changed to `current_mode'"
        }

        // Section headers ------------------------------------------------------
        if ("`section'" != "" & "`section'" != "`current_section'") {
            local current_section "`section'"
            file write _dyntex "# `current_section'" _n _n
            display as result "Section: `current_section'"
        }

        if ("`subsection'" != "" & "`subsection'" != "`current_subsection'") {
            local current_subsection "`subsection'"
            file write _dyntex "## `current_subsection'" _n _n
            display as result "  Subsection: `current_subsection'"
        }

        // Content --------------------------------------------------------------
        if (substr("`isfigure'", 1, 1) == "y") {
            display as result "  Figure `id'"
            file write _dyntex `"::: {custom-style="center"}"' _n
            file write _dyntex "![`caption_clean'](`fig_dir'/`id'.png)" _n _n
            file write _dyntex ":::" _n _n
        }
        else {
            local footopt ""
            if ("`footnote_clean'" != "") local footopt `" footnote("`footnote_clean'")"'

            display as result "  Table `id'"
            file write _dyntex "<<dd_do: nocommands>>" _n
            file write _dyntex `"quietly use "`tab_dir'/`id'.dta", clear"' _n
            file write _dyntex `" capture kable, space(90) cap("`caption_clean'")`footopt' out("temp.md")"' _n
            file write _dyntex "<</dd_do>>" _n _n
            file write _dyntex `"<<dd_include: "temp.md">>"' _n _n
        }

        if ("`footnote_clean'" != "" & substr("`isfigure'", 1, 1) == "y") {
            file write _dyntex `"::: {custom-style="footnote"}"' _n
            file write _dyntex "`footnote_clean'" _n
            file write _dyntex ":::" _n _n
        }
    }

    if ("`current_mode'" != "Portrait") {
        file write _dyntex "\BeginPortrait" _n
    }

    file close _dyntex
    display as result "✅ Created dyntex instructions in `dyntex_file'"
end
