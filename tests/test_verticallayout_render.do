* ==============================================================================
* test_verticallayout_render.do -- end-to-end check that `quant, verticallayout'
* renders a LEADING BLANK LINE in the final .docx. Exercises the real pipeline:
* quant -> kable (grid table) -> knit (pandoc + table-breaks.lua). The docx is
* read back to a pandoc AST and inspected. Requires pandoc on PATH; the whole
* file is skipped otherwise.
*
* A single price row in verticallayout has four stacked lines (N, mean (SD),
* median [IQR], (min/max)) plus the leading blank line = five lines = four
* LineBreaks. Without the fix there would be only three. The table-breaks
* filter must also have consumed the VBLANKLINE sentinel.
* ==============================================================================

* repo root (strip a trailing /tests from cwd, like run_all.do does)
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
    display as text _newline(1) "  (skipping test_verticallayout_render: pandoc not on PATH)"
}
else {
    local wd "`c(tmpdir)'/sr_vl_render"
    capture mkdir "`wd'"

    start_case "verticallayout: leading blank line survives into the rendered docx"
        sysuse auto, clear
        quant price, output("`wd'/vt.dta") verticallayout
        use "`wd'/vt.dta", clear
        keep variable value
        kable, space(90) cap("vertical render test") out("`wd'/table.md")

        capture erase "`wd'/out.docx"
        knit using "`wd'/table.md", saving("`wd'/out.docx") replace ///
            filters(`""`repo'/ressources/page-orientation.lua" "`repo'/ressources/table-breaks.lua" "`repo'/ressources/list-tables.lua""')

        * Read the produced docx back to a pandoc AST and count the markers.
        capture erase "`wd'/back.txt"
        quietly shell pandoc "`wd'/out.docx" -t native -o "`wd'/back.txt" 2>/dev/null

        quietly shell grep -c "VBLANKLINE" "`wd'/back.txt" > "`wd'/g_sent" 2>/dev/null
        quietly shell grep -c "LineBreak"  "`wd'/back.txt" > "`wd'/g_brk"  2>/dev/null

        tempname fa fb
        file open `fa' using "`wd'/g_sent", read text
        file read `fa' n_sent
        file close `fa'
        file open `fb' using "`wd'/g_brk", read text
        file read `fb' n_brk
        file close `fb'

        eq, expr(`"`n_sent' == 0"') msg("table-breaks filter consumed the VBLANKLINE sentinel")
        eq, expr(`"`n_brk' == 4"')  msg("four line breaks => one leading blank + three between stats")
    end_case
}
