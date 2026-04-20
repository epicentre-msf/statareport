* ==============================================================================
* test_quant.do -- verify quant output on sysuse auto against known values.
* ==============================================================================

start_case "quant: minimal, default format"
    sysuse auto, clear
    tempfile out
    quant price mpg weight, output("`out'")
    use "`out'", clear
    eq, expr("_N == 3") msg("3 rows for 3 variables")
    eq, expr(`"variable[1] == "price""')  msg("row 1 is price")
    eq, expr(`"variable[2] == "mpg""')    msg("row 2 is mpg")
    eq, expr(`"variable[3] == "weight""') msg("row 3 is weight")
    substr_in, haystack(`"`=value[1]'"') needle("74")     msg("price row has N=74")
    substr_in, haystack(`"`=value[1]'"') needle("5006.5") msg("price row has median 5006.5")
    substr_in, haystack(`"`=value[1]'"') needle("4195.0") msg("price row has p25 4195.0")
    substr_in, haystack(`"`=value[1]'"') needle("6342.0") msg("price row has p75 6342.0")
    substr_in, haystack(`"`=value[1]'"') needle("15906")  msg("price row has max 15906")
end_case

start_case "quant: by(foreign) addtotal, %9.0f -- exact cell contents"
    sysuse auto, clear
    tempfile out
    quant price mpg weight, output("`out'") by(foreign) addtotal format(%9.0f)
    use "`out'", clear
    eq, expr("_N == 3") msg("still 3 rows")
    substr_in, haystack(`"`=value_0[1]'"') needle("4782") msg("price Domestic median = 4782")
    substr_in, haystack(`"`=value_0[1]'"') needle("4184") msg("price Domestic p25 = 4184")
    substr_in, haystack(`"`=value_0[1]'"') needle("6234") msg("price Domestic p75 = 6234")
    substr_in, haystack(`"`=value_1[1]'"') needle("5759") msg("price Foreign median = 5759")
    substr_in, haystack(`"`=value_1[1]'"') needle("7140") msg("price Foreign p75 = 7140")
    substr_in, haystack(`"`=value[1]'"')   needle("74,")  msg("price Total has N=74 prefix")
    substr_in, haystack(`"`=value[1]'"')   needle("5006") msg("price Total median = 5006")
end_case

start_case "quant: meanonly -- `N, mean (SD)' layout"
    sysuse auto, clear
    tempfile out
    quant price mpg, output("`out'") meanonly
    use "`out'", clear
    eq, expr("_N == 2") msg("2 rows")
    substr_in, haystack(`"`=value[1]'"') needle("6165.3") msg("price mean = 6165.3")
    substr_in, haystack(`"`=value[1]'"') needle("2949.5") msg("price SD = 2949.5")
end_case

start_case "quant: sumonly by(foreign) addtotal"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") sumonly by(foreign) addtotal
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"')   needle("456229") msg("total sum = 456229")
    substr_in, haystack(`"`=value[1]'"')   needle("100.0")  msg("total percentage = 100")
    substr_in, haystack(`"`=value_0[1]'"') needle("69.2")   msg("Domestic share = 69.2%")
    substr_in, haystack(`"`=value_1[1]'"') needle("30.8")   msg("Foreign share = 30.8%")
end_case

start_case "quant: idstart() bumps the id column"
    sysuse auto, clear
    tempfile out
    quant price mpg, output("`out'") idstart(10)
    use "`out'", clear
    eq, expr(`"id[1] == "10""') msg("first id = 10")
    eq, expr(`"id[2] == "11""') msg("second id = 11")
end_case

start_case "quant: append two calls without id collision"
    sysuse auto, clear
    tempfile out
    quant price,  output("`out'") idstart(1)
    quant weight, output("`out'") append idstart(100)
    use "`out'", clear
    eq, expr("_N == 2") msg("2 rows after append")
    eq, expr(`"id[1] == "1""')   msg("row 1 id = 1")
    eq, expr(`"id[2] == "100""') msg("row 2 id = 100")
end_case
