/*
Assign sequential labels to variables.

Each variable in `varlist` receives a variable label with the supplied
starting number. This is useful when a downstream table template expects
unique numeric identifiers stored in the label metadata (e.g. for
cross-referencing).

Options
-------
- starting(): integer value to begin the sequence (defaults to 1).
*/

capture program drop generate_label_ids
program generate_label_ids
    version 15
    syntax varlist(min=1) [, STARTing(integer 1)]

    if (`starting' < 0) {
        display as error "generate_label_ids: starting value must be non-negative"
        exit 198
    }

    foreach v of local varlist {
        label variable `v' "`starting'"
        local starting = `starting' + 1
    }
end
