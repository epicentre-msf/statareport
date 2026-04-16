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
*/

capture program drop label_table
program label_table
    version 15
    syntax , TAB_file(string) LABEL_file(string) TAB_id(string) ///
        [ LABEL_name(string) VALUE_name(string) DROP_value(string) ]

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

    merge 1:1 id using "`labels_dta'", keep(master match) nogenerate

    if ("`drop_value'" != "") {
        capture confirm variable value
        if (!_rc) {
            quietly replace value = trim(value)
            drop if value == "`drop_value'"
        }
    }

    capture confirm variable order
    if (!_rc) {
        sort order
    }
    else {
        sort id
    }

    keep label value*
    order label value*

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
