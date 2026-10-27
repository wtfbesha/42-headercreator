#!/bin/bash
# add_header.sh — prepend a 42 header to every .c and .h file in the cwd.
# Usage: ./add_header.sh <login> [email]

set -e

LOGIN="${1:-mtorfs}"
EMAIL="${2:-${LOGIN}@student.42.fr}"

if [ -z "$LOGIN" ]; then
    echo "Usage: $0 <login> [email]"
    exit 1
fi

DATE=$(date +"%Y/%m/%d %H:%M:%S")

shopt -s nullglob
files=( *.c *.h )
if [ ${#files[@]} -eq 0 ]; then
    echo "No .c or .h files in $(pwd)"
    exit 1
fi

for f in "${files[@]}"; do
    # Detect if file already starts with a 42 header (first line contains the banner)
    if head -n 1 "$f" | grep -q '^/\* \*\{74\} \*/$'; then
        # Skip first 11 lines (the existing header)
        body=$(tail -n +12 "$f")
    else
        body=$(cat "$f")
    fi

    # Build the header with the filename padded to 51 chars
    printf '/* ************************************************************************** */\n'
    printf '/*                                                                            */\n'
    printf '/*                                                        :::      ::::::::   */\n'
    printf '/*   %-50s :+:      :+:    :+:   */\n' "$f"
    printf '/*                                                    +:+ +:+         +:+     */\n'
    printf '/*   By: %-42s +#+  +:+       +#+        */\n' "$LOGIN <$EMAIL>"
    printf '/*                                                +#+#+#+#+#+   +#+           */\n'
    printf '/*   Created: %s by %-15s #+#    #+#             */\n' "$DATE" "$LOGIN"
    printf '/*   Updated: %s by %-15s ###   ########.fr       */\n' "$DATE" "$LOGIN"
    printf '/*                                                                            */\n'
    printf '/* ************************************************************************** */\n'
    printf '%s\n' "$body"
done > /tmp/libft_with_headers.txt

# Write back into files one by one (safer than trying to split the combined output)
for f in "${files[@]}"; do
    if head -n 1 "$f" | grep -q '^/\* \*\{74\} \*/$'; then
        body=$(tail -n +12 "$f")
    else
        body=$(cat "$f")
    fi

    {
        printf '/* ************************************************************************** */\n'
        printf '/*                                                                            */\n'
        printf '/*                                                        :::      ::::::::   */\n'
        printf '/*   %-50s :+:      :+:    :+:   */\n' "$f"
        printf '/*                                                    +:+ +:+         +:+     */\n'
        printf '/*   By: %-42s +#+  +:+       +#+        */\n' "$LOGIN <$EMAIL>"
        printf '/*                                                +#+#+#+#+#+   +#+           */\n'
        printf '/*   Created: %s by %-15s #+#    #+#             */\n' "$DATE" "$LOGIN"
        printf '/*   Updated: %s by %-15s ###   ########.fr       */\n' "$DATE" "$LOGIN"
        printf '/*                                                                            */\n'
        printf '/* ************************************************************************** */\n'
        printf '%s\n' "$body"
    } > "$f.tmp"
    mv "$f.tmp" "$f"
    echo "header added: $f"
done

rm -f /tmp/libft_with_headers.txt
echo "Done."
