*! translate_dta_labels 1.3
*! Translate the free-text fields of a Stata label-export file (var_lbl_folder.txt)
*! from one language into another via the Anthropic Messages API, by shelling
*! out to curl + jq. The source language is fromlang() (default French) and the
*! target language is tolang() (default English).
*!
*! The API key is NEVER read into a Stata command string or written to disk:
*! the OS shell sources the project .StataEnviron (when present) and expands
*! $<KEYVAR> at call time; the key may instead be exported in the OS
*! environment. Key lookup order: envfile() if given, else .StataEnviron at the
*! here-root (or current dir), with the OS environment as the fallback.
*! Requires: curl, jq.
capture program drop translate_dta_labels
program translate_dta_labels
    version 15
    syntax [, INfile(string) OUTfile(string) MODel(string) FROMlang(string) ///
              TOlang(string) KEYVar(string) ENVfile(string) CHUNKsize(integer 100) ///
              MAXtokens(integer 8192) VERBose DRYrun]

    if `"`infile'"'   == "" local infile   "var_lbl_folder.txt"
    if `"`outfile'"'  == "" local outfile  "var_lbl_folder_en.txt"
    if "`model'"      == "" local model    "claude-sonnet-4-6"
    if "`fromlang'"   == "" local fromlang  "French"
    if "`tolang'"     == "" local tolang    "English"
    if "`keyvar'"     == "" local keyvar    "ANTH_API_KEY"

    // Resolve the project .StataEnviron. With no envfile() the file is looked
    // for at the cached here-root, else in the current directory. It is the OS
    // shell -- not Stata -- that sources this file, so the key value never
    // enters a Stata local or command string.
    if (`"`envfile'"' == "") {
        local root ""
        capture mata: st_local("root", __here_root__)
        if (`"`root'"' != "") local envfile `"`root'/.StataEnviron"'
        else                  local envfile ".StataEnviron"
    }
    local have_envfile 0
    capture confirm file `"`envfile'"'
    if (!_rc) local have_envfile 1

    // preflight: input exists
    capture confirm file "`infile'"
    if _rc {
        display as error "input file not found: `infile'"
        exit 601
    }

    // preflight: curl and jq present
    tempfile chk
    quietly shell { command -v curl ; command -v jq ; } > "`chk'" 2>/dev/null
    mata: st_local("ntool", strofreal(_xlt_nlines("`chk'")))
    if `ntool' < 2 {
        display as error "curl and/or jq not found on PATH (install jq with: brew install jq)"
        exit 199
    }

    tempfile sysf chunkf bodyf respf httpf outf errf runf keyck keyout

    // preflight: the key must be reachable by the shell -- either exported in
    // the OS environment or defined in the project .StataEnviron, which the run
    // script sources. This probe sources the same file and prints only
    // OK/MISSING, so the key value is never read back into Stata.
    tempname kh
    file open `kh' using "`keyck'", write text replace
    file write `kh' "#!/bin/sh" _n
    file write `kh' `"[ -f "`envfile'" ] && . "`envfile'""' _n
    file write `kh' `"[ -n "\$`keyvar'" ] && echo OK || echo MISSING"' _n
    file close `kh'
    quietly shell sh "`keyck'" > "`keyout'" 2>/dev/null
    mata: st_local("keystate", _xlt_firstline("`keyout'"))
    if ("`keystate'" != "OK") {
        display as error "API key `keyvar' not found."
        if (`have_envfile') {
            display as error "  add a line  `keyvar'=<key>  to `envfile'"
        }
        else {
            display as error "  no .StataEnviron found (looked for `envfile')"
            display as error "  create one there with a line  `keyvar'=<key>"
        }
        display as error "  -- or export `keyvar' in the OS environment."
        display as error "  macOS GUI Stata also reads ~/.zshenv, or: launchctl setenv `keyvar' <key>"
        exit 198
    }

    // system prompt (no labels, no secrets)
    file open sp using "`sysf'", write text replace
    file write sp `"You translate statistical survey metadata from `fromlang' into `tolang'."' _n
    file write sp `"The input is lines from a Stata label-export file. Fields are separated by the pipe character (|)."' _n
    file write sp `"On every line the ONLY translatable text is the substring AFTER THE FINAL pipe."' _n
    file write sp `"Translate that final field into clear, professional `tolang'. If it is already `tolang', leave it unchanged."' _n
    file write sp `"Copy everything else exactly: the leading tag, file name, variable name, value-label-set name, integer code and note index."' _n
    file write sp `"Copy any line beginning with FILE or # unchanged."' _n
    file write sp `"Return exactly the same number of lines, in the same order. Never add, remove, reorder, merge or split lines."' _n
    file write sp `"Output only the resulting lines: no preamble, no commentary, no code fences."' _n
    file close sp

    // run.sh: build body (jq escapes everything), call API, extract text.
    // \$ keeps the dollar literal so the OS shell -- not Stata -- expands it.
    file open rs using "`runf'", write text replace
    file write rs "#!/bin/sh" _n
    file write rs `"[ -f "`envfile'" ] && . "`envfile'""' _n
    file write rs `"jq -n --arg model "`model'" --argjson max `maxtokens' --rawfile sys "`sysf'" --rawfile content "`chunkf'" '{model:\$model,max_tokens:\$max,system:\$sys,messages:[{role:"user",content:\$content}]}' > "`bodyf'""' _n
    file write rs `"curl -sS -o "`respf'" -w '%{http_code}' https://api.anthropic.com/v1/messages -H "x-api-key: \$`keyvar'" -H "anthropic-version: 2023-06-01" -H "content-type: application/json" -d @"`bodyf'" > "`httpf'""' _n
    file write rs `"jq -r '[.content[]? | select(.type=="text") | .text] | join("")' "`respf'" > "`outf'" 2>/dev/null"' _n
    file write rs `"jq -r '.error.message // empty' "`respf'" > "`errf'" 2>/dev/null"' _n
    file close rs

    // write the # header lines once (overwrites outfile)
    mata: _xlt_writehdr("`infile'", "`outfile'")

    // number of translatable (non-#) lines
    mata: st_local("nd", strofreal(_xlt_ndata("`infile'")))

    if "`dryrun'" != "" {
        display as text "DRY RUN: `nd' record lines, chunk size `chunksize', model `model'"
        display as text "  translate `fromlang' -> `tolang'"
        display as text "  run script: `runf'"
        display as text "  system prompt: `sysf'"
        if (`have_envfile') display as text "  env file (sourced by shell): `envfile'"
        else                display as text "  env file: none found (`envfile')"
        exit 0
    }

    local nfail 0
    local lo 1
    while `lo' <= `nd' {
        local hi = min(`lo' + `chunksize' - 1, `nd')
        mata: _xlt_chunk("`infile'", "`chunkf'", `lo', `hi')

        quietly shell sh "`runf'"

        mata: st_local("http", _xlt_firstline("`httpf'"))
        local expect = `hi' - `lo' + 1

        if "`http'" != "200" {
            mata: st_local("emsg", _xlt_firstline("`errf'"))
            display as error "chunk `lo'-`hi': HTTP `http' `emsg' -- kept original (untranslated) lines"
            mata: _xlt_append_clean("`chunkf'", "`outfile'")
            local ++nfail
        }
        else {
            mata: st_local("oc", strofreal(_xlt_count_clean("`outf'")))
            if `oc' != `expect' {
                display as error "chunk `lo'-`hi': expected `expect' lines, got `oc' -- kept original lines"
                mata: _xlt_append_clean("`chunkf'", "`outfile'")
                local ++nfail
            }
            else {
                mata: _xlt_append_clean("`outf'", "`outfile'")
                if "`verbose'" != "" display as text "chunk `lo'-`hi': ok"
            }
        }
        local lo = `hi' + 1
    }

    if `nfail' == 0 {
        display as result "Translated `nd' lines (`fromlang' -> `tolang') -> `outfile'"
    }
    else {
        display as error "Finished with `nfail' failed chunk(s); those lines were left untranslated in `outfile'"
    }
end

version 15
mata:
mata set matastrict off

// count non-comment (non-#) data lines
real scalar _xlt_ndata(string scalar infile)
{
    string colvector L
    L = cat(infile)
    if (rows(L) == 0) return(0)
    return(colsum(substr(L, 1, 1) :!= "#"))
}

// total physical lines in a file
real scalar _xlt_nlines(string scalar path)
{
    string colvector L
    L = cat(path)
    return(rows(L))
}

// write only the leading "#" header lines to outfile (overwrite mode)
void _xlt_writehdr(string scalar infile, string scalar outfile)
{
    string colvector L, H
    real   scalar    fh, i
    L  = cat(infile)
    H  = (rows(L) ? select(L, substr(L, 1, 1) :== "#") : J(0, 1, ""))
    if (fileexists(outfile)) unlink(outfile)   // fopen(...,"w") aborts r(602) if it exists
    fh = fopen(outfile, "w")
    for (i = 1; i <= rows(H); i++) fput(fh, H[i])
    fclose(fh)
}

// write data lines lo..hi (1-based over the non-# lines) to a chunk file
void _xlt_chunk(string scalar infile, string scalar outchunk, real scalar lo, real scalar hi)
{
    string colvector L, D
    real   scalar    fh, i
    L  = cat(infile)
    D  = select(L, substr(L, 1, 1) :!= "#")
    if (fileexists(outchunk)) unlink(outchunk)  // fopen(...,"w") aborts r(602) if it exists
    fh = fopen(outchunk, "w")
    for (i = lo; i <= hi; i++) fput(fh, D[i])
    fclose(fh)
}

// first line of a file, or "" if empty/missing
string scalar _xlt_firstline(string scalar path)
{
    string colvector L
    L = cat(path)
    if (rows(L) == 0) return("")
    return(strtrim(L[1]))
}

// keep a returned line? drop code fences and blank lines
real scalar _xlt_keep(string scalar t)
{
    return(t != "" & substr(t, 1, 3) != "```")
}

// count kept lines in a model-output file (for parity check)
real scalar _xlt_count_clean(string scalar src)
{
    string colvector O
    real   scalar    i, n
    O = cat(src)
    n = 0
    for (i = 1; i <= rows(O); i++) if (_xlt_keep(O[i])) n++
    return(n)
}

// append kept lines of src onto outfile
void _xlt_append_clean(string scalar src, string scalar outfile)
{
    string colvector O
    real   scalar    fh, i
    O  = cat(src)
    fh = fopen(outfile, "a")
    for (i = 1; i <= rows(O); i++) if (_xlt_keep(O[i])) fput(fh, O[i])
    fclose(fh)
}
end
