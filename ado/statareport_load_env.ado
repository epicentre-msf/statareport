*! statareport_load_env -- read .StataEnviron + OS env vars into $dir_* globals
*!
*! Looks for KEY=VALUE pairs (like a dotenv file) and exposes them as
*! Stata globals. Each KEY maps to a global name:
*!
*!     ONEDRIVE  -> $dir_onedrive
*!     DATASETS  -> $dir_datasets (+ primed as statareport_set_data_root)
*!     PROJECT   -> $dir_project
*!     XXX       -> $dir_xxx    (case-insensitive; global is always lower)
*!
*! Lookup order:
*!     1. Options: env(KEY=VAL ...)               -- explicit in the do-file
*!     2. File:    .StataEnviron at the project root (or the path in file())
*!     3. OS env:  $ONEDRIVE, $DATASETS, $PROJECT, $STATAREPORT_*
*!
*! Usage:
*!     statareport_load_env
*!     statareport_load_env, file("config/prod.env")
*!     statareport_load_env, env("ONEDRIVE=/Users/me/OneDrive DATASETS=/data")
*!
*! Options:
*!     file(str)    path to the env file. Default: <here-root>/.StataEnviron.
*!     env(str)     inline KEY=VALUE pairs, space-separated.
*!     prefix(str)  only load keys that start with this prefix (e.g.
*!                  "STATAREPORT_"). The prefix is stripped before naming
*!                  the global.
*!     keepcase     preserve the original key case in the global name
*!                  (default: lowercase).
*!     noos         skip the operating-system env fallback.
*!     quiet        suppress the per-key "loaded" line.
*!
*! Stored results:
*!     r(loaded)    space-separated list of globals that were set
*!     r(n_loaded)  count
*!     r(source)    "file", "env", "os", "mixed", or "none"

capture program drop statareport_load_env
program define statareport_load_env, rclass
    version 15
    syntax [, FILE(string) ENV(string) PREfix(string) ///
        KEEPcase NOOS QUIet]

    // 1. Resolve the env file path.
    local _file `"`file'"'
    if (`"`_file'"' == "") {
        local root ""
        capture mata: st_local("root", __here_root__)
        if (`"`root'"' != "") local _file `"`root'/.StataEnviron"'
        else                  local _file `".StataEnviron"'
    }

    // 2. Collect raw KEY=VALUE pairs in deterministic precedence order.
    //    env() option wins over the file; the file wins over the OS env.
    tempname pairs
    mata: statareport_env_init()

    local had_file 0
    local had_env  0
    local had_os   0

    capture confirm file `"`_file'"'
    if (!_rc) {
        mata: statareport_env_read_file(`"`_file'"')
        local had_file 1
    }

    if (`"`env'"' != "") {
        mata: statareport_env_read_inline(`"`env'"')
        local had_env 1
    }

    if ("`noos'" == "") {
        tempfile osenv
        if (c(os) == "Windows") {
            capture !set > "`osenv'" 2>&1
        }
        else {
            capture !printenv > "`osenv'" 2>&1
        }
        capture confirm file "`osenv'"
        if (!_rc) {
            mata: statareport_env_read_osfile(`"`osenv'"')
            local had_os 1
        }
    }

    // 3. Emit Stata globals.
    local lowercase = ("`keepcase'" == "")
    local loaded ""
    mata: statareport_env_emit(`"`prefix'"', strofreal(`lowercase'), "loaded")

    // 4. If DATASETS was provided, prime statareport_set_data_root too.
    if ("$dir_datasets" != "") {
        capture statareport_set_data_root, path("$dir_datasets") quiet
    }

    // 5. Count and report.
    local n : word count `loaded'
    local source "none"
    if (`had_file' + `had_env' + `had_os' == 1) {
        if (`had_file') local source "file"
        else if (`had_env') local source "env"
        else local source "os"
    }
    else if (`n' > 0) {
        local source "mixed"
    }

    if ("`quiet'" == "" & `n' > 0) {
        display as text "statareport_load_env: " as result "`n' global(s)" ///
            as text " loaded from " as result "`source'"
        foreach g of local loaded {
            display as text "  " as result "$`g'" ///
                as text " = " as result `"${`g'}"'
        }
    }

    return local loaded   `"`loaded'"'
    return scalar n_loaded = `n'
    return local source   "`source'"
    return local file     `"`_file'"'
end

// =====================================================================
// Mata helpers -- store accumulated KEY -> VALUE pairs, then emit.
// =====================================================================
capture mata mata drop statareport_env_init()
capture mata mata drop statareport_env_read_file()
capture mata mata drop statareport_env_read_inline()
capture mata mata drop statareport_env_read_os()
capture mata mata drop statareport_env_emit()
capture mata mata drop statareport_env_put()

mata:
void statareport_env_init()
{
    external string matrix __statareport_env__
    __statareport_env__ = J(0, 2, "")
}

void statareport_env_put(string scalar key, string scalar value)
{
    external string matrix __statareport_env__
    real scalar i, n
    n = rows(__statareport_env__)
    // upsert: last value wins
    for (i = 1; i <= n; i++) {
        if (__statareport_env__[i, 1] == key) {
            __statareport_env__[i, 2] = value
            return
        }
    }
    __statareport_env__ = __statareport_env__ \ (key, value)
}

void statareport_env_read_file(string scalar path)
{
    real scalar fh
    string scalar line, key, value
    real scalar eq

    fh = fopen(path, "r")
    while ((line = fget(fh)) != J(0,0,"")) {
        line = strtrim(line)
        if (line == "" | substr(line, 1, 1) == "#") continue
        // allow optional "export " prefix a la shell
        if (substr(line, 1, 7) == "export ") line = strtrim(substr(line, 8, .))
        eq = strpos(line, "=")
        if (eq <= 1) continue
        key = strtrim(substr(line, 1, eq - 1))
        value = strtrim(substr(line, eq + 1, .))
        // strip surrounding quotes if present
        if (strlen(value) >= 2 & (substr(value, 1, 1) == "\"" | substr(value, 1, 1) == "'")) {
            if (substr(value, strlen(value), 1) == substr(value, 1, 1)) {
                value = substr(value, 2, strlen(value) - 2)
            }
        }
        statareport_env_put(key, value)
    }
    fclose(fh)
}

void statareport_env_read_inline(string scalar raw)
{
    string rowvector toks
    string scalar t, key, value
    real scalar i, eq
    toks = tokens(raw)
    for (i = 1; i <= cols(toks); i++) {
        t = toks[i]
        eq = strpos(t, "=")
        if (eq <= 1) continue
        key = substr(t, 1, eq - 1)
        value = substr(t, eq + 1, .)
        statareport_env_put(key, value)
    }
}

void statareport_env_read_osfile(string scalar path)
{
    // Parse the output of `printenv' (POSIX) or `set' (Windows). Only
    // pick up keys from a known allow-list plus anything prefixed
    // with STATAREPORT_ -- avoid polluting the store with every
    // PATH / HOME / ... that the shell exports.
    string rowvector allow
    real scalar fh, i, eq, accept
    string scalar line, key, value
    allow = ("ONEDRIVE", "DATASETS", "PROJECT",
             "DIR_ONEDRIVE", "DIR_DATASETS", "DIR_PROJECT")

    fh = fopen(path, "r")
    while ((line = fget(fh)) != J(0,0,"")) {
        line = strtrim(line)
        eq = strpos(line, "=")
        if (eq <= 1) continue
        key = substr(line, 1, eq - 1)
        value = substr(line, eq + 1, .)
        // allowlist match or STATAREPORT_* prefix
        accept = 0
        for (i = 1; i <= cols(allow); i++) {
            if (key == allow[i]) {
                accept = 1
                break
            }
        }
        if (substr(key, 1, 12) == "STATAREPORT_") accept = 1
        if (accept) statareport_env_put(key, value)
    }
    fclose(fh)
}

void statareport_env_emit(string scalar prefix, string scalar lowercase_s,
                           string scalar loaded_local)
{
    external string matrix __statareport_env__
    real scalar n, i, lowercase
    string scalar key, value, gname, loaded
    lowercase = strtoreal(lowercase_s)
    loaded = ""

    n = rows(__statareport_env__)
    for (i = 1; i <= n; i++) {
        key = __statareport_env__[i, 1]
        value = __statareport_env__[i, 2]

        if (prefix != "") {
            if (substr(key, 1, strlen(prefix)) != prefix) continue
            key = substr(key, strlen(prefix) + 1, .)
        }

        gname = (lowercase ? strlower(key) : key)
        if (substr(gname, 1, 4) != "dir_") gname = "dir_" + gname

        // Validate as Stata identifier
        if (!regexm(gname, "^[A-Za-z_][A-Za-z0-9_]*$")) continue

        // Emit as a Stata global
        st_global(gname, value)

        loaded = loaded + " " + gname
    }

    st_local(loaded_local, strtrim(loaded))
}
end
