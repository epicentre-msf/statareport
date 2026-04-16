/*
Render a Markdown document to Word using Pandoc.

Syntax
------
knit using <input.md>, [saving(<output.docx>) replace default(<defaults.yaml>) ///
    reference(<reference.docx>) first(<metadata.yaml>) toc(<yes|no>) ///
    number_sec PANdocloc(<path-to-pandoc>)]

Behaviour
---------
- If `saving()` is omitted the output name is inferred from the input file with
  a `.docx` extension.
- A defaults YAML file is required by Pandoc. Provide your own through the
  `default()` option or let the command generate a temporary one that includes
  the output file and optional reference/metadata files.
- By default the generated document includes a table of contents and numbered
  sections. Disable numbering with the `number_sec` option (set to `no`).
*/

capture program drop knit
program knit
    version 15
    tempfile pandoc_log defaults_tmp
    tempvar pandoc_status

    syntax using/ , [ SAVing(string) REPlace DEFAULT(string) REFERENCE(string) ///
        FIRST(string) TOC(string) NUMBER_sec(string) PANdocloc(string) ]

    confirm file "`using'"

    // Resolve output file -----------------------------------------------------
    if ("`saving'" == "") {
        local output = regexr("`using'", "\.[^.]*$", "")
        local output "`output'.docx"
    }
    else {
        local output "`saving'"
    }

    if ("`replace'" == "") {
        capture confirm new file "`output'"
        if (_rc) {
            display as error "knit: output file `output' exists. Use replace to overwrite."
            exit 602
        }
    }

    // Determine Pandoc binary -------------------------------------------------
    local pandoc "`pandocloc'"
    if ("`pandoc'" == "") {
        local pandoc "pandoc"
        if (c(os) == "MacOSX") {
            capture confirm file "/opt/homebrew/bin/pandoc"
            if (!_rc) local pandoc "/opt/homebrew/bin/pandoc"
        }
    }

    // Resolve defaults YAML ---------------------------------------------------
    local defaults_file "`default'"
    local include_toc 1
    local include_num 1

    if ("`toc'" != "") {
        local lowertoc = lower(trim("`toc'"))
        if (inlist("`lowertoc'", "no", "off")) local include_toc 0
    }

    if ("`number_sec'" != "") {
        local lowernum = lower(trim("`number_sec'"))
        if (inlist("`lowernum'", "no", "off")) local include_num 0
    }

    if ("`defaults_file'" != "") {
        confirm file "`defaults_file'"
    }
    else {
        local defaults_file "`defaults_tmp'"
        knit__write_defaults using("`using'") output("`output'") defaults("`defaults_file'") ///
            reference("`reference'") first("`first'") toc(`include_toc') number(`include_num')
    }

    // Assemble CLI flags ------------------------------------------------------
    local toc_flag ""
    if (`include_toc') local toc_flag "--table-of-contents"

    local number_flag ""
    if (`include_num') local number_flag "--number-sections"

    local reference_flag ""
    if ("`reference'" != "") local reference_flag `"--reference-doc="`reference'""'

    local metadata_flag ""
    if ("`first'" != "") local metadata_flag `"--metadata-file="`first'""'

    capture noisily {
        local command `"!"' + `"`pandoc'"'
        `command' --defaults="`defaults_file'" `toc_flag' `number_flag' ///
            `reference_flag' `metadata_flag' > "`pandoc_log'" 2>&1
    }

    if (_rc) {
        file open `pandoc_status' using "`pandoc_log'", read text
        file read `pandoc_status' line
        while (r(eof) == 0) {
            display as error "`line'"
            file read `pandoc_status' line
        }
        file close `pandoc_status'
        display as error "knit: Pandoc exited with error code `_rc'"
        exit _rc
    }

    display as result "✅ Rendered `using' to `output'"
end

capture program drop knit__write_defaults
program knit__write_defaults
    version 15
    syntax using/ , OUTPUT(string) DEFAULTS(string) [REFERENCE(string) FIRST(string) ///
        TOC(integer 0 1) NUMBER(integer 0 1)]

    tempname fh
    capture file close `fh'
    file open `fh' using "`defaults'", write replace

    file write `fh' "from: markdown" _n
    file write `fh' "input-file: `using'" _n
    file write `fh' "output-file: `output'" _n

    if ("`reference'" != "") {
        file write `fh' "reference-doc: `reference'" _n
    }

    if ("`first'" != "") {
        file write `fh' "metadata-file: `first'" _n
    }

    if (`toc') file write `fh' "table-of-contents: true" _n
    if (!`toc') file write `fh' "table-of-contents: false" _n

    if (`number') file write `fh' "number-sections: true" _n
    if (!`number') file write `fh' "number-sections: false" _n

    file close `fh'
end
