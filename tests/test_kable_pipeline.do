* ==============================================================================
* test_kable_pipeline.do -- end-to-end smoke test:
*   sysuse auto -> quant+qual -> label_table -> save -> kable -> .md grid.
* ==============================================================================

start_case "end-to-end: mixed quant+qual produces a grid table with real headers"
    sysuse auto, clear
    gen heavy   = weight > 3000 if !missing(weight)
    gen cheap   = price  < 5000 if !missing(price)
    gen thirsty = mpg    < 20   if !missing(mpg)
    label var heavy   "Heavy"
    label var cheap   "Cheap"
    label var thirsty "Thirsty"

    tempfile out xlsx md
    quant price mpg weight,    output(`"`out'"') by(foreign) addtotal idstart(1)  format(%9.0f)
    qual  heavy cheap thirsty, output(`"`out'"') append by(foreign) addtotal idstart(10)

    clear
    set obs 6
    gen id = cond(_n <= 3, string(_n), string(_n + 6))
    gen str label = ""
    replace label = "Price"    if id == "1"
    replace label = "Mileage"  if id == "2"
    replace label = "Weight"   if id == "3"
    replace label = "Heavy"    if id == "10"
    replace label = "Cheap"    if id == "11"
    replace label = "Thirsty"  if id == "12"
    gen order = _n
    export excel using `"`xlsx'.xlsx"', sheet("mix") firstrow(variables) replace

    label_table, tab_file(`"`out'"') label_file(`"`xlsx'.xlsx"') tab_id("mix") ///
        label_name("Characteristic")
    save `"`out'"', replace
    use `"`out'"', clear
    capture noisily kable, caption("End-to-end") output(`"`md'"')
    rc_eq, expect(0) msg("kable returned rc=0")

    tempname fh
    file open `fh' using `"`md'"', read text
    local has_caption  = 0
    local has_grid_sep = 0
    local saw_price    = 0
    local saw_thirsty  = 0
    local saw_bt_hdr   = 0
    file read `fh' line
    while (r(eof) == 0) {
        local L `"`macval(line)'"'
        if (strpos(`"`L'"', "Table: End-to-end") > 0) local has_caption = 1
        if (strpos(`"`L'"', "+========")          > 0) local has_grid_sep = 1
        if (strpos(`"`L'"', "+:=======")          > 0) local has_grid_sep = 1
        if (strpos(`"`L'"', "Price")              > 0) local saw_price = 1
        if (strpos(`"`L'"', "Thirsty")            > 0) local saw_thirsty = 1
        if (regexm(`"`L'"', "^\|[ ]+` +\|"))           local saw_bt_hdr = 1
        file read `fh' line
    }
    file close `fh'

    eq, expr("`has_caption'  == 1") msg("caption present")
    eq, expr("`has_grid_sep' == 1") msg("grid alignment row present")
    eq, expr("`saw_price'    == 1") msg("Price row rendered")
    eq, expr("`saw_thirsty'  == 1") msg("Thirsty row rendered")
    eq, expr("`saw_bt_hdr'   == 0") msg("no corrupted backtick header")
end_case

start_case "end-to-end: verified numeric cells round-trip through kable"
    sysuse auto, clear
    tempfile out xlsx md
    quant price, output(`"`out'"') by(foreign) addtotal format(%9.0f)

    clear
    set obs 1
    gen id = "1"
    gen label = "Price"
    gen order = 1
    export excel using `"`xlsx'.xlsx"', sheet("P") firstrow(variables) replace

    label_table, tab_file(`"`out'"') label_file(`"`xlsx'.xlsx"') tab_id("P") ///
        label_name("Characteristic")
    save `"`out'"', replace
    use `"`out'"', clear
    kable, caption("P") output(`"`md'"')

    tempname fh
    local has_4782 = 0
    local has_5759 = 0
    local has_74   = 0
    file open `fh' using `"`md'"', read text
    file read `fh' line
    while (r(eof) == 0) {
        if (strpos(`"`macval(line)'"', "4782")  > 0) local has_4782 = 1
        if (strpos(`"`macval(line)'"', "5759")  > 0) local has_5759 = 1
        if (strpos(`"`macval(line)'"', "74,")   > 0) local has_74   = 1
        file read `fh' line
    }
    file close `fh'

    eq, expr("`has_4782' == 1") msg("rendered table includes Domestic median 4782")
    eq, expr("`has_5759' == 1") msg("rendered table includes Foreign  median 5759")
    eq, expr("`has_74'   == 1") msg("rendered table includes Total N=74 prefix")
end_case
