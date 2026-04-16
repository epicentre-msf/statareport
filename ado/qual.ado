/*
					Qualitative variables tabulations
================================================================================

This program creates tables on categorical variables ready for publication. The
tables are saved in the output variable that could be provided by the user,
and you can compute the tables by values of a categorical variable.

Parameters:
============

output: the output file for the tabulation
format: the format in the computation
append: if the output file exists, do you want to append the current tabulation to previous data?
by: compute qualitative values by a categorical varlist.
pct: pct(col) for column percentages (default), pct(row) for row percentages

Examples:
===========

sysuse auto, clear
gen price_high = (price > 10000)
gen mpg_low = (mpg < 100)
sum price_high mpg_low, det
label variable price_high "High prices"
label variable mpg_low "Low mpg"
bysort foreign: tab1 mpg_low price_high
qual price_high mpg_low, output("temp.dta") by(foreign)
cls
use "temp.dta", clear
list

*/


	capture program drop qual
	program qual
	  version 15
		syntax varlist(min=1) [if] , OUTput(string) [FORMat(string) append BY(varlist max=1) ADDTOTal IDStart(integer 1) PCT(string)]
		marksample touse, novarlist
		local qual_varlist "`varlist'"

		if ("`format'" == ""){
		  local format "%9.1f"
		}

		// Percent type when using by():
		// - default is column percentages (within each by-group)
		// - pct(row) gives row percentages (distribution across by-groups for each row/variable)
		if ("`pct'" == "") {
			local pct "col"
		}
		local pct = lower("`pct'")
		if ("`pct'" == "column") {
			local pct "col"
		}
			if !inlist("`pct'", "col", "row") {
				display as error "Option pct() must be pct(col) or pct(row); got pct(`pct')"
				exit 198
			}

		if ("`idstart'" == ""){
			local idstart 1
		}

	if (`idstart' < 1 ){
		display as error "Start ids must be an integer (>= 1), IDStart = `idstart' is not"
		exit 1
	}

	quietly count if `touse'
	local N = `r(N)'

	// output of the temporary file
	tempfile postoutput


	if ("`append'" != ""){
		confirm file "`output'"
	}

		* Compute values for each levels of a categorical variable

		if ("`by'" != ""){
			// check if the `by' variable is categorical:

			local labname: value label `by'

		if ("`labname'" == ""){
			display "`by' is not a categorical variable"
			exit 1
		}

		// Get the different values of the categorical variable


			levelsof `by', local(levels)
			local counter = 0

			// For pct(row), precompute totals per row/variable to use as denominator
			// across all by-groups.
			if ("`pct'" == "row") {
				foreach v of varlist `varlist' {
					quietly summarize `v' if `touse', meanonly
					local rowsum_`v' = r(sum)
				}
			}

			foreach L of local levels {

				// foreach of the levels of the variable, compute the
				// summary of the variable.

			local counter = `counter' + 1
			// using postfile to improve the output
			tempfile postoutput`L'
			tempname posthandle
			quietly postfile `posthandle' str32 variable  str2045 label str2045 value_`L' using "`postoutput'`L'", replace
			local nlines = 0

				foreach v of varlist `varlist'{
				  local nlines = `nlines' + 1
				  quietly sum `v' if `touse' & `by' == `L' , detail
					local n_m = `r(sum)'
					local nobs = `r(N)'

					// Percent denominator depends on pct()
					local denom = `nobs'
					if ("`pct'" == "row") {
						local denom = `rowsum_`v''
					}

					local perc_m = 0
					if (!missing(`denom') & (`denom' != 0)) {
						local perc_m = 100 * (`n_m' / `denom')
					}
					local perc_m = string(`perc_m', "`format'")
					//If you have a dot, replace by 0
					if ("`perc_m'" == "."){
						local perc_m "0.0"
					}


				local qual = "`n_m' (`perc_m')"

				local lbl: variable label `v'
				post `posthandle' ("`v'") ("`lbl'") ("`qual'")
			}

			local lvlname : label `labname' `L'
			postclose `posthandle'

			preserve
			 quietly{
				if ("`counter'" == "1"){
						use "`postoutput'`L'", clear
						label variable value_`L' "`lvlname' \n (N = `nobs')"
						quietly statareport__apply_order, order("`qual_varlist'")
						save "`postoutput'", replace
				}
				else{
					use "`postoutput'", clear
					quietly merge 1:1 variable label using "`postoutput'`L'"
					label variable value_`L' "`lvlname' \n (N = `nobs')"
					capture drop _merge
					quietly statareport__apply_order, order("`qual_varlist'")
					save "`postoutput'", replace
				}
			 }
			restore

		}

	}

		// Adding the total or computing for everyone

		if (("`by'" == "") | ("`by'" != "" & "`addtotal'" != "")) {

		tempfile posttotal
		tempname posthandle

		quietly postfile `posthandle' str32 variable  str2045 label str2045 value using "`posttotal'", replace

			foreach v of varlist `varlist'{

			  quietly sum `v' if `touse' , detail
				local n_m = `r(sum)'
				local nobs = `r(N)'

				// If pct(row) is requested with by(), the "Total" column is the row total,
				// so the percentage is 100 (or 0 if the row total is 0).
				local denom = `nobs'
				if ("`by'" != "" & "`pct'" == "row") {
					local denom = `n_m'
				}

				local perc_m = 0
				if (!missing(`denom') & (`denom' != 0)) {
					local perc_m = 100 * (`n_m' / `denom')
				}
				local perc_m = string(`perc_m', "`format'")
				//If you have a dot, replace by 0
				if ("`perc_m'" == "."){
					local perc_m "0.0"
				}

			if ("`nobs'" == "`N'"){
			  local qual = "`n_m' (`perc_m')"
			}
			else{
			  local qual = "`nobs', `n_m' (`perc_m')"
			}

			local lbl: variable label `v'
			post `posthandle' ("`v'") ("`lbl'") ("`qual'")
		}
		postclose `posthandle'

		quietly{
			preserve
				if ("`addtotal'" != ""){
					use "`posttotal'", clear
					merge 1:1 variable label using "`postoutput'"
					label variable value "Total \n (N = `nobs')"
					capture drop _merge
					order value, last
					quietly statareport__apply_order, order("`qual_varlist'")
					save "`postoutput'", replace

				}
				else{
					use "`posttotal'", clear
					quietly statareport__apply_order, order("`qual_varlist'")
					save "`postoutput'", replace

				}
			restore
		}
	}

	preserve
		// add the id variable
		if ("`idstart'" != ""){
			use "`postoutput'", clear
			gen id = _n
			replace id = id + `idstart' - 1
		}
		tostring id, replace
		quietly save "`postoutput'", replace
	restore

	preserve
		// if append, add your data to the previous file
		if ("`append'" != ""){
			use "`output'", clear
			append using "`postoutput'"
		}
		else{
			use "`postoutput'", clear
		}

		label variable variable "Variables"
		label variable label "Variables labels"

		quietly save "`output'", replace
		display as result "`output' saved successfully"
	restore
end
