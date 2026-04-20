/*
Add percentage annotations to numeric count variables.

For each variable in `varlist`, the program replaces the variable with a
string of the form "count (percent)" where the percent is computed against a
user-supplied denominator. If no denominator is supplied, the command uses the
sample size of the filtered dataset.

Options
-------
- denominators(): numlist of positive denominators. Provide one value to reuse
  for all variables, or one value per variable in `varlist`.
- form(): numeric display format for percents. Defaults to "%9.1f".

Notes
-----
- The original numeric variables are replaced by strings. Run the command on a
  copy of the data if you still need the raw counts afterwards.
*/

capture program drop add_perc
program add_perc
    version 15
    syntax varlist(min=1 numeric) [if], [DENOMinators(numlist >0) FORM(string)]

    marksample touse, novarlist

    quietly count if `touse'
    if (r(N) == 0) {
        display as error "add_perc: no observations in sample"
        exit 2000
    }

    if ("`form'" == "") local form "%9.1f"

    local nbvar : word count `varlist'

    // Build the denominator list -------------------------------------------------
    local nbdenom : word count `denominators'
    if ("`denominators'" == "") {
        local denominators `r(N)'
        local nbdenom 1
    }

    if (`nbdenom' != 1 & `nbdenom' != `nbvar') {
        display as error "add_perc: denominators must be one value or match the number of variables"
        exit 3
    }

    local idx = 0
    foreach d of numlist `denominators' {
        local ++idx
        if (`d' <= 0) {
            display as error "add_perc: denominator `d' must be strictly positive"
            exit 3
        }
        local denom`idx' = `d'
    }

    if (`nbdenom' == 1) {
        forvalues i = 2/`nbvar' {
            local denom`i' = `denom1'
        }
    }

    // Transform each variable ----------------------------------------------------
    local i = 0
    foreach v of local varlist {
        local ++i
        local vlabel : variable label `v'
        local vnote1 "``v'[note1]'"

        tempvar base perc numtxt perctxt result
        gen double `base' = `v'
        quietly replace `base' = 0 if missing(`base') & `touse'

        gen double `perc' = .
        quietly replace `perc' = 100 * `base' / `denom`i'' if `touse'

        gen str40 `numtxt' = trim(string(`base', "%9.0g"))
        quietly replace `numtxt' = "0" if `touse' & (`numtxt' == "" | `numtxt' == ".")
        quietly replace `numtxt' = trim(string(`v', "%9.0g")) if !`touse'

        gen str40 `perctxt' = ""
        quietly replace `perctxt' = trim(string(`perc', "`form'")) if !missing(`perc')

        gen str80 `result' = `numtxt', before(`v')
        quietly replace `result' = trim(`result') + " (" + `perctxt' + ")" if `touse' & `perctxt' != ""

        drop `v'
        rename `result' `v'
        format `v' %-s

        if ("`vlabel'" != "") {
            label variable `v' "`vlabel'"
        }
        if ("`vnote1'" != "") {
            note `v': `"`vnote1'"'
        }

        drop `base' `perc' `numtxt' `perctxt'
    }
end
