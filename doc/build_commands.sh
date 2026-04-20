#!/usr/bin/env bash
# doc/build_commands.sh -- regenerate doc/docs/commands/*.md from ado/*.sthlp.
#
# Usage (from the repository root):
#     ./doc/build_commands.sh
#
# The script relies only on awk + POSIX shell so it runs unchanged under
# GitHub Actions (ubuntu-latest) and macOS.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ADO="$REPO/ado"
OUT="$REPO/doc/docs/commands"
REPO_URL="https://github.com/epicentre-msf/statareport/blob/main"

# Internal helpers we don't surface in the command index.
SKIP="statareport__apply_order statareport__read_file statareport__writenone"

mkdir -p "$OUT"

convert_one() {
    local src="$1"
    local stem="$2"
    awk -v stem="$stem" -v repo_url="$REPO_URL" '
    function render_inline(s,   payload, colon, head, tail, rendered, cmd, label) {
        # {* ...} comments (inline)
        gsub(/\{\*[^}]*\}/, "", s)
        # {cmdab:root:tail}  ->  **`root`**`tail`
        while (match(s, /\{cmdab:[^}]+\}/)) {
            payload = substr(s, RSTART+7, RLENGTH-8)
            colon = index(payload, ":")
            if (colon > 0) {
                head = substr(payload, 1, colon-1)
                tail = substr(payload, colon+1)
                rendered = "**`" head "`**`" tail "`"
            } else {
                rendered = "`" payload "`"
            }
            s = substr(s, 1, RSTART-1) rendered substr(s, RSTART+RLENGTH)
        }
        # {cmd:X}  ->  `X`
        while (match(s, /\{cmd:[^}]+\}/)) {
            payload = substr(s, RSTART+5, RLENGTH-6)
            s = substr(s, 1, RSTART-1) "`" payload "`" substr(s, RSTART+RLENGTH)
        }
        # {opt X}  or  {opt:X}  ->  `X`
        while (match(s, /\{opt[: ][^}]+\}/)) {
            payload = substr(s, RSTART+5, RLENGTH-6)
            s = substr(s, 1, RSTART-1) "`" payload "`" substr(s, RSTART+RLENGTH)
        }
        # {opth X}  ->  `X`
        while (match(s, /\{opth [^}]+\}/)) {
            payload = substr(s, RSTART+6, RLENGTH-7)
            s = substr(s, 1, RSTART-1) "`" payload "`" substr(s, RSTART+RLENGTH)
        }
        # {it:X}  ->  *X*
        while (match(s, /\{it:[^}]+\}/)) {
            payload = substr(s, RSTART+4, RLENGTH-5)
            s = substr(s, 1, RSTART-1) "*" payload "*" substr(s, RSTART+RLENGTH)
        }
        # {bf:X}  ->  **X**
        while (match(s, /\{bf:[^}]+\}/)) {
            payload = substr(s, RSTART+4, RLENGTH-5)
            s = substr(s, 1, RSTART-1) "**" payload "**" substr(s, RSTART+RLENGTH)
        }
        # {hi:X}  ->  **X**
        while (match(s, /\{hi:[^}]+\}/)) {
            payload = substr(s, RSTART+4, RLENGTH-5)
            s = substr(s, 1, RSTART-1) "**" payload "**" substr(s, RSTART+RLENGTH)
        }
        # {help X}  or  {help X:label}
        # Link only to commands we actually ship; render Stata builtins
        # as plain code so `mkdocs --strict` does not trip on missing
        # files.
        while (match(s, /\{help [^}]+\}/)) {
            payload = substr(s, RSTART+6, RLENGTH-7)
            colon = index(payload, ":")
            if (colon > 0) {
                cmd = substr(payload, 1, colon-1)
                label = substr(payload, colon+1)
            } else {
                cmd = payload
                label = payload
            }
            # Stata builtins / external references -- not linkified.
            if (cmd == "do" || cmd == "adopath" || cmd == "dyntext" || \
                cmd == "help" || cmd == "sysuse" || cmd == "net" || \
                cmd == "findfile" || cmd == "confirm" || cmd == "capture" || \
                cmd == "pandoc") {
                rendered = "`" label "`"
            } else if (colon > 0) {
                rendered = "[" label "](" cmd ".md)"
            } else {
                rendered = "[`" payload "`](" payload ".md)"
            }
            s = substr(s, 1, RSTART-1) rendered substr(s, RSTART+RLENGTH)
        }
        # {break}  ->  hard line break (two spaces)
        gsub(/\{break\}/, "  ", s)
        # {hline N}  ->  ---
        gsub(/\{hline[^}]*\}/, "---", s)
        # {...} (literal ellipsis marker)
        gsub(/\{\.\.\.\}/, "", s)
        # Strip {p_end} wherever it appears
        gsub(/\{p_end\}/, "", s)
        # Unknown tags are left as-is so block-level handlers can still
        # see {synopt:...}, {title:...}, etc.
        return s
    }

    BEGIN {
        first_title_seen = 0
    }

    # Strip file directive and version pragma
    /^\{smcl\}/ { next }
    /^\{\*[ \t]*\*!.*version/ { next }

    # {title:Foo}
    /\{title:[^}]*\}/ {
        line = $0
        if (match(line, /\{title:[^}]*\}/)) {
            payload = substr(line, RSTART+7, RLENGTH-8)
            if (!first_title_seen) {
                printf "# `%s`\n\n", stem
                first_title_seen = 1
                # And keep the body after the title tag, if any
                after = substr(line, RSTART+RLENGTH)
                if (length(after) > 0) print render_inline(after)
            } else {
                printf "\n## %s\n\n", render_inline(payload)
            }
            next
        }
    }

    # {synoptline}
    /\{synoptline\}/ {
        print ""
        print "---"
        print ""
        next
    }

    # {synopthdr:Foo}
    /\{synopthdr:[^}]*\}/ {
        line = $0
        if (match(line, /\{synopthdr:[^}]*\}/)) {
            payload = substr(line, RSTART+11, RLENGTH-12)
            print ""
            printf "**%s**\n\n", payload
            next
        }
    }

    # {synoptset ...} and {p2colreset}
    /^\{synoptset/ { next }
    /^[ \t]*\{p2colreset\}/ { next }
    /^\{p2colreset\}/ { next }

    # {synopt:OPT}DESC{p_end}
    # Render inline first so nested {cmd:} {it:} collapse to markdown,
    # then split on the synopt close.
    /\{synopt:/ {
        line = render_inline($0)
        if (match(line, /\{synopt:[^}]*\}/)) {
            payload = substr(line, RSTART+8, RLENGTH-9)
            rest = substr(line, RSTART+RLENGTH)
            sub(/^[ \t]*/, "", rest)
            if (length(rest) > 0) {
                printf "- %s — %s\n", payload, rest
            } else {
                printf "- %s\n", payload
            }
            next
        }
    }

    # Structural paragraph tags
    /^[ \t]*\{pstd\}/ {
        sub(/^[ \t]*\{pstd\}/, "", $0)
        print render_inline($0)
        next
    }
    /^[ \t]*\{phang\}/ {
        sub(/^[ \t]*\{phang\}/, "> ", $0)
        print render_inline($0)
        next
    }
    /^[ \t]*\{phang2\}/ {
        sub(/^[ \t]*\{phang2\}/, "    ", $0)
        print render_inline($0)
        next
    }
    /^[ \t]*\{psee\}/ {
        sub(/^[ \t]*\{psee\}/, "> ", $0)
        print render_inline($0)
        next
    }
    /^[ \t]*\{p [0-9]/ {
        sub(/^[ \t]*\{p [^}]*\}/, "", $0)
        print render_inline($0)
        next
    }
    /^[ \t]*\{p_end\}[ \t]*$/ { print ""; next }

    # {* ...} line comment
    /^\{\*[^}]*\}[ \t]*$/ { next }

    # Fallback: render inline
    { print render_inline($0) }
    ' "$src"
}

count=0
for sthlp in "$ADO"/*.sthlp; do
    stem=$(basename "$sthlp" .sthlp)
    skip_this=0
    for s in $SKIP; do
        if [ "$stem" = "$s" ]; then
            skip_this=1
            break
        fi
    done
    [ "$skip_this" = 1 ] && continue

    dst="$OUT/$stem.md"
    {
        convert_one "$sthlp" "$stem"
        printf '\n---\n\n*Source*: [`ado/%s.sthlp`](%s/ado/%s.sthlp)\n' \
            "$stem" "$REPO_URL" "$stem"
    } > "$dst"
    count=$((count + 1))
done

echo "wrote $count command pages to doc/docs/commands"
