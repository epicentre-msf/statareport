* ==============================================================================
* test_label_table.do -- label_table covers:
*   - merges labels from Excel sheet keyed on id
*   - drops rows whose Excel `order' cell is blank (numeric missing or "")
*   - sorts by `order' ascending
*   - attaches label_name() / value_name() as notes for kable headers
* ==============================================================================

capture program drop _write_qual_dta
program _write_qual_dta
    args path
    sysuse auto, clear
    gen heavy   = weight > 3000 if !missing(weight)
    gen cheap   = price  < 5000 if !missing(price)
    gen thirsty = mpg    < 20   if !missing(mpg)
    label var heavy   "Heavy"
    label var cheap   "Cheap"
    label var thirsty "Thirsty"
    qual heavy cheap thirsty, output(`"`path'"')
end

start_case "label_table: basic merge, sort by order, keep only label+value"
    tempfile dta xlsx
    _write_qual_dta `"`dta'"'
    clear
    set obs 3
    gen id = string(_n)
    gen str label = ""
    replace label = "LBL_HEAVY"   if id == "1"
    replace label = "LBL_CHEAP"   if id == "2"
    replace label = "LBL_THIRSTY" if id == "3"
    gen order = .
    replace order = 3 if id == "1"
    replace order = 1 if id == "2"
    replace order = 2 if id == "3"
    export excel using `"`xlsx'.xlsx"', sheet("S1") firstrow(variables) replace

    label_table, tab_file(`"`dta'"') label_file(`"`xlsx'.xlsx"') tab_id("S1") ///
        label_name("HEADER") value_name("VALHEADER")

    quietly ds
    local vars `r(varlist)'
    local nvars : word count `vars'
    eq, expr("`nvars' == 2") msg("only 2 columns remain")
    substr_in, haystack(`"`vars'"') needle("label") msg("label present")
    substr_in, haystack(`"`vars'"') needle("value") msg("value present")

    eq, expr("_N == 3") msg("3 rows after merge")
    eq, expr(`"label[1] == "LBL_CHEAP""')   msg("row 1 is LBL_CHEAP (order=1)")
    eq, expr(`"label[2] == "LBL_THIRSTY""') msg("row 2 is LBL_THIRSTY (order=2)")
    eq, expr(`"label[3] == "LBL_HEAVY""')   msg("row 3 is LBL_HEAVY (order=3)")

    local n1 : char label[note1]
    streq, left(`"`n1'"') right(`"HEADER"')    msg("label note1 = label_name()")
    local n2 : char value[note1]
    streq, left(`"`n2'"') right(`"VALHEADER"') msg("value note1 = value_name()")
end_case

start_case "label_table: blank numeric order drops the row"
    tempfile dta xlsx
    _write_qual_dta `"`dta'"'
    clear
    set obs 3
    gen id = string(_n)
    gen str label = ""
    replace label = "HEAVY"   if id == "1"
    replace label = "CHEAP"   if id == "2"
    replace label = "THIRSTY" if id == "3"
    gen order = .
    replace order = 1 if id == "1"
    replace order = 2 if id == "3"
    export excel using `"`xlsx'.xlsx"', sheet("S2") firstrow(variables) replace

    label_table, tab_file(`"`dta'"') label_file(`"`xlsx'.xlsx"') tab_id("S2") ///
        label_name("HEADER")

    eq, expr("_N == 2")                  msg("cheap dropped (blank order)")
    eq, expr(`"label[1] == "HEAVY""')    msg("HEAVY survives")
    eq, expr(`"label[2] == "THIRSTY""')  msg("THIRSTY survives")
end_case

start_case "label_table: blank string order drops the row"
    tempfile dta xlsx
    _write_qual_dta `"`dta'"'
    clear
    set obs 3
    gen id = string(_n)
    gen str label = ""
    replace label = "HEAVY"   if id == "1"
    replace label = "CHEAP"   if id == "2"
    replace label = "THIRSTY" if id == "3"
    gen str order = ""
    replace order = "1" if id == "1"
    replace order = ""  if id == "2"
    replace order = "2" if id == "3"
    export excel using `"`xlsx'.xlsx"', sheet("S3") firstrow(variables) replace

    label_table, tab_file(`"`dta'"') label_file(`"`xlsx'.xlsx"') tab_id("S3") ///
        label_name("HEADER")

    eq, expr("_N == 2")                  msg("blank string order drops the row")
    eq, expr(`"label[1] == "HEAVY""')    msg("HEAVY first")
    eq, expr(`"label[2] == "THIRSTY""')  msg("THIRSTY second")
end_case

start_case "label_table: errors on missing tab_file"
    tempfile xlsx
    clear
    set obs 1
    gen id = "1"
    gen label = "x"
    export excel using `"`xlsx'.xlsx"', sheet("S") firstrow(variables) replace
    capture label_table, tab_file("nonexistent.dta") label_file(`"`xlsx'.xlsx"') tab_id("S")
    rc_eq, expect(601) msg("missing tab_file -> error 601")
end_case
