// Internal helper: restore the row order of post-processed summary tables
/*
This program sorts the dataset in memory so that the rows follow the
order of a supplied varlist. Rows that do not match any entry keep their
relative order but are pushed to the bottom.

Usage (internal):
    statareport__apply_order, order("var1 var2 var3") [match(varname)]

Options:
    order()  : required space separated list defining the desired order.
    match()  : variable whose values should be matched against the order
               list. Defaults to the string variable named "variable".
    strict   : if specified, throw an error when any order items are missing
               from the dataset.
*/

capture program drop statareport__apply_order
program define statareport__apply_order
    version 15
    syntax , ORDER(string) [MATCH(string) STRICT]

    if ("`order'" == "") exit 0

    local matchvar `match'
    if ("`matchvar'" == "") local matchvar variable

    confirm variable `matchvar'

    // Track rows that are not explicitly covered by the order list
    tempvar __statareport_sort
    gen double `__statareport_sort' = _N + _n

    local idx = 0
    foreach item of local order {
        local ++idx
        quietly replace `__statareport_sort' = `idx' if `matchvar' == "`item'"
        quietly count if `matchvar' == "`item'"
        if ("`strict'" != "" & r(N) == 0) {
            display as error "statareport__apply_order: order item '`item'' not found in variable `matchvar'"
            exit 198
        }
    }

    sort `__statareport_sort'
    drop `__statareport_sort'
end
