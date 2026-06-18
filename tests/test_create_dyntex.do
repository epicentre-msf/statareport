* ==============================================================================
* test_create_dyntex.do -- heading hierarchy in the generated DynTex.
*
* Section/Subsection/Subsubsection columns map to "# / ## / ###" markdown
* headings. Subsubsection is optional: label sheets that predate the column
* still build, and produce no level-3 headings.
* ==============================================================================

local wd "`c(tmpdir)'/sr_create_dyntex"
capture mkdir "`wd'"

* Helper: count lines in a file that match an (extended) regex via grep.
* Mirrors the grep+read pattern used elsewhere in the suite.
capture program drop _grepcount
program _grepcount, rclass
    args pattern file out
    quietly shell grep -cE '`pattern'' "`file'" > "`out'" 2>/dev/null
    tempname fh
    file open `fh' using "`out'", read text
    file read `fh' n
    file close `fh'
    return local n "`n'"
end

* ------------------------------------------------------------------------------
start_case "create_dyntex: Subsubsection column emits level-3 (###) headings"
    clear
    set obs 1
    gen str20 InputID      = "tbl1"
    gen str3  Include       = "Yes"
    gen str40 Caption       = "Table caption"
    gen str3  Figure        = "No"
    gen str40 FootNote       = "A footnote"
    gen str20 Section        = "Results"
    gen str20 Subsection     = "Tables"
    gen str20 Subsubsection  = "Deep dive"
    gen str20 DisplayMode    = "Portrait"
    export excel using "`wd'/labels3.xlsx", sheet("Sheet1") firstrow(variables) replace

    create_dyntex using "`wd'/labels3.xlsx", dyntex_file("`wd'/out3.dyntex") ///
        label_sheet("Sheet1") tab_dir("`wd'") fig_dir("`wd'") quiet

    _grepcount "^# "   "`wd'/out3.dyntex" "`wd'/g_h1"
    local n_h1 = r(n)
    _grepcount "^## "  "`wd'/out3.dyntex" "`wd'/g_h2"
    local n_h2 = r(n)
    _grepcount "^### " "`wd'/out3.dyntex" "`wd'/g_h3"
    local n_h3 = r(n)
    quietly shell grep -c '^### Deep dive$' "`wd'/out3.dyntex" > "`wd'/g_h3txt" 2>/dev/null
    tempname ft
    file open `ft' using "`wd'/g_h3txt", read text
    file read `ft' n_h3txt
    file close `ft'

    eq, expr("`n_h1' == 1")    msg("one level-1 (#) heading from Section")
    eq, expr("`n_h2' == 1")    msg("one level-2 (##) heading from Subsection")
    eq, expr("`n_h3' == 1")    msg("one level-3 (###) heading from Subsubsection")
    eq, expr("`n_h3txt' == 1") msg("the ### heading carries the Subsubsection text")
end_case

* ------------------------------------------------------------------------------
start_case "create_dyntex: Subsubsection is optional (older sheets without it still build)"
    clear
    set obs 1
    gen str20 InputID      = "tbl1"
    gen str3  Include       = "Yes"
    gen str40 Caption       = "Table caption"
    gen str3  Figure        = "No"
    gen str40 FootNote       = "A footnote"
    gen str20 Section        = "Results"
    gen str20 Subsection     = "Tables"
    gen str20 DisplayMode    = "Portrait"
    export excel using "`wd'/labels2.xlsx", sheet("Sheet1") firstrow(variables) replace

    capture create_dyntex using "`wd'/labels2.xlsx", dyntex_file("`wd'/out2.dyntex") ///
        label_sheet("Sheet1") tab_dir("`wd'") fig_dir("`wd'") quiet
    eq, expr("_rc == 0") msg("create_dyntex builds without the Subsubsection column")

    _grepcount "^### " "`wd'/out2.dyntex" "`wd'/g2_h3"
    local n2_h3 = r(n)
    _grepcount "^## "  "`wd'/out2.dyntex" "`wd'/g2_h2"
    local n2_h2 = r(n)

    eq, expr("`n2_h3' == 0") msg("no level-3 headings emitted when the column is absent")
    eq, expr("`n2_h2' == 1") msg("level-2 (##) heading still emitted (regression guard)")
end_case
