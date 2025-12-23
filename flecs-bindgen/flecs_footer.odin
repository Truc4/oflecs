// Bindings that didn't generate (they were defined in flecs.c)

@(default_calling_convention = "c", link_prefix = "Ecs")
foreign lib {
  @(link_prefix="ecs_")
  os_api: os_api_t

	/* Builtin component ids */

	/** Tag added to queries. */
	@(link_prefix = "")
	EcsQuery: entity_t

	/** Tag added to observers. */
	Observer: entity_t

	/** Tag added to systems. */
	@(link_prefix = "")
	EcsSystem: entity_t

	/** Root scope for builtin flecs entities */
	Flecs: entity_t

	/** Core module scope */
	FlecsCore: entity_t

	/** Entity associated with world (used for "attaching" components to world) */
	World: entity_t

	/** Wildcard entity ("*"). Matches any id, returns all matches. */
	Wildcard: entity_t

	/** Any entity ("_"). Matches any id, returns only the first. */
	Any: entity_t

	/** This entity. Default source for queries. */
	This: entity_t

	/** Variable entity ("$"). Used in expressions to prefix variable names */
	Variable: entity_t

	/** Marks a relationship as transitive.
 * Behavior:
 *
 * @code
 *   if R(X, Y) and R(Y, Z) then R(X, Z)
 * @endcode
 */
	Transitive: entity_t

	/** Marks a relationship as reflexive.
 * Behavior:
 *
 * @code
 *   R(X, X) == true
 * @endcode
 */
	Reflexive: entity_t

	/**:: entity_t entity_tnsures that entity/component cannot be used as target in `IsA` relationship.
 * Final can improve the performance of queries as they will not attempt to 
 * substitute a final component with its subsets.
 *
 * Behavior:
 *
 * @code
 *   if IsA(X, Y) and Final(Y) throw error
 * @endcode
 */
	Final: entity_t

	/** Mark component as inheritable.
 * This is the opposite of Final. This trait can be used to enforce that queries
 * take into account component inheritance before inheritance (IsA) 
 * relationships are added with the component as target.
 */
	Inheritable: entity_t

	/** Relationship that specifies component inheritance behavior. */
	OnInstantiate: entity_t

	/** Override component on instantiate. 
 * This will copy the component from the base entity `(IsA target)` to the
 * instance. The base component will never be inherited from the prefab. */
	Override: entity_t

	/** Inherit component on instantiate. 
 * This will inherit (share) the component from the base entity `(IsA target)`.
 * The component can be manually overridden by adding it to the instance. */
	Inherit: entity_t

	/** Never inherit component on instantiate. 
 * This will not copy or share the component from the base entity `(IsA target)`.
 * When the component is added to an instance, its value will never be copied 
 * from the base entity. */
	DontInherit: entity_t

	/** Marks relationship as commutative.
 * Behavior:
 *
 * @code
 *   if R(X, Y) then R(Y, X)
 * @endcode
 */
	Symmetric: entity_t

	/** Can be added to relationship to indicate that the relationship can only occur
 * once on an entity. Adding a 2nd instance will replace the 1st.
 *
 * Behavior:
 *
 * @code
 *   R(X, Y) + R(X, Z) = R(X, Z)
 * @endcode
 */
	Exclusive: entity_t

	/** Marks a relationship as acyclic. Acyclic relationships may not form cycles. */
	Acyclic: entity_t

	/** Marks a relationship as traversable. Traversable relationships may be
 * traversed with "up" queries. Traversable relationships are acyclic. */
	Traversable: entity_t

	/** Ensure that a component always is added together with another component.
 *
 * Behavior:
 *
 * @code
 *   If With(R, O) and R(X) then O(X)
 *   If With(R, O) and R(X, Y) then O(X, Y)
 * @endcode
 */
	With: entity_t

	/** Ensure that relationship target is child of specified entity.
 *
 * Behavior:
 *
 * @code
 *   If OneOf(R, O) and R(X, Y), Y must be a child of O
 *   If OneOf(R) and R(X, Y), Y must be a child of R
 * @endcode
 */
	OneOf: entity_t

	/** Mark a component as toggleable with ecs_enable_id(). */
	CanToggle: entity_t

	/** Can be added to components to indicate it is a trait. Traits are components
 * and/or tags that are added to other components to modify their behavior.
 */
	Trait: entity_t

	/** Ensure that an entity is always used in pair as relationship.
 *
 * Behavior:
 *
 * @code
 *   e.add(R) panics
 *   e.add(X, R) panics, unless X has the "Trait" trait
 * @endcode
 */
	Relationship: entity_t

	/** Ensure that an entity is always used in pair as target.
 *
 * Behavior:
 *
 * @code
 *   e.add(T) panics
 *   e.add(T, X) panics
 * @endcode
 */
	Target: entity_t

	/** Can be added to relationship to indicate that it should never hold data, 
 * even when it or the relationship target is a component. */
	PairIsTag: entity_t

	/** Tag to indicate name identifier */
	Name: entity_t

	/** Tag to indicate symbol identifier */
	Symbol: entity_t

	/** Tag to indicate alias identifier */
	Alias: entity_t

	/** Used to express parent-child relationships. */
	ChildOf: entity_t

	/** Used to express inheritance relationships. */
	IsA: entity_t

	/** Used to express dependency relationships */
	DependsOn: entity_t

	/** Used to express a slot (used with prefab inheritance) */
	SlotOf: entity_t

	/** Tag that when added to a parent ensures stable order of ecs_children result. */
	OrderedChildren: entity_t

	/** Tag added to module entities */
	Module: entity_t

	/** Tag to indicate an entity/component/system is private to a module */
	Private: entity_t

	/** Tag added to prefab entities. Any entity with this tag is automatically
 * ignored by queries, unless #EcsPrefab is explicitly queried for. */
	Prefab: entity_t

	/** When this tag is added to an entity it is skipped by queries, unless
 * #EcsDisabled is explicitly queried for. */
	Disabled: entity_t

	/** Trait added to entities that should never be returned by queries. Reserved
 * for internal entities that have special meaning to the query engine, such as
 * #EcsThis, #EcsWildcard, #EcsAny. */
	NotQueryable: entity_t

	/** Event that triggers when an id is added to an entity */
	OnAdd: entity_t

	/** Event that triggers when an id is removed from an entity */
	OnRemove: entity_t

	/** Event that triggers when a component is set for an entity */
	OnSet: entity_t

	/** Event that triggers observer when an entity starts/stops matching a query */
	Monitor: entity_t

	/** Event that triggers when a table is created. */
	OnTableCreate: entity_t

	/** Event that triggers when a table is deleted. */
	OnTableDelete: entity_t

	/** Relationship used for specifying cleanup behavior. */
	OnDelete: entity_t

	/** Relationship used to define what should happen when a target entity (second
 * element of a pair) is deleted. */
	OnDeleteTarget: entity_t

	/** Remove cleanup policy. Must be used as target in pair with #EcsOnDelete or
 * #EcsOnDeleteTarget. */
	Remove: entity_t

	/** Delete cleanup policy. Must be used as target in pair with #EcsOnDelete or
 * #EcsOnDeleteTarget. */
	Delete: entity_t

	/** Panic cleanup policy. Must be used as target in pair with #EcsOnDelete or
 * #EcsOnDeleteTarget. */
	Panic: entity_t

	/** Mark component as sparse */
	Sparse: entity_t

	/** Mark component as non-fragmenting */
	DontFragment: entity_t

	/** Marker used to indicate `$var == ...` matching in queries. */
	PredEq: entity_t

	/** Marker used to indicate `$var == "name"` matching in queries. */
	PredMatch: entity_t

	/** Marker used to indicate `$var ~= "pattern"` matching in queries. */
	PredLookup: entity_t

	/** Marker used to indicate the start of a scope (`{`) in queries. */
	ScopeOpen: entity_t

	/** Marker used to indicate the end of a scope (`}`) in queries. */
	ScopeClose: entity_t

	/** Tag used to indicate query is empty.
 * This tag is removed automatically when a query becomes non-empty, and is not
 * automatically re-added when it becomes empty.
 */
	Empty: entity_t

	OnStart: entity_t /**< OnStart pipeline phase. */
	PreFrame: entity_t /**< PreFrame pipeline phase. */
	OnLoad: entity_t /**< OnLoad pipeline phase. */
	PostLoad: entity_t /**< PostLoad pipeline phase. */
	PreUpdate: entity_t /**< PreUpdate pipeline phase. */
	OnUpdate: entity_t /**< OnUpdate pipeline phase. */
	OnValidate: entity_t /**< OnValidate pipeline phase. */
	PostUpdate: entity_t /**< PostUpdate pipeline phase. */
	PreStore: entity_t /**< PreStore pipeline phase. */
	OnStore: entity_t /**< OnStore pipeline phase. */
	PostFrame: entity_t /**< PostFrame pipeline phase. */
	Phase: entity_t /**< Phase pipeline phase. */

	Constant: entity_t /**< Tag added to enum/bitmask constants. */
}

// Wrapper

import "core:fmt"
import "core:mem"

// TODO: add overloads, generics, etc here to replace missing macros

Entity :: struct {
	world:  ^world_t,
	handle: entity_t,
}

EntityType :: struct {
	world:  ^world_t,
	handle: ^type_t,
	array:  []Entity,
}

Query :: struct {
	world:      ^world_t,
	handle:     ^query_t,
	desc:       query_desc_t,
	term_count: uint,
}

System :: struct {
	world:      ^world_t,
	callback:   iter_action_t,
	phase:      entity_t,
	query_desc: query_desc_t,
}

Pipeline :: struct {}

init :: proc() -> ^world_t {
	world := ecs_init()
	world_components[world] = make(ComponentEntityMap)
	world_systems[world] = make(SystemEntityMap)
	component_entities := &world_components[world]

	component_entities[Component] = 1
	component_entities[Identifier] = 2
	component_entities[Poly] = 3

	component_entities[TickSource] = FLECS_HI_COMPONENT_ID + 50
	component_entities[Timer] = FLECS_HI_COMPONENT_ID + 51
	component_entities[RateFilter] = FLECS_HI_COMPONENT_ID + 52

	component_entities[DefaultChildComponent] = FLECS_HI_COMPONENT_ID + 58

	component_entities[Pipeline] = FLECS_HI_COMPONENT_ID + 67

	return world
}

// Find or create an entity.
//
// This operation creates a new entity, or modifies an existing one. When a name is set in the ecs_entity_desc_t::name field and ecs_entity_desc_t::entity is not set, the operation will first attempt to find an existing entity by that name. If no entity with that name can be found, it will be created.
//
// If both a name and entity handle are provided, the operation will check if the entity name matches with the provided name. If the names do not match, the function will fail and return 0.
//
// If an id to a non-existing entity is provided, that entity id become alive.
//
// See the documentation of ecs_entity_desc_t for more details.
//
// Returns
// A handle to the new or existing entity, or 0 if failed.
entity :: proc {
	create_entity,
	create_entity_with_name,
	create_entity_with_entity,
	create_entity_with_component,
}

@(private)
create_entity :: proc(world: ^world_t) -> Entity {
	entity := new(world)
	return Entity{world, entity}
}

@(private)
create_entity_with_name :: proc(world: ^world_t, name: string) -> Entity {
	entity := entity_init(world, &entity_desc_t{name = fmt.ctprint(name)})
	return Entity{world, entity}
}

@(private)
create_entity_with_entity :: proc(entity: Entity) -> Entity {
	e := new_w_id(entity.world, entity.handle)
	return Entity{entity.world, e}
}

@(private)
create_entity_with_component :: proc(world: ^world_t, $T: typeid) -> Entity {
	e := new_w_id(world, get_component_handle(world, T))
	return Entity{world, e}
}

delete :: proc(entity: Entity) {
	ecs_delete(entity.world, entity.handle)
}

set_name :: proc(entity: Entity, name: string) {
	ecs_set_name(entity.world, entity.handle, fmt.ctprint(name))
}

@(private)
ComponentEntityMap :: map[typeid]entity_t
@(private)
SystemEntityMap :: map[^System]entity_t
@(private)
world_components := make(map[^world_t]ComponentEntityMap)
@(private)
world_systems := make(map[^world_t]SystemEntityMap)

// Add a (component) id to an entity.
//
// This operation adds a single (component) id to an entity. If the entity already has the id, this operation will have no side effects.
add :: proc {
	add_type,
	add_entity,
}

add_type :: proc(entity: Entity, $T: typeid) {
	component_e := get_component_handle(entity.world, T)
	add_id(entity.world, entity.handle, component_e)
}

add_entity :: proc(entity: Entity, first: Entity) {
	assert(entity.world == first.world)
	add_id(entity.world, entity.handle, first.handle)
}

// Set the value of a component.
//
// This operation allows an application to set the value of a component. The operation is equivalent to calling ecs_ensure_id() followed by ecs_modified_id(). The operation will not modify the value of the passed in component. If the component has a copy hook registered, it will be used to copy in the component.
//
// If the provided entity is 0, a new entity will be created.
set :: proc {
	entity_set,
	singleton_set,
}

entity_set :: proc(entity: Entity, component: $T) {
	// NOTE: set_id makes a copy of the data and discards the reference
	data: T = component
	component_e := get_component_handle(entity.world, T)
	set_id(entity.world, entity.handle, component_e, size_of(T), &data)
}

@(private)
singleton_set :: proc(world: ^world_t, component: $T) {
	entity_set(id(world, T), component)
}

// Get an immutable pointer to a component.
//
// This operation obtains a const pointer to the requested component. The operation accepts the component entity id.
//
// This operation can return inherited components reachable through an IsA relationship.
//
// Returns
// The component pointer, NULL if the entity does not have the component.
get :: proc {
	entity_get,
	singleton_get,
}

@(private)
entity_get :: proc(entity: Entity, $T: typeid) -> ^T {
	component_e := get_component_handle(entity.world, T)
	data := get_id(entity.world, entity.handle, component_e)
	component := (^T)(data)
	return component
}

@(private)
singleton_get :: proc(world: ^world_t, $T: typeid) -> ^T {
	return entity_get(id(world, T), T)
}

// TODO: less ambiguous name
// gets the entity from the component type
id :: proc(world: ^world_t, $T: typeid) -> Entity {
	return Entity{world, get_component_handle(world, T)}
}

id_system :: proc(world: ^world_t, system: ^System) -> Entity {
	return Entity{world, get_system_handle(world, system)}
}

// @(private)
get_component_handle :: proc(world: ^world_t, $T: typeid) -> entity_t {
	component_entities := &world_components[world]
	if !(T in component_entities) {
		register_component(world, T)
	}
	return component_entities[T]
}

get_system_handle :: proc(world: ^world_t, system: ^System) -> entity_t {
	system_entities := &world_systems[world]
	if !(system in system_entities) {
		register_system(system)
	}
	return system_entities[system]
}

@(private)
register_component :: proc(world: ^world_t, $T: typeid) {
	component_entities := &world_components[world]
	component_entities[T] = 0
	{
		type_cstring := fmt.ctprint(typeid_of(T))
		desc: component_desc_t
		edesc: entity_desc_t
		edesc.id = component_entities[T] // TODO: meant to be 0?
		edesc.use_low_id = true
		edesc.name = type_cstring
		edesc.symbol = type_cstring
		desc.entity = entity_init(world, &edesc)
		desc.type.size = size_of(T)
		desc.type.alignment = align_of(T)
		component_entities[T] = component_init(world, &desc)
	}
	assert(component_entities[T] != 0)
	// assert(c_typeids[T] != 0, INVALID_PARAMETER, "failed to create component %s", "Position")
}

get_name :: proc(entity: Entity) -> string {
	return string(ecs_get_name(entity.world, entity.handle))
}

remove :: proc(entity: Entity, $T: typeid) {
	component_e := get_component_handle(entity.world, T)
	remove_id(entity.world, entity.handle, component_e)
}

has :: proc {
	has_type,
	has_tag,
}

has_type :: proc(entity: Entity, $T: typeid) -> bool {
	component_e := get_component_handle(entity.world, T)
	return has_id(entity.world, entity.handle, component_e)
}

has_tag :: proc(entity: Entity, tag: Entity) -> bool {
	assert(entity.world == tag.world)
	return has_id(entity.world, entity.handle, tag.handle)
}

/* PAIRS */

ECS_PAIR: c.uint64_t : (c.ulonglong(1) << 63)

pair :: proc {
	pair_ee,
	pair_ie,
}

@(private)
pair_ii :: proc(first: entity_t, second: entity_t) -> id_t {
	return ECS_PAIR | ((c.uint64_t(first) << 32) + c.uint64_t(c.uint32_t(second)))
}

@(private)
pair_ee :: proc(first: Entity, second: Entity) -> Entity {
	assert(first.world == second.world)
	return Entity{first.world, pair_ii(first.handle, second.handle)}
}

@(private)
pair_ie :: proc(first: entity_t, second: Entity) -> Entity {
	return Entity{second.world, pair_ii(first, second.handle)}
}

has_pair :: proc(entity: Entity, first: Entity, second: Entity) -> bool {
	assert(entity.world == first.world)
	assert(entity.world == second.world)
	assert(second.world == first.world)
	return has_id(entity.world, entity.handle, pair_ii(first.handle, second.handle))
}

remove_pair :: proc(subject: Entity, first: Entity, second: Entity) {
	assert(subject.world == first.world)
	assert(subject.world == second.world)
	assert(second.world == first.world)
	remove_id(subject.world, subject.handle, pair_ii(first.handle, second.handle))
}

// ECS_ID_FLAGS_MASK :: ((0xFF) << 60)
// ECS_COMPONENT_MASK :: (~ECS_ID_FLAGS_MASK)
//
// pair_first :: proc(world: ^world_t, pair: id_t) -> Entity {
// 	entity := get_alive(world, c.uint32_t(pair) >> 32 & ECS_COMPONENT_MASK)
// 	return Entity{world, entity}
// }

/* Hierarchies */

get_path :: proc(child: Entity) -> string {
	path_ptr := get_path_w_sep(child.world, 0, child.handle, ".", nil)
	path := fmt.tprint(path_ptr)
	os_free(rawptr(path_ptr))
	return path
}

lookup :: proc(world: ^world_t, path: string) -> Entity {
	e := ecs_lookup(world, fmt.ctprint(path))
	return Entity{world, e}
}

lookup_from :: proc(parent: Entity, path: string) -> Entity {
	e := lookup_path_w_sep(parent.world, parent.handle, fmt.ctprint(path), ".", nil, true)
	return Entity{parent.world, e}
}

/* Type */

get_type :: proc(entity: Entity) -> EntityType {
	type := ecs_get_type(entity.world, entity.handle)

	arr: []entity_t = cast([]entity_t)type.array[:type.count]

	entity_arr: [dynamic]Entity
	for handle in arr {
		append(&entity_arr, Entity{entity.world, handle})
	}
	entity_type := EntityType{entity.world, type, entity_arr[:]}
	return entity_type
}

type_str :: proc(type: EntityType) -> string {
	cstr := ecs_type_str(type.world, type.handle)
	str := fmt.tprint(cstr)
	os_free(rawptr(cstr))
	return str
}

/* Singleton */

/* Query */

query_builder :: proc(world: ^world_t, entities: ..Entity) -> Query {
	query: Query
	desc: query_desc_t
	for entity in entities {
		desc.terms[query.term_count].id = entity.handle
		query.term_count += 1
	}
	return Query{world = world, desc = desc}
}

with :: proc {
	query_add_term_component,
	query_add_term_entity,
	query_add_term,
}

query_add_term_component :: proc(
	query: ^Query,
	$T: typeid,
	oper: oper_kind_t = oper_kind_t.And,
	parent := false, // NOTE: I do it the naive simple way until I know exactly how queries should be implemented
	cascade := false,
) {
	term := &query.desc.terms[query.term_count]
	term.id = get_component_handle(query.world, T)
	term.oper = i16(oper)
	src := &term.src
	if parent {term.trav = ChildOf}
	if cascade {term.src.id = Cascade | Up}
	query.term_count += 1
}

query_add_term_entity :: proc(
	query: ^Query,
	entity: Entity,
	oper: oper_kind_t = oper_kind_t.And,
	parent := false,
	cascade := false,
) {
	term := &query.desc.terms[query.term_count]
	term.id = entity.handle
	term.oper = i16(oper)
	if parent {term.trav = ChildOf}
	if cascade {term.src.id = Cascade | Up}
	query.term_count += 1
}

query_add_term :: proc(query: ^Query, term: term_t) {
	query.desc.terms[query.term_count] = term
	query.term_count += 1
}

build :: proc {
	query_build,
// system_build,
}

query_build :: proc(query: ^Query) {
	query.handle = query_init(query.world, &query.desc)
}

/* Memory */

@(private)
os_free :: proc(ptr: rawptr) {
	os_api.free_(ptr)
}


/* Iterators */
each :: proc {
	entity_each_component,
	query_each,
}

entity_each_component :: proc(
	world: ^world_t,
	$T: typeid,
	callback: proc(entity: Entity, component: ^T),
) {
	handle := get_component_handle(world, T)
	it := each_id(world, handle)
	for each_next(&it) {
		invoker_each(&it, T, callback)
	}
}

query_each :: proc(query: Query, callback: proc(entity: Entity, comp_entity: Entity)) {
	// Make sure its been built
	assert(query.handle != nil)
	it := query_iter(query.world, query.handle)
	for query_next(&it) {
		// TODO: is this the comp id?
		comp := Entity{query.world, it.ids[0]}

		for i := 0; i < int(it.count); i += 1 {
			callback(Entity{query.world, it.entities[i]}, comp)
		}
	}
}

@(private)
invoker_each :: proc(iter: ^iter_t, $T: typeid, callback: proc(entity: Entity, component: ^T)) {
	table_lock(iter.world, iter.table)

	count := iter.count == 0 && iter.table == nil ? 1 : iter.count

	component := field(iter, T, 0)

	for i := 0; i < int(count); i += 1 {
		entity := Entity{iter.world, iter.entities[i]}
		callback(entity, component)
	}

	table_unlock(iter.world, iter.table)
}

// TODO: what is index for?
field :: proc "contextless" (iter: ^iter_t, $T: typeid, index: i8 = 0) -> ^T {
	return (^T)(field_w_size(iter, size_of(T), index))
}

finished :: proc {
	query_finished,
}

query_finished :: proc(query: Query) {
	// Make sure its been built
	assert(query.handle != nil)
	query_fini(query.handle)
}

/* System */

system :: proc {
	system_with_component,
	system_with_query,
	system_with_phase,
}

system_with_component :: proc(world: ^world_t, $T: typeid, callback: iter_action_t) -> Entity {
	desc := system_desc_t {
		callback = callback,
	}
	desc.query.terms[0] = term_t {
		id = get_component_handle(world, T),
	}
	return Entity{world, system_init(world, &desc)}
}

system_with_query :: proc(query: Query, callback: iter_action_t) -> Entity {
	desc := system_desc_t {
		callback = callback,
	}
	desc.query = query.desc
	return Entity{query.world, system_init(query.world, &desc)}
}

system_with_phase :: proc(query: Query, callback: iter_action_t, phase: entity_t) -> Entity {
	system := System{query.world, callback, phase, query.desc}
	register_system(&system)
	return Entity{query.world, world_systems[query.world][&system]}
}

@(private)
register_system :: proc(system: ^System) {
	system_entities := &world_systems[system.world]
	system_entities[system] = 0
	{
		proc_cstring := fmt.ctprint(system^)
		desc: system_desc_t
		edesc: entity_desc_t
		add_ids: []id_t = {
			system.phase != 0 ? pair_ii(DependsOn, system.phase) : 0,
			system.phase,
			0,
		}
		edesc.id = system_entities[system] // TODO: meant to be 0?
		edesc.name = proc_cstring
		edesc.add = &add_ids[0] // zero terminated
		desc.entity = entity_init(system.world, &edesc)
		desc.query = system.query_desc
		desc.callback = system.callback
		system_entities[system] = system_init(system.world, &desc)
	}
	assert(system_entities[system] != 0)
}

// system_builder :: proc(world: ^world_t, entities: ..Entity) -> System {
// 	arr: [dynamic]entity_t
// 	for entity in entities {
// 		append(&arr, entity.handle)
// 	}
// 	return System{world = world, array = arr}
// }
//
// system_add_term_component :: proc(system: ^System, $T: typeid) {
// 	append(&system.array, get_component_handle(world, T))
// }
//
// system_add_term_entity :: proc(system: ^System, entity: Entity) {
// 	append(&system.array, entity.handle)
// }
//
// system_build :: proc(system: ^System) {
// 	terms: [FLECS_TERM_COUNT_MAX]term_t
// 	index := 0
// 	for id in system.array {
// 		terms[index] = term_t {
// 			id = id,
// 			// oper = i16(system.oper[index]),
// 		}
// 		index += 1
// 	}
// 	desc := system_desc_t {
// 		terms = terms,
// 	}
// 	system.handle = system_init(system.world, &desc)
// }

run :: proc(system: Entity, delta_time: f32 = 0) {
	ecs_run(system.world, system.handle, delta_time, nil)
}

/* Pipeline */

/* Observer */

observer :: proc(query: Query, event: entity_t, callback: iter_action_t) {
	desc := observer_desc_t {
		query    = query.desc,
		events   = {event, 0, 0, 0, 0, 0, 0, 0}, // TODO: convert
		callback = callback,
	}
	observer_init(query.world, &desc)
}

/* Module */

module :: proc "contextless" (world: ^world_t, $T: typeid, name: cstring) {
	component_entities := &world_components[world]
	component_entities[T] = 0
	{
		desc: component_desc_t
		desc.entity = component_entities[T]
		component_entities[T] = module_init(world, name, &desc)
		set_scope(world, component_entities[T])
	}
}

import_module :: proc(world: ^world_t, import_proc: module_action_t, $T: typeid) {
	import_c(world, import_proc, fmt.ctprint(typeid_of(T)))
}
