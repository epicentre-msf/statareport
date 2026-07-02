* ==============================================================================
* test_variant_relabel.do -- variant caption/list relabeling.
*
* statareport_render, variant("listings") must (a) derive caption_label="Listings"
* and list_title="List of Listings" and (b) have knit rewrite the finished docx so
* every "Table N" caption reads "Listings N" and the "List Of Tables" heading reads
* "List of Listings" -- while leaving the SEQ Table numbering field intact so the
* list still collects. norelabel must turn the whole thing off.
*
* Exercises the real pipeline (quant -> kable -> knit + pandoc + lua filters) and
* reads word/document.xml back out of the .docx. Requires pandoc + unzip on PATH;
* the whole file is skipped otherwise.
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
    display as text _newline(1) "  (skipping test_variant_relabel: pandoc not on PATH)"
}
else {

* Count matching lines of a fixed pattern in a file; pat() carries its own
* shell quoting so patterns can hold XML metacharacters (>, spaces).
capture program drop _grepc
program define _grepc, rclass
    syntax , File(string) Pat(string)
    tempfile o
    tempname h
    quietly shell grep -c -F `pat' "`file'" > "`o'" 2>/dev/null
    file open `h' using "`o'", read text
    file read `h' n
    file close `h'
    if ("`n'" == "") local n 0
    return local n "`n'"
end

    * Hermetic: earlier suites leave $file_*/$dir_* globals pointing at their own
    * (now-gone) scratch dirs. statareport_render, variant("listings") would pull
    * $file_reference_listings from there and hand pandoc a missing --reference-doc.
    * Drop the render-relevant globals so only our explicit paths are used.
    capture macro drop file_reference file_reference_listings ///
        file_default_options file_default_options_listings

    local wd "`c(tmpdir)'/sr_variant_relabel"
    capture mkdir "`wd'"
    local flt `""`repo'/ressources/page-orientation.lua" "`repo'/ressources/table-breaks.lua" "`repo'/ressources/list-tables.lua""'

    * A captioned table + a header carrying \listoftables (-> a List Of Tables).
    sysuse auto, clear
    quant price, output("`wd'/q.dta")
    use "`wd'/q.dta", clear
    keep variable value
    kable, space(90) cap("Adverse events by arm") out("`wd'/table.md")
    statareport_write_header using "`wd'/hdr.txt", title("Study") listoftables replace quiet

    * ----------------------------------------------------------------------
    start_case "variant(listings): captions + list heading relabeled to the variant"
        capture erase "`wd'/out.docx"
        statareport_render, variant("listings") ///
            input("`wd'/table.md") output("`wd'/out.docx") ///
            header("`wd'/hdr.txt") filters(`"`flt'"') ///
            toc(no) skip_dyntex skip_dyntext quiet

        * (a) render derived the two strings from the variant name
        streq, left(`"`r(caption_label)'"') right("Listings") ///
            msg("render derives caption_label = proper(variant)")
        streq, left(`"`r(list_title)'"') right("List of Listings") ///
            msg("render derives list_title = List of proper(variant)")

        * (b) knit rewrote the finished docx
        quietly shell unzip -p "`wd'/out.docx" word/document.xml > "`wd'/doc.xml" 2>/dev/null

        _grepc, file("`wd'/doc.xml") pat("'>Listings'")
        eq, expr(`"`r(n)' >= 1"') msg("caption prefix word rewritten to Listings")
        _grepc, file("`wd'/doc.xml") pat("'>Table'")
        eq, expr(`"`r(n)' == 0"') msg("no Table-prefixed caption run left behind")
        _grepc, file("`wd'/doc.xml") pat("'List of Listings'")
        eq, expr(`"`r(n)' >= 1"') msg("list heading rewritten to List of Listings")
        _grepc, file("`wd'/doc.xml") pat("'List Of Tables'")
        eq, expr(`"`r(n)' == 0"') msg("old List Of Tables heading gone")
        _grepc, file("`wd'/doc.xml") pat("'SEQ Table'")
        eq, expr(`"`r(n)' >= 1"') msg("SEQ Table numbering field left intact")
    end_case

    * ----------------------------------------------------------------------
    start_case "variant(listings) norelabel: document left as-is (Table / List Of Tables)"
        capture erase "`wd'/out2.docx"
        statareport_render, variant("listings") norelabel ///
            input("`wd'/table.md") output("`wd'/out2.docx") ///
            header("`wd'/hdr.txt") filters(`"`flt'"') ///
            toc(no) skip_dyntex skip_dyntext quiet

        * norelabel suppresses the derived label (returned empty)
        local got_cap `"`r(caption_label)'"'
        eq, expr(`"strlen(`"`got_cap'"') == 0"') ///
            msg("norelabel suppresses the derived caption_label")

        quietly shell unzip -p "`wd'/out2.docx" word/document.xml > "`wd'/doc2.xml" 2>/dev/null
        _grepc, file("`wd'/doc2.xml") pat("'>Table'")
        eq, expr(`"`r(n)' >= 1"') msg("caption prefix stays Table under norelabel")
        _grepc, file("`wd'/doc2.xml") pat("'>Listings'")
        eq, expr(`"`r(n)' == 0"') msg("no relabeling happened under norelabel")
        _grepc, file("`wd'/doc2.xml") pat("'List Of Tables'")
        eq, expr(`"`r(n)' >= 1"') msg("heading stays List Of Tables under norelabel")
    end_case

}
