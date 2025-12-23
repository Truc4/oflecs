package main

import "core:fmt"
import ecs "../distr/oflecs"

Position :: struct {
	x, y: f32,
}

Velocity :: struct {
	x, y: f32,
}

main :: proc() {

	/* WORLD */

	world := ecs.init()

	/* ENTITIES */
	{
		e := ecs.entity(world)
		defer ecs.delete(e)
	}
	{
		e := ecs.entity(world, "Bob")
		defer ecs.delete(e)

		fmt.println("Name: ", ecs.get_name(e))
	}

	/* COMPONENTS */
	{
		e := ecs.entity(world, "Bob")
		defer ecs.delete(e)

		ecs.add(e, Position)
		ecs.set(e, Position{10, 20})
		p := ecs.get(e, Position)

		fmt.println(p)

		ecs.remove(e, Position)
	}

	/* COMPONENT ENTITIES */
	{
		pos_e := ecs.id(world, Position)
		fmt.println("Position name: ", ecs.get_name(pos_e))

		ecs.add(pos_e, Velocity)

		c := ecs.get(pos_e, ecs.Component)
		fmt.println("Component size: ", c.size)
	}

	/* TAGS */
	{
		e := ecs.entity(world)
		defer ecs.delete(e)

		// WARN: crashes, need to add special case for 0 sized types
		// FixedTag :: struct {}
		// ecs.add(e, FixedTag)
		// fmt.println("Entity has tag: ", ecs.has(e, FixedTag))

		DynTag := ecs.entity(world)
		ecs.add(e, DynTag)
		fmt.println("Entity has tag: ", ecs.has(e, DynTag))
	}

	/* PAIRS */
	{
		Likes := ecs.entity(world)

		Bob := ecs.entity(world)
		Alice := ecs.entity(world)

		ecs.add(Bob, ecs.pair(Likes, Alice))
		ecs.add(Alice, ecs.pair(Likes, Bob))
		fmt.println("Does Bob like Alice? ", ecs.has_pair(Bob, Likes, Alice))

		ecs.remove_pair(Bob, Likes, Alice)
		fmt.println("Does Bob still like Alice? ", ecs.has_pair(Bob, Likes, Alice))

		id := ecs.pair(Likes, Bob)

		// WARN: IDK how the bit math is supposed to work
		// if (ecs.id_is_pair(id)) {
		// 	relationship := ecs.pair_first(world, id)
		// 	target := ecs.pair_second(world, id)
		// }
	}

	/* Hierarchies */
	{
		parent := ecs.entity(world)
		defer ecs.delete(parent)

		child := ecs.entity(ecs.pair(ecs.ChildOf, parent))
		defer ecs.delete(child)
	}
	{
		parent := ecs.entity(world, "parent")
		defer ecs.delete(parent)

		child := ecs.entity(world, "child")
		defer ecs.delete(child)

		ecs.add(child, ecs.pair(ecs.ChildOf, parent))

		path := ecs.get_path(child)
		fmt.println(path) // output: 'parent.child'

		ecs.lookup(world, "parent.child") // returns child
		ecs.lookup_from(parent, "child") // returns child
	}
	{
		// TODO: idk if this works or if this is how it should be modified
		q := ecs.query_builder(world)
		ecs.with(&q, Position)
		ecs.with(&q, Position, parent = true, cascade = true)
		ecs.build(&q)
		defer ecs.finished(q)

		ecs.each(q, proc(e: ecs.Entity, ce: ecs.Entity) {
			fmt.println(e)
		})
	}

	/* Type */
	{
		e := ecs.entity(world)
		defer ecs.delete(e)
		ecs.add(e, Position)
		ecs.add(e, Velocity)

		type := ecs.get_type(e)
		type_str := ecs.type_str(type)
		fmt.println("Type: ", type_str)

		for component in type.array {
			if component == ecs.id(world, Position) {
				// Found Position component!
			}
		}
	}

	/* Singleton */
	{
		Gravity :: struct {
			value: f32,
		}
		ecs.set(world, Gravity{9.81})

		g := ecs.get(world, Gravity)

		//TODO: query
	}

	/* Query */
	{
		parent := ecs.entity(world, "Parent")
		defer ecs.delete(parent)
		child := ecs.entity(ecs.pair(ecs.ChildOf, parent))
		defer ecs.delete(child)
		ecs.set_name(child, "Child")

		ecs.add(parent, Position)
		ecs.add(child, Position)
		ecs.set(parent, Position{1, 2})
		ecs.set(child, Position{3, 4})

		ecs.each(world, Position, proc(e: ecs.Entity, pos: ^Position) {
			fmt.println("Entity with Position: ", ecs.get_name(e))
			fmt.println("Entity pos: ", pos)
		})

		{
			q := ecs.query_builder(world)
			ecs.with(&q, Position)
			ecs.with(&q, ecs.pair(ecs.ChildOf, parent))
			ecs.build(&q)
			defer ecs.finished(q) // query needs to be freed if it was built

			ecs.each(q, proc(e: ecs.Entity, ce: ecs.Entity) {
				fmt.println("Entity with Position and child of parent: ", ecs.get_name(e))
			})
		}
		// {
		// 	q := ecs.query_builder(world)
		// 	defer ecs.finished(q) // q needs to be freed after being built
		// 	ecs.with(&q, ecs.pair(ecs.ChildOf, parent))
		// 	ecs.with(&q, Position, ecs.oper_kind_t.Not)
		// 	ecs.build(&q)
		//
		// 	ecs.each(q, proc(e: ecs.Entity, ce: ecs.Entity) {
		// 		fmt.println("Entity without Position: ", ecs.get_name(e))
		// 	})
		// }
	}

	/* System */
	// {
	// 	e := ecs.entity(world)
	// 	defer ecs.delete(e)
	//
	// 	ecs.add(e, Position)
	// 	ecs.set(e, Position{})
	//
	// 	move_system := ecs.system(world, Position, proc "c" (iter: ^ecs.iter_t) {
	// 		pos := ecs.field(iter, Position, 0)
	// 		pos.x += 1
	// 	})
	//defer ecs.delete(move_system)
	//
	// 	fmt.println(ecs.get(e, Position))
	//
	// 	ecs.run(move_system)
	//
	// 	fmt.println(ecs.get(e, Position))
	// }
	{
		e := ecs.entity(world)
		defer ecs.delete(e)

		ecs.add(e, Position)
		ecs.set(e, Position{})

		q := ecs.query_builder(world)
		ecs.with(&q, Position)

		move_system := ecs.system(q, proc "c" (iter: ^ecs.iter_t) {
			pos := ecs.field(iter, Position)
			pos.x += 1
		})
		defer ecs.delete(move_system)

		fmt.println(ecs.get(e, Position))

		ecs.run(move_system)

		fmt.println(ecs.get(e, Position))
	}

	/* Pipeline */
	{
		q := ecs.query_builder(world)
		ecs.with(&q, Position)
		ecs.with(&q, Velocity)

		move: ecs.iter_action_t = proc "c" (iter: ^ecs.iter_t) {
			pos := ecs.field(iter, Position)
			pos.x += 1
		}
		sys := ecs.system(q, move, ecs.OnUpdate)
		defer ecs.delete(sys)

		ecs.progress(world, 0)
	}

	/* Observer */
	{
		q := ecs.query_builder(world)
		ecs.with(&q, Position)
		ecs.with(&q, Velocity)

		move: ecs.iter_action_t = proc "c" (iter: ^ecs.iter_t) {
			pos := ecs.field(iter, Position)
			pos.x += 1
		}

		ecs.observer(q, ecs.OnSet, move)

		e := ecs.entity(world) // Doesn't invoke the observer
		ecs.set(e, Position{10, 20}) // Doesn't invoke the observer
		ecs.set(e, Velocity{1, 2}) // Invokes the observer
		ecs.set(e, Position{20, 40}) // Invokes the observer
	}

	/* Module */
	{
		MyModule :: struct {}
		MyModuleImport: ecs.module_action_t : proc "c" (world: ^ecs.world_t) {
			ecs.module(world, MyModule, "MyModule")
		}
		ecs.import_module(world, MyModuleImport, MyModule)
	}

	fmt.println("Done")
}
