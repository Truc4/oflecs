// Platform-specific imports for the generated bindings. Libraries are built by build_flecs.bat (Windows)
// or build_flecs.sh (Linux, macOS, WASM via Emscripten) into distr/oflecs/.
when ODIN_OS == .Windows {
	foreign import lib "flecs.lib"
} else when ODIN_OS == .Linux {
	foreign import lib "linux/flecs.a"
} else when ODIN_OS == .Darwin {
	foreign import lib "macos/flecs.a"
} else when ODIN_ARCH == .wasm32 || ODIN_ARCH == .wasm64p32 {
	// For -build-mode:obj web builds the library is linked by emcc (see build_flecs.sh); this import
	// only names it.
	foreign import lib "wasm/flecs.a"
}
_ :: lib
