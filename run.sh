#!/usr/bin/env bash
set -euo pipefail
if [[ "${BASH_SOURCE[0]}" == */* ]]; then
  cd "${BASH_SOURCE[0]%/*}"
fi

if [[ "${OSTYPE:-}" == msys* || "${OSTYPE:-}" == cygwin* ]] && [[ -x ./runtime/swipl/bin/swipl.exe ]]; then
  prolog=./runtime/swipl/bin/swipl.exe
elif command -v swipl >/dev/null 2>&1; then
  prolog=swipl
else
  echo "SWI-Prolog is missing. Install it from https://www.swi-prolog.org/Download.html" >&2
  exit 1
fi

port="${1:-8081}"
exec "$prolog" -q -s web_server.pl -- "$port"
