/*
Convert variables to string while keeping user-friendly headers.

This helper is primarily used before exporting tables. It converts value
labelled variables to their labelled string, rounds numerics, and preserves a
useful note for each column so downstream code (e.g. kable) can render the
right headers.

Options
-------
- round(): numeric rounding increment. Defaults to 0.01 (two decimals).
- usevarnames: force column notes to use the variable name.
- usevarlabels: force column notes to use the variable label when available.

Notes
-----
- The original variables are replaced with string versions; run on temporary
  data if the numerics are still needed later in the pipeline.
*/

capture program drop convert_wisely
program convert_wisely
    version 15
    syntax varlist [, ROUnd(real 0.01) USEVARNames USEVARLabels]

    foreach v of local varlist {
        tempvar work tmpstr decoded
        local header ""
        local varlabel : variable label `v'

        local header ``v'[note1]'"
        quietly note drop `v'

        if ("`usevarlabels'" != "") {
            local header : variable label `v'
        }

        if ("`header'" == "" & "`usevarnames'" != "") {
            local header `v'
        }

        if ("`header'" == "") {
            local header : variable label `v'
        }

        if ("`header'" == "") {
            local header `v'
        }

        local lbl : value label `v'
        if ("`lbl'" != "") {
            decode `v', generate(`decoded')
            drop `v'
            rename `decoded' `v'
        }
        else {
            capture confirm numeric variable `v'
            if (!_rc) {
                gen double `work' = `v'
                quietly replace `work' = round(`work', `round')
                tostring `work', generate(`tmpstr') format("%18.0g") force
                drop `v' `work'
                rename `tmpstr' `v'
            }
            else {
                gen strL `tmpstr' = `v'
                drop `v'
                rename `tmpstr' `v'
            }
        }

        quietly replace `v' = "" if `v' == "."
        format `v' %-s

        if ("`varlabel'" != "") {
            label variable `v' "`varlabel'"
        }

        note `v': `"`header''"
    }
end
