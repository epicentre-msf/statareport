*! export_dta_labels 1.1
*! Extract dataset/variable/value labels and notes from every .dta in a
*! folder into a pipe-delimited flat file (one record per line, free text last).
capture program drop export_dta_labels
program export_dta_labels
    version 15
    syntax [, Folder(string) OUTfile(string) PATtern(string)]

    if "`folder'"  == "" local folder  "."
    if "`outfile'" == "" local outfile "`folder'/var_lbl_folder.txt"
    if `"`pattern'"' == "" local pattern "*.dta"

    // header (created / overwritten here; data blocks are appended in Mata)
    tempname fh
    file open `fh' using "`outfile'", write text replace
    file write `fh' "# Stata label export. One record per line. Fields are pipe-delimited. The LAST field is free text." _n
    file write `fh' "# Record types:" _n
    file write `fh' "#   DTALBL|<file>|<dataset label>" _n
    file write `fh' "#   VARLBL|<file>|<var>|<variable label>" _n
    file write `fh' "#   VALSET|<file>|<set>|<code>|<value label>" _n
    file write `fh' "#   DTANOTE|<file>|<idx>|<note>" _n
    file write `fh' "#   VARNOTE|<file>|<var>|<idx>|<note>" _n
    file write `fh' "# Translate ONLY the final free-text field. Copy tags, file, var, set, code, idx and all # lines verbatim." _n
    file write `fh' "# Do not add, remove, reorder or merge lines." _n
    file close `fh'

    // accept one or more space-separated glob patterns ("*" and "?" wildcards,
    // per Stata's dir extended function); union dedupes overlapping matches.
    local files ""
    foreach pat of local pattern {
        local hits : dir "`folder'" files `"`pat'"'
        local files : list files | hits
    }
    if `: word count `files'' == 0 {
        display as error "no files matching `pattern' found in `folder'"
        exit 601
    }

    foreach f of local files {
        preserve
        quietly use "`folder'/`f'", clear
        local dlbl : data label
        quietly label dir
        local sets `r(names)'
        mata: _exp_dta_block("`outfile'", "`f'", st_local("dlbl"), st_local("sets"))
        restore
    }

    display as result "Exported labels from `: word count `files'' file(s) to: `outfile'"
end

version 15
mata:
mata set matastrict off

void _exp_dta_block(string scalar outfile, string scalar fname,
                    string scalar dlbl,    string scalar setlist)
{
    real   scalar    fh, i, nv, j, k, nnotes
    string scalar    nm, lab, note, setname
    real   colvector V
    string colvector T
    string rowvector sets

    fh = fopen(outfile, "a")

    fput(fh, "FILE|" + fname)

    if (dlbl != "") fput(fh, "DTALBL|" + fname + "|" + _clean(dlbl))

    // variable labels
    nv = st_nvar()
    for (i = 1; i <= nv; i++) {
        lab = st_varlabel(i)
        if (lab != "") fput(fh, "VARLBL|" + fname + "|" + st_varname(i) + "|" + _clean(lab))
    }

    // value-label sets (each set is written once, regardless of how many vars use it)
    if (setlist != "") {
        sets = tokens(setlist)
        for (j = 1; j <= cols(sets); j++) {
            setname = sets[j]
            if (st_vlexists(setname)) {
                st_vlload(setname, V, T)
                for (k = 1; k <= rows(V); k++) {
                    fput(fh, "VALSET|" + fname + "|" + setname + "|" +
                             strofreal(V[k], "%18.0g") + "|" + _clean(T[k]))
                }
            }
        }
    }

    // dataset notes
    nnotes = strtoreal(st_global("_dta[note0]"))
    if (nnotes != . & nnotes > 0) {
        for (k = 1; k <= nnotes; k++) {
            note = st_global("_dta[note" + strofreal(k) + "]")
            fput(fh, "DTANOTE|" + fname + "|" + strofreal(k) + "|" + _clean(note))
        }
    }

    // variable notes
    for (i = 1; i <= nv; i++) {
        nm     = st_varname(i)
        nnotes = strtoreal(st_global(nm + "[note0]"))
        if (nnotes != . & nnotes > 0) {
            for (k = 1; k <= nnotes; k++) {
                note = st_global(nm + "[note" + strofreal(k) + "]")
                fput(fh, "VARNOTE|" + fname + "|" + nm + "|" + strofreal(k) + "|" + _clean(note))
            }
        }
    }

    fclose(fh)
}

// collapse CR/LF to single spaces so every record stays on one line, then trim
string scalar _clean(string scalar s)
{
    s = subinstr(s, char(13), " ")
    s = subinstr(s, char(10), " ")
    return(strtrim(s))
}
end
