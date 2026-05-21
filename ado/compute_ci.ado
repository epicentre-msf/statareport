/*
				Binomial confidence intervals for indicator variables
================================================================================

This program computes binomial confidence intervals for one or more 0/1
indicator variables and writes the result to an output dataset, following the
same workflow as {help quant} and {help qual}: one row per variable with the
columns {cmd:variable}, {cmd:label} and {cmd:value}, ready for
{help label_table}/{help kable}. The output dataset is required and the result
can be appended to an existing table.

Each {cmd:value} cell takes the form {it:n (percent%), [lower% - upper%]}.

Parameters:
============

output : output dataset for the table (required).
method : interval method, mirroring {cmd:ci proportions} (default {cmd:exact}):
         exact (Clopper-Pearson), wald, wilson, agresti, jeffreys.
level  : confidence level in percent (default 95).
format : display format for percentages (default %9.2f).
append : if the output file exists, append this table to the previous data.
by     : compute confidence intervals within each level of a categorical
         variable (one value column per level).
addtotal : with by(), also add an overall (Total) column.
idstart  : first row id (default 1).

Examples:
===========

sysuse auto, clear
gen byte heavy = weight > 3000 if !missing(weight)
gen byte cheap = price  < 5000 if !missing(price)
label variable heavy "Heavy"
label variable cheap "Cheap"
compute_ci heavy cheap, output("ci.dta") method(jeffreys)
compute_ci heavy cheap, output("ci.dta") by(foreign) addtotal

*/


capture program drop compute_ci
program compute_ci
	version 15
	syntax varlist(min=1) [if] , OUTput(string) ///
		[METHod(string) LEVel(numlist >0 max=1) FORMat(string) ///
		 append BY(varlist max=1) ADDTOTal IDStart(integer 1)]

	marksample touse, novarlist
	local ci_varlist "`varlist'"

	// interval method --------------------------------------------------------
	if ("`method'" == "") local method "exact"
	local method = strtrim(strlower("`method'"))
	if (!inlist("`method'", "exact", "wald", "wilson", "agresti", "jeffreys")) {
		display as error ///
			"compute_ci: method() must be exact, wald, wilson, agresti, or jeffreys"
		exit 198
	}

	// confidence level -------------------------------------------------------
	if ("`level'" == "") local level 95
	if (`level' <= 0 | `level' >= 100) {
		display as error "compute_ci: level must be between 0 and 100"
		exit 198
	}

	// percentage display format ----------------------------------------------
	if ("`format'" == "") local format "%9.2f"

	// first row id -----------------------------------------------------------
	if (`idstart' < 1) {
		display as error "Start ids must be an integer (>= 1), IDStart = `idstart' is not"
		exit 1
	}

	// every variable must be a 0/1 indicator ---------------------------------
	foreach v of varlist `varlist' {
		quietly count if !missing(`v') & !inlist(`v', 0, 1) & `touse'
		if (r(N) > 0) {
			display as error "compute_ci: `v' must be coded 0/1 (or missing)"
			exit 7
		}
	}

	quietly count if `touse'
	local N = r(N)
	if (`N' == 0) {
		display as error "compute_ci: no observations in sample"
		exit 2000
	}

	// output of the temporary file
	tempfile postoutput

	if ("`append'" != "") {
		confirm file "`output'"
	}

	// ---- by() : one confidence-interval column per level -------------------
	if ("`by'" != "") {
		local labname : value label `by'
		if ("`labname'" == "") {
			display "`by' is not a categorical variable"
			exit 1
		}

		levelsof `by', local(levels)
		local counter = 0

		foreach L of local levels {
			local ++counter
			tempfile postoutput`L'
			tempname posthandle
			quietly postfile `posthandle' str32 variable str2045 label str2045 value_`L' using "`postoutput'`L'", replace

			quietly count if `touse' & `by' == `L'
			local groupN = r(N)

			foreach v of varlist `varlist' {
				// non-missing count is the binomial denominator
				quietly count if !missing(`v') & `touse' & `by' == `L'
				local nobs = r(N)
				local val ""
				if (`nobs' > 0) {
					quietly count if `v' == 1 & `touse' & `by' == `L'
					local n = r(N)
					quietly ci proportions `v' if `touse' & `by' == `L', `method' level(`level')
					local perc = 100 * `n' / `nobs'
					local n_str    = strtrim(string(`n', "%9.0g"))
					local perc_str = strtrim(string(`perc', "`format'"))
					local lb_str   = strtrim(string(100 * r(lb), "`format'"))
					local ub_str   = strtrim(string(100 * r(ub), "`format'"))
					local val "`n_str' (`perc_str'%), [`lb_str'% - `ub_str'%]"
				}
				local lbl : variable label `v'
				post `posthandle' ("`v'") ("`lbl'") ("`val'")
			}

			local lvlname : label `labname' `L'
			postclose `posthandle'

			preserve
			quietly {
				if ("`counter'" == "1") {
					use "`postoutput'`L'", clear
					label variable value_`L' "`lvlname' \n (N = `groupN')"
					statareport__apply_order, order("`ci_varlist'")
					save "`postoutput'", replace
				}
				else {
					use "`postoutput'", clear
					merge 1:1 variable label using "`postoutput'`L'"
					label variable value_`L' "`lvlname' \n (N = `groupN')"
					capture drop _merge
					statareport__apply_order, order("`ci_varlist'")
					save "`postoutput'", replace
				}
			}
			restore
		}
	}

	// ---- overall column : no by(), or the Total column with by() -----------
	if (("`by'" == "") | ("`by'" != "" & "`addtotal'" != "")) {
		tempfile posttotal
		tempname posthandle
		quietly postfile `posthandle' str32 variable str2045 label str2045 value using "`posttotal'", replace

		foreach v of varlist `varlist' {
			quietly count if !missing(`v') & `touse'
			local nobs = r(N)
			local val ""
			if (`nobs' > 0) {
				quietly count if `v' == 1 & `touse'
				local n = r(N)
				quietly ci proportions `v' if `touse', `method' level(`level')
				local perc = 100 * `n' / `nobs'
				local n_str    = strtrim(string(`n', "%9.0g"))
				local perc_str = strtrim(string(`perc', "`format'"))
				local lb_str   = strtrim(string(100 * r(lb), "`format'"))
				local ub_str   = strtrim(string(100 * r(ub), "`format'"))
				local val "`n_str' (`perc_str'%), [`lb_str'% - `ub_str'%]"
			}
			local lbl : variable label `v'
			post `posthandle' ("`v'") ("`lbl'") ("`val'")
		}
		postclose `posthandle'

		quietly {
			preserve
				if ("`addtotal'" != "") {
					use "`posttotal'", clear
					merge 1:1 variable label using "`postoutput'"
					label variable value "Total \n (N = `N')"
					capture drop _merge
					order value, last
					statareport__apply_order, order("`ci_varlist'")
					save "`postoutput'", replace
				}
				else {
					use "`posttotal'", clear
					statareport__apply_order, order("`ci_varlist'")
					save "`postoutput'", replace
				}
			restore
		}
	}

	// add the row ids --------------------------------------------------------
	preserve
		use "`postoutput'", clear
		gen id = _n + `idstart' - 1
		quietly tostring id, replace
		quietly save "`postoutput'", replace
	restore

	// if append, add this table to the previous file -------------------------
	preserve
		if ("`append'" != "") {
			use "`output'", clear
			append using "`postoutput'"
		}
		else {
			use "`postoutput'", clear
		}

		label variable variable "Variables"
		label variable label "Variables labels"

		quietly save "`output'", replace
		display as result "`output' saved successfully"
	restore
end
