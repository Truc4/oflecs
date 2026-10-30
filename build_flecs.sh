#!/usr/bin/env bash
# Linux / macOS / WASM counterpart of init.bat + build_flecs.bat + generate_flecs_bindings.bat.
#
# Produces distr/oflecs/ with:
#   flecs.odin          generated bindings + flecs_footer.odin (the wrapper)
#   linux/flecs.a       native static library   (on Linux)
#   macos/flecs.a       native static library   (on macOS)
#   wasm/flecs.a        Emscripten static library (if emcc is on PATH)
#
# Requirements: clang, libclang (apt install libclang-dev), Odin, and emcc for the WASM library.
#
# Usage: ./build_flecs.sh [all|libs|bindings]   (default: all)
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(pwd)"
WHAT="${1:-all}"
OUT="$ROOT/distr/oflecs"
SRC="$ROOT/flecs/distr/flecs.c"
HDR="$ROOT/flecs/distr/flecs.h"
CFLAGS="-O2 -DFLECS_STATIC -DNDEBUG"

[ -f "$SRC" ] || { echo "flecs submodule missing: git submodule update --init" >&2; exit 1; }
mkdir -p "$OUT"

build_libs() {
	tmp="$(mktemp -d)"
	case "$(uname -s)" in
	Linux)
		clang -c $CFLAGS -fPIC "$SRC" -o "$tmp/flecs.o"
		mkdir -p "$OUT/linux" && ar rcs "$OUT/linux/flecs.a" "$tmp/flecs.o"
		echo "built $OUT/linux/flecs.a" ;;
	Darwin)
		clang -c $CFLAGS "$SRC" -o "$tmp/flecs.o"
		mkdir -p "$OUT/macos" && ar rcs "$OUT/macos/flecs.a" "$tmp/flecs.o"
		echo "built $OUT/macos/flecs.a" ;;
	esac
	if command -v emcc >/dev/null; then
		# The HTTP/REST addons compile under Emscripten; they are simply never started in the browser.
		emcc -c $CFLAGS "$SRC" -o "$tmp/flecs_web.o"
		mkdir -p "$OUT/wasm" && emar rcs "$OUT/wasm/flecs.a" "$tmp/flecs_web.o"
		echo "built $OUT/wasm/flecs.a"
	else
		echo "emcc not found: skipping the WASM library"
	fi
	rm -rf "$tmp"
}

build_bindings() {
	gen="$ROOT/odin-c-bindgen/bindgen.bin"
	if [ ! -x "$gen" ]; then
		llvm_lib="$(llvm-config --libdir 2>/dev/null || echo /usr/lib/llvm-18/lib)"
		(cd "$ROOT/odin-c-bindgen" && odin build src -out:bindgen.bin \
			-extra-linker-flags:"-L$llvm_lib -Wl,-rpath,$llvm_lib")
	fi
	cp "$HDR" "$ROOT/flecs-bindgen/flecs.h"
	(cd "$ROOT/odin-c-bindgen" && ./bindgen.bin "$ROOT/flecs-bindgen")
	mv "$ROOT/flecs-bindgen/flecs/flecs.odin" "$OUT/flecs.odin"
	echo "generated $OUT/flecs.odin"
}

case "$WHAT" in
all) build_libs; build_bindings ;;
libs) build_libs ;;
bindings) build_bindings ;;
*) echo "usage: $0 [all|libs|bindings]" >&2; exit 2 ;;
esac
