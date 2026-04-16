*******************************************************
* Example workflow for the statareport package
* Demonstrates how to create the standard workspace,
* summarise data, and export Markdown-ready tables
* using only in-memory sample datasets (sysuse auto).
*******************************************************

clear all
set more off

* Ensure the package ado files are reachable when running from source
capture which quant
if (_rc) {
    adopath + "../ado"
}

capture which quant
if (_rc) {
    display as error "statareport example: ado files not found. Install the package or adjust adopath."
    exit 111
}

* 1. Create a demonstration workspace (will be reused if it already exists)
local demo_root "../example_workspace"
statareport_setup_dirs, root("`demo_root'")

local output_tables "`demo_root'/output_tables"
local output_md "`demo_root'/output_md"
local output_figures "`demo_root'/output_figures"

display as text "Writing demonstration outputs under `demo_root'"

* 2. Load the built-in Auto dataset into memory
capture sysuse auto, clear
if (_rc) {
    display as error "Unable to load the sysuse auto dataset (rc = `_rc')."
    exit _rc
}

* Basic cleanup for reproducibility
sort make
gen long id = _n
label var id "Vehicle ID"

* 3. Derive indicators and labels used in the summaries ---------------------
label define yesno 0 "No" 1 "Yes", replace

generate byte high_mpg = (mpg >= 25) if !missing(mpg)
replace high_mpg = 0 if missing(high_mpg)
label var high_mpg "MPG >= 25"
label values high_mpg yesno

generate byte expensive = (price > 10000) if !missing(price)
replace expensive = 0 if missing(expensive)
label var expensive "Price > $10k"
label values expensive yesno

generate byte heavy = (weight > 3000) if !missing(weight)
replace heavy = 0 if missing(heavy)
label var heavy "Weight > 3,000 lbs"
label values heavy yesno

clonevar rep78_cat = rep78
label define rep78_lbl 1 "Very poor" 2 "Poor" 3 "Fair" 4 "Good" 5 "Excellent", replace
label values rep78_cat rep78_lbl
label var rep78_cat "Repair record (1978)"

* 4. Quantitative summaries -------------------------------------------------
display as text "Creating quantitative summaries (quant)"
quant price mpg, ///
    output("`output_tables'/auto_quant.dta") ///
    by(foreign) addtotal format("%9.1f") idstart(100)

quant weight length turn if !missing(rep78_cat), ///
    output("`output_tables'/auto_quant.dta") ///
    by(rep78_cat) meanonly append format("%9.1f") idstart(200)

* 5. Qualitative summaries --------------------------------------------------
display as text "Creating qualitative summaries (qual)"
qual high_mpg heavy expensive, ///
    output("`output_tables'/auto_qual.dta") ///
    by(foreign) addtotal format("%9.1f") idstart(300)

* 6. Convert datasets for reporting and export Markdown tables --------------
display as text "Exporting Markdown tables with kable"
use "`output_tables'/auto_quant.dta", clear
convert_wisely *
kable, caption("Quantitative summaries for the Auto dataset") ///
    footnote("Generated with sysuse auto.") ///
    output("`output_md'/auto_quant.md")

use "`output_tables'/auto_qual.dta", clear
convert_wisely *
kable, caption("Qualitative indicators for the Auto dataset") ///
    footnote("Indicators: MPG >= 25, Weight > 3,000 lbs, Price > $10k.") ///
    output("`output_md'/auto_qual.md")

display as result "Example workflow completed. Review outputs in `demo_root'."
