#!/usr/bin/env bash

set -euo pipefail

cmd="${1}"

[[ -z "${cmd}" ]] && exit 0

if echo "${cmd}" | grep -qP '\bgit\b.*\b(clean|commit|push|reset|rm)\b'; then
    echo 'prohibited git operation, ask the user to run the command manually' >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\b(mv|rm|unlink|rmdir|shred|wipe|truncate|dd|fallocate)\b'; then
    echo 'destructive command blocked, ask the user to run the command manually' >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\bfind\b.*\b(-delete|-exec\s+(/.*/)?rm\b|-execdir\s+(/.*/)?rm\b)'; then
    echo 'destructive find command blocked, ask the user to run the command manually' >&2
    exit 1
fi

if echo "${cmd}" | grep -qP '\b(perl|ruby|php|lua|Rscript)\b.*\s-[ecEC]\b'; then
    exit 2
fi
