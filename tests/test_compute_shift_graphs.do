* ==============================================================================
* test_compute_shift_graphs.do
*
* Two layers:
*   1. Naming + stored results (no pandoc): the default filename stem is
*      <measure>_<evalue>_<suffix>; fname() overrides it; r(stem)/r(graph)/r(png)
*      report the resolved name; and two comparisons that share evalue() but use
*      different fname() land in DIFFERENT files (the fix for "two time points
*      give the same result" -- a collision caused by the stem omitting basevalue).
*   2. End-to-end render (pandoc-gated): two figure rows that follow each other in
*      the label sheet must BOTH keep their image and caption in the .docx. A
*      missing/overwritten PNG would drop one figure's image at render time, which
*      is the "two graphs on a page, only the second shows" symptom.
* ==============================================================================

* repo root (strip a trailing /tests from cwd, like run_all.do does)
local repo = subinstr("`c(pwd)'", "\", "/", .)
if (substr("`repo'", -6, 6) == "/tests") {
    local repo = substr("`repo'", 1, strlen("`repo'") - 6)
}

local wd "`c(tmpdir)'/sr_shift"
capture mkdir "`wd'"
local out "`wd'/out"
capture mkdir "`out'"

* --- shared fixtures: config xlsx + a long dataset whose values differ by visit
clear
input str12 parameter str20 name str8 units double lln double uln
"measure" "My Measure" "U/L" 5 45
end
export excel using "`wd'/cfg.xlsx", firstrow(variables) replace

clear
set seed 12345
set obs 60
gen id = _n
expand 3
bysort id: gen visit = _n
gen measure = visit*10 + rnormal(0, 1)
save "`wd'/data.dta", replace

* ------------------------------------------------------------------------------
* Layer 1a: default naming + stored results.
* ------------------------------------------------------------------------------
start_case "compute_shift_graphs: default stem is <measure>_<evalue>_<suffix> and is returned in r()"
    use "`wd'/data.dta", clear
    compute_shift_graphs measure, evar(visit) evalue(3) basevalue(1) ///
        name("My Measure") idvariable(id) outputdir("`out'") suffix("test") ///
        configfile("`wd'/cfg.xlsx")
    local stem_d = r(stem)
    local png_d  = r(png)
    local gph_d  = r(graph)

    streq, left("`stem_d'") right("measure_3_test") msg("r(stem) is measure_3_test")
    capture confirm file "`png_d'"
    rc_eq, expect(0) msg("default .png is written at r(png)")
    capture confirm file "`gph_d'"
    rc_eq, expect(0) msg("default .gph is written at r(graph)")
    streq, left("`png_d'") right("`out'/measure_3_test.png") msg("r(png) is the full default path")
end_case

* ------------------------------------------------------------------------------
* Layer 1b: fname() overrides the stem.
* ------------------------------------------------------------------------------
start_case "compute_shift_graphs: fname() overrides the default stem"
    use "`wd'/data.dta", clear
    compute_shift_graphs measure, evar(visit) evalue(3) basevalue(1) ///
        name("My Measure") idvariable(id) outputdir("`out'") suffix("test") ///
        configfile("`wd'/cfg.xlsx") fname("custom_stem")
    local stem_c = r(stem)
    local png_c  = r(png)

    streq, left("`stem_c'") right("custom_stem") msg("r(stem) honours fname()")
    capture confirm file "`png_c'"
    rc_eq, expect(0) msg("fname() .png is written")
    capture confirm file "`out'/custom_stem.gph"
    rc_eq, expect(0) msg("fname() .gph is written")
end_case

* ------------------------------------------------------------------------------
* Layer 1c: two comparisons sharing evalue() but with different fname() do NOT
*           collide -- both files exist (the bug-1 fix).
* ------------------------------------------------------------------------------
start_case "compute_shift_graphs: fname() keeps two same-evalue comparisons in separate files"
    * baseline(1) -> week(3)
    use "`wd'/data.dta", clear
    compute_shift_graphs measure, evar(visit) evalue(3) basevalue(1) ///
        name("My Measure") idvariable(id) outputdir("`out'") suffix("test") ///
        configfile("`wd'/cfg.xlsx") fname("cmp_bl_to_3")
    * week(2) -> week(3): same evalue, different baseline
    use "`wd'/data.dta", clear
    compute_shift_graphs measure, evar(visit) evalue(3) basevalue(2) ///
        name("My Measure") idvariable(id) outputdir("`out'") suffix("test") ///
        configfile("`wd'/cfg.xlsx") fname("cmp_w2_to_3")

    capture confirm file "`out'/cmp_bl_to_3.png"
    rc_eq, expect(0) msg("first comparison file survives")
    capture confirm file "`out'/cmp_w2_to_3.png"
    rc_eq, expect(0) msg("second comparison file exists (no overwrite)")
end_case

* ------------------------------------------------------------------------------
* Layer 2: end-to-end render of two consecutive figures (pandoc-gated).
* ------------------------------------------------------------------------------
tempfile pc
quietly shell command -v pandoc > "`pc'" 2>/dev/null
tempname ph
file open `ph' using "`pc'", read text
file read `ph' pcline
local has_pandoc = (r(eof) == 0)
file close `ph'

if (`has_pandoc' == 0) {
    display as text _newline(1) "  (skipping test_compute_shift_graphs render: pandoc not on PATH)"
}
else {
    start_case "render: two figures following each other both keep their image and caption"
        * Two distinct shift-graph PNGs with their own fname() stems.
        use "`wd'/data.dta", clear
        compute_shift_graphs measure, evar(visit) evalue(3) basevalue(1) ///
            name("My Measure") idvariable(id) outputdir("`out'") suffix("r") ///
            configfile("`wd'/cfg.xlsx") fname("shiftA")
        use "`wd'/data.dta", clear
        compute_shift_graphs measure, evar(visit) evalue(3) basevalue(2) ///
            name("My Measure") idvariable(id) outputdir("`out'") suffix("r") ///
            configfile("`wd'/cfg.xlsx") fname("shiftB")

        * Label sheet: two consecutive figure rows. A trailing Include="No" row
        * carries non-empty optional columns so FootNote/Subsection import as
        * STRING (an all-empty column round-trips to numeric-missing -> ".") and
        * the two figure rows keep genuinely empty footnotes -> pure adjacency.
        clear
        set obs 3
        gen str12 InputID     = ""
        gen str3  Include     = "Yes"
        gen str3  Figure      = "Yes"
        gen str20 Caption     = ""
        gen str20 FootNote    = ""
        gen str12 Section     = "Results"
        gen str12 Subsection  = ""
        gen str12 DisplayMode = "Portrait"
        replace InputID = "shiftA"      in 1
        replace InputID = "shiftB"      in 2
        replace InputID = "zzz_dummy"   in 3
        replace Caption = "ShiftCapAlpha" in 1
        replace Caption = "ShiftCapBeta"  in 2
        replace Caption = "drop me"       in 3
        replace Include = "No"            in 3
        replace Figure  = "No"            in 3
        replace FootNote   = "x"          in 3
        replace Subsection = "x"          in 3
        export excel using "`wd'/labels.xlsx", sheet("Sheet1") firstrow(variables) replace

        create_dyntex using "`wd'/labels.xlsx", dyntex_file("`wd'/r.dyntex") ///
            label_sheet("Sheet1") tab_dir("`out'") fig_dir("`out'") quiet
        dyntext "`wd'/r.dyntex", saving("`wd'/r.md") replace
        capture erase "`wd'/r.docx"
        knit using "`wd'/r.md", saving("`wd'/r.docx") replace ///
            reference("`repo'/ressources/custom_reference.docx") ///
            filters("`repo'/ressources/page-orientation.lua `repo'/ressources/table-breaks.lua")

        quietly shell unzip -p "`wd'/r.docx" word/document.xml > "`wd'/r_doc.xml" 2>/dev/null

        * Count embedded images (a:blip) by OCCURRENCE (document.xml is one line,
        * so grep -c would always say 1) and check both captions are present.
        quietly shell grep -o '<a:blip'    "`wd'/r_doc.xml" | wc -l > "`wd'/r_blip"  2>/dev/null
        quietly shell grep -c 'ShiftCapAlpha' "`wd'/r_doc.xml"      > "`wd'/r_capA"  2>/dev/null
        quietly shell grep -c 'ShiftCapBeta'  "`wd'/r_doc.xml"      > "`wd'/r_capB"  2>/dev/null

        tempname gb ga gB
        file open `gb' using "`wd'/r_blip", read text
        file read `gb' n_blip
        file close `gb'
        file open `ga' using "`wd'/r_capA", read text
        file read `ga' n_capA
        file close `ga'
        file open `gB' using "`wd'/r_capB", read text
        file read `gB' n_capB
        file close `gB'

        local nb = real(strtrim("`n_blip'"))
        local na = real(strtrim("`n_capA'"))
        local nB = real(strtrim("`n_capB'"))
        eq, expr("`nb' == 2") msg("both figure images are embedded (2 drawings)")
        eq, expr("`na' >= 1") msg("first figure caption present in the docx")
        eq, expr("`nB' >= 1") msg("second figure caption present in the docx")
    end_case
}
