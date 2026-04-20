# `compute_shift_graphs`

**compute_shift_graphs** --- Create paired baseline vs post-baseline scatterplots with reference lines.


## Syntax

`compute_shift_graphs` *varname* [`if`]`,`
**`evar`**`iable(`*varname*`)` **`eval`**`ue(`*integer*`)` **`base`**`value(`*integer*`)`
`name(`*string*`)` **`id`**`variable(`*varname*`)` **`output`**`dir(`*string*`)`
**`suf`**`fix(`*string*`)` **`conf`**`igfile(`*string*`)`



**Options**


---

- **`evar`**`iable(`*varname*`)` — numeric visit indicator identifying baseline and analysis records (required)
- **`eval`**`ue(`*integer*`)` — value of `evariable()` marking the analysis visit (required)
- **`base`**`value(`*integer*`)` — value of `evariable()` marking the baseline visit (required)
- `name(`*string*`)` — identifier used to select the configuration row (required)
- **`id`**`variable(`*varname*`)` — unique identifier for individuals (required)
- **`output`**`dir(`*string*`)` — directory for storing generated `.gph` and PNG files (required; created if missing)
- **`suf`**`fix(`*string*`)` — suffix appended to the graph filenames (required)
- **`conf`**`igfile(`*string*`)` — Excel file with columns `parameter`, `name`, `units`, `lln`, `uln` (required)

---



## Description

`compute_shift_graphs` plots paired laboratory or biomarker values at
baseline and a specified post-baseline visit as a scatterplot with LLN (lower
limit of normal) and ULN (upper limit of normal) reference lines. The
configuration is read from an Excel file that must contain columns
`parameter`, `name`, `units`, `lln`, and `uln`. Matching
succeeds when `parameter` equals the measurement variable name or when
`name` matches the value supplied in `name()`. All options are required.

Each graph is saved as both a Stata graph (`.gph`) and a PNG file
using the stem `<parameter>_<evalue>_<suffix>` inside `outputdir()`.


## Options

> `evariable(varname)` specifies the numeric variable that identifies
visits (e.g., a visit number). Required.

> `evalue(integer)` the value of `evariable()` that marks the
post-baseline analysis visit. Required.

> `basevalue(integer)` the value of `evariable()` that marks the
baseline visit. Required.

> `name(string)` an identifier that selects the correct row from the
configuration file. Required.

> `idvariable(varname)` the variable containing a unique identifier for
each individual (e.g., patient ID). Required.

> `outputdir(string)` the directory where graph files are saved. The
directory is created if it does not already exist. Required.

> `suffix(string)` a string appended to each graph filename to
distinguish different analyses. Required.

> `configfile(string)` path to the Excel configuration file. The file
must contain one row per parameter with columns `parameter`, `name`,
`units`, `lln`, and `uln`. Required.


## Examples

> `. compute_shift_graphs alt, evar(visit) evalue(4) basevalue(0) name("ALT") idvariable(patient_id) outputdir("output_figures") suffix("wk4") configfile("input_md/shift_graphs_inputs.xlsx")`

> `. compute_shift_graphs creatinine if arm==1, evar(visitnum) evalue(8) basevalue(1) name("CREAT") idvariable(subjid) outputdir("output_figures/lab") suffix("wk8_arm1") configfile("config/lab_limits.xlsx")`


## Also see

[`create_dyntex`](create_dyntex.md), [`knit`](knit.md)

---

*Source*: [`ado/compute_shift_graphs.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/compute_shift_graphs.sthlp)
