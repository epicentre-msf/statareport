/*
Quantitative variables program
==============================


This program creates tables on quantitative variables ready for publication. The
tables are saved in the output variable that could be provided by the user,
and you can compute the tables by values of a categorical variable.

Parameters:
============

output: the output file for the tabulation
format: optional global numeric format; used for any statistic without its own
per-statistic option (see details)
meanformat, medformat, mxformat: per-statistic formats for the mean/SD, the
median/IQR, and the min/max. Defaults: meanformat %9.1f; medformat/mxformat the
variable's own display format (see details)
append: if the output file exists, do you want to append the current tabulation to previous data?
by: compute qualitative values by a categorical varlist.

fullresult, meanonly, medianonly, verticallayout: modify display for results (see details)

mxsep, medsep, mxbrack, medbrack: separators for showing results (see details)

Details:
==========

Display details
------------------
Full results write result: N, median (IQR) (min/max)
Mean only writes result: N, mean (SD)
Median only writes result: Median (IQR) (min/max)
Vertical layout stacks every statistic on its own line, opening with a blank
line:
    <blank>
    N
    mean (SD)
    median [Q1 ; Q3]
    (min/max)
The leading blank line is carried as a "VBLANKLINE" sentinel on the cell's
first line; the table-breaks.lua pandoc filter turns it into the blank line at
render time (a genuinely empty first line is dropped by pandoc). This layout is
therefore meant for the docx render pipeline. The leading blank line is on by
default; add the noline option to drop it (no sentinel is emitted).

Separators
---------------------------------

mxsep: Min / Maximum separator, could be any given string, default is "/"
medsep: Separator for the IQR, could be any given string, default is ";"

mxbrack: use bracket to wrap (min/max). Default is parenthesis
mxparenth: use parenthesis to wrap IQR. Default is brackets.

Formats
---------------------------------

format: optional global numeric format. When supplied it is used for every
statistic that does not have its own per-statistic option (below). It has no
default of its own anymore -- if it is omitted, the per-statistic defaults
apply.

meanformat, medformat, mxformat: per-statistic numeric formats. Precedence for
each statistic is: the specific option, else the global format() if supplied,
else a per-statistic default:
  - meanformat (mean and SD)        -> default "%9.1f"
  - medformat  (median and IQR)     -> default = the variable's own display
                                       format (e.g. a %9.0f variable prints its
                                       median with no decimals)
  - mxformat   (min and max)        -> default = the variable's own display
                                       format
Because the median/min-max defaults follow the variable, they are resolved per
variable. As a final safety net the median/min-max formats fall back to "%9.1f"
if the variable's display format is somehow empty (a numeric variable always
has one, so this is belt-and-suspenders against passing an empty format to
string(), which would silently blank the cell). The sum/percentage (sumonly)
use the global format() if supplied, else "%9.1f".

For the median/IQR/min-max values a dropped leading zero is restored: some
display formats (notably %g, the default for a freshly generated variable)
print ".5" rather than "0.5", so the formatted value is rewritten to "0.5"
(and "-.5" to "-0.5"). See quant__leadzero below.

Example
==========================================

sysuse auto, clear
*/


capture program drop quant
program quant
	version 15
	*Full results write result like N, median (IQR) (min/max)
	*Mean only writes result like - N, mean (SD)
	*Median only writes result like median (IQR) (min/max)

	syntax varlist(min=1 numeric) [if] , OUTput(string) [append BY(varlist max=1) FULLresult MEANonly MEDianonly ///
													FORMat(string) MEANFORMat(string) MEDFORMat(string) MXFORMat(string) ///
													mxsep(string) medsep(string) MXBrack  ///
													MEDPARenth ADDTOTal IDStart(integer 1) sumonly VERTIcallayout noline]


	marksample touse, novarlist
	local quant_varlist "`varlist'"

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

	// separators --------------------------------------------------------------

	if ("`mxsep'" == "") {
		local mxsep = "/"
	}

	if ("`medsep'" == "") {
		local medsep = ";"
	}

	// mop and mcl are opening and closings for the minimum/maximum.
	// default are parenthesis

	local mop = "("
	local mcl = ")"

	if ("`mxbrack'" != ""){
		local  mop = "["
		local mcl  = "]"
	}

	// medop and medcl are opening and closings for IQR [p25 ; p75]
	// default are brackets.

	local medop = "["
	local medcl = "]"

	if ("`medparenth'" != ""){
		local medop = "("
		local medcl =  ")"
	}

	// --- Format resolution ----------------------------------------------------
	// Precedence for every statistic: the specific option (meanformat/medformat/
	// mxformat) wins; otherwise the global format() when the user supplied one;
	// otherwise a per-statistic default:
	//   mean (+SD)    -> %9.1f
	//   median (+IQR) -> the variable's own display format
	//   min / max     -> the variable's own display format
	//   sum / %       -> %9.1f  (sumonly mode)
	//
	// The global `format' is deliberately NOT defaulted to %9.1f here: an empty
	// `format' is what lets the per-variable median/min-max defaults fire. mean
	// and the sum format do not depend on the variable, so they are resolved
	// once. medformat/mxformat may fall back to each variable's display format
	// (which differs across variables), so they are recomputed per variable
	// inside the computation loops from the saved originals below.
	if ("`meanformat'" == "") local meanformat "`format'"
	if ("`meanformat'" == "") local meanformat "%9.1f"

	local sumformat "`format'"
	if ("`sumformat'" == "") local sumformat "%9.1f"

	local medformat0 "`medformat'"
	local mxformat0  "`mxformat'"
	local defaultmode = ("`fullresult'" == "") & ("`medianonly'" == "") & ("`meanonly'" == "") & ("`sumonly'" == "") & ("`verticallayout'" == "")
	local requires_detail = ("`fullresult'" != "") | ("`medianonly'" != "") | ("`verticallayout'" != "") | `defaultmode'

	// Vertical-layout leading blank line: a "VBLANKLINE" sentinel on the cell's
	// first line that the table-breaks.lua pandoc filter turns into a blank line
	// at render time. Added by default; suppressed with the noline option. Keep
	// "VBLANKLINE" in sync with ressources/table-breaks.lua.
	//
	// syntax strips the leading "no": the `noline' option fills local `line'
	// with "noline" when given and leaves it empty otherwise -- so an empty
	// `line' means "keep the leading blank line".
	local vblank ""
	if (("`verticallayout'" != "") & ("`line'" == "")) {
		local vblank "VBLANKLINE \n "
	}

	// Precompute total sums to use as denominator when sumonly is requested
	if ("`sumonly'" != "") {
		foreach v of varlist `varlist' {
			quietly summarize `v' if `touse'
			local totalsum_`v' = r(sum)
		}
	}

	// Compute values for each levels of a categorical variable

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

		foreach L of local levels {


			// foreach of the levels of the variable, compute the
			// summary of the variable.

			local counter = `counter' + 1
			// using postfile to improve the output
			tempfile postoutput`L'
			tempname posthandle
			quietly postfile `posthandle' str32 variable  str2045 label str2045 value_`L'  using "`postoutput'`L'", replace

			foreach v of varlist `varlist'{
			  * Working on full result first
				if (`requires_detail') {
					quietly summarize `v' if `touse' & `by' == `L', detail
				}
				else {
					quietly summarize `v' if `touse' & `by' == `L'
				}

				// Per-variable median / min-max formats: specific option >
				// global format() > the variable's own display format > %9.1f.
				// The %9.1f tail is a safety net: a numeric variable always has
				// a display format, but if `: format' ever returned empty it
				// would pass "" to string() and silently blank the cell.
				local medformat "`medformat0'"
				if ("`medformat'" == "") local medformat "`format'"
				if ("`medformat'" == "") local medformat : format `v'
				if ("`medformat'" == "") local medformat "%9.1f"
				local mxformat "`mxformat0'"
				if ("`mxformat'" == "") local mxformat "`format'"
				if ("`mxformat'" == "") local mxformat : format `v'
				if ("`mxformat'" == "") local mxformat "%9.1f"

				local nobs = `r(N)'
				local emptydb = (`nobs' == 0)

				local sm ""
				local allperc ""

				if (!`emptydb'){
					local mn = string(`r(mean)', "`meanformat'")
					local sd = string(`r(sd)', "`meanformat'")

					if (`requires_detail') {
						local med = string(`r(p50)', "`medformat'")
						local p25 = string(`r(p25)', "`medformat'")
						local p75 =  string(`r(p75)', "`medformat'")
						local min = string(`r(min)', "`mxformat'")
						local max = string(`r(max)', "`mxformat'")
						// Some display formats (e.g. %g) drop the leading 0
						// (".5" not "0.5"); restore it on the median/IQR/min-max.
						quant__leadzero med `"`med'"'
						quant__leadzero p25 `"`p25'"'
						quant__leadzero p75 `"`p75'"'
						quant__leadzero min `"`min'"'
						quant__leadzero max `"`max'"'
					}

					local grp_sum = `r(sum)'
					local sm = string(`grp_sum', "`sumformat'")

					if ("`sumonly'" != "") {
						local totalsm = `totalsum_`v''
						local allperc = string(0, "`sumformat'")
						if (!missing(`totalsm') & (`totalsm' != 0)) {
							local allperc = string(100 * `grp_sum' / `totalsm', "`sumformat'")
						}
					}
				}

				local fpart "`nobs', "

				if (("`sumonly'" != "") & (!`emptydb')){
					local quantval = "`sm' (`allperc')"
				}

				if (("`meanonly'" != "") & (!`emptydb'))  {
					local  quantval = "`nobs', `mn' (`sd')"
				}

				if (("`medianonly'" != "") & (!`emptydb')) {
					local quantval = "`med'  `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
				}

				if (("`fullresult'" != "") & (!`emptydb')) {
					local quantval =  "`med' `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
				}
				// Avoid regression with previous code
				if (`defaultmode' & (!`emptydb')) {
					local quantval =  "`med'  `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
				}

				if (("`verticallayout'" != "") & (!`emptydb')) {
				// `vblank' prepends the leading-blank sentinel (empty under noline).
				local quantval = "`vblank'`nobs' \n `mn' (`sd') \n `med' `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
				}

				local lbl: variable label `v'
				quietly post `posthandle' ("`v'") ("`lbl'") ("`quantval'")
			}


			local lvlname : label `labname' `L'
			postclose `posthandle'

			// append different values of the `by'
			preserve
			 quietly{
			 if ("`counter'" == "1"){
						use "`postoutput'`L'", clear
						label variable value_`L' "`lvlname' \n (N = `nobs')"
						quietly statareport__apply_order, order("`quant_varlist'")
						save "`postoutput'", replace
				}
				else{
					use "`postoutput'", clear
					quietly merge 1:1 variable label using "`postoutput'`L'"
					label variable value_`L' "`lvlname' \n (N = `nobs')"
					capture drop _merge
					quietly statareport__apply_order, order("`quant_varlist'")
					save "`postoutput'", replace
				}
			 }
			restore

		}

	}

	// this is a local that tests if I should add total
	local addtotaltable = ("`by'" != "" & "`addtotal'" != "")

	if (("`by'" == "") | `addtotaltable'){
	* Do not compute values base on categories
		tempfile posttotal
		tempname posthandle
		quietly postfile `posthandle' str32 variable  str2045 label str2045 value  using "`posttotal'", replace
		foreach v of varlist `varlist'{
			if (`requires_detail') {
				quietly summarize `v' if `touse', detail
			}
			else {
				quietly summarize `v' if `touse'
			}

			// Per-variable median / min-max formats: specific option > global
			// format() > the variable's own display format > %9.1f (safety net,
			// see the by() loop above).
			local medformat "`medformat0'"
			if ("`medformat'" == "") local medformat "`format'"
			if ("`medformat'" == "") local medformat : format `v'
			if ("`medformat'" == "") local medformat "%9.1f"
			local mxformat "`mxformat0'"
			if ("`mxformat'" == "") local mxformat "`format'"
			if ("`mxformat'" == "") local mxformat : format `v'
			if ("`mxformat'" == "") local mxformat "%9.1f"

			local nobs = `r(N)'
			local emptydb = (`nobs' == 0)

			local sm ""
			local allperc ""

			if (!`emptydb'){
				local mn = string(`r(mean)', "`meanformat'")
				local sd = string(`r(sd)', "`meanformat'")
				if (`requires_detail') {
					local med = string(`r(p50)', "`medformat'")
					local p25 = string(`r(p25)', "`medformat'")
					local p75 =  string(`r(p75)', "`medformat'")
					local min = string(`r(min)', "`mxformat'")
					local max = string(`r(max)', "`mxformat'")
					// Some display formats (e.g. %g) drop the leading 0
					// (".5" not "0.5"); restore it on the median/IQR/min-max.
					quant__leadzero med `"`med'"'
					quant__leadzero p25 `"`p25'"'
					quant__leadzero p75 `"`p75'"'
					quant__leadzero min `"`min'"'
					quant__leadzero max `"`max'"'
				}

				local grp_sum = `r(sum)'
				local sm = string(`grp_sum', "`sumformat'")

				if ("`sumonly'" != "") {
					local totalsm = `totalsum_`v''
					local allperc = string(0, "`sumformat'")
					if (!missing(`totalsm') & (`totalsm' != 0)) {
						local allperc = string(100 * `grp_sum' / `totalsm', "`sumformat'")
					}
				}
			}

			local fpart "`nobs', "


			if (("`sumonly'" != "") & (!`emptydb')){
				local quantval = "`sm' (`allperc')"
			}

			if ("`meanonly'" != "")  {
				local  quantval = "`nobs', `mn' (`sd')"
			}

			if ("`medianonly'" != "") {
				local quantval = "`med'  `medop'`p25' `medsep' `p75'`medcl' \n  `mop'`min' `mxsep' `max'`mcl'"
			}

			if ("`fullresult'" != "") {
				local quantval =  "`fpart' `med' `medop'`p25' `medsep' `p75'`medcl' \n  `mop'`min' `mxsep' `max'`mcl'"
			}
			// Avoid regression with previous code
			if (`defaultmode') {
				local quantval =  "`fpart' `med'  `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
			}

			if (("`verticallayout'" != "") & (!`emptydb')) {
				// `vblank' prepends the leading-blank sentinel (empty under noline).
				local quantval = "`vblank'`nobs' \n `mn' (`sd') \n `med' `medop'`p25' `medsep' `p75'`medcl' \n `mop'`min' `mxsep' `max'`mcl'"
			}

			local lbl: variable label `v'
			quietly post `posthandle' ("`v'") ("`lbl'") ("`quantval'")
		}

		postclose `posthandle'
		quietly{
			preserve
					if (`addtotaltable'){
						use "`posttotal'", clear
						merge 1:1 variable label using "`postoutput'"
						label variable value "Total \n (N = `N')"
						capture drop _merge
						quietly statareport__apply_order, order("`quant_varlist'")
						order value, last
						save "`postoutput'", replace

					}
				else{
					use "`posttotal'", clear
					quietly statareport__apply_order, order("`quant_varlist'")
					save "`postoutput'", replace

				}
			restore
		}
	}


	// add the IDs if required
	preserve
		// add the id variable
		if ("`idstart'" != ""){
			use "`postoutput'", clear
			gen id = _n - 1
			quietly replace id = id + `idstart'
		}
		quietly{
			 tostring id, replace
			 save "`postoutput'", replace
		}
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
		display as result "Sucessfully saved file `output'"
	restore
end

// Restore the leading zero on a "naked decimal" formatted value: ".5" -> "0.5"
// and "-.5" -> "-0.5". Some Stata display formats (notably %g, the default for a
// freshly generated variable) drop the zero before the decimal point, so the
// per-variable median/min-max defaults can produce values like ".5". Takes the
// NAME of a caller local and rewrites it in place via c_local; a no-op for
// values that already have a leading digit (or a leading "0").
capture program drop quant__leadzero
program quant__leadzero
	version 15
	// `lname' is the NAME of a caller local and `value' its current contents
	// (locals are not visible across program scopes, so the value is passed in).
	// Rewrite that caller local in place via c_local.
	args lname value
	if (substr(`"`value'"', 1, 1) == ".")        local value = "0" + `"`value'"'
	else if (substr(`"`value'"', 1, 2) == "-.")   local value = "-0" + substr(`"`value'"', 2, .)
	c_local `lname' `"`value'"'
end
