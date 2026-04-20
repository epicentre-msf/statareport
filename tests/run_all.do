* ==============================================================================
* tests/run_all.do -- run the statareport test suite in batch mode.
*
*   cd <repo>/tests
*   /path/to/statabe -b do run_all.do
*
* Expected exit: log ends with "TOTAL PASSED" if all tests pass, else
* "TOTAL FAILED (<n>)" and the process exits with r(9).
* ==============================================================================

capture log close _all
log using run_all.log, replace text

* `clear all' can spuriously fail with r(101) when run_all.do is re-invoked
* from an interactive session that still has helper programs/frames loaded
* from the previous run. Fall back to piecewise clearing in that case —
* either route reaches a clean slate before the tests start.
capture clear all
if (_rc) {
    clear
    capture mata: mata clear
    capture program drop _all
}
set more off

* Resolve repo root from this file's directory and point Stata at the package.
local repo = subinstr("`c(pwd)'", "\", "/", .)
if (substr("`repo'", -6, 6) == "/tests") {
    local repo = substr("`repo'", 1, strlen("`repo'") - 6)
}
adopath ++ "`repo'/ado"
display as text "repo = `repo'"

do _helpers.do

local suites test_convert_wisely test_label_table test_statareport_set_paths test_quant test_qual test_kable_pipeline

foreach s of local suites {
    display as result _newline(1) "########## running `s' ##########"
    do `s'.do
}

display as result _newline(2) "================================================================"
if ($tests_failed == 0) {
    display as result "TOTAL PASSED: $tests_total assertions"
}
else {
    display as error  "TOTAL FAILED ($tests_failed / $tests_total)"
}
display as result "================================================================"

log close

if ($tests_failed > 0) {
    exit 9, clear
}
