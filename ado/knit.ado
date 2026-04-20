/*
Render a Markdown document to Word using Pandoc.

Syntax
------
knit using <input.md>, [saving(<output.docx>) replace default(<defaults.yaml>) ///
    reference(<reference.docx>) first(<metadata.yaml>) ///
    prepend(<header.txt>) in_header(<preamble.tex>) ///
    filters(<list of lua filters>) ///
    from(<pandoc reader>) to(<pandoc writer>) ///
    toc(<yes|no>) number_sec(<yes|no>) PANdocloc(<path-to-pandoc>)]

Behaviour
---------
- If `saving()` is omitted the output name is inferred from the input file
  by replacing the extension with `.docx`.
- A Pandoc defaults YAML file is required. Provide your own through
  `default()` or let knit auto-generate a temporary one that encodes every
  option above.
- `prepend()` points at a file that pandoc concatenates in front of the
  `using` input (maps to `input-files:` with the prepend file first). This
  is the natural home for the project's header.txt (title / subtitle /
  \listoftables / \listoffigures).
- `in_header()` maps to `include-in-header:` and is meant for LaTeX preamble
  snippets. For docx output prefer `prepend()`.
- `filters()` accepts a space- or line-separated list of filter paths
  (typically Lua filters such as page-orientation.lua).
- Pandoc is located automatically via `command -v pandoc` (POSIX) or
  `where pandoc` (Windows); explicit override via `pandocloc()`.
*/

capture program drop knit
program knit, rclass
    version 15
    tempfile pandoc_log defaults_tmp
    tempname pandoc_status

    syntax using/ , [ SAVing(string) REPlace DEFAULT(string) REFERENCE(string) ///
        FIRST(string) PREpend(string) IN_header(string) FILTers(string) ///
        FROM(string) TO(string) ///
        TOC(string) NUMBER_sec(string) PANdocloc(string) ]

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
        statareport__locate_pandoc
        local pandoc "`r(pandoc)'"
    }
    if ("`pandoc'" == "") {
        local pandoc "pandoc"
    }

    // Pandoc reader / writer defaults match the values used in the shipped
    // default_options.yaml (see ressources/).
    if (`"`from'"' == "") {
        local from "markdown+autolink_bare_uris+tex_math_single_backslash+grid_tables+multiline_tables"
    }
    if (`"`to'"' == "") {
        local to "docx+native_numbering+styles"
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
            reference("`reference'") first("`first'") ///
            prepend(`"`prepend'"') in_header(`"`in_header'"') ///
            filters(`"`filters'"') ///
            from("`from'") to("`to'") ///
            toc(`include_toc') number(`include_num')
    }

    // Build the shell command. The leading "!" makes Stata treat the rest
    // as an OS command when the local is expanded on the next line.
    local pandoc_cmd `"!"`pandoc'" --defaults="`defaults_file'" > "`pandoc_log'" 2>&1"'

    capture noisily `pandoc_cmd'
    local rc = _rc

    if (`rc') {
        capture file close `pandoc_status'
        file open `pandoc_status' using "`pandoc_log'", read text
        file read `pandoc_status' line
        while (r(eof) == 0) {
            display as error "`line'"
            file read `pandoc_status' line
        }
        file close `pandoc_status'
        display as error "knit: Pandoc exited with error code `rc'"
        exit `rc'
    }

    display as result "Rendered `using' to `output'"

    return local output        `"`output'"'
    return local defaults_file `"`defaults_file'"'
    return local pandoc        `"`pandoc'"'
    return local input         `"`using'"'
end

// Write the Pandoc defaults YAML that `knit` feeds to pandoc via --defaults.
// Each key below maps to one of the globals typically defined in a
// statareport workflow (see `help statareport_set_paths'):
//
//   from:               pandoc reader, incl. extensions
//   to:                 pandoc writer, incl. extensions
//   input-files:        prepend file (if any) + main input   <- $file_header + $file_input
//   output-file:        the docx that pandoc produces        <- $file_output
//   reference-doc:      Word styles template                 <- $file_reference
//   include-in-header:  LaTeX preamble (rare for docx)
//   metadata-file:      YAML with title/author/date/etc.     <- first()
//   filters:            Lua/executable filters               <- $file_filters
//   table-of-contents:  yes/no toggle                        <- toc()
//   number-sections:    yes/no toggle                        <- number_sec()
//
// The YAML file itself lives at the path given by `default()` on knit; if
// the user does not supply one, knit creates a tempfile and passes it here.
capture program drop knit__write_defaults
program knit__write_defaults
    version 15
    syntax using/ , OUTPUT(string) DEFAULTS(string) ///
        FROM(string) TO(string) ///
        [REFERENCE(string) FIRST(string) ///
         PREpend(string) IN_header(string) FILTers(string) ///
         TOC(integer 1) NUMBER(integer 1)]

    tempname fh
    capture file close `fh'
    file open `fh' using "`defaults'", write replace

    file write `fh' "from: `from'" _n
    file write `fh' "to: `to'" _n

    // input-files: (prepend if present) + main input file.
    if (`"`prepend'"' != "") {
        file write `fh' "input-files:" _n
        file write `fh' "- `prepend'" _n
        file write `fh' "- `using'" _n
    }
    else {
        file write `fh' "input-file: `using'" _n
    }

    file write `fh' "output-file: `output'" _n

    if ("`reference'" != "") {
        file write `fh' "reference-doc: `reference'" _n
    }

    if ("`first'" != "") {
        file write `fh' "metadata-file: `first'" _n
    }

    if (`"`in_header'"' != "") {
        file write `fh' "include-in-header: `in_header'" _n
    }

    // filters: one entry per whitespace-separated path.
    if (`"`filters'"' != "") {
        file write `fh' "filters:" _n
        foreach f of local filters {
            file write `fh' "- `f'" _n
        }
    }

    if (`toc') file write `fh' "table-of-contents: true" _n
    else        file write `fh' "table-of-contents: false" _n

    if (`number') file write `fh' "number-sections: true" _n
    else           file write `fh' "number-sections: false" _n

    file close `fh'
end

// Locate the pandoc executable by asking the operating system.
// Returns r(pandoc) with the resolved absolute path or "" if not found.
capture program drop statareport__locate_pandoc
program statareport__locate_pandoc, rclass
    version 15

    tempfile lookup
    tempname fh

    if (c(os) == "Windows") {
        capture !where pandoc > "`lookup'" 2>&1
    }
    else {
        capture !command -v pandoc > "`lookup'" 2>&1
    }

    local resolved ""
    capture file close `fh'
    capture confirm file "`lookup'"
    if (!_rc) {
        file open `fh' using "`lookup'", read text
        file read `fh' line
        while (r(eof) == 0 & "`resolved'" == "") {
            local trimmed = trim(`"`line'"')
            if ("`trimmed'" != "" & !regexm("`trimmed'", "(not found|INFO:|Could not find)")) {
                local resolved `"`trimmed'"'
            }
            file read `fh' line
        }
        file close `fh'
    }

    // macOS Homebrew fallbacks
    if ("`resolved'" == "" & c(os) == "MacOSX") {
        capture confirm file "/opt/homebrew/bin/pandoc"
        if (!_rc) local resolved "/opt/homebrew/bin/pandoc"
        else {
            capture confirm file "/usr/local/bin/pandoc"
            if (!_rc) local resolved "/usr/local/bin/pandoc"
        }
    }

    return local pandoc `"`resolved'"'
end
