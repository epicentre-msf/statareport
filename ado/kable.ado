// program to convert data in memory to a Markdown grid table with optional multiline cells

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
pipe: Use pipe table format instead of grid

All the in-memory data is converted to strings, and the program only cares
about combining them into a Markdown grid table compatible with Pandoc.

usage:

sysuse auto, clear
kable

or

sysuse auto, clear
kable, usevarnames

or

sysuse auto, clear
kable, out("temp.md") caption("Auto table")
*/

capture program drop kable
program kable
    version 15
    syntax [, SPAce(numlist>0 integer) OUTput(string) ROUnd(real 0.01) CAPtion(string) USEVARNames USEVARLabels nachar(string) FOOTnote(string) PIPE]

    local format "grid"
    if ("`pipe'" != "") {
        local format "pipe"
    }

    //Number of variables
    if (_N == 0) {
        if ("`output'" != ""){
            statareport__writenone "`output'" "`caption'" `"`footnote'"'
        }
        else{
            display as error "Empty data"
            tempfile f
            statareport__writenone "`f'" "`caption'" `"`footnote'"'
            statareport__read_file "`f'"
        }
        exit
    }

    tempfile savedtable
    quietly save "`savedtable'"
    quietly ds
    local allvars `r(varlist)'
    convert_wisely `allvars', round(`round') `usevarnames' `usevarlabels'

    local ncol : word count `allvars'
    if ("`nachar'" == "") {
        local nachar = "-"
    }

    tokenize "`allvars'"
    forvalues i=1/`ncol'{
        local v ``i''
        local header = trim("``v'[note1]'")
        local k2_head_`i' `"`header'"'
    }

    if ("`output'" != ""){
        local outfile "`output'"
    }
    else{
        tempfile outfile
        local outfile "`outfile'"
    }

    local k2_output   `"`outfile'"'
    local k2_caption  `"`caption'"'
    local k2_footnote `"`footnote'"'
    local k2_nachar   `"`nachar'"'
    local k2_space    "`space'"
    local k2_varlist  "`allvars'"
    local k2_ncol     "`ncol'"
    local k2_format   "`format'"

    mata: kable_render()

    if ("`output'" == ""){
        statareport__read_file "`outfile'"
    }

    use "`savedtable'", clear
end

capture mata: mata drop kable_render()
capture mata: mata drop k2_normalize_matrix()
capture mata: mata drop k2_split_lines()
capture mata: mata drop k2_maxwidth()
capture mata: mata drop k2_pad()
capture mata: mata drop k2_repeat()
capture mata: mata drop k2_make_separator()
capture mata: mata drop k2_make_alignment()
capture mata: mata drop k2_make_pipe_alignment()
capture mata: mata drop k2_render_row()
capture mata: mata drop k2_pipe_cell()
capture mata: mata drop k2_render_pipe_row()

mata:

string matrix function k2_normalize_matrix(string matrix X)
{
    real scalar R, C, r, c;
    string scalar newline, carriage, backslash, s;

    R = rows(X);
    C = cols(X);
    newline = char(10);
    carriage = char(13);
    backslash = char(92);

    for (r = 1; r <= R; r++) {
        for (c = 1; c <= C; c++) {
            s = X[r,c];
            if (ustrlen(s) == 0) {
                continue;
            }
            s = subinstr(s, carriage + newline, newline, .);
            s = subinstr(s, carriage, newline, .);
            s = subinstr(s, backslash + "r", newline, .);
            s = subinstr(s, backslash + "n", newline, .);
            X[r,c] = s;
        }
    }
    return(X);
}

string rowvector function k2_split_lines(string scalar s)
{
    string scalar newline;
    real scalar start, pos;
    string rowvector parts;

    newline = char(10);
    if (ustrlen(s) == 0) {
        return("");
    }

    start = 1;
    parts = J(1, 0, "");
    pos = ustrpos(s, newline, start);
    while (pos > 0) {
        parts = parts, usubstr(s, start, pos - start);
        start = pos + 1;
        pos = ustrpos(s, newline, start);
    }
    parts = parts, usubstr(s, start, .);
    if (cols(parts) == 0) {
        parts = parts, s;
    }
    return(parts);
}

real scalar function k2_maxwidth(string scalar s)
{
    string rowvector parts;
    real scalar maxw, i, w;

    parts = k2_split_lines(s);
    maxw = 0;
    for (i = 1; i <= cols(parts); i++) {
        w = ustrlen(ustrtrim(parts[i]));
        if (w > maxw) maxw = w;
    }
    return(maxw);
}

string scalar function k2_repeat(string scalar unit, real scalar times)
{
    real scalar i;
    string scalar out;

    if (times <= 0) {
        return("");
    }
    out = "";
    for (i = 1; i <= times; i++) {
        out = out + unit;
    }
    return(out);
}

string scalar function k2_pad(string scalar s, real scalar width)
{
    string scalar trimmed;
    real scalar len, target;

    trimmed = ustrtrim(s);
    len = ustrlen(trimmed);
    target = ceil(width);
    if (len >= target) {
        return(trimmed);
    }
    return(trimmed + k2_repeat(" ", target - len));
}

string scalar function k2_make_separator(real rowvector widths)
{
    string scalar sep;
    real scalar i, w;

    sep = "+";
    for (i = 1; i <= cols(widths); i++) {
        w = ceil(widths[i]);
        sep = sep + k2_repeat("-", w + 2) + "+";
    }
    return(sep);
}

string scalar function k2_make_alignment(real rowvector widths)
{
    string scalar line;
    real scalar i, w;

    if (cols(widths) == 0) {
        return("+");
    }

    w = ceil(widths[1]);
    line = "+:" + k2_repeat("=", w + 1) + "+";
    for (i = 2; i <= cols(widths); i++) {
        w = ceil(widths[i]);
        line = line + k2_repeat("=", w + 1) + ":" + "+";
    }
    return(line);
}

string scalar function k2_make_pipe_alignment(real rowvector widths)
{
    string scalar line;
    real scalar i, w;

    line = "|";
    for (i = 1; i <= cols(widths); i++) {
        w = ceil(widths[i]);
        if (w < 3) w = 3;
        if (i == 1) {
            line = line + ":" + k2_repeat("-", w) + "|";
        }
        else {
            line = line + k2_repeat("-", w) + ":|";
        }
    }
    return(line);
}

string colvector function k2_render_row(string rowvector cells, real rowvector widths)
{
    real scalar ncol, c, maxh, r, target, total;
    string colvector rendered;
    string rowvector lines;
    string scalar rowtxt, part;

    ncol = cols(cells);
    maxh = 0;

    for (c = 1; c <= ncol; c++) {
        lines = k2_split_lines(cells[c]);
        total = cols(lines);
        if (total > maxh) {
            maxh = total;
        }
    }
    if (maxh < 1) {
        maxh = 1;
    }

    rendered = J(maxh, 1, "");
    for (r = 1; r <= maxh; r++) {
        rowtxt = "|";
        for (c = 1; c <= ncol; c++) {
            lines = k2_split_lines(cells[c]);
            total = cols(lines);
            part = "";
            if (r <= total) {
                part = lines[r];
            }
            target = ceil(widths[c]);
            rowtxt = rowtxt + " " + k2_pad(part, target) + " |";
        }
        rendered[r] = rowtxt;
    }

    return(rendered);
}

string scalar function k2_pipe_cell(string scalar s)
{
    string scalar t;
    t = s;
    if (ustrlen(t) == 0) {
        return(t);
    }
    t = subinstr(t, char(10), "<br>", .);
    t = subinstr(t, "|", "&#124;", .);
    return(t);
}

string scalar function k2_render_pipe_row(string rowvector cells, real rowvector widths)
{
    real scalar ncol, c, target;
    string scalar rowtxt, part;

    ncol = cols(cells);
    rowtxt = "|";
    for (c = 1; c <= ncol; c++) {
        part = k2_pipe_cell(cells[c]);
        target = ceil(widths[c]);
        rowtxt = rowtxt + " " + k2_pad(part, target) + " |";
    }
    return(rowtxt);
}

void function kable_render()
{
    string scalar outfile, caption, footnote, nachar, spacelist, format, macro, h, sep, align, rowstr, t, suffix;
    string rowvector varnames, headers, parts_row, row;
    string matrix data, header_m;
    string colvector lines, hdr, rendered;
    real scalar ncol, nobs, c, r, mn, val, nparts, fh, nlines, i;
    real rowvector widths;

    outfile = st_local("k2_output");
    caption = st_local("k2_caption");
    footnote = st_local("k2_footnote");
    nachar = st_local("k2_nachar");
    if (nachar == "") nachar = "-";
    spacelist = st_local("k2_space");
    format = st_local("k2_format");
    if (format == "") format = "grid";
    varnames = tokens(st_local("k2_varlist"));
    ncol = cols(varnames);
    nobs = st_nobs();

    headers = J(1, ncol, "");
    for (c = 1; c <= ncol; c++) {
        macro = sprintf("k2_head_%g", c);
        h = st_local(macro);
        if (h == "") h = varnames[c];
        headers[c] = h;
    }

    if (nobs == 0) {
        data = J(0, ncol, "");
    }
    else {
        data = st_sdata(., varnames);
    }

    header_m = k2_normalize_matrix(headers);
    headers = header_m[1,.];
    data = k2_normalize_matrix(data);

    for (r = 1; r <= rows(data); r++) {
        for (c = 1; c <= ncol; c++) {
            rowstr = data[r,c];
            t = ustrtrim(rowstr);
            if (ustrlen(t) == 0) {
                data[r,c] = nachar;
            }
            else if (t == ".") {
                data[r,c] = nachar;
            }
            else if (usubstr(t, 1, 1) == "." & ustrlen(t) == 2) {
                suffix = usubstr(t, 2, 1);
                if ((suffix >= "a" & suffix <= "z") | (suffix >= "A" & suffix <= "Z")) {
                    data[r,c] = nachar;
                }
            }
        }
    }

    if (spacelist == "") {
        widths = J(1, ncol, 0);
        for (c = 1; c <= ncol; c++) {
            val = k2_maxwidth(headers[c]);
            if (val > widths[c]) widths[c] = val;
        }
        for (r = 1; r <= rows(data); r++) {
            for (c = 1; c <= ncol; c++) {
                val = k2_maxwidth(data[r,c]);
                if (val > widths[c]) widths[c] = val;
            }
        }
        mn = k2_maxwidth(nachar);
        for (c = 1; c <= ncol; c++) {
            if (widths[c] < mn) widths[c] = mn;
            if (widths[c] < 1) widths[c] = 1;
        }
    }
    else {
        parts_row = tokens(spacelist);
        nparts = cols(parts_row);
        if (nparts == 1) {
            val = strtoreal(parts_row[1]);
            widths = J(1, ncol, val);
        }
        else if (nparts == ncol) {
            widths = strtoreal(parts_row);
        }
        else {
            errprintf("Aborting, :( -- Number of space (%g) != Number of vars in memory (%g)--\n", nparts, ncol);
            error(3);
        }
        for (c = 1; c <= ncol; c++) {
            if (missing(widths[c]) || widths[c] <= 0) widths[c] = 1;
        }
    }

    sep = k2_make_separator(widths);
    align = k2_make_alignment(widths);

    lines = J(0, 1, "");
    lines = lines \ "";
    lines = lines \ ("Table: " + caption);
    lines = lines \ "";
    lines = lines \ "";
    if (format == "pipe") {
        lines = lines \ k2_render_pipe_row(headers, widths);
        lines = lines \ k2_make_pipe_alignment(widths);
        for (r = 1; r <= rows(data); r++) {
            row = data[r,.];
            lines = lines \ k2_render_pipe_row(row, widths);
        }
    }
    else {
        lines = lines \ sep;

        hdr = k2_render_row(headers, widths);
        lines = lines \ hdr;
        lines = lines \ align;

        for (r = 1; r <= rows(data); r++) {
            row = data[r,.];
            rendered = k2_render_row(row, widths);
            lines = lines \ rendered;
            lines = lines \ sep;
        }
    }

    lines = lines \ "";
    lines = lines \ footnote;

    if (fileexists(outfile)) {
        unlink(outfile);
    }
    fh = fopen(outfile, "w");
    nlines = rows(lines);
    for (i = 1; i <= nlines; i++) {
        fput(fh, lines[i]);
    }
    fclose(fh);
}

end
