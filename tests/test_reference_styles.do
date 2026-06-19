* ==============================================================================
* test_reference_styles.do -- guard the Word styles the render pipeline relies
* on inside the shipped reference docx files.
*
* TOC1/TOC2/TOC3  : section / subsection / subsubsection entries in the TOC.
*                   A missing TOC3 makes Word render level-3 entries with an
*                   oversized fallback ("huge subsubsection in TOC").
* TableofFigures  : the style Word applies to every "TOC \c" entry, i.e. the
*                   List of Tables / List of Figures. Missing -> Word falls back
*                   to the bold/blue caption look ("very bold and big").
*
* Uses unzip + grep on word/styles.xml, matching the other docx-inspecting
* tests in this suite.
* ==============================================================================

local repo = subinstr("`c(pwd)'", "\", "/", .)
if (substr("`repo'", -6, 6) == "/tests") {
    local repo = substr("`repo'", 1, strlen("`repo'") - 6)
}

foreach ref in custom_reference custom_reference-listings {
    start_case "reference docx `ref': defines TOC1-3 + TableofFigures styles"
        local doc "`repo'/ressources/`ref'.docx"
        tempfile sx
        quietly shell unzip -p "`doc'" word/styles.xml > "`sx'" 2>/dev/null

        foreach sid in TOC1 TOC2 TOC3 TableofFigures {
            tempfile g
            quietly shell grep -c 'w:styleId="`sid'"' "`sx'" > "`g'" 2>/dev/null
            tempname fh
            file open `fh' using "`g'", read text
            file read `fh' n
            file close `fh'
            eq, expr("`n' >= 1") msg("`ref' defines the `sid' style")
        }
    end_case
}
