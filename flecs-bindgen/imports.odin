// Platform-specific imports for the generated bindings. Libraries are built by build_flecs.bat (Windows)
// or build_flecs.sh (Linux, macOS, WASM via Emscripten) into distr/oflecs/.
when ODIN_OS == .Windows {
	foreign import lib "flecs.lib"
} else when ODIN_OS == .Linux {
	foreign import lib "linux/flecs.a"
} else when ODIN_OS == .Darwin {
	foreign import lib "macos/flecs.a"
} else when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
	// Web builds are `-build-mode:obj` objects linked by emcc with wasm/flecs.a (see build_flecs.sh).
	// Odin turns a WASM import path into the import's module name, so it must be "env" (Emscripten's
	// own module) for emcc to resolve the symbols against the library. Same trick as vendor:raylib.
	FLECS_WASM_LIB :: #config(FLECS_WASM_LIB, "env.o")
	foreign import lib {FLECS_WASM_LIB}
}
_ :: lib
