* ==============================================================================
* tests/_helpers.do -- assertion helpers for the statareport test suite.
*
* All helpers take options to avoid Stata's tokenizer eating quoted payloads.
*
*   eq,  expr("_N == 3") msg("three rows")
*   streq, left("a") right("a") msg("strings equal")
*   substr_in, haystack("xyz") needle("y") msg("y is in xyz")
*   rc_eq, expect(601) msg("...")      // checks _rc from the preceding capture
*
* To test that a command errors:
*   capture somecommand
*   rc_eq, expect(601) msg("somecommand errors with 601")
*
* Counters: $tests_total, $tests_failed, $tests_case_failed.
* ==============================================================================

global tests_total       0
global tests_failed      0
global tests_case_failed 0

capture program drop eq
program define eq
    syntax , expr(string) msg(string)
    global tests_total = $tests_total + 1
    capture assert `expr'
    if (_rc) {
        global tests_failed      = $tests_failed      + 1
        global tests_case_failed = $tests_case_failed + 1
        display as error `"  FAIL: `msg'  [assert `expr' -> rc=`=_rc']"'
    }
    else {
        display as text  "    ok: `msg'"
    }
end

capture program drop streq
program define streq
    syntax , left(string) right(string) msg(string)
    global tests_total = $tests_total + 1
    if (`"`left'"' == `"`right'"') {
        display as text "    ok: `msg'"
    }
    else {
        global tests_failed      = $tests_failed      + 1
        global tests_case_failed = $tests_case_failed + 1
        display as error `"  FAIL: `msg'  [got {`left'} expected {`right'}]"'
    }
end

capture program drop substr_in
program define substr_in
    syntax , haystack(string) needle(string) msg(string)
    global tests_total = $tests_total + 1
    if (strpos(`"`haystack'"', `"`needle'"') > 0) {
        display as text "    ok: `msg'"
    }
    else {
        global tests_failed      = $tests_failed      + 1
        global tests_case_failed = $tests_case_failed + 1
        display as error `"  FAIL: `msg'  [did not find {`needle'} in {`haystack'}]"'
    }
end

capture program drop rc_eq
program define rc_eq
    * Reads the caller's _rc (already captured) and compares to expect.
    * The caller is expected to wrap the test command with `capture'.
    syntax , expect(integer) msg(string)
    local got = _rc
    global tests_total = $tests_total + 1
    if (`got' == `expect') {
        display as text "    ok: `msg'  [rc=`got']"
    }
    else {
        global tests_failed      = $tests_failed      + 1
        global tests_case_failed = $tests_case_failed + 1
        display as error "  FAIL: `msg'  [rc=`got', expected `expect']"
    }
end

capture program drop start_case
program define start_case
    args name
    global tests_case_failed = 0
    display as result _newline(1) "=== `name' ==="
end

capture program drop end_case
program define end_case
    if ($tests_case_failed == 0) {
        display as result "--- PASSED ---"
    }
    else {
        display as error "--- FAILED ($tests_case_failed) ---"
    }
end
