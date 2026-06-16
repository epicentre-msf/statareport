* ==============================================================================
* test_translate_dta_labels.do -- exercise the API-key preflight and the
* .StataEnviron sourcing path. These cases NEVER call the API: they use a fake
* keyvar() plus dryrun so only key resolution is tested. Requires jq+curl on
* PATH (the command's own preflight); the whole file is skipped otherwise.
* ==============================================================================

* Is jq available? (command's curl/jq preflight runs before the key check.)
tempfile jqchk
quietly shell command -v jq > "`jqchk'" 2>/dev/null
tempname jh
file open `jh' using "`jqchk'", read text
file read `jh' jqline
local has_jq = (r(eof) == 0)
file close `jh'

if (`has_jq' == 0) {
    display as text _newline(1) "  (skipping test_translate_dta_labels: jq not on PATH)"
}
else {
    * throwaway project dir with a minimal export-format input file
    local tdir "`c(tmpdir)'/sr_translate_test"
    capture mkdir "`tdir'"
    tempname ih
    file open `ih' using "`tdir'/in.txt", write text replace
    file write `ih' "# header line, copied verbatim" _n
    file write `ih' "DTALBL|test.dta|Une etiquette de jeu de donnees" _n
    file close `ih'

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
}
