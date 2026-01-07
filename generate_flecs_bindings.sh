#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# generate_flecs_bindings.sh
# 1) Run: odin-c-bindgen/bindgen flecs-bindgen
# 2) Move generated flecs.odin -> distr/oflecs/flecs.odin
# 3) Copy flecs static lib -> distr/oflecs/flecs.a (+ optional flecs.lib symlink)
# ============================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BINDGEN_EXE="${ROOT}/odin-c-bindgen/bindgen"
BINDGEN_DIR="${ROOT}/odin-c-bindgen"
FLECS_BINDGEN_DIR="${ROOT}/flecs-bindgen"

OUT_DIR="${ROOT}/distr/oflecs"
OUT_ODIN="${OUT_DIR}/flecs.odin"
OUT_LIB_A="${OUT_DIR}/flecs.a"
OUT_LIB_COMPAT="${OUT_DIR}/flecs.lib"

# Source lib produced by build_flecs.sh (try multiple common Linux names)
SRC_LIB_CANDIDATES=(
	"${FLECS_BINDGEN_DIR}/flecs/flecs.lib"
	"${FLECS_BINDGEN_DIR}/flecs/flecs.a"
	"${FLECS_BINDGEN_DIR}/flecs/libflecs.a"
	"${FLECS_BINDGEN_DIR}/flecs/libflecs_static.a"
)

if [[ ! -x "${BINDGEN_EXE}" ]]; then
	echo "ERROR: bindgen not found or not executable at:"
	echo "  ${BINDGEN_EXE}"
	exit 1
fi

if [[ ! -d "${FLECS_BINDGEN_DIR}" ]]; then
	echo "ERROR: flecs-bindgen folder not found at:"
	echo "  ${FLECS_BINDGEN_DIR}"
	exit 2
fi

mkdir -p "${OUT_DIR}"

echo "Running bindgen..."
pushd "${BINDGEN_DIR}" >/dev/null
"${BINDGEN_EXE}" "${FLECS_BINDGEN_DIR}"
popd >/dev/null

# --- Find flecs.odin under flecs-bindgen
GEN_ODIN=""
if [[ -f "${FLECS_BINDGEN_DIR}/flecs.odin" ]]; then
	GEN_ODIN="${FLECS_BINDGEN_DIR}/flecs.odin"
elif [[ -f "${FLECS_BINDGEN_DIR}/flecs/flecs.odin" ]]; then
	GEN_ODIN="${FLECS_BINDGEN_DIR}/flecs/flecs.odin"
else
	GEN_ODIN="$(find "${FLECS_BINDGEN_DIR}" -type f -name "flecs.odin" -print -quit || true)"
fi

if [[ -z "${GEN_ODIN}" ]]; then
	echo "ERROR: Could not find generated flecs.odin under:"
	echo "  ${FLECS_BINDGEN_DIR}"
	exit 4
fi

echo "Found generated Odin file:"
echo "  ${GEN_ODIN}"

rm -f "${OUT_ODIN}"
mv -f "${GEN_ODIN}" "${OUT_ODIN}"

# --- Locate source static lib
SRC_LIB=""
for c in "${SRC_LIB_CANDIDATES[@]}"; do
	if [[ -f "${c}" ]]; then
		SRC_LIB="${c}"
		break
	fi
done

if [[ -z "${SRC_LIB}" ]]; then
	echo "ERROR: Could not find flecs static library under:"
	echo "  ${FLECS_BINDGEN_DIR}/flecs"
	echo "Expected from build_flecs.sh output."
	exit 6
fi

cp -f "${SRC_LIB}" "${OUT_LIB_A}"

# Optional compatibility for anything still expecting flecs.lib
ln -sf "flecs.a" "${OUT_LIB_COMPAT}"

echo
echo "Success:"
echo "  ${OUT_ODIN}"
echo "  ${OUT_LIB_A}"
echo "  ${OUT_LIB_COMPAT} (symlink)"
echo
