/*
Compute binomial confidence intervals for indicator variables.

Creates a string variable named `tab_<varname>' containing
"n (percent%), [lower% - upper%]" using exact (Clopper-Pearson) confidence
intervals.
*/

capture program drop compute_ci
program compute_ci
    version 15
    syntax varname [if], [LEVel(numlist >0 max=1) FORMAT(string) REPLACE]

    marksample touse, novarlist

    if ("`level'" == "") local level 95
    if (`level' <= 0 | `level' >= 100) {
        display as error "compute_ci: level must be between 0 and 100"
        exit 198
    }

    if ("`format'" == "") local format "%9.2f"

    quietly count if `touse'
    local N = r(N)
    if (`N' == 0) {
        display as error "compute_ci: no observations in sample"
        exit 2000
    }

    quietly count if !missing(`varlist') & !inlist(`varlist', 0, 1) & `touse'
    if (r(N) > 0) {
        display as error "compute_ci: variable must be coded 0/1 (or missing)"
        exit 7
    }

    quietly count if `varlist' == 1 & `touse'
    local n = r(N)

    quietly ci proportions `varlist' if `touse', exact level(`level')

    local lb = 100 * r(lb)
    local ub = 100 * r(ub)
    local perc = 100 * `n' / `N'

    local n_str    = strtrim(string(`n', "%9.0g"))
    local perc_str = strtrim(string(`perc', "`format'")) + "%"
    local lb_str   = strtrim(string(`lb', "`format'")) + "%"
    local ub_str   = strtrim(string(`ub', "`format'")) + "%"

    local varname : word 1 of `varlist'
    local outvar = "tab_`varname'"

    capture confirm new variable `outvar'
    if (_rc & "`replace'" == "") {
        display as error "compute_ci: variable `outvar' already exists. Use option replace to overwrite."
        exit 110
    }
    if (_rc) {
        capture drop `outvar'
    }

    gen str70 `outvar' = "`n_str' (`perc_str'), [`lb_str' - `ub_str']"
    label variable `outvar' "`varname': exact `level'% CI"
end
