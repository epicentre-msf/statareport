* ==============================================================================
* test_translate_dta_labels.do -- exercise the API-key preflight, the
* .StataEnviron sourcing path, and the r(602) overwrite regression. None of
* these cases perform a real translation: the key preflight and dryrun cases
* use a fake keyvar(), and the multi-chunk case uses a fake key so every chunk
* returns non-200 and the original lines are kept. The command-level cases need
* jq+curl on PATH (the command's own preflight) and are skipped otherwise; the
* direct-helper regression cases need neither.
* ==============================================================================

* Compile the .ado and its Mata helpers (_xlt_*) into this session so the
* regression cases can call them directly. (Auto-loading via adopath does not
* expose ado-private Mata functions to an interactive `mata:' call.)
capture findfile translate_dta_labels.ado
if (_rc == 0) quietly run "`r(fn)'"

* Throwaway project dir with a minimal export-format input file.
local tdir "`c(tmpdir)'/sr_translate_test"
capture mkdir "`tdir'"
tempname ih
file open `ih' using "`tdir'/in.txt", write text replace
file write `ih' "# header line, copied verbatim" _n
file write `ih' "DTALBL|test.dta|Une etiquette de jeu de donnees" _n
file close `ih'

* ------------------------------------------------------------------------------
* r(602) regression -- deterministic, no jq/network. Mata fopen(...,"w") aborts
* if the target exists, so the chunk/header writers must remove it first.
* ------------------------------------------------------------------------------
start_case "translate_dta_labels: chunk writer overwrites a reused file (no r(602))"
    tempfile cf
    capture mata: _xlt_chunk("`tdir'/in.txt", "`cf'", 1, 1)
    rc_eq, expect(0) msg("first chunk write succeeds")
    capture mata: _xlt_chunk("`tdir'/in.txt", "`cf'", 1, 1)
    rc_eq, expect(0) msg("re-writing the same chunk file does not r(602)")
end_case

start_case "translate_dta_labels: header writer overwrites an existing output (no r(602))"
    tempfile of
    capture mata: _xlt_writehdr("`tdir'/in.txt", "`of'")
    rc_eq, expect(0) msg("first header write succeeds")
    capture mata: _xlt_writehdr("`tdir'/in.txt", "`of'")
    rc_eq, expect(0) msg("re-writing the header file does not r(602)")
end_case

* ------------------------------------------------------------------------------
* Command-level cases -- require jq+curl (the command's curl/jq preflight runs
* before the key check).
* ------------------------------------------------------------------------------
tempfile jqchk
quietly shell command -v jq > "`jqchk'" 2>/dev/null
tempname jh
file open `jh' using "`jqchk'", read text
file read `jh' jqline
local has_jq = (r(eof) == 0)
file close `jh'

if (`has_jq' == 0) {
    display as text _newline(1) "  (skipping translate_dta_labels command-level cases: jq not on PATH)"
}
else {
    start_case "translate_dta_labels: key read from .StataEnviron passes preflight"
        tempname eh
        file open `eh' using "`tdir'/.StataEnviron", write text replace
        file write `eh' "# project env" _n
        file write `eh' "FAKE_TRKEY=sk-test-not-a-real-key" _n
        file close `eh'
        capture translate_dta_labels, infile("`tdir'/in.txt") outfile("`tdir'/out.txt") ///
            keyvar(FAKE_TRKEY) envfile("`tdir'/.StataEnviron") dryrun
        rc_eq, expect(0) msg("dryrun succeeds when key is defined in .StataEnviron")
    end_case

    start_case "translate_dta_labels: quoted value in .StataEnviron is sourced"
        tempname eh2
        file open `eh2' using "`tdir'/.StataEnviron", write text replace
        file write `eh2' `"export FAKE_TRKEY="sk-quoted-value""' _n
        file close `eh2'
        capture translate_dta_labels, infile("`tdir'/in.txt") outfile("`tdir'/out.txt") ///
            keyvar(FAKE_TRKEY) envfile("`tdir'/.StataEnviron") dryrun
        rc_eq, expect(0) msg("dryrun succeeds with an exported, quoted key")
    end_case

    start_case "translate_dta_labels: missing key (not in env or file) errors 198"
        capture translate_dta_labels, infile("`tdir'/in.txt") outfile("`tdir'/out.txt") ///
            keyvar(FAKE_TRKEY_ABSENT) envfile("`tdir'/.StataEnviron") dryrun
        rc_eq, expect(198) msg("undefined key exits 198")
    end_case

    start_case "translate_dta_labels: no .StataEnviron and no env var errors 198"
        capture translate_dta_labels, infile("`tdir'/in.txt") outfile("`tdir'/out.txt") ///
            keyvar(FAKE_TRKEY_ABSENT) envfile("`tdir'/does_not_exist.env") dryrun
        rc_eq, expect(198) msg("absent env file + unset var exits 198")
    end_case

    * Full multi-chunk run. With a fake key every chunk returns non-200 (401
    * online, connection error offline), so the loop keeps the original lines
    * and must complete -- exercising _xlt_chunk on chunks 2+ where the r(602)
    * bug used to abort. Also overwrites a pre-existing output file.
    start_case "translate_dta_labels: multi-chunk loop completes and preserves originals"
        tempname mh
        file open `mh' using "`tdir'/multi.txt", write text replace
        file write `mh' "# header" _n
        forvalues k = 1/5 {
            file write `mh' "VARLBL|f.dta|v`k'|Une variable `k'" _n
        }
        file close `mh'
        tempname sh
        file open `sh' using "`tdir'/multi_out.txt", write text replace
        file write `sh' "STALE" _n
        file close `sh'
        tempname kh
        file open `kh' using "`tdir'/.StataEnviron", write text replace
        file write `kh' "FAKE_TRKEY=sk-not-a-real-key" _n
        file close `kh'
        capture translate_dta_labels, infile("`tdir'/multi.txt") outfile("`tdir'/multi_out.txt") ///
            keyvar(FAKE_TRKEY) envfile("`tdir'/.StataEnviron") chunksize(2)
        rc_eq, expect(0) msg("3-chunk run completes (no r(602) on chunk 2+)")
        mata: st_local("c", invtokens(cat("`tdir'/multi_out.txt")', " "))
        eq, expr(`"strpos("`c'", "STALE") == 0"')          msg("stale output was overwritten")
        eq, expr(`"strpos("`c'", "# header") > 0"')         msg("header preserved")
        eq, expr(`"strpos("`c'", "VARLBL|f.dta|v5") > 0"')  msg("all 5 original records kept")
    end_case
}
