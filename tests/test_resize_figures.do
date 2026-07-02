* ==============================================================================
* test_resize_figures.do -- resize-figures.lua forces the physical size of report
* figures in the Word output. A figure whose path contains output_figures/ must
* come out at 11.5cm x 10cm (= 4139999 x 3599999 EMU in the docx drawing extent),
* regardless of the PNG's intrinsic size; without the filter it keeps its
* intrinsic size. Requires pandoc + unzip on PATH; skipped otherwise.
* ==============================================================================

local repo = subinstr("`c(pwd)'", "\", "/", .)
if (substr("`repo'", -6, 6) == "/tests") {
    local repo = substr("`repo'", 1, strlen("`repo'") - 6)
}

* pandoc present?
tempfile pc
quietly shell command -v pandoc > "`pc'" 2>/dev/null
tempname ph
file open `ph' using "`pc'", read text
file read `ph' pcline
local has_pandoc = (r(eof) == 0)
file close `ph'

if (`has_pandoc' == 0) {
    display as text _newline(1) "  (skipping test_resize_figures: pandoc not on PATH)"
}
else {

* Count lines containing a fixed numeric EMU value (no quotes/regex).
capture program drop _grepn
program define _grepn, rclass
    syntax , File(string) Num(string)
    tempfile o
    tempname h
    quietly shell grep -c -F `num' "`file'" > "`o'" 2>/dev/null
    file open `h' using "`o'", read text
    file read `h' n
    file close `h'
    if ("`n'" == "") local n 0
    return local n "`n'"
end

    local wd "`c(tmpdir)'/sr_resize_figures"
    capture mkdir "`wd'"
    capture mkdir "`wd'/output_figures"
    local resize "`repo'/ressources/resize-figures.lua"

    * A real PNG under an output_figures/ path (the filter keys off that folder).
    sysuse auto, clear
    quietly scatter mpg price, name(g_rf, replace)
    quietly graph export "`wd'/output_figures/fig.png", replace width(600)

    tempname mh
    file open `mh' using "`wd'/img.md", write replace text
    file write `mh' "![A safety figure](`wd'/output_figures/fig.png)" _n
    file close `mh'

    * ----------------------------------------------------------------------
    start_case "resize-figures.lua: output_figures image forced to 11.5cm x 10cm"
        capture erase "`wd'/out.docx"
        knit using "`wd'/img.md", saving("`wd'/out.docx") replace ///
            filters(`""`resize'""') toc(no)
        quietly shell unzip -p "`wd'/out.docx" word/document.xml > "`wd'/doc.xml" 2>/dev/null

        _grepn, file("`wd'/doc.xml") num("4139999")
        eq, expr(`"`r(n)' >= 1"') msg("drawing width forced to 11.5cm (4139999 EMU)")
        _grepn, file("`wd'/doc.xml") num("3599999")
        eq, expr(`"`r(n)' >= 1"') msg("drawing height forced to 10cm (3599999 EMU)")
    end_case

    * ----------------------------------------------------------------------
    start_case "no resize filter: image keeps its intrinsic size (control)"
        capture erase "`wd'/out2.docx"
        knit using "`wd'/img.md", saving("`wd'/out2.docx") replace toc(no)
        quietly shell unzip -p "`wd'/out2.docx" word/document.xml > "`wd'/doc2.xml" 2>/dev/null

        _grepn, file("`wd'/doc2.xml") num("4139999")
        eq, expr(`"`r(n)' == 0"') msg("no forced width without the filter")
    end_case

}
