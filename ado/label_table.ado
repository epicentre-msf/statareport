/*
Label tables by merging metadata from an Excel sheet.

Options
-------
- tab_file(): path to the dataset that needs labelling (required).
- label_file(): Excel workbook containing the labels (required).
- tab_id(): worksheet name that holds the id/label mapping (required).
- label_name(): optional note for the `label` column.
- value_name(): optional note propagated to all `value*` columns.
- drop_value(): drop rows whose `value` matches the provided string (case
  sensitive after trimming).

Row ordering & removal via the `order` column
----------------------------------------------
If the Excel sheet contains an `order` column, rows are sorted by it.
Rows whose `order` cell is blank (empty string or missing number) are
dropped from the final labelled table. This is the supported way to hide
a computed row from the report without re-running `quant`/`qual`: clear
the `order` cell in Excel and re-render.
*/

capture program drop label_table
program label_table
    version 15
    syntax , TAB_file(string) LABEL_file(string) TAB_id(string) ///
        [ LABEL_name(string) VALUE_name(string) DROP_value(string) KEEPid ]

    confirm file "`tab_file'"
    confirm file "`label_file'"

    tempfile labels_dta

    import excel using "`label_file'", sheet("`tab_id'") firstrow clear

    capture confirm variable id
    if (_rc) {
        display as error "label_table: sheet `tab_id' must contain an 'id' column"
        exit 111
    }

    capture confirm variable label
    if (_rc) {
        display as error "label_table: sheet `tab_id' must contain a 'label' column"
        exit 111
    }

    quietly tostring id, replace
    quietly replace label = trim(label)
    quietly duplicates drop id, force
    compress
    save "`labels_dta'", replace

    use "`tab_file'", clear

    capture confirm variable id
    if (_rc) {
        display as error "label_table: dataset `tab_file' must contain an 'id' column"
        exit 111
    }

    quietly tostring id, replace

    // Both master (from quant/qual) and using (from the Excel sheet) carry a
    // `label' column. `update replace' makes the Excel label win — without
    // this, Stata silently keeps the master's value and every Excel label
    // edit is ignored. The expanded keep() list is required because update
    // creates extra _merge codes (match_update, match_conflict) that the
    // bare keep(master match) would drop.
    merge 1:1 id using "`labels_dta'", ///
        keep(master match match_update match_conflict) update replace nogenerate

    if ("`drop_value'" != "") {
        capture confirm variable value
        if (!_rc) {
            quietly replace value = trim(value)
            drop if value == "`drop_value'"
        }
    }

    capture confirm variable order
    if (!_rc) {
        // Blank `order` cells in the Excel sheet = drop the row from the
        // final labelled table. This lets users hide rows from the report
        // without changing the underlying quant/qual computation.
        capture confirm numeric variable order
        if (!_rc) {
            quietly drop if missing(order)
        }
        else {
            quietly drop if trim(order) == ""
        }
        sort order
    }
    else {
        sort id
    }

    if ("`keepid'" != "") {
        keep id label value*
        order id label value*
    }
    else {
        keep label value*
        order label value*
    }

    if ("`label_name'" != "") {
        capture note label: `label_name'
    }

    if ("`value_name'" != "") {
        unab valuevars : value*
        foreach v of local valuevars {
            capture note `v': `value_name'
        }
    }

    display as result "✅ Labels applied using `tab_id'"
end
