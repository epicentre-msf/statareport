# Your first report

A vignette-style walk through from `cd` to a rendered `.docx`, using the
built-in `sysuse auto` dataset so anyone can follow along.

!!! tip "TL;DR"
    ```stata
    cd ~/scratch/mytrial_demo
    ! touch .here
    here
    statareport_init_project, prefix("AutoDemo") ///
        title("Auto trial") author("Me") listoftables listoffigures
    * ... edit do_files/00-final-do-file.do to register your data ...
    do do_files/00-final-do-file.do
    ```

We'll do that step by step.

## 0. Prerequisites

- Stata 15 or newer.
- Pandoc installed and on your PATH — `pandoc --version` should work
  from a terminal.
- `statareport` installed — see [Installation](install.md).

## 1. Create an empty project directory

```stata
cd ~/scratch/mytrial_demo
```

Any empty folder will do.

## 2. Seed the project root marker

`here` walks up the directory tree until it finds one of `.here`, `.git`,
or `*.stpr`. The easiest first-time signal is an empty `.here` file:

```stata
! touch .here    // on macOS/Linux; on Windows: ! type nul > .here
```

Now call `here` to cache that location in Mata:

```stata
here
```

You'll see `(here: /…/mytrial_demo  [.here])`. Subsequent commands read
the cached value silently.

## 3. Scaffold the project

```stata
statareport_init_project, prefix("AutoDemo") ///
    title("Auto dataset trial") ///
    subtitle("A toy example using sysuse auto") ///
    author("Report") ///
    listoftables listoffigures
```

That creates the canonical folder layout, writes a fully-populated
`do_files/00-final-do-file.do`, drops stubs for steps 01–07, and copies
the shipped Lua filters, reference docx, Excel templates, and pandoc
header into `input_md/` and `input_tables/`:

```
mytrial_demo/
├── .here
├── .StataEnviron.example              ← copy to .StataEnviron if you need shared paths
├── do_files/
│   ├── 00-final-do-file.do            ← the master, regenerable
│   ├── 01-create-datasets.do          ← stubs you fill in
│   ├── … 07-listings.do
│   └── helpers/
├── programs/                          ← project-local .ado files
├── input_md/
│   ├── header.txt                     ← generated from title/subtitle
│   ├── *.lua                          ← pandoc filters (ready to use)
│   └── custom_reference*.docx
├── input_tables/
│   ├── tables_labels.xlsx
│   └── shift_graph_input.xlsx
├── output_md/, output_tables/, output_figures/, output_word/
├── local_datasets/
└── logs/
```

## 4. Point at your data

Open `do_files/00-final-do-file.do`. You'll see a section that looks
like this (abbreviated):

```stata
statareport_set_data_root, path("local_datasets")     // TODO: point at your data export

statareport_add_data, name(preselection)   path("preselection_visit.dta")
statareport_add_data, name(demo)           path("demog.dta")
statareport_add_data, name(vital_signs)    path("vital_signs.dta")
statareport_add_data, name(adverse_events) path("adverse_events.dta")
```

For this demo we'll use `sysuse auto` instead. Replace that block with:

```stata
* load the Auto dataset into local_datasets/ so add_data can find it
sysuse auto, clear
save "local_datasets/auto.dta", replace

statareport_set_data_root, path("local_datasets")
statareport_add_data, name(auto) path("auto.dta")
statareport_confirm_data
```

## 5. Write the analysis (step 03)

Open `do_files/03-baseline.do` and replace the `// TODO` stub with:

```stata
use "$data_auto", clear

quietly {
    gen heavy = weight > 3000 if !missing(weight)
    label var heavy "Weight > 3,000 lbs"
    label define yesno 0 "No" 1 "Yes"
    label values heavy yesno
}

quant price mpg weight, ///
    output("$dir_tables/auto_quant.dta") by(foreign) addtotal

qual heavy, ///
    output("$dir_tables/auto_qual.dta") by(foreign) addtotal

* Label the tables so create_dyntex / kable know what to print
label_table, tab_file("$dir_tables/auto_quant.dta") ///
    label_file("$file_label") tab_id("quant_auto")

use "$dir_tables/auto_quant.dta", clear
convert_wisely *
save "$dir_lbltables/quant_auto.dta", replace
```

(Real reports fill in 02, 04–07 similarly — each operates on the
`$data_*` globals registered in 00.)

## 6. Register the table in `tables_labels.xlsx`

The Excel file shipped by `statareport_init_project` has sample rows.
Open it and add (or keep) a row whose `InputID` is `quant_auto`,
`Include` = `Yes`, `Caption` = `Demographics by origin`, etc. The
Lua filter + `create_dyntex` will pick it up.

## 7. Render

Run the whole do-file top-to-bottom:

```stata
do do_files/00-final-do-file.do
```

The tail calls `statareport_render`, which stitches together:

1. **`create_dyntex`** — reads `tables_labels.xlsx`, writes a DynTex
   control file to `output_md/AutoDemo-dyn.txt`.
2. **`dyntext`** — compiles the DynTex into a Markdown document at
   `output_md/AutoDemo.txt` (calling `kable` for every referenced table).
3. **`knit`** — auto-generates a pandoc defaults YAML with your filters
   / header / reference.docx / TOC / numbering and runs pandoc.

The finished document lands at
`output_word/AutoDemo-<YYYYMMDD>.docx`.

!!! success "You're done"
    Every future run is a single `do do_files/00-final-do-file.do`.
    Change your analysis code, re-run, and the `.docx` regenerates.

## Next steps

- Regenerate `header.txt` whenever the study title changes:
  [`statareport_write_header`](commands/statareport_write_header.md).
- Keep machine-specific paths out of git with
  [`.StataEnviron`](configuration.md).
- Add a listings variant:
  ```stata
  statareport_render, variant("listings") toc(no)
  ```
- For very custom pandoc YAML, hand-edit
  `input_md/default_options.yaml` and pass it through `default()`.
