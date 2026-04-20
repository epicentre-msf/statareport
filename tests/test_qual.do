* ==============================================================================
* test_qual.do -- verify qual output on derived indicators from sysuse auto.
* ==============================================================================

capture program drop _setup_qual
program _setup_qual
    sysuse auto, clear
    gen heavy   = weight > 3000 if !missing(weight)
    gen cheap   = price  < 5000 if !missing(price)
    gen thirsty = mpg    < 20   if !missing(mpg)
end

start_case "qual: minimal counts & percentages"
    _setup_qual
    tempfile out
    qual heavy cheap thirsty, output("`out'")
    use "`out'", clear
    eq, expr("_N == 3") msg("3 rows")
    substr_in, haystack(`"`=value[1]'"') needle("39 (52.7)") msg("heavy   = 39 (52.7)")
    substr_in, haystack(`"`=value[2]'"') needle("37 (50.0)") msg("cheap   = 37 (50.0)")
    substr_in, haystack(`"`=value[3]'"') needle("35 (47.3)") msg("thirsty = 35 (47.3)")
end_case

start_case "qual: by(foreign) addtotal -- row totals add up"
    _setup_qual
    tempfile out
    qual heavy cheap thirsty, output("`out'") by(foreign) addtotal
    use "`out'", clear
    eq, expr("_N == 3") msg("3 rows")
    substr_in, haystack(`"`=value_0[1]'"') needle("37 (71.2)") msg("heavy   Dom = 37 (71.2)")
    substr_in, haystack(`"`=value_1[1]'"') needle("2 (9.1)")   msg("heavy   For = 2 (9.1)")
    substr_in, haystack(`"`=value[1]'"')   needle("39 (52.7)") msg("heavy   Tot = 39 (52.7)")
    substr_in, haystack(`"`=value_0[2]'"') needle("29 (55.8)") msg("cheap   Dom = 29 (55.8)")
    substr_in, haystack(`"`=value_1[2]'"') needle("8 (36.4)")  msg("cheap   For = 8 (36.4)")
    substr_in, haystack(`"`=value_0[3]'"') needle("30 (57.7)") msg("thirsty Dom = 30 (57.7)")
    substr_in, haystack(`"`=value_1[3]'"') needle("5 (22.7)")  msg("thirsty For = 5 (22.7)")
end_case

start_case "qual: pct(row) with binary indicators"
    _setup_qual
    tempfile out
    qual heavy cheap thirsty, output("`out'") by(foreign) pct(row) addtotal
    use "`out'", clear
    substr_in, haystack(`"`=value_0[1]'"') needle("94.9")  msg("heavy Dom row% = 94.9")
    substr_in, haystack(`"`=value_1[1]'"') needle("5.1")   msg("heavy For row% = 5.1")
    substr_in, haystack(`"`=value[1]'"')   needle("100.0") msg("heavy Tot row% = 100.0")
end_case

start_case "qual: pct(row) rejects non-binary input"
    _setup_qual
    tempfile out
    gen rep = rep78
    capture qual rep, output("`out'") by(foreign) pct(row)
    rc_eq, expect(459) msg("non-binary rep78 rejected under pct(row)")
end_case

start_case "qual: idstart bumps ids"
    _setup_qual
    tempfile out
    qual heavy cheap, output("`out'") idstart(50)
    use "`out'", clear
    eq, expr(`"id[1] == "50""') msg("first id = 50")
    eq, expr(`"id[2] == "51""') msg("second id = 51")
end_case
