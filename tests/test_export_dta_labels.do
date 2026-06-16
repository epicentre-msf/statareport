* ==============================================================================
* test_export_dta_labels.do -- verify export_dta_labels folder scan and the
* pattern() glob filter.
* ==============================================================================

* ------------------------------------------------------------------------------
* Build a throwaway folder of labelled .dta files in Stata's temp area.
* ------------------------------------------------------------------------------
local tdir "`c(tmpdir)'/sr_export_test"
capture mkdir "`tdir'"
* start from a clean slate (idempotent across re-runs)
local old : dir "`tdir'" files "*"
foreach f of local old {
    capture erase "`tdir'/`f'"
}

foreach nm in survey_a survey_b census_x {
    clear
    set obs 3
    gen x = _n
    label data "dataset `nm'"
    label variable x "x in `nm'"
    quietly save "`tdir'/`nm'.dta", replace
}

start_case "export_dta_labels: default pattern picks up every .dta"
    export_dta_labels, folder("`tdir'") outfile("`tdir'/all.txt")
    mata: st_local("c", invtokens(cat("`tdir'/all.txt")', " "))
    eq, expr(`"strpos("`c'", "FILE|survey_a.dta") > 0"') msg("survey_a included")
    eq, expr(`"strpos("`c'", "FILE|survey_b.dta") > 0"') msg("survey_b included")
    eq, expr(`"strpos("`c'", "FILE|census_x.dta") > 0"') msg("census_x included")
end_case

start_case "export_dta_labels: pattern() restricts to a prefix glob"
    export_dta_labels, folder("`tdir'") pattern("survey_*.dta") outfile("`tdir'/sv.txt")
    mata: st_local("c", invtokens(cat("`tdir'/sv.txt")', " "))
    eq, expr(`"strpos("`c'", "FILE|survey_a.dta") > 0"')  msg("survey_a included")
    eq, expr(`"strpos("`c'", "FILE|survey_b.dta") > 0"')  msg("survey_b included")
    eq, expr(`"strpos("`c'", "FILE|census_x.dta") == 0"') msg("census_x excluded by survey_ glob")
end_case

start_case "export_dta_labels: multiple space-separated globs, deduped union"
    export_dta_labels, folder("`tdir'") pattern("survey_a.dta census_x.dta") outfile("`tdir'/mix.txt")
    mata: st_local("c", invtokens(cat("`tdir'/mix.txt")', " "))
    eq, expr(`"strpos("`c'", "FILE|survey_a.dta") > 0"')  msg("survey_a included")
    eq, expr(`"strpos("`c'", "FILE|census_x.dta") > 0"')  msg("census_x included")
    eq, expr(`"strpos("`c'", "FILE|survey_b.dta") == 0"') msg("survey_b excluded")
end_case

start_case "export_dta_labels: no match errors 601"
    capture export_dta_labels, folder("`tdir'") pattern("nomatch_*.dta") outfile("`tdir'/none.txt")
    rc_eq, expect(601) msg("no matching files exits 601")
end_case
