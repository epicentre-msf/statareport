* ==============================================================================
* test_convert_wisely.do -- regression tests for convert_wisely.
*
* Past bugs this guards against:
*   (1) `format `v' %-s' raised "invalid %format" for string variables.
*   (2) Re-setting note1 via compound quotes stored the literal backtick and
*       quote tokens in the note, corrupting kable column headers.
* ==============================================================================

start_case "convert_wisely: runs without r(120) (invalid %format)"
    clear
    set obs 3
    gen str name = cond(_n == 1, "alpha", cond(_n == 2, "beta", "gamma"))
    gen x = _n
    label variable x "The X"
    note x: COLHDR
    capture noisily convert_wisely name x
    rc_eq, expect(0) msg("convert_wisely returns rc=0")
end_case

start_case "convert_wisely: note1 survives unchanged (round-trip)"
    clear
    set obs 2
    gen y = _n
    note y: MY_HEADER
    convert_wisely y
    local n1 : char y[note1]
    streq, left(`"`n1'"') right(`"MY_HEADER"') msg("note1 = MY_HEADER after convert_wisely")
end_case

start_case "convert_wisely: fills note1 from variable label when no note set"
    clear
    set obs 2
    gen z = _n
    label variable z "ZLBL"
    convert_wisely z
    local n1 : char z[note1]
    streq, left(`"`n1'"') right(`"ZLBL"') msg("note1 falls back to variable label")
end_case

start_case "convert_wisely: kable header is the note, not a backtick"
    * End-to-end: after the full quant -> label_table -> save -> kable path,
    * the first kable header must be the label_name(), not a backtick/empty.
    sysuse auto, clear
    tempfile out xlsx md
    quant price mpg, output(`"`out'"')

    clear
    set obs 2
    gen id = string(_n)
    gen str label = cond(_n == 1, "Price", "Mileage (mpg)")
    gen order = _n
    export excel using `"`xlsx'.xlsx"', sheet("S") firstrow(variables) replace

    label_table, tab_file(`"`out'"') label_file(`"`xlsx'.xlsx"') tab_id("S") ///
        label_name("Characteristic") value_name("Total")
    save `"`out'"', replace
    use `"`out'"', clear
    kable, caption("X") output(`"`md'"')

    * Read the rendered file and check the header row.
    tempname fh
    local found = 0
    local saw_backtick_header = 0
    file open `fh' using `"`md'"', read text
    file read `fh' line
    while (r(eof) == 0) {
        if (strpos(`"`macval(line)'"', "Characteristic") > 0) local found = 1
        if (regexm(`"`macval(line)'"', "^\|[ ]+` +\|")) local saw_backtick_header = 1
        file read `fh' line
    }
    file close `fh'
    eq, expr("`found' == 1")              msg("kable output contains 'Characteristic' header")
    eq, expr("`saw_backtick_header' == 0") msg("no backtick-only header row in kable output")
end_case
