#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# init.sh
# Initializes the project by:
#   1) Checking for system clang + libclang
#   2) Building flecs
#   3) Building odin-c-bindgen
# ============================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Check for system clang + libclang
# ------------------------------------------------------------

have_clang=0
have_libclang=0

# clang compiler
if command -v clang >/dev/null 2>&1; then
	have_clang=1
fi

# libclang via ldconfig (Linux)
if command -v ldconfig >/dev/null 2>&1; then
	if ldconfig -p 2>/dev/null | grep -q "libclang.so"; then
		have_libclang=1
	fi
fi

# libclang fallback paths (Linux + macOS)
for p in \
	/usr/lib/libclang.so \
	/usr/local/lib/libclang.so \
	/usr/lib/libclang.dylib \
	/usr/local/lib/libclang.dylib \
	/opt/homebrew/opt/llvm/lib/libclang.dylib; do
	if [[ -f "$p" ]]; then
		have_libclang=1
	fi
done

if [[ "$have_clang" -ne 1 || "$have_libclang" -ne 1 ]]; then
	echo "libclang not found on this system."
	echo
	echo "Please install LLVM/Clang (version 16 or newer)."
	echo
	echo "Ubuntu / Debian / Mint:"
	echo "  sudo apt install libclang-dev"
	echo
	echo "Arch Linux:"
	echo "  sudo pacman -S clang"
	echo
	echo "macOS (Homebrew):"
	echo "  brew install llvm"
	echo
	echo "After installing, re-run:"
	echo "  ./init.sh"
	exit 1
fi

# ------------------------------------------------------------
# Build steps
# ------------------------------------------------------------

"${ROOT}/build_flecs.sh"
"${ROOT}/ensure_libclang.sh"
"${ROOT}/build_bindgen.sh"

echo
echo "Initialization completed successfully."
