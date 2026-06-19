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
    substr_in, haystack(`"`=value[1]'"') needle("74")      msg("price row has N=74")
    * Default median/min-max now use price's own display format (%8.0gc), so the
    * values are comma-grouped -- mean (not shown here) would still be %9.1f.
    substr_in, haystack(`"`=value[1]'"') needle("5,006.5") msg("median in price's %8.0gc format (5,006.5)")
    substr_in, haystack(`"`=value[1]'"') needle("4,195")   msg("p25 in price's %8.0gc format (4,195)")
    substr_in, haystack(`"`=value[1]'"') needle("6,342")   msg("p75 in price's %8.0gc format (6,342)")
    substr_in, haystack(`"`=value[1]'"') needle("15,906")  msg("max in price's %8.0gc format (15,906)")
    * mpg has a plain %8.0g format (no comma grouping)
    substr_in, haystack(`"`=value[2]'"') needle("18 ; 25") msg("mpg IQR in mpg's %8.0g format (18 ; 25)")
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

start_case "quant: verticallayout -- N, mean (SD), median [IQR], (min/max) stacked"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") verticallayout
    use "`out'", clear
    eq, expr("_N == 1") msg("1 row")
    substr_in, haystack(`"`=value[1]'"') needle("74")      msg("vertical has N=74")
    * mean/SD keep the %9.1f default; median/IQR/min-max use price's %8.0gc format
    substr_in, haystack(`"`=value[1]'"') needle("6165.3")  msg("vertical has mean 6165.3 (%9.1f)")
    substr_in, haystack(`"`=value[1]'"') needle("2949.5")  msg("vertical has SD 2949.5 (%9.1f)")
    substr_in, haystack(`"`=value[1]'"') needle("5,006.5") msg("vertical has median 5,006.5 (price's %8.0gc)")
    substr_in, haystack(`"`=value[1]'"') needle("4,195")   msg("vertical has p25 4,195 (price's %8.0gc)")
    substr_in, haystack(`"`=value[1]'"') needle("6,342")   msg("vertical has p75 6,342 (price's %8.0gc)")
    substr_in, haystack(`"`=value[1]'"') needle("15,906")  msg("vertical has max 15,906 (price's %8.0gc)")
    substr_in, haystack(`"`=value[1]'"') needle("\n")     msg("vertical uses \n line breaks between stats")
    eq, expr(`"substr(`"`=value[1]'"', 1, 10) == "VBLANKLINE""') msg("cell leads with the VBLANKLINE sentinel (rendered as a leading blank line)")
end_case

start_case "quant: verticallayout noline -- no leading-blank sentinel"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") verticallayout noline
    use "`out'", clear
    eq, expr(`"strpos(`"`=value[1]'"', "VBLANKLINE") == 0"') msg("noline omits the VBLANKLINE sentinel")
    eq, expr(`"substr(`"`=value[1]'"', 1, 2) == "74""')      msg("cell starts straight at N under noline")
    substr_in, haystack(`"`=value[1]'"') needle("\n")        msg("noline still stacks stats with \n breaks")
    substr_in, haystack(`"`=value[1]'"') needle("5,006.5")   msg("noline still has median (price's %8.0gc)")
end_case

start_case "quant: verti abbreviation works"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") verti
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("6165.3") msg("verti abbrev has mean")
end_case

start_case "quant: per-statistic formats override the global format"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") verticallayout meanformat(%9.3f) medformat(%9.2f) mxformat(%9.0f)
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("6165.257")        msg("meanformat -> mean at %9.3f")
    substr_in, haystack(`"`=value[1]'"') needle("2949.496")        msg("meanformat -> SD at %9.3f")
    substr_in, haystack(`"`=value[1]'"') needle("5006.50")         msg("medformat -> median at %9.2f")
    substr_in, haystack(`"`=value[1]'"') needle("4195.00")         msg("medformat -> p25 at %9.2f")
    substr_in, haystack(`"`=value[1]'"') needle("6342.00")         msg("medformat -> p75 at %9.2f")
    substr_in, haystack(`"`=value[1]'"') needle("(3291 / 15906)")  msg("mxformat -> min/max at %9.0f")
end_case

start_case "quant: a specific format takes precedence; unset ones fall back to global"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") format(%9.0f) medformat(%9.2f)
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("5006.50")         msg("medformat overrides the global %9.0f")
    substr_in, haystack(`"`=value[1]'"') needle("(3291 / 15906)")  msg("min/max fall back to the global %9.0f")
end_case

start_case "quant: meanformat overrides the default global format"
    sysuse auto, clear
    tempfile out
    quant price, output("`out'") meanonly meanformat(%9.3f)
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("6165.257") msg("meanonly mean at meanformat %9.3f")
    substr_in, haystack(`"`=value[1]'"') needle("2949.496") msg("meanonly SD at meanformat %9.3f")
end_case

start_case "quant: default median/min-max take the variable's own format; mean stays %9.1f"
    * A controlled variable with a %9.3f display format isolates the new default
    * (no auto %8.0gc comma noise). median/IQR/min-max should show 3 decimals;
    * the mean must still use the %9.1f default, not the variable's format.
    clear
    set obs 5
    gen v = _n          // 1..5 -> median 3, p25 2, p75 4, min 1, max 5
    format v %9.3f
    tempfile out
    quant v, output("`out'")
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("3.000") msg("default median uses v's %9.3f format (3.000)")
    substr_in, haystack(`"`=value[1]'"') needle("2.000 ; 4.000") msg("default IQR uses v's %9.3f format")
    substr_in, haystack(`"`=value[1]'"') needle("(1.000 / 5.000)") msg("default min/max use v's %9.3f format")

    * Rebuild v (the output dataset just loaded has no `v', and `value'/`variable'
    * would make `quant v' an ambiguous abbreviation).
    clear
    set obs 5
    gen v = _n
    format v %9.3f
    quant v, output("`out'") meanonly
    use "`out'", clear
    substr_in, haystack(`"`=value[1]'"') needle("3.0")           msg("default mean uses the %9.1f default (3.0)")
    eq, expr(`"strpos(`"`=value[1]'"', "3.000") == 0"')          msg("mean is NOT in the variable's %9.3f format")
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
