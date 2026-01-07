#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SUBMOD="${ROOT}/odin-c-bindgen"
DEST_LIB_DIR="${SUBMOD}/libclang"
mkdir -p "${DEST_LIB_DIR}"

OS="$(uname -s)"

# ----------------------------
# Helpers
# ----------------------------
die() {
	echo "ERROR: $*" >&2
	exit 1
}

# ----------------------------
# Locate system libclang
# ----------------------------
SRC_LIB=""

if [[ "${OS}" == "Linux" ]]; then
	# Preferred: ask dynamic linker cache
	if command -v ldconfig >/dev/null 2>&1; then
		# Try to pick the "best" libclang.so.* (often highest version).
		# ldconfig output format varies; this grabs the resolved absolute path.
		SRC_LIB="$(ldconfig -p 2>/dev/null |
			awk '/libclang\.so/ {print $NF}' |
			grep -E 'libclang\.so(\.[0-9]+)*$' |
			head -n 1 || true)"
	fi

	# Fallback: common locations
	if [[ -z "${SRC_LIB}" ]]; then
		for p in \
			/usr/lib/libclang.so \
			/usr/local/lib/libclang.so \
			/usr/lib64/libclang.so \
			/lib/x86_64-linux-gnu/libclang.so \
			/usr/lib/x86_64-linux-gnu/libclang.so \
			/usr/lib/llvm-*/lib/libclang.so \
			/usr/lib/llvm-*/lib/libclang.so.*; do
			# glob may expand to itself if no match, so test -f carefully
			for m in $p; do
				if [[ -f "$m" ]]; then
					SRC_LIB="$m"
					break 2
				fi
			done
		done
	fi

	DEST_LIB="${SUBMOD}/libclang.so"

elif [[ "${OS}" == "Darwin" ]]; then
	# macOS: system or Homebrew LLVM
	for p in \
		/usr/lib/libclang.dylib \
		/usr/local/lib/libclang.dylib \
		/opt/homebrew/opt/llvm/lib/libclang.dylib \
		/usr/local/opt/llvm/lib/libclang.dylib; do
		if [[ -f "$p" ]]; then
			SRC_LIB="$p"
			break
		fi
	done

	DEST_LIB="${SUBMOD}/libclang.dylib"

else
	die "Unsupported OS: ${OS}"
fi

# ----------------------------
# Fallback: local ./llvm bundle (your old layout)
# ----------------------------
if [[ -z "${SRC_LIB}" ]]; then
	LLVM_DIR="${ROOT}/llvm"
	if [[ "${OS}" == "Linux" ]]; then
		if [[ -f "${LLVM_DIR}/libclang.so" ]]; then
			SRC_LIB="${LLVM_DIR}/libclang.so"
		else
			v="$(ls -1 "${LLVM_DIR}"/libclang.so.* 2>/dev/null | head -n 1 || true)"
			[[ -n "$v" ]] && SRC_LIB="$v"
		fi
	elif [[ "${OS}" == "Darwin" ]]; then
		[[ -f "${LLVM_DIR}/libclang.dylib" ]] && SRC_LIB="${LLVM_DIR}/libclang.dylib"
	fi
fi

# ----------------------------
# Validate + copy
# ----------------------------
if [[ -z "${SRC_LIB}" ]]; then
	echo "libclang not found."
	echo
	echo "Install LLVM/Clang (version 16+ recommended), then re-run this script."
	echo
	echo "Ubuntu / Debian / Mint:"
	echo "  sudo apt install libclang-dev"
	echo
	echo "Arch Linux:"
	echo "  sudo pacman -S clang"
	echo
	echo "macOS (Homebrew):"
	echo "  brew install llvm"
	exit 2
fi

cp -f "${SRC_LIB}" "${DEST_LIB}"

# Nice-to-have: also copy a versioned .so if we copied an unversioned linker name
if [[ "${OS}" == "Linux" ]]; then
	# If SRC_LIB is libclang.so (not versioned), try to also copy a versioned one for runtime robustness
	base="$(basename "${SRC_LIB}")"
	if [[ "${base}" == "libclang.so" ]]; then
		# Find a versioned one near it
		dir="$(dirname "${SRC_LIB}")"
		ver="$(ls -1 "${dir}/libclang.so."* 2>/dev/null | head -n 1 || true)"
		if [[ -n "${ver}" ]]; then
			cp -f "${ver}" "${SUBMOD}/"
		fi
	fi
fi

echo "libclang installed in submodule:"
echo "  ${DEST_LIB}"
