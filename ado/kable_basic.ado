//program to convert a data in memory to a md table, preferably pandoc

/*
output: the output file
caption: The table caption
usevarnames: use the var names as heading
usevarlabels: use the var labels as heading

Default is to use the first note of the variable as heading and
then variable label and finally variable name if no notes/label found.

nachar: A character for missings, default is "-"
Round: (rounding for numerics)
Space: The space to put at the end of each variable, normally you can ignore
footnote: A paragraph appended after the table

All the in-memory data is converted to strings; dates and unusual formats are
not handled specially.

usage:

sysuse auto, clear
kable_basic

or

sysuse auto, clear
kable_basic, usevarnames

or

sysuse auto, clear
kable_basic, out("temp.md") caption("Auto table")
*/


capture program drop kable_basic
program kable_basic
    version 15
    //parameters are the file, the space to input
    syntax [, SPAce(numlist>0 integer) OUTput(string) ROUnd(real 0.01) CAPtion(string) USEVARNames USEVARLabels nachar(string) FOOTnote(string)]

    local footnote_text `"`footnote'"'

    //Number of variables
    if (_N == 0) {
        if ("`output'" != "") {
            statareport__writenone "`output'" "`caption'" `"`footnote_text'"'
        }
        else{
            display as error "Empty data"
            tempfile f
            statareport__writenone "`f'" "`caption'" `"`footnote_text'"'
            statareport__read_file "`f'"
        }
        exit
    }

    tempfile savedtable
    quietly save "`savedtable'"
    quietly ds
    local allvars `r(varlist)'
    convert_wisely `allvars', round(`round') `usevarnames' `usevarlabels'
    //ncol is the total number of variables
    local ncol : word count `allvars'
    if ("`nachar'" == "") {
        local nachar = "-"
    }
    //space is the space length for each of the column. need to update in near future
    local nval : word count `space'
    // Managing the default behaviour for the space by aligning the columns to maximum length
    if ("`space'" == ""){
        foreach v of local allvars{
            *First keep the length of the note
            local notel = "``v'[note1]'"
            local notel = ulength("`notel'")
            local typel: type `v'
            local typel = regexr("`typel'", "str", "")
            *now the space
            if (`typel' > `notel'){
                local space = "`space' " + "`typel'"
            }
            else{
                local space = "`space' " + "`notel'"
            }
        }
        local nval = `ncol'
    }
    else{
        if (`nval' == 1){
            local space: display _dup(`ncol') "`space' "
        }
    }

    //length greather than one: check the length with the corresponding data
    if (`ncol' != `nval' & `nval' != 1){
        display as error "Aborting, :( -- Number of space (`nval') != Number of vars in memory (`ncol')--"
        exit 3
    }

    tokenize "`allvars'"
    forvalues i=1/`ncol'{
        local allvars_`i' "``i''"
    }
    tokenize "`space'"
    forvalues i = 1/`ncol'{
        local space_`i' "``i''"
    }
    forvalues i = 1/`ncol'{
        kable_basic__add_data_space `allvars_`i'' `space_`i'' "`nachar'"
    }
    if ("`output'" != ""){
        kable_basic__write_data "`output'" "`space'" "`caption'" `"`footnote_text'"'
    }
    else{
        // print on the console: write on a file and read the file back to
        // avoid depending on the console width.
        tempfile f
        kable_basic__write_data "`f'" "`space'" "`caption'" `"`footnote_text'"'
        statareport__read_file "`f'"
    }
    use "`savedtable'", clear
end


**# Write the data to a file
capture program drop kable_basic__write_data
program kable_basic__write_data
    version 15
    args f space caption footnote

    tempname fh
    capture file close `fh'
    quietly file open `fh' using "`f'", write replace
    file write `fh' _n
    file write `fh' "Table: `caption'"
    file write `fh' _n
    file write `fh' _n
    *add heading and the data to fh
    kable_basic__add_heading `fh' "`space'"
    kable_basic__add_data `fh' "`space'"
    if (`"`footnote'"' != "") {
        file write `fh' _n
        file write `fh' `"`footnote'"' _n
    }
    quietly file close `fh'
end

**#  add space to data
capture program drop kable_basic__add_data_space
program kable_basic__add_data_space
    version 15
    args vari max nachar

    tempvar lvar
    local mm = `max' + 1
    quietly replace `vari' = "`nachar'" if `vari' == "."
    gen `lvar' = ulength(`vari')
    summarize `lvar', meanonly
    if (`r(max)' > `mm'){
        display as error "Increase the space for variable `vari', too small"
    }
    local pad: display _dup(`mm') " "
    quietly replace `vari' = `vari' + substr("`pad'", 1, `mm' - `lvar')
end

**# --- ADD HEADINGS TO THE FILE
capture program drop kable_basic__add_heading
program kable_basic__add_heading
    version 15
    args fh space

    quietly ds
    local allvars `r(varlist)'
    local ncol: word count `r(varlist)'

    tokenize "`space'"
    forvalues i=1/`ncol'{
        local space_`i' ``i''
    }
    tokenize "`allvars'"
    forvalues i=1/`ncol'{
        local v_`i' ``i''
    }
    //writing the first line
    kable_basic__add_separator `fh' "`space'"
    file write `fh' _n
    file write `fh' "|"
    //add the space and write to the file
    forvalues i = 1/`ncol'{
        local mylab "``v_`i''[note1]'"
        local mylabl = ulength("`mylab'")
        local mm = `space_`i'' + 1
        if (`mylabl' > `mm'){
            display as error "Increase the space for var `v_`i''; too small"
        }
        local pad: display _dup(`mm') " "
        local mylab = trim("`mylab'") + substr("`pad'", 1, `mm' - `mylabl')
        file write `fh' "`mylab'"
        file write `fh' "|"
    }

    file write `fh' _n
    local first_column : display _dup(`space_1') "="
    local first_column = "+" + ":" + "`first_column'"
    file write `fh' "`first_column'"
    file write `fh' "+"

    forvalues i=2/`ncol'{
        local col: display _dup(`space_`i'') "="
        local col = "`col'" + ":" + "+"
        file write `fh' "`col'"
    }
    file write `fh' _n
end

**# convert data to the md table
capture program drop kable_basic__add_data
program kable_basic__add_data
    version 15
    args fh space

    tempfile mytxt
    tempname myt
    quietly export delimited using "`mytxt'", delimiter("|") novar nolabel
    file open `myt' using "`mytxt'", read
    file read `myt' line
    while r(eof) == 0{
        file write `fh' "|"
        file write `fh' "`line'"
        file write `fh' "|"
        file write `fh' _n
        kable_basic__add_separator `fh' "`space'"
        file write `fh' _n
        file read `myt' line
    }
    file close `myt'
end

//--- add the separator for a line (grid tables)
capture program drop kable_basic__add_separator
program kable_basic__add_separator
    version 15
    args fh space

    quietly ds
    local ncol: word count `r(varlist)'
    tokenize "`space'"
    file write `fh' "+"
    forvalues i = 1/`ncol'{
        local nb = ``i'' + 1
        local col: display _dup(`nb') "-"
        local col = "`col'" + "+"
        file write `fh' "`col'"
    }
end
