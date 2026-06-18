* ==============================================================================
* test_footnote_style.do -- footnotes must carry the "footnote" custom style so
* they pick up the footnote paragraph style from the reference docx.
*
* Two layers:
*   1. create_dyntex content (no pandoc): the generated DynTex must wrap every
*      footnote -- table AND figure -- in a custom-style="footnote" fenced div,
*      and must NOT forward the footnote to kable's footnote() option (which
*      would emit a plain, unstyled paragraph).
*   2. End-to-end render (pandoc-gated): a footnote wrapped that way must land in
*      the .docx as a paragraph styled "footnote", the footnote style definition
*      from the custom reference must survive, and the reference's page-number
*      footer must NOT be lost (regression guard requested alongside the fix).
* ==============================================================================

* repo root (strip a trailing /tests from cwd, like run_all.do does)
local repo = subinstr("`c(pwd)'", "\", "/", .)
if (substr("`repo'", -6, 6) == "/tests") {
    local repo = substr("`repo'", 1, strlen("`repo'") - 6)
}

local wd "`c(tmpdir)'/sr_footnote"
capture mkdir "`wd'"

* ------------------------------------------------------------------------------
* Layer 1: create_dyntex emits a styled footnote block for tables and figures.
* ------------------------------------------------------------------------------
start_case "create_dyntex: footnotes are wrapped in custom-style=footnote (table + figure)"
    clear
    set obs 2
    gen str20 InputID     = cond(_n == 1, "tbl1", "fig1")
    gen str3  Include     = "Yes"
    gen str40 Caption     = cond(_n == 1, "Table caption", "Figure caption")
    gen str3  Figure      = cond(_n == 1, "No", "Yes")
    gen str40 FootNote    = cond(_n == 1, "Table note alpha", "Figure note beta")
    * Non-empty section/subsection: an all-empty column round-trips through
    * export/import excel as numeric-missing and tostring()s to ".".
    gen str20 Section     = "Results"
    gen str20 Subsection  = "Tables"
    gen str20 DisplayMode = "Portrait"
    export excel using "`wd'/labels.xlsx", sheet("Sheet1") firstrow(variables) replace

    create_dyntex using "`wd'/labels.xlsx", dyntex_file("`wd'/out.dyntex") ///
        label_sheet("Sheet1") tab_dir("`wd'") fig_dir("`wd'") quiet

    * Count, via grep, footnote divs / any leftover kable footnote() / note texts.
    * (grep sidesteps Stata's quoting rules for a needle containing literal ".)
    quietly shell grep -c 'custom-style="footnote"' "`wd'/out.dyntex" > "`wd'/g_div"   2>/dev/null
    quietly shell grep -c 'footnote('               "`wd'/out.dyntex" > "`wd'/g_kfoot" 2>/dev/null
    quietly shell grep -c 'Table note alpha'        "`wd'/out.dyntex" > "`wd'/g_tnote" 2>/dev/null
    quietly shell grep -c 'Figure note beta'        "`wd'/out.dyntex" > "`wd'/g_fnote" 2>/dev/null

    tempname gd gk gt gf
    file open `gd' using "`wd'/g_div",   read text
    file read `gd' n_div
    file close `gd'
    file open `gk' using "`wd'/g_kfoot", read text
    file read `gk' n_kfoot
    file close `gk'
    file open `gt' using "`wd'/g_tnote", read text
    file read `gt' n_tnote
    file close `gt'
    file open `gf' using "`wd'/g_fnote", read text
    file read `gf' n_fnote
    file close `gf'

    eq, expr("`n_div' == 2")   msg("two custom-style=footnote blocks (one per item)")
    eq, expr("`n_kfoot' == 0") msg("kable call no longer carries a footnote() option")
    eq, expr("`n_tnote' == 1") msg("table footnote text present in the dyntex")
    eq, expr("`n_fnote' == 1") msg("figure footnote text present in the dyntex")
end_case

* ------------------------------------------------------------------------------
* Layer 2: rendered footnote carries the footnote style; page numbers survive.
* ------------------------------------------------------------------------------
tempfile pc
quietly shell command -v pandoc > "`pc'" 2>/dev/null
tempname ph
file open `ph' using "`pc'", read text
file read `ph' pcline
local has_pandoc = (r(eof) == 0)
file close `ph'

if (`has_pandoc' == 0) {
    display as text _newline(1) "  (skipping test_footnote_style render: pandoc not on PATH)"
}
else {
    start_case "footnote style: wrapped footnote renders with the footnote style from the custom reference"
        * Build a table via kable WITHOUT a footnote (as the fixed create_dyntex
        * does), then append the footnote div exactly as create_dyntex emits it.
        sysuse auto, clear
        quant price mpg, output("`wd'/fn.dta")
        use "`wd'/fn.dta", clear
        keep variable value
        kable, space(90) cap("Footnote style render test") out("`wd'/fn_table.md")

        tempname af
        file open `af' using "`wd'/fn_table.md", write append text
        file write `af' _n `"::: {custom-style="footnote"}"' _n
        file write `af' "Source: footnote should be styled." _n
        file write `af' ":::" _n
        file close `af'

        capture erase "`wd'/fn_out.docx"
        knit using "`wd'/fn_table.md", saving("`wd'/fn_out.docx") replace ///
            reference("`repo'/ressources/custom_reference.docx")

        * Pull the relevant parts out of the .docx (a zip) for inspection.
        quietly shell unzip -p "`wd'/fn_out.docx" word/document.xml > "`wd'/fn_doc.xml" 2>/dev/null
        quietly shell unzip -p "`wd'/fn_out.docx" word/styles.xml   > "`wd'/fn_sty.xml" 2>/dev/null
        quietly shell unzip -p "`wd'/fn_out.docx" word/footer1.xml  > "`wd'/fn_foot.xml" 2>/dev/null

        * (a) a paragraph in the body is styled "footnote"
        quietly shell grep -c 'w:val="footnote"'     "`wd'/fn_doc.xml"  > "`wd'/fn_g_doc"  2>/dev/null
        * (b) the footnote style definition from the reference survives in output
        quietly shell grep -c 'w:styleId="footnote"' "`wd'/fn_sty.xml"  > "`wd'/fn_g_sty"  2>/dev/null
        * (c) regression guard: the reference's page-number footer is still there
        quietly shell grep -c 'PAGE'                 "`wd'/fn_foot.xml" > "`wd'/fn_g_page" 2>/dev/null

        tempname ga gb gc
        file open `ga' using "`wd'/fn_g_doc",  read text
        file read `ga' n_doc
        file close `ga'
        file open `gb' using "`wd'/fn_g_sty",  read text
        file read `gb' n_sty
        file close `gb'
        file open `gc' using "`wd'/fn_g_page", read text
        file read `gc' n_page
        file close `gc'

        eq, expr("`n_doc' >= 1")  msg("footnote paragraph carries pStyle=footnote in the docx")
        eq, expr("`n_sty' >= 1")  msg("footnote style definition kept from the custom reference")
        eq, expr("`n_page' >= 1") msg("page-number footer from the custom reference is preserved")
    end_case
}
