# `translate_dta_labels`

**translate_dta_labels** --- Translate the free-text fields of a label-export file from one language into another via the Anthropic Messages API.


## Syntax

`translate_dta_labels` [`,` *options*]



**Options**


---

- `in:file(string)` — flat file produced by [`export_dta_labels`](export_dta_labels.md) (default: `var_lbl_folder.txt`)
- `out:file(string)` — translated flat file to write (default: `var_lbl_folder_en.txt`)
- `mod:el(string)` — Anthropic model id (default: `claude-sonnet-4-6`)
- `from:lang(string)` — source language (default: `French`)
- `to:lang(string)` — target language (default: `English`)
- `keyv:ar(string)` — environment variable holding the API key (default: `ANTH_API_KEY`)
- `chunk:size(integer)` — records sent per API request (default: 100)
- `max:tokens(integer)` — max output tokens per request (default: 8192)
- `verb:ose` — report each chunk as it succeeds
- `dry:run` — preflight only: show counts and the generated script, make no API call

---



## Description

`translate_dta_labels` is the second step of the label-translation
pipeline. It reads the pipe-delimited file written by [`export_dta_labels`](export_dta_labels.md),
sends the records to the Anthropic Messages API in chunks, and writes a file of
the same shape in which only the final free-text field of each record has been
translated from `fromlang` into `tolang`. Tags, file names, variable
names, value-label sets, codes and note indices are copied verbatim, and the
`#` header lines are preserved, so the result drops straight into
[`apply_dta_labels`](apply_dta_labels.md).

The translation runs by shelling out to `curl` and `jq`, which must
be on the `PATH` (install `jq` with `brew install jq`). `jq`
builds the JSON request body so every field is correctly escaped.

**API key handling.** The key is never read into a Stata command string
or written to disk. Stata only checks that the environment variable named by
`keyvar` is visible and non-empty; the OS shell expands it at call time when
the request is sent. On macOS a GUI-launched Stata ignores `~/.zprofile` and
`~/.zshrc`: put the variable in `~/.zshenv` and launch Stata from a
terminal, or run `launchctl setenv ANTH_API_KEY <key>`.

**Robustness.** Records are processed in chunks of `chunksize`. If a
chunk returns a non-200 HTTP status, or returns a different number of lines than
were sent, that chunk's original (untranslated) lines are kept and the run
continues. The command reports how many chunks failed so nothing is silently
dropped.


## Options

> `infile(string)` the export file to translate. Defaults to
`var_lbl_folder.txt`.

> `outfile(string)` the translated file to write. Defaults to
`var_lbl_folder_en.txt`, which is the default `infile` of
[`apply_dta_labels`](apply_dta_labels.md).

> `model(string)` Anthropic model id used for the translation. Defaults
to `claude-sonnet-4-6`.

> `fromlang(string)` the language the labels are written in. Defaults to
`French`.

> `tolang(string)` the language to translate into. Defaults to
`English`. Set it to translate into any other target language; text already
in `tolang` is left unchanged.

> `keyvar(string)` name of the environment variable holding the
Anthropic API key. Defaults to `ANTH_API_KEY`.

> `chunksize(integer)` number of records sent per API request. Defaults
to 100. Smaller chunks are more robust to per-request line-count mismatches;
larger chunks make fewer calls.

> `maxtokens(integer)` maximum number of output tokens requested per
API call. Defaults to 8192.

> `verbose` display a confirmation line for each chunk that succeeds.

> `dryrun` run the preflight checks, report the record count, chunk
size and model, print the paths to the generated run script and system prompt,
then exit without calling the API.


## Examples

> `. translate_dta_labels, dryrun`

> `. translate_dta_labels`

> `. translate_dta_labels, fromlang("Spanish") tolang("English") verbose`

> `. translate_dta_labels, infile("labels.txt") outfile("labels_en.txt") chunksize(50)`


## Workflow

`translate_dta_labels` sits between [`export_dta_labels`](export_dta_labels.md) and
[`apply_dta_labels`](apply_dta_labels.md):

`export_dta_labels` {c -} >{c -} `translate_dta_labels` {c -} >{c -} `apply_dta_labels`


## Also see

[`export_dta_labels`](export_dta_labels.md), [`apply_dta_labels`](apply_dta_labels.md)

---

*Source*: [`ado/translate_dta_labels.sthlp`](https://github.com/epicentre-msf/statareport/blob/main/ado/translate_dta_labels.sthlp)
