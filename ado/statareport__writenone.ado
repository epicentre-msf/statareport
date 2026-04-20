// Internal helper: write a "None" placeholder table to disk using the
// Pandoc custom-style syntax. Called by kable/kable_basic when the dataset
// in memory is empty.
capture program drop statareport__writenone
program statareport__writenone
    version 15
    args f caption footnote

    tempname fh
    capture file close `fh'
    quietly file open `fh' using "`f'", write replace
    file write `fh' `"Table: `caption'"' _n
    file write `fh' _n
    file write `fh' `":::{custom-style="Nonestyle"}"' _n
    file write `fh' "None" _n
    file write `fh' ":::" _n
    if (`"`footnote'"' != "") {
        file write `fh' _n
        file write `fh' `"`footnote'"' _n
    }
    file write `fh' _n
    file close `fh'
end
