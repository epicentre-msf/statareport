// Internal helper: read a text file and echo every line to the Results window.
// Used by kable/kable_basic when no output path is supplied so the table is
// shown to the user without hitting console-width truncation.
capture program drop statareport__read_file
program statareport__read_file
    version 15
    args f

    tempname fh
    capture file close `fh'
    file open `fh' using "`f'", read
    file read `fh' line
    while (r(eof) == 0) {
        display as text `"`line'"'
        file read `fh' line
    }
    file close `fh'
end
