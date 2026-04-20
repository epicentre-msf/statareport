*! statareport_write_header -- generate the pandoc include-file (header.txt)
*!
*! Writes a text file with a YAML front-matter block (title/subtitle/author)
*! followed by LaTeX directives for a table of contents, list of tables,
*! and list of figures. The generated file is meant to be consumed by
*! knit via its prepend()/using input-files machinery, exactly like the
*! hand-written header.txt used in the original mytrial workflow.
*!
*! Usage:
*!     statareport_write_header using "$file_header", ///
*!         title("Sample trial") ///
*!         subtitle("Phase III report") ///
*!         author("contributors") toc listoftables listoffigures
*!
*! Options:
*!     title(str)         document title (required unless noyaml)
*!     subtitle(str)      optional subtitle (accepts newlines via \n)
*!     author(str)        document author line
*!     toc                emit \tableofcontents in the body
*!     listoftables       emit \listoftables
*!     listoffigures      emit \listoffigures
*!     noyaml             skip the YAML block entirely
*!     replace            overwrite the destination file
*!     quiet              suppress the "wrote <file>" line

capture program drop statareport_write_header
program define statareport_write_header
    version 15
    syntax using/, [ TITLE(string) SUBTITLE(string) AUTHOR(string) ///
        TOC LISToftables LISTOFfigures NOYAML REPlace QUIet ]

    // Guard against accidental overwrite
    if ("`replace'" == "") {
        capture confirm new file "`using'"
        if (_rc) {
            display as error ///
                "statareport_write_header: `using' exists. Pass replace to overwrite."
            exit 602
        }
    }

    // Mata does the writing so we can emit literal LaTeX macros (\newpage,
    // \listoftables, ...) without Stata's macro processor chewing them up.
    local has_yaml = ("`noyaml'" == "")
    local has_toc  = ("`toc'" != "")
    local has_lot  = ("`listoftables'" != "")
    local has_lof  = ("`listoffigures'" != "")

    mata: statareport_header_emit(             ///
        "`using'",                             ///
        strofreal(`has_yaml'),                 ///
        `"`title'"',                           ///
        `"`subtitle'"',                        ///
        `"`author'"',                          ///
        strofreal(`has_toc'),                  ///
        strofreal(`has_lot'),                  ///
        strofreal(`has_lof'))

    if ("`quiet'" == "") {
        display as text "statareport_write_header: wrote " as result "`using'"
    }
end

capture mata mata drop statareport_header_emit()
mata:
void statareport_header_emit(
    string scalar dst,
    string scalar has_yaml_s,
    string scalar title,
    string scalar subtitle,
    string scalar author,
    string scalar has_toc_s,
    string scalar has_lot_s,
    string scalar has_lof_s)
{
    real scalar fh, has_yaml, has_toc, has_lot, has_lof
    string rowvector sub_lines
    real scalar i

    has_yaml = strtoreal(has_yaml_s)
    has_toc  = strtoreal(has_toc_s)
    has_lot  = strtoreal(has_lot_s)
    has_lof  = strtoreal(has_lof_s)

    if (fileexists(dst)) unlink(dst)
    fh = fopen(dst, "w")

    if (has_yaml) {
        fput(fh, "---")
        if (title != "") fput(fh, `"title: ""' + title + `"""')
        if (subtitle != "") {
            // Render subtitle as a YAML block scalar so embedded line
            // breaks survive. Split on "\n" (two chars) as well as real
            // newlines, so callers can pass either form.
            sub_lines = tokens(subinstr(subtitle, "\n", char(10)), char(10))
            fput(fh, "subtitle: |")
            for (i = 1; i <= cols(sub_lines); i++) {
                fput(fh, "          " + sub_lines[i])
            }
        }
        if (author != "") fput(fh, "author: " + author)
        fput(fh, "---")
        fput(fh, "")
    }

    fput(fh, "")
    fput(fh, "\newpage")
    fput(fh, "")

    if (has_toc) {
        fput(fh, "\tableofcontents")
        fput(fh, "")
        fput(fh, "\newpage")
        fput(fh, "")
    }
    if (has_lot) {
        fput(fh, "\listoftables")
        fput(fh, "")
        fput(fh, "\newpage")
        fput(fh, "")
    }
    if (has_lof) {
        fput(fh, "\listoffigures")
        fput(fh, "")
        fput(fh, "\newpage")
        fput(fh, "")
    }

    fclose(fh)
}
end
