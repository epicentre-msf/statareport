* ==============================================================================
* test_compute_ci.do -- verify compute_ci output on derived indicators from
* sysuse auto. compute_ci mirrors quant/qual: it writes a variable/label/value
* table to output(), supports method(), level(), format(), append, by(),
* addtotal and idstart.
* ==============================================================================

capture program drop _setup_ci
program _setup_ci
    sysuse auto, clear
    gen byte heavy      = weight > 3000 if !missing(weight)
    gen byte cheap      = price  < 5000 if !missing(price)
    gen byte foreigncar = foreign == 1
    label variable heavy      "Heavy car"
    label variable cheap      "Cheap car"
    label variable foreigncar "Foreign"
end

start_case "compute_ci: table structure & default exact interval"
    _setup_ci
    tempfile out
    compute_ci heavy cheap, output("`out'")
    use "`out'", clear
    eq, expr("_N == 2") msg("2 rows")
    * required output columns exist
    capture confirm variable variable
    eq, expr("_rc == 0") msg("variable column present")
    capture confirm variable label
    eq, expr("_rc == 0") msg("label column present")
    capture confirm variable value
    eq, expr("_rc == 0") msg("value column present")
    capture confirm variable id
    eq, expr("_rc == 0") msg("id column present")
    * one row per input variable, in order, with labels carried over
    eq, expr(`"variable[1] == "heavy""') msg("row 1 = heavy")
    eq, expr(`"label[1] == "Heavy car""') msg("row 1 label kept")
    eq, expr(`"variable[2] == "cheap""') msg("row 2 = cheap")
    * exact (Clopper-Pearson) cell contents
    substr_in, haystack(`"`=value[1]'"') needle("39 (52.70%), [40.75% - 64.43%]") msg("heavy exact CI")
    substr_in, haystack(`"`=value[2]'"') needle("37 (50.00%), [38.14% - 61.86%]") msg("cheap exact CI")
end_case

start_case "compute_ci: method() changes the interval"
    _setup_ci
    tempfile out
    compute_ci heavy, output("`out'") method(exact)
    use "`out'", clear
    local v_exact = value[1]
    _setup_ci
    compute_ci heavy, output("`out'") method(jeffreys)
    use "`out'", clear
    local v_jeff = value[1]
    eq, expr(`""`v_exact'" != "`v_jeff'""') msg("exact and jeffreys differ")
    * n and percent are method-independent; only the bounds move
    substr_in, haystack(`"`v_jeff'"') needle("39 (52.70%)") msg("jeffreys keeps n & percent")
end_case

start_case "compute_ci: level() changes the interval width"
    _setup_ci
    tempfile out
    compute_ci heavy, output("`out'") level(95)
    use "`out'", clear
    local v95 = value[1]
    _setup_ci
    compute_ci heavy, output("`out'") level(90)
    use "`out'", clear
    local v90 = value[1]
    eq, expr(`""`v95'" != "`v90'""') msg("90% and 95% intervals differ")
end_case

start_case "compute_ci: format() controls decimals"
    _setup_ci
    tempfile out
    compute_ci heavy, output("`out'") format(%5.1f)
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("39 (52.7%)") msg("one-decimal percent")
end_case

start_case "compute_ci: by(foreign) addtotal -- per-level + total columns"
    _setup_ci
    tempfile out
    compute_ci heavy cheap, output("`out'") by(foreign) addtotal
    use "`out'", clear
    eq, expr("_N == 2") msg("2 rows")
    * heavy: domestic / foreign / total
    substr_in, haystack(`"`=value_0[1]'"') needle("37 (71.15%), [56.92% - 82.87%]") msg("heavy Domestic CI")
    substr_in, haystack(`"`=value_1[1]'"') needle("2 (9.09%), [1.12% - 29.16%]")    msg("heavy Foreign CI")
    substr_in, haystack(`"`=value[1]'"')   needle("39 (52.70%), [40.75% - 64.43%]") msg("heavy Total CI")
    * cheap per-level
    substr_in, haystack(`"`=value_0[2]'"') needle("29 (55.77%)") msg("cheap Domestic CI")
    substr_in, haystack(`"`=value_1[2]'"') needle("8 (36.36%)")  msg("cheap Foreign CI")
    * column headers carry group label + N
    local l0 : variable label value_0
    substr_in, haystack(`"`l0'"') needle("Domestic") msg("value_0 header has group label")
    substr_in, haystack(`"`l0'"') needle("N = 52")   msg("value_0 header has group N")
    local l1 : variable label value_1
    substr_in, haystack(`"`l1'"') needle("Foreign") msg("value_1 header has group label")
    substr_in, haystack(`"`l1'"') needle("N = 22")  msg("value_1 header has group N")
    local lt : variable label value
    substr_in, haystack(`"`lt'"') needle("Total")  msg("total header label")
    substr_in, haystack(`"`lt'"') needle("N = 74") msg("total header N")
end_case

start_case "compute_ci: append continues the table"
    _setup_ci
    tempfile out
    compute_ci heavy cheap, output("`out'") idstart(1)
    _setup_ci
    compute_ci foreigncar, output("`out'") append idstart(3)
    use "`out'", clear
    eq, expr("_N == 3") msg("3 rows after append")
    eq, expr(`"variable[3] == "foreigncar""') msg("appended row is foreigncar")
    eq, expr(`"id[3] == "3""') msg("appended id continues at 3")
    substr_in, haystack(`"`=value[3]'"') needle("22 (29.73%)") msg("appended CI value")
end_case

start_case "compute_ci: idstart bumps ids"
    _setup_ci
    tempfile out
    compute_ci heavy cheap, output("`out'") idstart(50)
    use "`out'", clear
    eq, expr(`"id[1] == "50""') msg("first id = 50")
    eq, expr(`"id[2] == "51""') msg("second id = 51")
end_case

start_case "compute_ci: invalid input is rejected"
    _setup_ci
    tempfile out
    * non-binary variable
    capture compute_ci rep78, output("`out'")
    rc_eq, expect(7) msg("non-binary variable rejected")
    * unknown method
    capture compute_ci heavy, output("`out'") method(bogus)
    rc_eq, expect(198) msg("unknown method rejected")
    * append onto a file that does not exist
    capture compute_ci heavy, output("`=c(tmpdir)'/no_such_ci_file_xyz.dta") append
    rc_eq, expect(601) msg("append to missing file rejected")
    * output() is required
    capture compute_ci heavy
    rc_eq, expect(198) msg("missing output() rejected")
end_case
