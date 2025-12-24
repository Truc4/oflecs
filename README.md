# oflecs

oflecs provides native Flecs bindings for the Odin programming language.

This is a personal project, I have not extensively testing the entire Flecs API. I just make changes when I need to for my personal projects. I also implemented the Flecs Quickstart demos and made sure they work.

- Flecs is built as a static library
- Bindings are generated using odin-c-bindgen
- Wrapper designed for usage similar to other bindings for Flecs
- The workflow is currently only scripted for Windows

This repository exists primarily for my own use, but is published publicly in case it’s useful to others.

## Overview

This project consists of two layers:

1. **Low-level generated bindings**  
   Generated directly from `flecs.h` using `odin-c-bindgen`.

2. **A handwritten wrapper layer**  
   I wrote a wrapper on top of the generated bindings to make Flecs usage feel more similar to other language bindings without using an object-oriented API.

The wrapper aims to:

- Reduce boilerplate
- Replace common C macros with Odin procedures
- Provide a more Odin-style API
- Keep everything explicit and data-oriented (no classes, no hidden state)

This wrapper is opinionated and reflects how I like to use Flecs.

## Wrapper Design Philosophy

- Not object-oriented
- Thin abstractions over Flecs concepts
- Explicit `world` ownership
- Struct-based handles (`Entity`, `Query`, `System`, etc.)
- Minimal magic, no fluent OO chains

## Example: Components (C vs Odin)

### Original Flecs C code

```c
ECS_COMPONENT(world, Position);
ECS_COMPONENT(world, Velocity);

ecs_entity_t e = ecs_new(world);

// Add a component. This creates the component in the ECS storage, but does not
// assign it with a value.
ecs_add(world, e, Velocity);

// Set the value for the Position & Velocity components. A component will be
// added if the entity doesn't have it yet.
ecs_set(world, e, Position, {10, 20});
ecs_set(world, e, Velocity, {1, 2});

// Get a component
const Position *p = ecs_get(world, e, Position);

// Remove component
ecs_remove(world, e, Position);
```

### Equivalent code using oflecs

```odin
Position :: struct {
    x, y: f32,
}

Velocity :: struct {
    x, y: f32,
}

world := ecs.init()

e := ecs.entity(world)
defer ecs.delete(e)

// Add component (no value yet)
ecs.add(e, Velocity)

// Set component values
ecs.set(e, Position{10, 20})
ecs.set(e, Velocity{1, 2})

// Get component
p := ecs.get(e, Position)
fmt.println(p)

// Remove component
ecs.remove(e, Position)
```

Notes:

- Components are registered lazily on first use
- `ecs.set` automatically adds the component if missing
- The API stays explicit and procedural

## Example Usage

Below is a condensed example showing the wrapper style:

```odin
world := ecs.init()

e := ecs.entity(world, "Bob")
defer ecs.delete(e)

ecs.add(e, Position)
ecs.set(e, Position{10, 20})

pos := ecs.get(e, Position)
fmt.println(pos)
```

Query example:

```odin
q := ecs.query_builder(world)
ecs.with(&q, Position)
ecs.build(&q)
defer ecs.finished(q)

ecs.each(q, proc(e: ecs.Entity, ce: ecs.Entity) {
    fmt.println(ecs.get_name(e))
})
```

System example:

```odin
q := ecs.query_builder(world)
ecs.with(&q, Position)

move_system := ecs.system(q, proc "c" (iter: ^ecs.iter_t) {
    pos := ecs.field(iter, Position)
    pos.x += 1
})
defer ecs.delete(move_system)

ecs.run(move_system)
```

The full example used for testing lives in the `examples/` directory.

## Project Status & Scope

- ✅ Works for my personal projects and updated for my personal use cases
- ✅ Works for Flecs quickstart examples
- ❌ Not exhaustively tested across Flecs
- ❌ Not all Flecs APIs are wrapped but everthing should be exposed
- ❌ Wrapper API may change without notice

If you need fully validated bindings, you should audit and extend these yourself.

## Requirements

### Required tools

- Windows
- Odin (must be available in `PATH`)
- Visual Studio 2022 (MSVC toolchain)

### Required external dependency

- **libclang 20.1.8**

Download LLVM/Clang from:

https://github.com/llvm/llvm-project/releases/tag/llvmorg-20.1.8

After extracting the Windows archive, copy:

- `lib/libclang.lib` → `llvm/libclang.lib`
- `bin/libclang.dll` → `llvm/libclang.dll`

Directory layout:

```
llvm/
  libclang.lib
  libclang.dll
```

## Quick Start

Make sure you have the requirements installed. Including `libclang.lib` and `libclang.dll` in the `llvm` directory.

From the repository root:

```bat
init.bat
```

This will:

1. Build Flecs as a static library
2. Ensure `libclang` is installed where the bindgen expects it
3. Build the bindgen executable

Then generate the bindings:

```bat
generate_flecs_bindings.bat
```

Final outputs:

```
distr/oflecs/
├─ flecs.odin
└─ flecs.lib
```

You can now copy the `oflecs` folder for use in your Odin projects.
