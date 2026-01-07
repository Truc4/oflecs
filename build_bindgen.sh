#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SUBMOD="${ROOT}/odin-c-bindgen"
SRC_DIR="${SUBMOD}/src"
OUT_EXE="${SUBMOD}/bindgen"

die() {
	echo "ERROR: $*" >&2
	exit 1
}

if [[ ! -d "${SRC_DIR}" ]]; then
	die "Not found: ${SRC_DIR}"
fi

if ! command -v odin >/dev/null 2>&1; then
	die "odin not found in PATH"
fi

pushd "${SUBMOD}" >/dev/null

# Build to a predictable output name
if ! odin build "${SRC_DIR}" -out:"${OUT_EXE}"; then
	popd >/dev/null || true
	die "Odin build failed"
fi

popd >/dev/null

echo "Success: ${OUT_EXE}"
