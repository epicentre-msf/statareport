{smcl}
{* *! version 1.3 16jun2026}
{title:Title}
{pstd}{bf:translate_dta_labels} {hline 2} Translate the free-text fields of a label-export file from one language into another via the Anthropic Messages API.

{title:Syntax}
{p 4 8 2}{cmd:translate_dta_labels} [{cmd:,} {it:options}]
{p_end}

{synoptset 30 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt in:file(string)}}flat file produced by {help export_dta_labels} (default: {cmd:var_lbl_folder.txt}){p_end}
{synopt:{opt out:file(string)}}translated flat file to write (default: {cmd:var_lbl_folder_en.txt}){p_end}
{synopt:{opt mod:el(string)}}Anthropic model id (default: {cmd:claude-sonnet-4-6}){p_end}
{synopt:{opt from:lang(string)}}source language (default: {cmd:French}){p_end}
{synopt:{opt to:lang(string)}}target language (default: {cmd:English}){p_end}
{synopt:{opt keyv:ar(string)}}environment variable holding the API key (default: {cmd:ANTH_API_KEY}){p_end}
{synopt:{opt env:file(string)}}dotenv file the shell sources for the key (default: {cmd:.StataEnviron} at the project root){p_end}
{synopt:{opt chunk:size(integer)}}records sent per API request (default: 100){p_end}
{synopt:{opt max:tokens(integer)}}max output tokens per request (default: 8192){p_end}
{synopt:{opt verb:ose}}report each chunk as it succeeds{p_end}
{synopt:{opt dry:run}}preflight only: show counts and the generated script, make no API call{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}
{pstd}{cmd:translate_dta_labels} is the second step of the label-translation
pipeline. It reads the pipe-delimited file written by {help export_dta_labels},
sends the records to the Anthropic Messages API in chunks, and writes a file of
the same shape in which only the final free-text field of each record has been
translated from {opt fromlang} into {opt tolang}. Tags, file names, variable
names, value-label sets, codes and note indices are copied verbatim, and the
{cmd:#} header lines are preserved, so the result drops straight into
{help apply_dta_labels}.

{pstd}The translation runs by shelling out to {cmd:curl} and {cmd:jq}, which must
be on the {cmd:PATH} (install {cmd:jq} with {cmd:brew install jq}). {cmd:jq}
builds the JSON request body so every field is correctly escaped.

{pstd}{bf:API key handling.} The key is never read into a Stata command string
or written to disk. The OS shell sources the project {cmd:.StataEnviron} (a
{cmd:KEY=VALUE} dotenv file) and expands the variable named by {opt keyvar} at
call time, so the value flows file {c -}>{c -} shell {c -}>{c -} request without
passing through Stata. The recommended setup is therefore a project-level
{cmd:.StataEnviron} containing a line like {cmd:ANTH_API_KEY=sk-...} (an optional
{cmd:export} prefix and surrounding quotes are accepted).

{pstd}The key may instead be exported in the operating-system environment. The
preflight accepts the key if it is found in {opt envfile} {it:or} the OS
environment, and errors with a hint otherwise. On macOS a GUI-launched Stata
ignores {cmd:~/.zprofile} and {cmd:~/.zshrc}: either use {cmd:.StataEnviron} as
above, put the variable in {cmd:~/.zshenv} and launch Stata from a terminal, or
run {cmd:launchctl setenv ANTH_API_KEY <key>}.

{pstd}{bf:Robustness.} Records are processed in chunks of {opt chunksize}. If a
chunk returns a non-200 HTTP status, or returns a different number of lines than
were sent, that chunk's original (untranslated) lines are kept and the run
continues. The command reports how many chunks failed so nothing is silently
dropped.

{title:Options}
{phang}{opt infile(string)} the export file to translate. Defaults to
{cmd:var_lbl_folder.txt}.

{phang}{opt outfile(string)} the translated file to write. Defaults to
{cmd:var_lbl_folder_en.txt}, which is the default {opt infile} of
{help apply_dta_labels}.

{phang}{opt model(string)} Anthropic model id used for the translation. Defaults
to {cmd:claude-sonnet-4-6}.

{phang}{opt fromlang(string)} the language the labels are written in. Defaults to
{cmd:French}.

{phang}{opt tolang(string)} the language to translate into. Defaults to
{cmd:English}. Set it to translate into any other target language; text already
in {opt tolang} is left unchanged.

{phang}{opt keyvar(string)} name of the environment variable holding the
Anthropic API key. Defaults to {cmd:ANTH_API_KEY}.

{phang}{opt envfile(string)} path to a dotenv file that the shell sources to
obtain the key. When omitted, {cmd:.StataEnviron} at the cached {help here}
project root is used, or {cmd:.StataEnviron} in the current directory if no root
is cached. The file is only read by the shell, never by Stata; if it does not
exist, the command falls back to the OS environment.

{phang}{opt chunksize(integer)} number of records sent per API request. Defaults
to 100. Smaller chunks are more robust to per-request line-count mismatches;
larger chunks make fewer calls.

{phang}{opt maxtokens(integer)} maximum number of output tokens requested per
API call. Defaults to 8192.

{phang}{opt verbose} display a confirmation line for each chunk that succeeds.

{phang}{opt dryrun} run the preflight checks, report the record count, chunk
size and model, print the paths to the generated run script and system prompt,
then exit without calling the API.

{title:Examples}
{phang}{cmd:. translate_dta_labels, dryrun}{p_end}

{phang}{cmd:. translate_dta_labels}{p_end}

{phang}{cmd:. translate_dta_labels, fromlang("Spanish") tolang("English") verbose}{p_end}

{phang}{cmd:. translate_dta_labels, infile("labels.txt") outfile("labels_en.txt") chunksize(50)}{p_end}

{phang}{cmd:. translate_dta_labels, envfile("config/secrets.env") keyvar("MY_ANTHROPIC_KEY")}{p_end}

{title:Workflow}
{pstd}{cmd:translate_dta_labels} sits between {help export_dta_labels} and
{help apply_dta_labels}:

{p 8 12 2}{cmd:export_dta_labels} {c -} >{c -} {cmd:translate_dta_labels} {c -} >{c -} {cmd:apply_dta_labels}{p_end}

{title:Also see}
{pstd}{help export_dta_labels}, {help apply_dta_labels}{p_end}
