*! apply_dta_labels 1.0
*! Read a translated flat file (var_lbl_folder_en.txt) and re-apply the
*! translated labels/notes onto the ORIGINAL .dta files, saving the result
*! into a sub-directory (default: en/). Data are never altered, only labels.
capture program drop apply_dta_labels
program apply_dta_labels
    version 15
    syntax [, Folder(string) INfile(string) SUBdir(string)]

    if "`folder'" == "" local folder "."
    if "`infile'" == "" local infile "`folder'/var_lbl_folder_en.txt"
    if "`subdir'" == "" local subdir "en"

    capture mkdir "`folder'/`subdir'"

    tempname fh
    file open `fh' using "`infile'", read text

    local curfile ""
    local loaded  0

    file read `fh' line
    while r(eof) == 0 {

        // strip a trailing CR (Windows-edited files); use macval so embedded
        // backticks/apostrophes in the text are NOT expanded as macros
        local line = subinstr(`"`macval(line)'"', char(13), "", .)
        local trim = strtrim(`"`macval(line)'"')

        // skip blanks and comment lines
        if `"`trim'"' == "" | substr(`"`macval(trim)'"', 1, 1) == "#" {
            file read `fh' line
            continue
        }

        local p    = strpos(`"`macval(trim)'"', "|")
        local tag  = substr(`"`macval(trim)'"', 1, `p' - 1)
        local rest = substr(`"`macval(trim)'"', `p' + 1, .)

        if "`tag'" == "FILE" {
            // close out the previous file
            if `loaded' quietly save "`folder'/`subdir'/`curfile'", replace
            local curfile = `"`macval(rest)'"'
            capture quietly use "`folder'/`curfile'", clear
            if _rc {
                display as error "cannot open original: `folder'/`curfile' (block skipped)"
                local loaded 0
            }
            else {
                quietly notes drop _all   // rebuilt in encounter order below
                local loaded 1
            }
            file read `fh' line
            continue
        }

        if `loaded' == 0 {
            file read `fh' line
            continue
        }

        // peel the leading filename field, present on every data record
        local p  = strpos(`"`macval(rest)'"', "|")
        local fl = substr(`"`macval(rest)'"', 1, `p' - 1)
        local r1 = substr(`"`macval(rest)'"', `p' + 1, .)

        if "`fl'" != "`curfile'" {
            display as error "file-field mismatch (`fl' vs `curfile') on a `tag' line; stopping to avoid corruption"
            file close `fh'
            exit 459
        }

        if "`tag'" == "DTALBL" {
            label data `"`macval(r1)'"'
        }
        else if "`tag'" == "VARLBL" {
            local p   = strpos(`"`macval(r1)'"', "|")
            local v   = substr(`"`macval(r1)'"', 1, `p' - 1)
            local txt = substr(`"`macval(r1)'"', `p' + 1, .)
            mata: _set_varlabel(st_local("v"), st_local("txt"))
        }
        else if "`tag'" == "VALSET" {
            local p    = strpos(`"`macval(r1)'"', "|")
            local set  = substr(`"`macval(r1)'"', 1, `p' - 1)
            local r2   = substr(`"`macval(r1)'"', `p' + 1, .)
            local p    = strpos(`"`macval(r2)'"', "|")
            local code = substr(`"`macval(r2)'"', 1, `p' - 1)
            local txt  = substr(`"`macval(r2)'"', `p' + 1, .)
            mata: st_vlmodify(st_local("set"), strtoreal(st_local("code")), st_local("txt"))
        }
        else if "`tag'" == "DTANOTE" {
            local p   = strpos(`"`macval(r1)'"', "|")
            local txt = substr(`"`macval(r1)'"', `p' + 1, .)   // drop the idx field
            notes _dta : `"`macval(txt)'"'
        }
        else if "`tag'" == "VARNOTE" {
            local p   = strpos(`"`macval(r1)'"', "|")
            local v   = substr(`"`macval(r1)'"', 1, `p' - 1)
            local r2  = substr(`"`macval(r1)'"', `p' + 1, .)
            local p   = strpos(`"`macval(r2)'"', "|")
            local txt = substr(`"`macval(r2)'"', `p' + 1, .)   // drop the idx field
            notes `v' : `"`macval(txt)'"'
        }

        file read `fh' line
    }

    if `loaded' quietly save "`folder'/`subdir'/`curfile'", replace
    file close `fh'

    display as result "Applied translated labels into: `folder'/`subdir'/"
end

version 15
mata:
mata set matastrict off

void _set_varlabel(string scalar vname, string scalar lab)
{
    real scalar idx
    idx = st_varindex(vname)
    if (idx > 0 & idx != .) st_varlabel(idx, lab)
}
end
