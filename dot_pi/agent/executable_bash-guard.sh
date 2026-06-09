#!/usr/bin/env bash

set -euo pipefail

cmd="${1}"

[[ -z "${cmd}" ]] && exit 0

if echo "${cmd}" | grep -qP '\bgit\b.*\b(clean|commit|push|reset|rm)\b'; then
    echo 'Prohibited git operation' >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\b(rm|unlink|rmdir|shred|wipe|truncate|dd|fallocate)\b'; then
    echo "destructive command blocked" >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\bfind\b.*\b(-delete|-exec\s+(/.*/)?rm\b|-execdir\s+(/.*/)?rm\b)'; then
    echo "destructive find command blocked" >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\b(perl|python3?|ruby|node|php|lua|Rscript)\b.*\s-[ecEC]\b'; then
    exit 2
fi
