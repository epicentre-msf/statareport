---
hide:
  - navigation
---

# statareport

<div markdown>
<img src="assets/hexa.png" alt="statareport hex sticker" width="180" align="right" style="margin-left: 2em; margin-bottom: 1em;">

**A Stata package for automated Stata-to-Word reporting.**

Go from empty folder to a rendered `.docx` with a single `statareport_render`.
The package bundles publication-ready table commands (`quant`, `qual`, `kable`),
a project scaffold (`statareport_init_project`), a configuration loader
(`.StataEnviron`), and a Pandoc-driven render pipeline (`create_dyntex` +
`dyntext` + `knit`) stitched together through convention-based globals.

</div>

<div style="clear: both;"></div>

## Highlights

- :material-folder-plus: **`statareport_init_project`** scaffolds the whole project — folders, master do-file, pandoc resources.
- :material-cog: **`.StataEnviron`** keeps machine-specific paths out of the repository.
- :material-format-list-bulleted: **`statareport_set_paths`** replaces 15+ hand-written `global file_*` lines with one call.
- :material-database: **`statareport_add_data`** registers datasets *and* confirms them in one step.
- :material-play: **`statareport_render`** wraps the three-stage pipeline in a single command.
- :material-file-word: **`knit`** auto-generates the Pandoc defaults YAML and auto-detects the pandoc binary.

## Quick install

```stata
net install statareport, from("https://raw.githubusercontent.com/epicentre-msf/statareport/main/") replace
```

See [**Installation**](install.md) for alternatives (local directory, subfolder layouts).

## Where to go next

- New here? [**Your first report**](tutorial.md) walks through a full render from `cd`
  to the finished `.docx`.
- Using statareport in an existing project? Jump to [**Workflow overview**](workflow.md).
- Looking for a specific command? [**Commands overview**](commands/index.md)
  has the full index.

## License

MIT. See the [project on GitHub](https://github.com/epicentre-msf/statareport).
