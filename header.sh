#!/bin/bash

set -euo pipefail

LOGIN=""
EMAIL=""
DIR="."
EXTS="c h"
DRY_RUN=0

usage() {
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

while getopts ":l:e:d:x:nh" opt; do
    case "$opt" in
        l) LOGIN="$OPTARG" ;;
        e) EMAIL="$OPTARG" ;;
        d) DIR="$OPTARG" ;;
        x) EXTS="$OPTARG" ;;
        n) DRY_RUN=1 ;;
        h) usage 0 ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage 1 ;;
        \?) echo "Unknown option: -$OPTARG" >&2; usage 1 ;;
    esac
done
shift $((OPTIND - 1))

[ -z "$LOGIN" ] && { echo "error: -l <login> is required" >&2; usage 1; }

case "$LOGIN" in
    *[!a-zA-Z0-9_-]*) echo "error: invalid login: $LOGIN" >&2; exit 1 ;;
esac

[ -z "$EMAIL" ] && EMAIL="${LOGIN}@student.42.fr"
[ -d "$DIR" ] || { echo "error: not a directory: $DIR" >&2; exit 1; }

DATE=$(date +"%Y/%m/%d %H:%M:%S")

FILES=()
while IFS= read -r -d '' f; do
    FILES+=("$f")
done < <(
    find "$DIR" \
        \( -type d \( -name .git -o -name .svn -o -name .hg \) -prune \) -o \
        -type f -print0 \
    | while IFS= read -r -d '' path; do
        ext="${path##*.}"
        for want in $EXTS; do
            if [ "$ext" = "$want" ]; then
                printf '%s\0' "$path"
                break
            fi
        done
      done
)

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No matching files (extensions: $EXTS) under $DIR"
    exit 1
fi

write_header() 
{
    local fname="$1"
    local who="$LOGIN <$EMAIL>"
    local login_pad="$LOGIN"

    if [ ${#who} -gt 42 ]; then
        who="${who:0:42}"
    fi
    if [ ${#login_pad} -gt 18 ]; then
        login_pad="${login_pad:0:18}"
    fi
    if [ ${#fname} -gt 51 ]; then
        fname="${fname:0:51}"
    fi

    printf '/* ************************************************************************** */\n'
    printf '/*                                                                            */\n'
    printf '/*                                                        :::      ::::::::   */\n'
    printf '/*   %-51s :+:      :+:    :+:   */\n' "$fname"
    printf '/*                                                    +:+ +:+         +:+     */\n'
    printf '/*   By: %-42s +#+  +:+       +#+        */\n' "$who"
    printf '/*                                                +#+#+#+#+#+   +#+           */\n'
    printf '/*   Created: %s by %-18s #+#    #+#             */\n' "$DATE" "$login_pad"
    printf '/*   Updated: %s by %-18s ###   ########.fr       */\n' "$DATE" "$login_pad"
    printf '/*                                                                            */\n'
    printf '/* ************************************************************************** */\n'
}
HEADER_RE='^/\* \*{74} \*/$'

changed=0
preview=0

for f in "${FILES[@]}"; do
    [ -f "$f" ] || continue

    if head -n 1 "$f" 2>/dev/null | grep -Eq "$HEADER_RE"; then
        body=$(tail -n +12 "$f")
        had_header=1
    else
        body=$(cat "$f")
        had_header=0
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'would %s: %s\n' \
            "$([ "$had_header" -eq 1 ] && echo 'rewrite' || echo 'add')" "$f"
        preview=$((preview + 1))
        continue
    fi

    base=$(basename "$f")
    {
        write_header "$base"
        [ -n "$body" ] && printf '%s\n' "$body"
    } > "$f.tmp"
    mv "$f.tmp" "$f"
    echo "header added: $f"
    changed=$((changed + 1))
done

if [ "$DRY_RUN" -eq 1 ]; then
    echo "Dry run: $preview file(s) would be processed."
else
    echo "Done. $changed file(s) updated."
fi
