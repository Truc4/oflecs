#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# build_flecs.sh
# Builds flecs as a STATIC lib and copies:
#   - lib -> root/flecs-bindgen/flecs/(libflecs.a or flecs.a)
#   - flecs.h -> root/flecs-bindgen/flecs.h (from flecs/distr/flecs.h)
# ============================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLECS_DIR="${ROOT}/flecs"

OUT_ROOT="${ROOT}/flecs-bindgen"
OUT_LIB_DIR="${OUT_ROOT}/flecs"
OUT_LIB_A="${OUT_LIB_DIR}/libflecs.a"
OUT_HDR="${OUT_ROOT}/flecs.h"

if [[ ! -f "${FLECS_DIR}/CMakeLists.txt" ]]; then
	echo "ERROR: ${FLECS_DIR}/CMakeLists.txt not found."
	exit 2
fi

mkdir -p "${OUT_ROOT}" "${OUT_LIB_DIR}"

BUILD_DIR="$(mktemp -d -t flecs_build_XXXXXX)"
echo "Using temporary build dir: ${BUILD_DIR}"

cleanup() {
	rm -rf "${BUILD_DIR}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

# Configure (generator left to CMake default; add -G Ninja if you want)
cmake -S "${FLECS_DIR}" -B "${BUILD_DIR}" \
	-DFLECS_STATIC=ON -DFLECS_SHARED=OFF -DFLECS_PIC=OFF

# Build: try common targets
BUILT=0
if cmake --build "${BUILD_DIR}" --target flecs_static >/dev/null 2>&1; then
	BUILT=1
elif cmake --build "${BUILD_DIR}" --target flecs >/dev/null 2>&1; then
	BUILT=1
elif cmake --build "${BUILD_DIR}" >/dev/null 2>&1; then
	BUILT=1
fi

if [[ "${BUILT}" != "1" ]]; then
	echo "ERROR: flecs build failed."
	exit 6
fi

# Locate static library (common names)
LIB_PATH="$(
	find "${BUILD_DIR}" -type f \( -name "libflecs_static.a" -o -name "libflecs.a" -o -name "flecs.a" \) \
		-print -quit || true
)"

if [[ -z "${LIB_PATH}" ]]; then
	echo "ERROR: Could not find built static flecs library under:"
	echo "  ${BUILD_DIR}"
	exit 7
fi

HDR_PATH="${FLECS_DIR}/distr/flecs.h"
if [[ ! -f "${HDR_PATH}" ]]; then
	echo "ERROR: Missing ${HDR_PATH}"
	exit 8
fi

echo "LIB_PATH=${LIB_PATH}"
cp -f "${LIB_PATH}" "${OUT_LIB_A}"
cp -f "${HDR_PATH}" "${OUT_HDR}"

# Optional convenience names
ln -sf "libflecs.a" "${OUT_LIB_DIR}/flecs.a"
ln -sf "libflecs.a" "${OUT_LIB_DIR}/flecs.lib"

echo "Success:"
echo "  ${OUT_LIB_A}"
echo "  ${OUT_HDR}"
