/*
Create baseline vs. post-baseline shift graphs with reference limits.

Inputs
------
- The dataset must contain the continuous variable of interest, a visit
  indicator ({opt evariable()}), and a unique identifier ({opt idvariable()}).
- An Excel configuration file supplies reference limits (LLN/ULN), units, and a
  friendly name for the shift graph.

The program saves both a Stata graph ({cmd:.gph}) and a PNG using the supplied
output directory and suffix.

Output sizing
-------------
- {opt width()} sets the exported PNG width in pixels (default 2400). Larger
  values give a crisper image; the height is derived from the aspect ratio so
  the picture is never distorted.
- {opt xsize()} / {opt ysize()} set the graph aspect ratio in inches
  (default 7.5 x 4.5).
*/

capture program drop compute_shift_graphs
program define compute_shift_graphs
    version 15
    syntax varname(numeric) [if], ///
        EVARiable(varname numeric) ///
        EVALue(integer) ///
        BASEvalue(integer) ///
        NAME(string) ///
        IDvariable(varname) ///
        OUTputdir(string) ///
        SUFfix(string) ///
        CONFigfile(string) ///
        [ WIDTH(integer 2400) XSize(real 7.5) YSize(real 4.5) ]

    marksample touse, novarlist
    local measure `varlist'

    confirm numeric variable `evariable'
    confirm variable `idvariable'
    confirm file "`configfile'"

    * Ensure output directory exists (ignore if already created)
    capture mkdir "`outputdir'"

    * Pull configuration row ---------------------------------------------------
    local req_cols parameter name units lln uln
    preserve
        import excel using "`configfile'", firstrow clear
        foreach col of local req_cols {
            capture confirm variable `col'
            if (_rc) {
                display as error "compute_shift_graphs: config file missing column '`col''"
                exit 111
            }
        }
        keep if trim(lower(parameter)) == trim(lower("`measure'")) | trim(lower(name)) == trim(lower("`name'"))
        quietly count
        if (r(N) != 1) {
            display as error "compute_shift_graphs: expected exactly one config row (found `r(N)')"
            exit 9
        }
        local unit = trim(units[1])
        local lln  = lln[1]
        local uln  = uln[1]
        local lname = trim(name[1])
    restore

    if ("`lname'" == "") local lname "`measure'"

    * Resolve labels for baseline/analysis visits ------------------------------
    local base_label : label (`evariable') `basevalue'
    if ("`base_label'" == "") local base_label : display %9.0g `basevalue'
    local eval_label : label (`evariable') `evalue'
    if ("`eval_label'" == "") local eval_label : display %9.0g `evalue'

    display as text "--- Shift graph for `lname'"

    tempfile mydata against
    preserve
        keep if `touse'
        keep `measure' `evariable' `idvariable'
        save "`mydata'", replace
    restore

    preserve
        use "`mydata'", clear
        keep if `evariable' == `evalue'
        rename `measure' `measure'_ev
        quietly summarize `measure'_ev, meanonly
        local maxy = max(r(max), `uln') + 0.01
        local miny = min(r(min), `lln') - 0.01
        save "`against'", replace
    restore

    preserve
        use "`mydata'", clear
        keep if `evariable' == `basevalue'
        quietly summarize `measure', meanonly
        local maxx = max(r(max), `uln', `maxy') + 0.02
        local minx = min(r(min), `lln', `miny') - 0.02
        merge 1:1 `idvariable' using "`against'", nogenerate keep(match)

        local lln_str = string(`lln', "%9.1f")
        local uln_str = string(`uln', "%9.1f")
        local diag_max = `maxx' * 1.068

        * Colour for the ULN label/reference lines (colour-blind friendly blue)
        local uln_color "0 114 178"

        twoway ///
            (scatter `measure'_ev `measure', sort ///
                mlcolor(black%68) mfcolor(black%60) msize(2-pt) msymbol(smcircle) ///
                text(`uln' `diag_max' "ULN" "`uln_str' `unit'", place(n) size(2rs) color("`uln_color'")) ///
                text(`lln' `diag_max' "LLN" "`lln_str' `unit'", place(n) size(2rs) color(black)) ///
                text(`diag_max' `lln' "LLN" "`lln_str' `unit'", place(ne) size(2rs) color(black)) ///
                text(`diag_max' `uln' "ULN" "`uln_str' `unit'", place(ne) size(2rs) color("`uln_color'")) ) ///
            (function y = x, range(`minx' `diag_max') lcolor(gs8) lwidth(0.2)), ///
            yline(`lln', lwidth(0.168) lcolor(gs12) lpattern(dash)) ///
            yline(`uln', lwidth(0.168) lcolor("`uln_color'") lpattern(dash)) ///
            xline(`lln', lwidth(0.168) lcolor(gs12) lpattern(dash)) ///
            xline(`uln', lwidth(0.168) lcolor("`uln_color'") lpattern(dash)) ///
            ytitle("`lname' at `eval_label' (`unit')", size(vsmall) color(black)) ///
            ylabel(, labsize(vsmall) nogrid glcolor(none)) ///
            xtitle("`lname' at `base_label' (`unit')", size(vsmall) color(black)) ///
            xlabel(, labsize(vsmall) tlcolor(black) nogrid) ///
            legend(off) graphregion(fcolor(white) lcolor(white)) ///
            plotregion(fcolor(white) ifcolor(white)) ///
            xsize(`xsize') ysize(`ysize')
    restore

    graph save "`outputdir'/`measure'_`evalue'_`suffix'", replace
    * Only width() is passed so the export height is derived from the
    * xsize()/ysize() aspect ratio above, keeping the PNG undistorted.
    graph export "`outputdir'/`measure'_`evalue'_`suffix'.png", as(png) width(`width') replace
end
