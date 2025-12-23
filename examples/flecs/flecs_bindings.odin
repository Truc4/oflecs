/**
 * @file flecs.h
 * @brief Flecs public API.
 *
 * This file contains the public API for Flecs.
 */
package oflecs

import "core:c"

/**
* @defgroup c C API
*
* @{
* @}
*/

/**
* @defgroup core Core
* @ingroup c
* Core ECS functionality (entities, storage, queries).
*
* @{
*/

/**
* @defgroup options API defines
* Defines for customizing compile time features.
*
* @{
*/

/* Flecs version macros */
FLECS_VERSION_MAJOR    :: 4  /**< Flecs major version. */
FLECS_VERSION_MINOR    :: 1  /**< Flecs minor version. */
FLECS_VERSION_PATCH    :: 4  /**< Flecs patch version. */
FLECS_HI_COMPONENT_ID  :: 256
FLECS_HI_ID_RECORD_ID  :: 1024
FLECS_SPARSE_PAGE_BITS :: 6
FLECS_ENTITY_PAGE_BITS :: 10
FLECS_ID_DESC_MAX      :: 32
FLECS_EVENT_DESC_MAX   :: 8

/** @def FLECS_VARIABLE_COUNT_MAX
* Maximum number of query variables per query */
FLECS_VARIABLE_COUNT_MAX       :: 64
FLECS_TERM_COUNT_MAX           :: 32
FLECS_TERM_ARG_COUNT_MAX       :: 16
FLECS_QUERY_VARIABLE_COUNT_MAX :: 64
FLECS_QUERY_SCOPE_NESTING_MAX  :: 8
FLECS_DAG_DEPTH_MAX            :: 128

/** Ids are the things that can be added to an entity.
* An id can be an entity or pair, and can have optional id flags. */
id_t :: u64

/** An entity identifier.
* Entity ids consist out of a number unique to the entity in the lower 32 bits,
* and a counter used to track entity liveliness in the upper 32 bits. When an
* id is recycled, its generation count is increased. This causes recycled ids
* to be very large (>4 billion), which is normal. */
entity_t :: id_t

/** A type is a list of (component) ids.
* Types are used to communicate the "type" of an entity. In most type systems a
* typeof operation returns a single type. In ECS however, an entity can have
* multiple components, which is why an ECS type consists of a vector of ids.
*
* The component ids of a type are sorted, which ensures that it doesn't matter
* in which order components are added to an entity. For example, if adding
* Position then Velocity would result in type [Position, Velocity], first
* adding Velocity then Position would also result in type [Position, Velocity].
*
* Entities are grouped together by type in the ECS storage in tables. The
* storage has exactly one table per unique type that is created by the
* application that stores all entities and components for that type. This is
* also referred to as an archetype.
*/
type_t :: struct {
	array: ^id_t, /**< Array with ids. */
	count: i32,   /**< Number of elements in array. */
}

world_t :: struct {}
stage_t :: struct {}
table_t :: struct {}

observable_t :: struct {
	on_add:      event_record_t,
	on_remove:   event_record_t,
	on_set:      event_record_t,
	on_wildcard: event_record_t,
	events:      sparse_t,

	/** @def FLECS_ACCURATE_COUNTERS
	* Define to ensure that global counters used for statistics (such as the
	* allocation counters in the OS API) are accurate in multithreaded
	* applications, at the cost of increased overhead.
	*/
	last_observer_id: u64,
}

/** Cached reference. */
ref_t :: struct {
	entity:             entity_t,
	id:                 entity_t,
	table_id:           u64,
	table_version_fast: u32,
	table_version:      u16,
	record:             ^record_t, /* If sanitized mode is enabled, so is debug mode */
	ptr:                rawptr,
}

/** Record for entity index. */
record_t :: struct {
	table: ^table_t,

	/**
	* @defgroup c C API
	*
	* @{
	* @}
	*/
	
	/**
	* @defgroup core Core
	* @ingroup c
	* Core ECS functionality (entities, storage, queries).
	*
	* @{
	*/
	
	/**
	* @defgroup options API defines
	* Defines for customizing compile time features.
	*
	* @{
	*/
	row:   u32,
	dense: i32, /**< Flecs minor version. */
}

component_record_t :: struct {}

/** A poly object.
* A poly (short for polymorph) object is an object that has a variable list of
* capabilities, determined by a mixin table. This is the current list of types
* in the flecs API that can be used as an ecs_poly_t:
*
* - ecs_world_t
* - ecs_stage_t
* - ecs_query_t
*
* Functions that accept an ecs_poly_t argument can accept objects of these
* types. If the object does not have the requested mixin the API will throw an
* assert.
*
* The poly/mixin framework enables partially overlapping features to be
* implemented once, and enables objects of different types to interact with
* each other depending on what mixins they have, rather than their type
* (in some ways it's like a mini-ECS). Additionally, each poly object has a
* header that enables the API to do sanity checking on the input arguments.
*/
poly_t   :: struct {}
mixins_t :: struct {}

/** Header for ecs_poly_t objects. */
header_t :: struct {
	type:     i32,       /**< Magic number indicating which type of flecs object */
	refcount: i32,       /**< Refcount, to enable RAII handles */
	mixins:   ^mixins_t, /**< Table with offsets to (optional) mixins */
}

/** Record that stores location of a component in a table.
* Table records are registered with component records, which allows for quickly
* finding all tables for a specific component. */
table_record_t :: struct {
	hdr:    table_cache_hdr_t,
	index:  i16,
	count:  i16,
	column: i16,
}

/** Function prototype for runnables (systems, observers).
* The run callback overrides the default behavior for iterating through the
* results of a runnable object.
*
* The default runnable iterates the iterator, and calls an iter_action (see
* below) for each returned result.
*
* @param it The iterator to be iterated by the runnable.
*/
run_action_t :: proc "c" (it: ^iter_t)

/** Function prototype for iterables.
* A system may invoke a callback multiple times, typically once for each
* matched table.
*
* @param it The iterator containing the data for the current match.
*/
iter_action_t :: proc "c" (it: ^iter_t)

/** Function prototype for iterating an iterator.
* Stored inside initialized iterators. This allows an application to iterate
* an iterator without needing to know what created it.
*
* @param it The iterator to iterate.
* @return True if iterator has no more results, false if it does.
*/
iter_next_action_t :: proc "c" (it: ^iter_t) -> bool

/** Function prototype for freeing an iterator.
* Free iterator resources.
*
* @param it The iterator to free.
*/
iter_fini_action_t :: proc "c" (it: ^iter_t)

/** Callback used for comparing components */
order_by_action_t :: proc "c" (e1: entity_t, ptr1: rawptr, e2: entity_t, ptr2: rawptr) -> i32

/** Callback used for sorting the entire table of components */
sort_table_action_t :: proc "c" (world: ^world_t, table: ^table_t, entities: ^entity_t, ptr: rawptr, size: i32, lo: i32, hi: i32, order_by: order_by_action_t)

/** Callback used for grouping tables in a query */
group_by_action_t :: proc "c" (world: ^world_t, table: ^table_t, group_id: id_t, ctx: rawptr) -> u64

/** Callback invoked when a query creates a new group. */
group_create_action_t :: proc "c" (world: ^world_t, group_id: u64, group_by_ctx: rawptr) -> rawptr

/** Callback invoked when a query deletes an existing group. */
group_delete_action_t :: proc "c" (world: ^world_t, group_id: u64, group_ctx: rawptr, group_by_ctx: rawptr)

/** Initialization action for modules */
module_action_t :: proc "c" (world: ^world_t)

/** Action callback on world exit */
fini_action_t :: proc "c" (world: ^world_t, ctx: rawptr)

/** Function to cleanup context data */
ctx_free_t :: proc "c" (ctx: rawptr)

/** Callback used for sorting values */
compare_action_t :: proc "c" (ptr1: rawptr, ptr2: rawptr) -> i32

/** Callback used for hashing values */
hash_value_action_t :: proc "c" (ptr: rawptr) -> u64

/** Constructor/destructor callback */
xtor_t :: proc "c" (ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Copy is invoked when a component is copied into another component. */
copy_t :: proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Move is invoked when a component is moved to another component. */
move_t :: proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Compare hook to compare component instances */
cmp_t :: proc "c" (a_ptr: rawptr, b_ptr: rawptr, type_info: ^type_info_t) -> i32

/** Equals operator hook */
equals_t :: proc "c" (a_ptr: rawptr, b_ptr: rawptr, type_info: ^type_info_t) -> bool

/** Destructor function for poly objects. */
flecs_poly_dtor_t :: proc "c" (poly: ^poly_t)

/** Specify read/write access for term */
inout_kind_t :: enum i32 {
	InOutDefault = 0, /**< InOut for regular terms, In for shared terms */
	InOutNone    = 1, /**< Term is neither read nor written */
	InOutFilter  = 2, /**< Same as InOutNone + prevents term from triggering observers */
	InOut        = 3, /**< Term is both read and written */
	In           = 4, /**< Term is only read */
	Out          = 5, /**< Term is only written */
}

/** Specify operator for term */
oper_kind_t :: enum i32 {
	And      = 0, /**< The term must match */
	Or       = 1, /**< One of the terms in an or chain must match */
	Not      = 2, /**< The term must not match */
	Optional = 3, /**< The term may match */
	AndFrom  = 4, /**< Term must match all components from term id */
	OrFrom   = 5, /**< Term must match at least one component from term id */
	NotFrom  = 6, /**< Term must match none of the components from term id */
}

/** Specify cache policy for query */
query_cache_kind_t :: enum i32 {
	Default = 0, /**< Behavior determined by query creation context */
	Auto    = 1, /**< Cache query terms that are cacheable */
	All     = 2, /**< Require that all query terms can be cached */
	None    = 3, /**< No caching */
}

/* Term id flags  */

/** Match on self.
* Can be combined with other term flags on the ecs_term_t::flags_ field.
* \ingroup queries
*/
EcsSelf                       :: (1<<63)

/** Match by traversing upwards.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsUp                         :: (1<<62)

/** Traverse relationship transitively.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsTrav                       :: (1<<61)

/** Sort results breadth first.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsCascade                    :: (1<<60)

/** Iterate groups in descending order.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsDesc                       :: (1<<59)

/** Term id is a variable.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsIsVariable                 :: (1<<58)

/** Term id is an entity.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsIsEntity                   :: (1<<57)

/** Term id is a name (don't attempt to lookup as entity).
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsIsName                     :: (1<<56)

/** All term traversal flags.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsTraverseFlags              :: (EcsSelf|EcsUp|EcsTrav|EcsCascade|EcsDesc)

/** All term reference kind flags.
* Can be combined with other term flags on the ecs_term_ref_t::id field.
* \ingroup queries
*/
EcsTermRefFlags               :: (EcsTraverseFlags|EcsIsVariable|EcsIsEntity|EcsIsName)

/** Type that describes a reference to an entity or variable in a term. */
term_ref_t :: struct {
	id:   entity_t, /**< Entity id. If left to 0 and flags does not 
                                 * specify whether id is an entity or a variable
                                 * the id will be initialized to #EcsThis.
                                 * To explicitly set the id to 0, leave the id
                                 * member to 0 and set #EcsIsEntity in flags. */
	name: cstring,  /**< Name. This can be either the variable name
                                 * (when the #EcsIsVariable flag is set) or an
                                 * entity name. When ecs_term_t::move is true,
                                 * the API assumes ownership over the string and
                                 * will free it when the term is destroyed. */
}

/** Type that describes a term (single element in a query). */
term_t :: struct {
	id:          id_t,       /**< Component id to be matched by term. Can be
                                 * set directly, or will be populated from the
                                 * first/second members, which provide more
                                 * flexibility. */
	src:         term_ref_t, /**< Source of term */
	first:       term_ref_t, /**< Component or first element of pair */
	second:      term_ref_t, /**< Second element of pair */
	trav:        entity_t,   /**< Relationship to traverse when looking for the
                                 * component. The relationship must have
                                 * the `Traversable` property. Default is `IsA`. */
	inout:       i16,        /**< Access to contents matched by term */
	oper:        i16,        /**< Operator of term */
	field_index: i8,         /**< Index of field for term in iterator */
	flags_:      flags16_t,  /**< Flags that help eval, set by ecs_query_init() */
}

/** Queries are lists of constraints (terms) that match entities.
* Created with ecs_query_init().
*/
query_t :: struct {
	hdr:          header_t,  /**< Object header */
	terms:        ^term_t,   /**< Query terms */
	sizes:        ^i32,      /**< Component sizes. Indexed by field */
	ids:          ^id_t,     /**< Component ids. Indexed by field */
	bloom_filter: u64,       /**< Bitmask used to quickly discard tables */
	flags:        flags32_t, /**< Query flags */
	var_count:    i8,        /**< Number of query variables */
	term_count:   i8,        /**< Number of query terms */
	field_count:  i8,        /**< Number of fields returned by query */

	/* Bitmasks for quick field information lookups */
	fixed_fields:           flags32_t,          /**< Fields with a fixed source */
	var_fields:             flags32_t,          /**< Fields with non-$this variable source */
	static_id_fields:       flags32_t,          /**< Fields with a static (component) id */
	data_fields:            flags32_t,          /**< Fields that have data */
	write_fields:           flags32_t,          /**< Fields that write data */
	read_fields:            flags32_t,          /**< Fields that read data */
	row_fields:             flags32_t,          /**< Fields that must be acquired with field_at */
	shared_readonly_fields: flags32_t,          /**< Fields that don't write shared data */
	set_fields:             flags32_t,          /**< Fields that will be set */
	cache_kind:             query_cache_kind_t, /**< Caching policy of query */
	vars:                   ^cstring,           /**< Array with variable names for iterator */
	ctx:                    rawptr,             /**< User context to pass to callback */
	binding_ctx:            rawptr,             /**< Context to be used for language bindings */
	entity:                 entity_t,           /**< Entity associated with query (optional) */
	real_world:             ^world_t,           /**< Actual world. */
	world:                  ^world_t,           /**< World or stage query was created with. */
	eval_count:             i32,                /**< Number of times query is evaluated */
}

/** An observer reacts to events matching a query.
* Created with ecs_observer_init().
*/
observer_t :: struct {
	hdr:   header_t, /**< Object header */
	query: ^query_t, /**< Observer query */

	/** Observer events */
	events:            [8]entity_t,
	event_count:       i32,           /**< Number of events */
	callback:          iter_action_t, /**< See ecs_observer_desc_t::callback */
	run:               run_action_t,  /**< See ecs_observer_desc_t::run */
	ctx:               rawptr,        /**< Observer context */
	callback_ctx:      rawptr,        /**< Callback language binding context */
	run_ctx:           rawptr,        /**< Run language binding context */
	ctx_free:          ctx_free_t,    /**< Callback to free ctx */
	callback_ctx_free: ctx_free_t,    /**< Callback to free callback_ctx */
	run_ctx_free:      ctx_free_t,    /**< Callback to free run_ctx */
	observable:        ^observable_t, /**< Observable for observer */
	world:             ^world_t,      /**< The world */
	entity:            entity_t,      /**< Entity associated with observer */
}

type_hooks_t :: struct {
	ctor: xtor_t, /**< ctor */
	dtor: xtor_t, /**< dtor */
	copy: copy_t, /**< copy assignment */
	move: move_t, /**< move assignment */

	/** Ctor + copy */
	copy_ctor: copy_t,

	/** Ctor + move */
	move_ctor: move_t,

	/** Ctor + move + dtor (or move_ctor + dtor).
	* This combination is typically used when a component is moved from one
	* location to a new location, like when it is moved to a new table. If
	* not set explicitly it will be derived from other callbacks. */
	ctor_move_dtor: move_t,

	/** Move + dtor.
	* This combination is typically used when a component is moved from one
	* location to an existing location, like what happens during a remove. If
	* not set explicitly it will be derived from other callbacks. */
	move_dtor: move_t,

	/** Compare hook */
	cmp: cmp_t,

	/** Equals hook */
	equals: equals_t,

	/** Hook flags.
	* Indicates which hooks are set for the type, and which hooks are illegal.
	* When an ILLEGAL flag is set when calling ecs_set_hooks() a hook callback
	* will be set that panics when called. */
	flags: flags32_t,

	/** Callback that is invoked when an instance of a component is added. This
	* callback is invoked before triggers are invoked. */
	on_add: iter_action_t,

	/** Callback that is invoked when an instance of the component is set. This
	* callback is invoked before triggers are invoked, and enable the component
	* to respond to changes on itself before others can. */
	on_set: iter_action_t,

	/** Callback that is invoked when an instance of the component is removed.
	* This callback is invoked after the triggers are invoked, and before the
	* destructor is invoked. */
	on_remove: iter_action_t,

	/** Callback that is invoked with the existing and new value before the
	* value is assigned. Invoked after on_add and before on_set. Registering
	* an on_replace hook prevents using operations that return a mutable
	* pointer to the component like get_mut, ensure and emplace. */
	on_replace:         iter_action_t,
	ctx:                rawptr,     /**< User defined context */
	binding_ctx:        rawptr,     /**< Language binding context */
	lifecycle_ctx:      rawptr,     /**< Component lifecycle context (see meta add-on)*/
	ctx_free:           ctx_free_t, /**< Callback to free ctx */
	binding_ctx_free:   ctx_free_t, /**< Callback to free binding_ctx */
	lifecycle_ctx_free: ctx_free_t, /**< Callback to free lifecycle_ctx */
}

/** Type that contains component information (passed to ctors/dtors/...)
*
* @ingroup components
*/
type_info_t :: struct {
	size:      size_t,       /**< Size of type */
	alignment: size_t,       /**< Alignment of type */
	hooks:     type_hooks_t, /**< Type hooks */
	component: entity_t,     /**< Handle to component (do not set) */
	name:      cstring,      /**< Type name. */
}

/** Utility to hold a value of a dynamic type. */
value_t :: struct {
	type: entity_t, /**< Type of value. */
	ptr:  rawptr,   /**< Pointer to value. */
}

/** Used with ecs_entity_init().
*
* @ingroup entities
*/
entity_desc_t :: struct {
	_canary:    i32,      /**< Used for validity testing. Must be 0. */
	id:         entity_t, /**< Set to modify existing entity (optional) */
	parent:     entity_t, /**< Parent entity. */
	name:       cstring,  /**< Name of the entity. If no entity is provided, an
                           * entity with this name will be looked up first. When
                           * an entity is provided, the name will be verified
                           * with the existing entity. */
	sep:        cstring,  /**< Optional custom separator for hierarchical names.
                           * Leave to NULL for default ('.') separator. Set to
                           * an empty string to prevent tokenization of name. */
	root_sep:   cstring,  /**< Optional, used for identifiers relative to root */
	symbol:     cstring,  /**< Optional entity symbol. A symbol is an unscoped
                           * identifier that can be used to lookup an entity. The
                           * primary use case for this is to associate the entity
                           * with a language identifier, such as a type or
                           * function name, where these identifiers differ from
                           * the name they are registered with in flecs. For
                           * example, C type "EcsPosition" might be registered
                           * as "flecs.components.transform.Position", with the
                           * symbol set to "EcsPosition". */
	use_low_id: bool,     /**< When set to true, a low id (typically reserved for
                           * components) will be used to create the entity, if
                           * no id is specified. */

	/** 0-terminated array of ids to add to the entity. */
	add: ^id_t,

	/** 0-terminated array of values to set on the entity. */
	set: ^value_t,

	/** String expression with components to add */
	add_expr: cstring,
}

/** Used with ecs_bulk_init().
*
* @ingroup entities
*/
bulk_desc_t :: struct {
	_canary:  i32,       /**< Used for validity testing. Must be 0. */
	entities: ^entity_t, /**< Entities to bulk insert. Entity ids provided by
                             * the application must be empty (cannot
                             * have components). If no entity ids are provided, the
                             * operation will create 'count' new entities. */
	count:    i32,       /**< Number of entities to create/populate */
	ids:      [32]id_t,  /**< Ids to create the entities with */
	data:     ^rawptr,   /**< Array with component data to insert. Each element in
                        * the array must correspond with an element in the ids
                        * array. If an element in the ids array is a tag, the
                        * data array must contain a NULL. An element may be
                        * set to NULL for a component, in which case the
                        * component will not be set by the operation. */
	table:    ^table_t,  /**< Table to insert the entities into. Should not be set
                         * at the same time as ids. When 'table' is set at the
                         * same time as 'data', the elements in the data array
                         * must correspond with the ids in the table's type. */
}

/** Used with ecs_component_init().
*
* @ingroup components
*/
component_desc_t :: struct {
	_canary: i32, /**< Used for validity testing. Must be 0. */

	/** Existing entity to associate with observer (optional) */
	entity: entity_t,

	/** Parameters for type (size, hooks, ...) */
	type: type_info_t,
}

/** Iterator.
* Used for iterating queries. The ecs_iter_t type contains all the information
* that is provided by a query, and contains all the state required for the
* iterator code.
*
* Functions that create iterators accept as first argument the world, and as
* second argument the object they iterate. For example:
*
* @code
* ecs_iter_t it = ecs_query_iter(world, q);
* @endcode
*
* When this code is called from a system, it is important to use the world
* provided by its iterator object to ensure thread safety. For example:
*
* @code
* void Collide(ecs_iter_t *it) {
*   ecs_iter_t qit = ecs_query_iter(it->world, Colliders);
* }
* @endcode
*
* An iterator contains resources that need to be released. By default this
* is handled by the last call to next() that returns false. When iteration is
* ended before iteration has completed, an application has to manually call
* ecs_iter_fini() to release the iterator resources:
*
* @code
* ecs_iter_t it = ecs_query_iter(world, q);
* while (ecs_query_next(&it)) {
*   if (cond) {
*     ecs_iter_fini(&it);
*     break;
*   }
* }
* @endcode
*
* @ingroup queries
*/
iter_t :: struct {
	/* World */
	world:      ^world_t, /**< The world. Can point to stage when in deferred/readonly mode. */
	real_world: ^world_t, /**< Actual world. Never points to a stage. */

	/* Matched data */
	offset:           i32,              /**< Offset relative to current table */
	count:            i32,              /**< Number of entities to iterate */
	entities:         ^entity_t,        /**< Entity identifiers */
	ptrs:             ^rawptr,          /**< Component pointers. If not set or if it's NULL for a field, use it.trs. */
	trs:              ^^table_record_t, /**< Info on where to find field in table */
	sizes:            ^size_t,          /**< Component sizes */
	table:            ^table_t,         /**< Current table */
	other_table:      ^table_t,         /**< Prev or next table when adding/removing */
	ids:              ^id_t,            /**< (Component) ids */
	sources:          ^entity_t,        /**< Entity on which the id was matched (0 if same as entities) */
	constrained_vars: flags64_t,        /**< Bitset that marks constrained variables */
	set_fields:       flags32_t,        /**< Fields that are set */
	ref_fields:       flags32_t,        /**< Bitset with fields that aren't component arrays */
	row_fields:       flags32_t,        /**< Fields that must be obtained with field_at */
	up_fields:        flags32_t,        /**< Bitset with fields matched through up traversal */

	/* Input information */
	system:    entity_t, /**< The system (if applicable) */
	event:     entity_t, /**< The event (if applicable) */
	event_id:  id_t,     /**< The (component) id for the event */
	event_cur: i32,      /**< Unique event id. Used to dedup observer calls */

	/* Query information */
	field_count: i8,       /**< Number of fields in iterator */
	term_index:  i8,       /**< Index of term that emitted an event.
                                   * This field will be set to the 'index' field
                                   * of an observer term. */
	query:       ^query_t, /**< Query being evaluated */

	/* Context */
	param:        rawptr, /**< Param passed to ecs_run */
	ctx:          rawptr, /**< System context */
	binding_ctx:  rawptr, /**< System binding context */
	callback_ctx: rawptr, /**< Callback language binding context */
	run_ctx:      rawptr, /**< Run language binding context */

	/* Time */
	delta_time:        f32, /**< Time elapsed since last frame */
	delta_system_time: f32, /**< Time elapsed since last system invocation */

	/* Iterator counters */
	frame_offset: i32, /**< Offset relative to start of iteration */

	/* Misc */
	flags:          flags32_t,      /**< Iterator flags */
	interrupted_by: entity_t,       /**< When set, system execution is interrupted */
	priv_:          iter_private_t, /**< Private data */

	/* Chained iterators */
	next:     iter_next_action_t, /**< Function to progress iterator */
	callback: iter_action_t,      /**< Callback of system or observer */
	fini:     iter_fini_action_t, /**< Function to cleanup iterator resources */
	chain_it: ^iter_t,            /**< Optional, allows for creating iterator chains */
}

/** Query must match prefabs.
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
* \ingroup queries
*/
EcsQueryMatchPrefab           :: (1<<1)

/** Query must match disabled entities.
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
* \ingroup queries
*/
EcsQueryMatchDisabled         :: (1<<2)

/** Query must match empty tables.
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
* \ingroup queries
*/
EcsQueryMatchEmptyTables      :: (1<<3)

/** Query may have unresolved entity identifiers.
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
* \ingroup queries
*/
EcsQueryAllowUnresolvedByName :: (1<<6)

/** Query only returns whole tables (ignores toggle/member fields).
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
* \ingroup queries
*/
EcsQueryTableOnly             :: (1<<7)

/** Enable change detection for query.
* Can be combined with other query flags on the ecs_query_desc_t::flags field.
*
* Adding this flag makes it possible to use ecs_query_changed() and
* ecs_iter_changed() with the query. Change detection requires the query to be
* cached. If cache_kind is left to the default value, this flag will cause it
* to default to EcsQueryCacheAuto.
*
* \ingroup queries
*/
EcsQueryDetectChanges         :: (1<<8)

/** Used with ecs_query_init().
*
* \ingroup queries
*/
query_desc_t :: struct {
	/** Used for validity testing. Must be 0. */
	_canary: i32,

	/** Query terms */
	terms: [32]term_t,

	/** Query DSL expression (optional) */
	expr: cstring,

	/** Caching policy of query */
	cache_kind: query_cache_kind_t,

	/** Flags for enabling query features */
	flags: flags32_t,

	/** Callback used for ordering query results. If order_by_id is 0, the
	* pointer provided to the callback will be NULL. If the callback is not
	* set, results will not be ordered. */
	order_by_callback: order_by_action_t,

	/** Callback used for ordering query results. Same as order_by_callback,
	* but more efficient. */
	order_by_table_callback: sort_table_action_t,

	/** Component to sort on, used together with order_by_callback or
	* order_by_table_callback. */
	order_by: entity_t,

	/** Component id to be used for grouping. Used together with the
	* group_by_callback. */
	group_by: id_t,

	/** Callback used for grouping results. If the callback is not set, results
	* will not be grouped. When set, this callback will be used to calculate a
	* "rank" for each entity (table) based on its components. This rank is then
	* used to sort entities (tables), so that entities (tables) of the same
	* rank are "grouped" together when iterated. */
	group_by_callback: group_by_action_t,

	/** Callback that is invoked when a new group is created. The return value of
	* the callback is stored as context for a group. */
	on_group_create: group_create_action_t,

	/** Callback that is invoked when an existing group is deleted. The return
	* value of the on_group_create callback is passed as context parameter. */
	on_group_delete: group_delete_action_t,

	/** Context to pass to group_by */
	group_by_ctx: rawptr,

	/** Function to free group_by_ctx */
	group_by_ctx_free: ctx_free_t,

	/** User context to pass to callback */
	ctx: rawptr,

	/** Context to be used for language bindings */
	binding_ctx: rawptr,

	/** Callback to free ctx */
	ctx_free: ctx_free_t,

	/** Callback to free binding_ctx */
	binding_ctx_free: ctx_free_t,

	/** Entity associated with query (optional) */
	entity: entity_t,
}

/** Used with ecs_observer_init().
*
* @ingroup observers
*/
observer_desc_t :: struct {
	/** Used for validity testing. Must be 0. */
	_canary: i32,

	/** Existing entity to associate with observer (optional) */
	entity: entity_t,

	/** Query for observer */
	query: query_desc_t,

	/** Events to observe (OnAdd, OnRemove, OnSet) */
	events: [8]entity_t,

	/** When observer is created, generate events from existing data. For example,
	* #EcsOnAdd `Position` would match all existing instances of `Position`. */
	yield_existing: bool,

	/** Callback to invoke on an event, invoked when the observer matches. */
	callback: iter_action_t,

	/** Callback invoked on an event. When left to NULL the default runner
	* is used which matches the event with the observer's query, and calls
	* 'callback' when it matches.
	* A reason to override the run function is to improve performance, if there
	* are more efficient way to test whether an event matches the observer than
	* the general purpose query matcher. */
	run: run_action_t,

	/** User context to pass to callback */
	ctx: rawptr,

	/** Callback to free ctx */
	ctx_free: ctx_free_t,

	/** Context associated with callback (for language bindings). */
	callback_ctx: rawptr,

	/** Callback to free callback ctx. */
	callback_ctx_free: ctx_free_t,

	/** Context associated with run (for language bindings). */
	run_ctx: rawptr,

	/** Callback to free run ctx. */
	run_ctx_free: ctx_free_t,

	/** Used for internal purposes. Do not set. */
	last_event_id: ^i32,
	term_index_:   i8,
	flags_:        flags32_t,
}

/** Used with ecs_emit().
*
* @ingroup observers
*/
event_desc_t :: struct {
	/** The event id. Only observers for the specified event will be notified */
	event: entity_t,

	/** Component ids. Only observers with a matching component id will be
	* notified. Observers are guaranteed to get notified once, even if they
	* match more than one id. */
	ids: ^type_t,

	/** The table for which to notify. */
	table: ^table_t,

	/** Optional 2nd table to notify. This can be used to communicate the
	* previous or next table, in case an entity is moved between tables. */
	other_table: ^table_t,

	/** Limit notified entities to ones starting from offset (row) in table */
	offset: i32,

	/** Limit number of notified entities to count. offset+count must be less
	* than the total number of entities in the table. If left to 0, it will be
	* automatically determined by doing `ecs_table_count(table) - offset`. */
	count: i32,

	/** Single-entity alternative to setting table / offset / count */
	entity: entity_t,

	/** Optional context.
	* The type of the param must be the event, where the event is a component.
	* When an event is enqueued, the value of param is coped to a temporary
	* storage of the event type. */
	param: rawptr,

	/** Same as param, but with the guarantee that the value won't be modified.
	* When an event with a const parameter is enqueued, the value of the param
	* is copied to a temporary storage of the event type. */
	const_param: rawptr,

	/** Observable (usually the world) */
	observable: ^poly_t,

	/** Event flags */
	flags: flags32_t,
}

/** Type with information about the current Flecs build */
build_info_t :: struct {
	compiler:      cstring,  /**< Compiler used to compile flecs */
	addons:        ^cstring, /**< Addons included in build */
	flags:         ^cstring, /**< Compile time settings */
	version:       cstring,  /**< Stringified version */
	version_major: i16,      /**< Major flecs version */
	version_minor: i16,      /**< Minor flecs version */
	version_patch: i16,      /**< Patch flecs version */
	debug:         bool,     /**< Is this a debug build */
	sanitize:      bool,     /**< Is this a sanitize build */
	perf_trace:    bool,     /**< Is this a perf tracing build */
}

/** Type that contains information about the world. */
world_info_t :: struct {
	last_component_id:          entity_t, /**< Last issued component entity id */
	min_id:                     entity_t, /**< First allowed entity id */
	max_id:                     entity_t, /**< Last allowed entity id */
	delta_time_raw:             f32,      /**< Raw delta time (no time scaling) */
	delta_time:                 f32,      /**< Time passed to or computed by ecs_progress() */
	time_scale:                 f32,      /**< Time scale applied to delta_time */
	target_fps:                 f32,      /**< Target fps */
	frame_time_total:           f32,      /**< Total time spent processing a frame */
	system_time_total:          f32,      /**< Total time spent in systems */
	emit_time_total:            f32,      /**< Total time spent notifying observers */
	merge_time_total:           f32,      /**< Total time spent in merges */
	rematch_time_total:         f32,      /**< Time spent on query rematching */
	world_time_total:           f64,      /**< Time elapsed in simulation */
	world_time_total_raw:       f64,      /**< Time elapsed in simulation (no scaling) */
	frame_count_total:          i64,      /**< Total number of frames */
	merge_count_total:          i64,      /**< Total number of merges */
	eval_comp_monitors_total:   i64,      /**< Total number of monitor evaluations */
	rematch_count_total:        i64,      /**< Total number of rematches */
	id_create_total:            i64,      /**< Total number of times a new id was created */
	id_delete_total:            i64,      /**< Total number of times an id was deleted */
	table_create_total:         i64,      /**< Total number of times a table was created */
	table_delete_total:         i64,      /**< Total number of times a table was deleted */
	pipeline_build_count_total: i64,      /**< Total number of pipeline builds */
	systems_ran_total:          i64,      /**< Total number of systems ran */
	observers_ran_total:        i64,      /**< Total number of times observer was invoked */
	queries_ran_total:          i64,      /**< Total number of times a query was evaluated */
	tag_id_count:               i32,      /**< Number of tag (no data) ids in the world */
	component_id_count:         i32,      /**< Number of component (data) ids in the world */
	pair_id_count:              i32,      /**< Number of pair ids in the world */
	table_count:                i32,      /**< Number of tables */
	creation_time:              u32,      /**< Time when world was created */

	cmd: struct {
		add_count:             i64, /**< Add commands processed */
		remove_count:          i64, /**< Remove commands processed */
		delete_count:          i64, /**< Delete commands processed */
		clear_count:           i64, /**< Clear commands processed */
		set_count:             i64, /**< Set commands processed */
		ensure_count:          i64, /**< Ensure/emplace commands processed */
		modified_count:        i64, /**< Modified commands processed */
		discard_count:         i64, /**< Commands discarded, happens when entity is no longer alive when running the command */
		event_count:           i64, /**< Enqueued custom events */
		other_count:           i64, /**< Other commands processed */
		batched_entity_count:  i64, /**< Entities for which commands were batched */
		batched_command_count: i64, /**< Commands batched */
	}, /**< Command statistics. */

	name_prefix: cstring, /**< Value set by ecs_set_name_prefix(). Used
                                       * to remove library prefixes of symbol
                                       * names (such as `Ecs`, `ecs_`) when
                                       * registering them as names. */
}

/** Type that contains information about a query group. */
query_group_info_t :: struct {
	id:          u64,
	match_count: i32,    /**< How often tables have been matched/unmatched */
	table_count: i32,    /**< Number of tables in group */
	ctx:         rawptr, /**< Group context, returned by on_group_create */
}

/** A (string) identifier. Used as pair with #EcsName and #EcsSymbol tags */
EcsIdentifier :: struct {
	value:      cstring,    /**< Identifier string */
	length:     size_t,     /**< Length of identifier */
	hash:       u64,        /**< Hash of current value */
	index_hash: u64,        /**< Hash of existing record in current index */
	index:      ^hashmap_t, /**< Current index */
}

/** Component information. */
EcsComponent :: struct {
	size:      size_t, /**< Component size */
	alignment: size_t, /**< Component alignment */
}

/** Component for storing a poly object */
EcsPoly :: struct {
	poly: ^poly_t, /**< Pointer to poly object */
}

/** When added to an entity this informs serialization formats which component
* to use when a value is assigned to an entity without specifying the
* component. This is intended as a hint, serialization formats are not required
* to use it. Adding this component does not change the behavior of core ECS
* operations. */
EcsDefaultChildComponent :: struct {
	component: id_t, /**< Default component id. */
}

/** The first user-defined component starts from this id. Ids up to this number
* are reserved for builtin components */
EcsFirstUserComponentId :: (8)

/** The first user-defined entity starts from this id. Ids up to this number
* are reserved for builtin entities */
EcsFirstUserEntityId :: (FLECS_HI_COMPONENT_ID+128)

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
	/** Create a new world.
	* This operation automatically imports modules from addons Flecs has been built
	* with, except when the module specifies otherwise.
	*
	* @return A new world
	*/
	init :: proc() -> ^world_t ---

	/** Create a new world with just the core module.
	* Same as ecs_init(), but doesn't import modules from addons. This operation is
	* faster than ecs_init() and results in less memory utilization.
	*
	* @return A new tiny world
	*/
	mini :: proc() -> ^world_t ---

	/** Create a new world with arguments.
	* Same as ecs_init(), but allows passing in command line arguments. Command line
	* arguments are used to:
	* - automatically derive the name of the application from argv[0]
	*
	* @return A new world
	*/
	init_w_args :: proc(argc: i32, argv: [^]cstring) -> ^world_t ---

	/** Delete a world.
	* This operation deletes the world, and everything it contains.
	*
	* @param world The world to delete.
	* @return Zero if successful, non-zero if failed.
	*/
	fini :: proc(world: ^world_t) -> i32 ---

	/** Returns whether the world is being deleted.
	* This operation can be used in callbacks like type hooks or observers to
	* detect if they are invoked while the world is being deleted.
	*
	* @param world The world.
	* @return True if being deleted, false if not.
	*/
	is_fini :: proc(world: ^world_t) -> bool ---

	/** Register action to be executed when world is destroyed.
	* Fini actions are typically used when a module needs to clean up before a
	* world shuts down.
	*
	* @param world The world.
	* @param action The function to execute.
	* @param ctx Userdata to pass to the function */
	atfini :: proc(world: ^world_t, action: fini_action_t, ctx: rawptr) ---
}

/** Type returned by ecs_get_entities(). */
entities_t :: struct {
	ids:         ^entity_t, /**< Array with all entity ids in the world. */
	count:       i32,       /**< Total number of entity ids. */
	alive_count: i32,       /**< Number of alive entity ids. */
}

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
	/** Return entity identifiers in world.
	* This operation returns an array with all entity ids that exist in the world.
	* Note that the returned array will change and may get invalidated as a result
	* of entity creation & deletion.
	*
	* To iterate all alive entity ids, do:
	* @code
	* ecs_entities_t entities = ecs_get_entities(world);
	* for (int i = 0; i < entities.alive_count; i ++) {
	*   ecs_entity_t id = entities.ids[i];
	* }
	* @endcode
	*
	* To iterate not-alive ids, do:
	* @code
	* for (int i = entities.alive_count + 1; i < entities.count; i ++) {
	*   ecs_entity_t id = entities.ids[i];
	* }
	* @endcode
	*
	* The returned array does not need to be freed. Mutating the returned array
	* will return in undefined behavior (and likely crashes).
	*
	* @param world The world.
	* @return Struct with entity id array.
	*/
	get_entities :: proc(world: ^world_t) -> entities_t ---

	/** Get flags set on the world.
	* This operation returns the internal flags (see api_flags.h) that are
	* set on the world.
	*
	* @param world The world.
	* @return Flags set on the world.
	*/
	world_get_flags :: proc(world: ^world_t) -> flags32_t ---

	/** Begin frame.
	* When an application does not use ecs_progress() to control the main loop, it
	* can still use Flecs features such as FPS limiting and time measurements. This
	* operation needs to be invoked whenever a new frame is about to get processed.
	*
	* Calls to ecs_frame_begin() must always be followed by ecs_frame_end().
	*
	* The function accepts a delta_time parameter, which will get passed to
	* systems. This value is also used to compute the amount of time the function
	* needs to sleep to ensure it does not exceed the target_fps, when it is set.
	* When 0 is provided for delta_time, the time will be measured.
	*
	* This function should only be ran from the main thread.
	*
	* @param world The world.
	* @param delta_time Time elapsed since the last frame.
	* @return The provided delta_time, or measured time if 0 was provided.
	*/
	frame_begin :: proc(world: ^world_t, delta_time: f32) -> f32 ---

	/** End frame.
	* This operation must be called at the end of the frame, and always after
	* ecs_frame_begin().
	*
	* @param world The world.
	*/
	frame_end :: proc(world: ^world_t) ---

	/** Register action to be executed once after frame.
	* Post frame actions are typically used for calling operations that cannot be
	* invoked during iteration, such as changing the number of threads.
	*
	* @param world The world.
	* @param action The function to execute.
	* @param ctx Userdata to pass to the function */
	run_post_frame :: proc(world: ^world_t, action: fini_action_t, ctx: rawptr) ---

	/** Signal exit
	* This operation signals that the application should quit. It will cause
	* ecs_progress() to return false.
	*
	* @param world The world to quit.
	*/
	quit :: proc(world: ^world_t) ---

	/** Return whether a quit has been requested.
	*
	* @param world The world.
	* @return Whether a quit has been requested.
	* @see ecs_quit()
	*/
	should_quit :: proc(world: ^world_t) -> bool ---

	/** Measure frame time.
	* Frame time measurements measure the total time passed in a single frame, and
	* how much of that time was spent on systems and on merging.
	*
	* Frame time measurements add a small constant-time overhead to an application.
	* When an application sets a target FPS, frame time measurements are enabled by
	* default.
	*
	* @param world The world.
	* @param enable Whether to enable or disable frame time measuring.
	*/
	measure_frame_time :: proc(world: ^world_t, enable: bool) ---

	/** Measure system time.
	* System time measurements measure the time spent in each system.
	*
	* System time measurements add overhead to every system invocation and
	* therefore have a small but measurable impact on application performance.
	* System time measurements must be enabled before obtaining system statistics.
	*
	* @param world The world.
	* @param enable Whether to enable or disable system time measuring.
	*/
	measure_system_time :: proc(world: ^world_t, enable: bool) ---

	/** Set target frames per second (FPS) for application.
	* Setting the target FPS ensures that ecs_progress() is not invoked faster than
	* the specified FPS. When enabled, ecs_progress() tracks the time passed since
	* the last invocation, and sleeps the remaining time of the frame (if any).
	*
	* This feature ensures systems are ran at a consistent interval, as well as
	* conserving CPU time by not running systems more often than required.
	*
	* Note that ecs_progress() only sleeps if there is time left in the frame. Both
	* time spent in flecs as time spent outside of flecs are taken into
	* account.
	*
	* @param world The world.
	* @param fps The target FPS.
	*/
	set_target_fps :: proc(world: ^world_t, fps: f32) ---

	/** Set default query flags.
	* Set a default value for the ecs_filter_desc_t::flags field. Default flags
	* are applied in addition to the flags provided in the descriptor. For a
	* list of available flags, see include/flecs/private/api_flags.h. Typical flags
	* to use are:
	*
	*  - `EcsQueryMatchEmptyTables`
	*  - `EcsQueryMatchDisabled`
	*  - `EcsQueryMatchPrefab`
	*
	* @param world The world.
	* @param flags The query flags.
	*/
	set_default_query_flags :: proc(world: ^world_t, flags: flags32_t) ---

	/** Begin readonly mode.
	* This operation puts the world in readonly mode, which disallows mutations on
	* the world. Readonly mode exists so that internal mechanisms can implement
	* optimizations that certain aspects of the world to not change, while also
	* providing a mechanism for applications to prevent accidental mutations in,
	* for example, multithreaded applications.
	*
	* Readonly mode is a stronger version of deferred mode. In deferred mode
	* ECS operations such as add/remove/set/delete etc. are added to a command
	* queue to be executed later. In readonly mode, operations that could break
	* scheduler logic (such as creating systems, queries) are also disallowed.
	*
	* Readonly mode itself has a single threaded and a multi threaded mode. In
	* single threaded mode certain mutations on the world are still allowed, for
	* example:
	* - Entity liveliness operations (such as new, make_alive), so that systems are
	*   able to create new entities.
	* - Implicit component registration, so that this works from systems
	* - Mutations to supporting data structures for the evaluation of uncached
	*   queries (filters), so that these can be created on the fly.
	*
	* These mutations are safe in a single threaded applications, but for
	* multithreaded applications the world needs to be entirely immutable. For this
	* purpose multi threaded readonly mode exists, which disallows all mutations on
	* the world. This means that in multi threaded applications, entity liveliness
	* operations, implicit component registration, and on-the-fly query creation
	* are not guaranteed to work.
	*
	* While in readonly mode, applications can still enqueue ECS operations on a
	* stage. Stages are managed automatically when using the pipeline addon and
	* ecs_progress(), but they can also be configured manually as shown here:
	*
	* @code
	* // Number of stages typically corresponds with number of threads
	* ecs_set_stage_count(world, 2);
	* ecs_stage_t *stage = ecs_get_stage(world, 1);
	*
	* ecs_readonly_begin(world);
	* ecs_add(world, e, Tag); // readonly assert
	* ecs_add(stage, e, Tag); // OK
	* @endcode
	*
	* When an attempt is made to perform an operation on a world in readonly mode,
	* the code will throw an assert saying that the world is in readonly mode.
	*
	* A call to ecs_readonly_begin() must be followed up with ecs_readonly_end().
	* When ecs_readonly_end() is called, all enqueued commands from configured
	* stages are merged back into the world. Calls to ecs_readonly_begin() and
	* ecs_readonly_end() should always happen from a context where the code has
	* exclusive access to the world. The functions themselves are not thread safe.
	*
	* In a typical application, a (non-exhaustive) call stack that uses
	* ecs_readonly_begin() and ecs_readonly_end() will look like this:
	*
	* @code
	* ecs_progress()
	*   ecs_readonly_begin()
	*     ecs_defer_begin()
	*
	*       // user code
	*
	*   ecs_readonly_end()
	*     ecs_defer_end()
	*@endcode
	*
	* @param world The world
	* @param multi_threaded Whether to enable readonly/multi threaded mode.
	* @return Whether world is in readonly mode.
	*/
	readonly_begin :: proc(world: ^world_t, multi_threaded: bool) -> bool ---

	/** End readonly mode.
	* This operation ends readonly mode, and must be called after
	* ecs_readonly_begin(). Operations that were deferred while the world was in
	* readonly mode will be flushed.
	*
	* @param world The world
	*/
	readonly_end :: proc(world: ^world_t) ---

	/** Merge stage.
	* This will merge all commands enqueued for a stage.
	*
	* @param stage The stage.
	*/
	merge :: proc(stage: ^world_t) ---

	/** Defer operations until end of frame.
	* When this operation is invoked while iterating, operations inbetween the
	* ecs_defer_begin() and ecs_defer_end() operations are executed at the end
	* of the frame.
	*
	* This operation is thread safe.
	*
	* @param world The world.
	* @return true if world changed from non-deferred mode to deferred mode.
	*
	* @see ecs_defer_end()
	* @see ecs_is_deferred()
	* @see ecs_defer_resume()
	* @see ecs_defer_suspend()
	* @see ecs_is_defer_suspended()
	*/
	defer_begin :: proc(world: ^world_t) -> bool ---

	/** End block of operations to defer.
	* See ecs_defer_begin().
	*
	* This operation is thread safe.
	*
	* @param world The world.
	* @return true if world changed from deferred mode to non-deferred mode.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_is_deferred()
	* @see ecs_defer_resume()
	* @see ecs_defer_suspend()
	*/
	defer_end :: proc(world: ^world_t) -> bool ---

	/** Suspend deferring but do not flush queue.
	* This operation can be used to do an undeferred operation while not flushing
	* the operations in the queue.
	*
	* An application should invoke ecs_defer_resume() before ecs_defer_end() is called.
	* The operation may only be called when deferring is enabled.
	*
	* @param world The world.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_end()
	* @see ecs_defer_is_deferred()
	* @see ecs_defer_resume()
	*/
	defer_suspend :: proc(world: ^world_t) ---

	/** Resume deferring.
	* See ecs_defer_suspend().
	*
	* @param world The world.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_end()
	* @see ecs_defer_is_deferred()
	* @see ecs_defer_suspend()
	*/
	defer_resume :: proc(world: ^world_t) ---

	/** Test if deferring is enabled for current stage.
	*
	* @param world The world.
	* @return True if deferred, false if not.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_end()
	* @see ecs_defer_resume()
	* @see ecs_defer_suspend()
	* @see ecs_is_defer_suspended()
	*/
	is_deferred :: proc(world: ^world_t) -> bool ---

	/** Test if deferring is suspended for current stage.
	*
	* @param world The world.
	* @return True if suspended, false if not.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_end()
	* @see ecs_is_deferred()
	* @see ecs_defer_resume()
	* @see ecs_defer_suspend()
	*/
	is_defer_suspended :: proc(world: ^world_t) -> bool ---

	/** Configure world to have N stages.
	* This initializes N stages, which allows applications to defer operations to
	* multiple isolated defer queues. This is typically used for applications with
	* multiple threads, where each thread gets its own queue, and commands are
	* merged when threads are synchronized.
	*
	* Note that the ecs_set_threads() function already creates the appropriate
	* number of stages. The ecs_set_stage_count() operation is useful for applications
	* that want to manage their own stages and/or threads.
	*
	* @param world The world.
	* @param stages The number of stages.
	*/
	set_stage_count :: proc(world: ^world_t, stages: i32) ---

	/** Get number of configured stages.
	* Return number of stages set by ecs_set_stage_count().
	*
	* @param world The world.
	* @return The number of stages used for threading.
	*/
	get_stage_count :: proc(world: ^world_t) -> i32 ---

	/** Get stage-specific world pointer.
	* Flecs threads can safely invoke the API as long as they have a private
	* context to write to, also referred to as the stage. This function returns a
	* pointer to a stage, disguised as a world pointer.
	*
	* Note that this function does not(!) create a new world. It simply wraps the
	* existing world in a thread-specific context, which the API knows how to
	* unwrap. The reason the stage is returned as an ecs_world_t is so that it
	* can be passed transparently to the existing API functions, vs. having to
	* create a dedicated API for threading.
	*
	* @param world The world.
	* @param stage_id The index of the stage to retrieve.
	* @return A thread-specific pointer to the world.
	*/
	get_stage :: proc(world: ^world_t, stage_id: i32) -> ^world_t ---

	/** Test whether the current world is readonly.
	* This function allows the code to test whether the currently used world
	* is readonly or whether it allows for writing.
	*
	* @param world A pointer to a stage or the world.
	* @return True if the world or stage is readonly.
	*/
	stage_is_readonly :: proc(world: ^world_t) -> bool ---

	/** Create unmanaged stage.
	* Create a stage whose lifecycle is not managed by the world. Must be freed
	* with ecs_stage_free().
	*
	* @param world The world.
	* @return The stage.
	*/
	stage_new :: proc(world: ^world_t) -> ^world_t ---

	/** Free unmanaged stage.
	*
	* @param stage The stage to free.
	*/
	stage_free :: proc(stage: ^world_t) ---

	/** Get stage id.
	* The stage id can be used by an application to learn about which stage it is
	* using, which typically corresponds with the worker thread id.
	*
	* @param world The world.
	* @return The stage id.
	*/
	stage_get_id :: proc(world: ^world_t) -> i32 ---

	/** Set a world context.
	* This operation allows an application to register custom data with a world
	* that can be accessed anywhere where the application has the world.
	*
	* @param world The world.
	* @param ctx A pointer to a user defined structure.
	* @param ctx_free A function that is invoked with ctx when the world is freed.
	*/
	set_ctx :: proc(world: ^world_t, ctx: rawptr, ctx_free: ctx_free_t) ---

	/** Set a world binding context.
	* Same as ecs_set_ctx() but for binding context. A binding context is intended
	* specifically for language bindings to store binding specific data.
	*
	* @param world The world.
	* @param ctx A pointer to a user defined structure.
	* @param ctx_free A function that is invoked with ctx when the world is freed.
	*/
	set_binding_ctx :: proc(world: ^world_t, ctx: rawptr, ctx_free: ctx_free_t) ---

	/** Get the world context.
	* This operation retrieves a previously set world context.
	*
	* @param world The world.
	* @return The context set with ecs_set_ctx(). If no context was set, the
	*         function returns NULL.
	*/
	get_ctx :: proc(world: ^world_t) -> rawptr ---

	/** Get the world binding context.
	* This operation retrieves a previously set world binding context.
	*
	* @param world The world.
	* @return The context set with ecs_set_binding_ctx(). If no context was set, the
	*         function returns NULL.
	*/
	get_binding_ctx :: proc(world: ^world_t) -> rawptr ---

	/** Get build info.
	*  Returns information about the current Flecs build.
	*
	* @return A struct with information about the current Flecs build.
	*/
	get_build_info :: proc() -> ^build_info_t ---

	/** Get world info.
	*
	* @param world The world.
	* @return Pointer to the world info. Valid for as long as the world exists.
	*/
	get_world_info :: proc(world: ^world_t) -> ^world_info_t ---

	/** Dimension the world for a specified number of entities.
	* This operation will preallocate memory in the world for the specified number
	* of entities. Specifying a number lower than the current number of entities in
	* the world will have no effect.
	*
	* @param world The world.
	* @param entity_count The number of entities to preallocate.
	*/
	dim :: proc(world: ^world_t, entity_count: i32) ---

	/** Free unused memory.
	* This operation frees allocated memory that is no longer in use by the world.
	* Examples of allocations that get cleaned up are:
	* - Unused pages in the entity index
	* - Component columns
	* - Empty tables
	*
	* Flecs uses allocators internally for speeding up allocations. Allocators are
	* not evaluated by this function, which means that the memory reported by the
	* OS may not go down. For this reason, this function is most effective when
	* combined with FLECS_USE_OS_ALLOC, which disables internal allocators.
	*
	* @param world The world.
	*/
	shrink :: proc(world: ^world_t) ---

	/** Set a range for issuing new entity ids.
	* This function constrains the entity identifiers returned by ecs_new_w() to the
	* specified range. This operation can be used to ensure that multiple processes
	* can run in the same simulation without requiring a central service that
	* coordinates issuing identifiers.
	*
	* If `id_end` is set to 0, the range is infinite. If `id_end` is set to a non-zero
	* value, it has to be larger than `id_start`. If `id_end` is set and ecs_new() is
	* invoked after an id is issued that is equal to `id_end`, the application will
	* abort.
	*
	* @param world The world.
	* @param id_start The start of the range.
	* @param id_end The end of the range.
	*/
	set_entity_range :: proc(world: ^world_t, id_start: entity_t, id_end: entity_t) ---

	/** Enable/disable range limits.
	* When an application is both a receiver of range-limited entities and a
	* producer of range-limited entities, range checking needs to be temporarily
	* disabled when inserting received entities. Range checking is disabled on a
	* stage, so setting this value is thread safe.
	*
	* @param world The world.
	* @param enable True if range checking should be enabled, false to disable.
	* @return The previous value.
	*/
	enable_range_check :: proc(world: ^world_t, enable: bool) -> bool ---

	/** Get the largest issued entity id (not counting generation).
	*
	* @param world The world.
	* @return The largest issued entity id.
	*/
	get_max_id :: proc(world: ^world_t) -> entity_t ---

	/** Force aperiodic actions.
	* The world may delay certain operations until they are necessary for the
	* application to function correctly. This may cause observable side effects
	* such as delayed triggering of events, which can be inconvenient when for
	* example running a test suite.
	*
	* The flags parameter specifies which aperiodic actions to run. Specify 0 to
	* run all actions. Supported flags start with 'EcsAperiodic'. Flags identify
	* internal mechanisms and may change unannounced.
	*
	* @param world The world.
	* @param flags The flags specifying which actions to run.
	*/
	run_aperiodic :: proc(world: ^world_t, flags: flags32_t) ---
}

/** Used with ecs_delete_empty_tables(). */
delete_empty_tables_desc_t :: struct {
	/** Free table data when generation > clear_generation. */
	clear_generation: u16,

	/** Delete table when generation > delete_generation. */
	delete_generation: u16,

	/** Amount of time operation is allowed to spend. */
	time_budget_seconds: f64,
}

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
	/** Cleanup empty tables.
	* This operation cleans up empty tables that meet certain conditions. Having
	* large amounts of empty tables does not negatively impact performance of the
	* ECS, but can take up considerable amounts of memory, especially in
	* applications with many components, and many components per entity.
	*
	* The generation specifies the minimum number of times this operation has
	* to be called before an empty table is cleaned up. If a table becomes non
	* empty, the generation is reset.
	*
	* The operation allows for both a "clear" generation and a "delete"
	* generation. When the clear generation is reached, the table's
	* resources are freed (like component arrays) but the table itself is not
	* deleted. When the delete generation is reached, the empty table is deleted.
	*
	* By specifying a non-zero id the cleanup logic can be limited to tables with
	* a specific (component) id. The operation will only increase the generation
	* count of matching tables.
	*
	* The min_id_count specifies a lower bound for the number of components a table
	* should have. Often the more components a table has, the more specific it is
	* and therefore less likely to be reused.
	*
	* The time budget specifies how long the operation should take at most.
	*
	* @param world The world.
	* @param desc Configuration parameters.
	* @return Number of deleted tables.
	*/
	delete_empty_tables :: proc(world: ^world_t, desc: ^delete_empty_tables_desc_t) -> i32 ---

	/** Get world from poly.
	*
	* @param poly A pointer to a poly object.
	* @return The world.
	*/
	get_world :: proc(poly: ^poly_t) -> ^world_t ---

	/** Get entity from poly.
	*
	* @param poly A pointer to a poly object.
	* @return Entity associated with the poly object.
	*/
	get_entity :: proc(poly: ^poly_t) -> entity_t ---

	/** Test if pointer is of specified type.
	* Usage:
	*
	* @code
	* flecs_poly_is(ptr, ecs_world_t)
	* @endcode
	*
	* This operation only works for poly types.
	*
	* @param object The object to test.
	* @param type The id of the type.
	* @return True if the pointer is of the specified type.
	*/
	flecs_poly_is_ :: proc(object: ^poly_t, type: i32) -> bool ---

	/** Make a pair id.
	* This function is equivalent to using the ecs_pair() macro, and is added for
	* convenience to make it easier for non C/C++ bindings to work with pairs.
	*
	* @param first The first element of the pair of the pair.
	* @param second The target of the pair.
	* @return A pair id.
	*/
	make_pair :: proc(first: entity_t, second: entity_t) -> id_t ---

	/** Begin exclusive thread access.
	* This operation ensures that only the thread from which this operation is
	* called can access the world. Attempts to access the world from other threads
	* will panic.
	*
	* ecs_exclusive_access_begin() must be called in pairs with
	* ecs_exclusive_access_end(). Calling ecs_exclusive_access_begin() from another
	* thread without first calling ecs_exclusive_access_end() will panic.
	*
	* A thread name can be provided to the function to improve debug messages. The
	* function does not(!) copy the thread name, which means the memory for the
	* name must remain alive for as long as the thread has exclusive access.
	*
	* This operation should only be called once per thread. Calling it multiple
	* times for the same thread will cause a panic.
	*
	* Note that this feature only works in builds where asserts are enabled. The
	* feature requires the OS API thread_self_ callback to be set.
	*
	* @param world The world.
	* @param thread_name Name of the thread obtaining exclusive access.
	*/
	exclusive_access_begin :: proc(world: ^world_t, thread_name: cstring) ---

	/** End exclusive thread access.
	* This operation should be called after ecs_exclusive_access_begin(). After
	* calling this operation other threads are no longer prevented from mutating
	* the world.
	*
	* When "lock_world" is set to true, no thread will be able to mutate the world
	* until ecs_exclusive_access_begin is called again. While the world is locked
	* only readonly operations are allowed. For example, ecs_get_id() is allowed,
	* but ecs_get_mut_id() is not allowed.
	*
	* A locked world can be unlocked by calling ecs_exclusive_access_end again with
	* lock_world set to false. Note that this only works for locked worlds, if\
	* ecs_exclusive_access_end() is called on a world that has exclusive thread
	* access from a different thread, a panic will happen.
	*
	* This operation must be called from the same thread that called
	* ecs_exclusive_access_begin(). Calling it from a different thread will cause
	* a panic.
	*
	* @param world The world.
	* @param lock_world When true, any mutations on the world will be blocked.
	*/
	exclusive_access_end :: proc(world: ^world_t, lock_world: bool) ---

	/** Create new entity id.
	* This operation returns an unused entity id. This operation is guaranteed to
	* return an empty entity as it does not use values set by ecs_set_scope() or
	* ecs_set_with().
	*
	* @param world The world.
	* @return The new entity id.
	*/
	new :: proc(world: ^world_t) -> entity_t ---

	/** Create new low id.
	* This operation returns a new low id. Entity ids start after the
	* FLECS_HI_COMPONENT_ID constant. This reserves a range of low ids for things
	* like components, and allows parts of the code to optimize operations.
	*
	* Note that FLECS_HI_COMPONENT_ID does not represent the maximum number of
	* components that can be created, only the maximum number of components that
	* can take advantage of these optimizations.
	*
	* This operation is guaranteed to return an empty entity as it does not use
	* values set by ecs_set_scope() or ecs_set_with().
	*
	* This operation does not recycle ids.
	*
	* @param world The world.
	* @return The new component id.
	*/
	new_low_id :: proc(world: ^world_t) -> entity_t ---

	/** Create new entity with (component) id.
	* This operation creates a new entity with an optional (component) id. When 0
	* is passed to the id parameter, no component is added to the new entity.
	*
	* @param world The world.
	* @param component The component to create the new entity with.
	* @return The new entity.
	*/
	new_w_id :: proc(world: ^world_t, component: id_t) -> entity_t ---

	/** Create new entity in table.
	* This operation creates a new entity in the specified table.
	*
	* @param world The world.
	* @param table The table to which to add the new entity.
	* @return The new entity.
	*/
	new_w_table :: proc(world: ^world_t, table: ^table_t) -> entity_t ---

	/** Find or create an entity.
	* This operation creates a new entity, or modifies an existing one. When a name
	* is set in the ecs_entity_desc_t::name field and ecs_entity_desc_t::entity is
	* not set, the operation will first attempt to find an existing entity by that
	* name. If no entity with that name can be found, it will be created.
	*
	* If both a name and entity handle are provided, the operation will check if
	* the entity name matches with the provided name. If the names do not match,
	* the function will fail and return 0.
	*
	* If an id to a non-existing entity is provided, that entity id become alive.
	*
	* See the documentation of ecs_entity_desc_t for more details.
	*
	* @param world The world.
	* @param desc Entity init parameters.
	* @return A handle to the new or existing entity, or 0 if failed.
	*/
	entity_init :: proc(world: ^world_t, desc: ^entity_desc_t) -> entity_t ---

	/** Bulk create/populate new entities.
	* This operation bulk inserts a list of new or predefined entities into a
	* single table.
	*
	* The operation does not take ownership of component arrays provided by the
	* application. Components that are non-trivially copyable will be moved into
	* the storage.
	*
	* The operation will emit OnAdd events for each added id, and OnSet events for
	* each component that has been set.
	*
	* If no entity ids are provided by the application, the returned array of ids
	* points to an internal data structure which changes when new entities are
	* created/deleted.
	*
	* If as a result of the operation triggers are invoked that deletes
	* entities and no entity ids were provided by the application, the returned
	* array of identifiers may be incorrect. To avoid this problem, an application
	* can first call ecs_bulk_init() to create empty entities, copy the array to one
	* that is owned by the application, and then use this array to populate the
	* entities.
	*
	* @param world The world.
	* @param desc Bulk creation parameters.
	* @return Array with the list of entity ids created/populated.
	*/
	bulk_init :: proc(world: ^world_t, desc: ^bulk_desc_t) -> ^entity_t ---

	/** Create N new entities.
	* This operation is the same as ecs_new_w_id(), but creates N entities
	* instead of one.
	*
	* @param world The world.
	* @param component The component to create the entities with.
	* @param count The number of entities to create.
	* @return The first entity id of the newly created entities.
	*/
	bulk_new_w_id :: proc(world: ^world_t, component: id_t, count: i32) -> ^entity_t ---

	/** Clone an entity
	* This operation clones the components of one entity into another entity. If
	* no destination entity is provided, a new entity will be created. Component
	* values are not copied unless copy_value is true.
	*
	* If the source entity has a name, it will not be copied to the destination
	* entity. This is to prevent having two entities with the same name under the
	* same parent, which is not allowed.
	*
	* @param world The world.
	* @param dst The entity to copy the components to.
	* @param src The entity to copy the components from.
	* @param copy_value If true, the value of components will be copied to dst.
	* @return The destination entity.
	*/
	clone :: proc(world: ^world_t, dst: entity_t, src: entity_t, copy_value: bool) -> entity_t ---

	/** Delete an entity.
	* This operation will delete an entity and all of its components. The entity id
	* will be made available for recycling. If the entity passed to ecs_delete() is
	* not alive, the operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	*/
	delete :: proc(world: ^world_t, entity: entity_t) ---

	/** Delete all entities with the specified component.
	* This will delete all entities (tables) that have the specified id. The
	* component may be a wildcard and/or a pair.
	*
	* @param world The world.
	* @param component The component.
	*/
	delete_with :: proc(world: ^world_t, component: id_t) ---

	/** Set child order for parent with OrderedChildren.
	* If the parent has the OrderedChildren trait, the order of the children
	* will be updated to the order in the specified children array. The operation
	* will fail if the parent does not have the OrderedChildren trait.
	*
	* This operation always takes place immediately, and is not deferred. When the
	* operation is called from a multithreaded system it will fail.
	*
	* The reason for not deferring this operation is that by the time the deferred
	* command would be executed, the children of the parent could have been changed
	* which would cause the operation to fail.
	*
	* @param world The world.
	* @param parent The parent.
	* @param children An array with children.
	* @param child_count The number of children in the provided array.
	*/
	set_child_order :: proc(world: ^world_t, parent: entity_t, children: ^entity_t, child_count: i32) ---

	/** Get ordered children.
	* If a parent has the OrderedChildren trait, this operation can be used to
	* obtain the array with child entities. If this operation is used on a parent
	* that does not have the OrderedChildren trait, it will fail.asm
	*
	* @param world The world.
	* @param parent The parent.
	* @return The array with child entities.
	*/
	get_ordered_children :: proc(world: ^world_t, parent: entity_t) -> entities_t ---

	/** Add a (component) id to an entity.
	* This operation adds a single (component) id to an entity. If the entity
	* already has the id, this operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component id to add.
	*/
	add_id :: proc(world: ^world_t, entity: entity_t, component: id_t) ---

	/** Remove a component from an entity.
	* This operation removes a single component from an entity. If the entity
	* does not have the component, this operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to remove.
	*/
	remove_id :: proc(world: ^world_t, entity: entity_t, component: id_t) ---

	/** Add auto override for component.
	* An auto override is a component that is automatically added to an entity when
	* it is instantiated from a prefab. Auto overrides are added to the entity that
	* is inherited from (usually a prefab). For example:
	*
	* @code
	* ecs_entity_t prefab = ecs_insert(world,
	*   ecs_value(Position, {10, 20}),
	*   ecs_value(Mass, {100}));
	*
	* ecs_auto_override(world, prefab, Position);
	*
	* ecs_entity_t inst = ecs_new_w_pair(world, EcsIsA, prefab);
	* assert(ecs_owns(world, inst, Position)); // true
	* assert(ecs_owns(world, inst, Mass)); // false
	* @endcode
	*
	* An auto override is equivalent to a manual override:
	*
	* @code
	* ecs_entity_t prefab = ecs_insert(world,
	*   ecs_value(Position, {10, 20}),
	*   ecs_value(Mass, {100}));
	*
	* ecs_entity_t inst = ecs_new_w_pair(world, EcsIsA, prefab);
	* assert(ecs_owns(world, inst, Position)); // false
	* ecs_add(world, inst, Position); // manual override
	* assert(ecs_owns(world, inst, Position)); // true
	* assert(ecs_owns(world, inst, Mass)); // false
	* @endcode
	*
	* This operation is equivalent to manually adding the id with the AUTO_OVERRIDE
	* bit applied:
	*
	* @code
	* ecs_add_id(world, entity, ECS_AUTO_OVERRIDE | id);
	* @endcode
	*
	* When a component is overridden and inherited from a prefab, the value from
	* the prefab component is copied to the instance. When the component is not
	* inherited from a prefab, it is added to the instance as if using ecs_add_id().
	*
	* Overriding is the default behavior on prefab instantiation. Auto overriding
	* is only useful for components with the `(OnInstantiate, Inherit)` trait.
	* When a component has the `(OnInstantiate, DontInherit)` trait and is overridden
	* the component is added, but the value from the prefab will not be copied.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to auto override.
	*/
	auto_override_id :: proc(world: ^world_t, entity: entity_t, component: id_t) ---

	/** Clear all components.
	* This operation will remove all components from an entity.
	*
	* @param world The world.
	* @param entity The entity.
	*/
	clear :: proc(world: ^world_t, entity: entity_t) ---

	/** Remove all instances of the specified component.
	* This will remove the specified id from all entities (tables). The id may be
	* a wildcard and/or a pair.
	*
	* @param world The world.
	* @param component The component.
	*/
	remove_all :: proc(world: ^world_t, component: id_t) ---

	/** Create new entities with specified component.
	* Entities created with ecs_entity_init() will be created with the specified
	* component. This does not apply to entities created with ecs_new().
	*
	* Only one component can be specified at a time. If this operation is called
	* while a component is already configured, the new component will override the
	* old component.
	*
	* @param world The world.
	* @param component The component.
	* @return The previously set component.
	* @see ecs_entity_init()
	* @see ecs_set_with()
	*/
	set_with :: proc(world: ^world_t, component: id_t) -> entity_t ---

	/** Get component set with ecs_set_with().
	* Get the component set with ecs_set_with().
	*
	* @param world The world.
	* @return The last component provided to ecs_set_with().
	* @see ecs_set_with()
	*/
	get_with :: proc(world: ^world_t) -> id_t ---

	/** Enable or disable entity.
	* This operation enables or disables an entity by adding or removing the
	* #EcsDisabled tag. A disabled entity will not be matched with any systems,
	* unless the system explicitly specifies the #EcsDisabled tag.
	*
	* @param world The world.
	* @param entity The entity to enable or disable.
	* @param enabled true to enable the entity, false to disable.
	*/
	enable :: proc(world: ^world_t, entity: entity_t, enabled: bool) ---

	/** Enable or disable component.
	* Enabling or disabling a component does not add or remove a component from an
	* entity, but prevents it from being matched with queries. This operation can
	* be useful when a component must be temporarily disabled without destroying
	* its value. It is also a more performant operation for when an application
	* needs to add/remove components at high frequency, as enabling/disabling is
	* cheaper than a regular add or remove.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to enable/disable.
	* @param enable True to enable the component, false to disable.
	*/
	enable_id :: proc(world: ^world_t, entity: entity_t, component: id_t, enable: bool) ---

	/** Test if component is enabled.
	* Test whether a component is currently enabled or disabled. This operation
	* will return true when the entity has the component and if it has not been
	* disabled by ecs_enable_component().
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component.
	* @return True if the component is enabled, otherwise false.
	*/
	is_enabled_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> bool ---

	/** Get an immutable pointer to a component.
	* This operation obtains a const pointer to the requested component. The
	* operation accepts the component entity id.
	*
	* This operation can return inherited components reachable through an `IsA`
	* relationship.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to get.
	* @return The component pointer, NULL if the entity does not have the component.
	*
	* @see ecs_get_mut_id()
	*/
	get_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> rawptr ---

	/** Get a mutable pointer to a component.
	* This operation obtains a mutable pointer to the requested component. The
	* operation accepts the component entity id.
	*
	* Unlike ecs_get_id(), this operation does not return inherited components.
	* This is to prevent errors where an application accidentally resolves an
	* inherited component shared with many entities and modifies it, while thinking
	* it is modifying an owned component.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to get.
	* @return The component pointer, NULL if the entity does not have the component.
	*/
	get_mut_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> rawptr ---

	/** Ensure entity has component, return pointer.
	* This operation returns a mutable pointer to a component. If the entity did
	* not yet have the component, it will be added.
	*
	* If ensure is called when the world is in deferred/readonly mode, the
	* function will:
	* - return a pointer to a temp storage if the component does not yet exist, or
	* - return a pointer to the existing component if it exists
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to get/add.
	* @return The component pointer.
	*
	* @see ecs_emplace_id()
	*/
	ensure_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t) -> rawptr ---

	/** Create a component ref.
	* A ref is a handle to an entity + component which caches a small amount of
	* data to reduce overhead of repeatedly accessing the component. Use
	* ecs_ref_get() to get the component data.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to create a ref for.
	* @return The reference.
	*/
	ref_init_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> ref_t ---

	/** Get component from ref.
	* Get component pointer from ref. The ref must be created with ecs_ref_init().
	* The specified component must match the component with which the ref was
	* created.
	*
	* @param world The world.
	* @param ref The ref.
	* @param component The component to get.
	* @return The component pointer, NULL if the entity does not have the component.
	*/
	ref_get_id :: proc(world: ^world_t, ref: ^ref_t, component: id_t) -> rawptr ---

	/** Update ref.
	* Ensures contents of ref are up to date. Same as ecs_ref_get_id(), but does not
	* return pointer to component id.
	*
	* @param world The world.
	* @param ref The ref.
	*/
	ref_update :: proc(world: ^world_t, ref: ^ref_t) ---

	/** Emplace a component.
	* Emplace is similar to ecs_ensure_id() except that the component constructor
	* is not invoked for the returned pointer, allowing the component to be
	* constructed directly in the storage.
	*
	* When the `is_new` parameter is not provided, the operation will assert when the
	* component already exists. When the `is_new` parameter is provided, it will
	* indicate whether the returned storage has been constructed.
	*
	* When `is_new` indicates that the storage has not yet been constructed, it must
	* be constructed by the code invoking this operation. Not constructing the
	* component will result in undefined behavior.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to get/add.
	* @param size The component size.
	* @param is_new Whether this is an existing or new component.
	* @return The (uninitialized) component pointer.
	*/
	emplace_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t, is_new: ^bool) -> rawptr ---

	/** Signal that a component has been modified.
	* This operation is usually used after modifying a component value obtained by
	* ecs_ensure_id(). The operation will mark the component as dirty, and invoke
	* OnSet observers and hooks.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component that was modified.
	*/
	modified_id :: proc(world: ^world_t, entity: entity_t, component: id_t) ---

	/** Set the value of a component.
	* This operation allows an application to set the value of a component. The
	* operation is equivalent to calling ecs_ensure_id() followed by
	* ecs_modified_id(). The operation will not modify the value of the passed in
	* component. If the component has a copy hook registered, it will be used to
	* copy in the component.
	*
	* If the provided entity is 0, a new entity will be created.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to set.
	* @param size The size of the pointed-to value.
	* @param ptr The pointer to the value.
	*/
	set_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t, ptr: rawptr) ---

	/** Test whether an entity is valid.
	* This operation tests whether the entity id:
	* - is not 0
	* - has a valid bit pattern
	* - is alive (see ecs_is_alive())
	*
	* If this operation returns true, it is safe to use the entity with other
	* other operations.
	*
	* This operation should only be used if an application cannot be sure that an
	* entity is initialized with a valid value. In all other cases where an entity
	* was initialized with a valid value, but the application wants to check if the
	* entity is (still) alive, use ecs_is_alive.
	*
	* @param world The world.
	* @param e The entity.
	* @return True if the entity is valid, false if the entity is not valid.
	* @see ecs_is_alive()
	*/
	is_valid :: proc(world: ^world_t, e: entity_t) -> bool ---

	/** Test whether an entity is alive.
	* Entities are alive after they are created, and become not alive when they are
	* deleted. Operations that return alive ids are (amongst others) ecs_new(),
	* ecs_new_low_id() and ecs_entity_init(). Ids can be made alive with the
	* ecs_make_alive() * function.
	*
	* After an id is deleted it can be recycled. Recycled ids are different from
	* the original id in that they have a different generation count. This makes it
	* possible for the API to distinguish between the two. An example:
	*
	* @code
	* ecs_entity_t e1 = ecs_new(world);
	* ecs_is_alive(world, e1);             // true
	* ecs_delete(world, e1);
	* ecs_is_alive(world, e1);             // false
	*
	* ecs_entity_t e2 = ecs_new(world);    // recycles e1
	* ecs_is_alive(world, e2);             // true
	* ecs_is_alive(world, e1);             // false
	* @endcode
	*
	* Other than ecs_is_valid(), this operation will panic if the passed in entity
	* id is 0 or has an invalid bit pattern.
	*
	* @param world The world.
	* @param e The entity.
	* @return True if the entity is alive, false if the entity is not alive.
	* @see ecs_is_valid()
	*/
	is_alive :: proc(world: ^world_t, e: entity_t) -> bool ---

	/** Remove generation from entity id.
	*
	* @param e The entity id.
	* @return The entity id without the generation count.
	*/
	strip_generation :: proc(e: entity_t) -> id_t ---

	/** Get alive identifier.
	* In some cases an application may need to work with identifiers from which
	* the generation has been stripped. A typical scenario in which this happens is
	* when iterating relationships in an entity type.
	*
	* For example, when obtaining the parent id from a `ChildOf` relationship, the parent
	* (second element of the pair) will have been stored in a 32 bit value, which
	* cannot store the entity generation. This function can retrieve the identifier
	* with the current generation for that id.
	*
	* If the provided identifier is not alive, the function will return 0.
	*
	* @param world The world.
	* @param e The for which to obtain the current alive entity id.
	* @return The alive entity id if there is one, or 0 if the id is not alive.
	*/
	get_alive :: proc(world: ^world_t, e: entity_t) -> entity_t ---

	/** Ensure id is alive.
	* This operation ensures that the provided id is alive. This is useful in
	* scenarios where an application has an existing id that has not been created
	* with ecs_new_w() (such as a global constant or an id from a remote application).
	*
	* When this operation is successful it guarantees that the provided id exists,
	* is valid and is alive.
	*
	* Before this operation the id must either not be alive or have a generation
	* that is equal to the passed in entity.
	*
	* If the provided id has a non-zero generation count and the id does not exist
	* in the world, the id will be created with the specified generation.
	*
	* If the provided id is alive and has a generation count that does not match
	* the provided id, the operation will fail.
	*
	* @param world The world.
	* @param entity The entity id to make alive.
	*
	* @see ecs_make_alive_id()
	*/
	make_alive :: proc(world: ^world_t, entity: entity_t) ---

	/** Same as ecs_make_alive(), but for components.
	* An id can be an entity or pair, and can contain id flags. This operation
	* ensures that the entity (or entities, for a pair) are alive.
	*
	* When this operation is successful it guarantees that the provided id can be
	* used in operations that accept an id.
	*
	* Since entities in a pair do not encode their generation ids, this operation
	* will not fail when an entity with non-zero generation count already exists in
	* the world.
	*
	* This is different from ecs_make_alive(), which will fail if attempted with an id
	* that has generation 0 and an entity with a non-zero generation is currently
	* alive.
	*
	* @param world The world.
	* @param component The component to make alive.
	*/
	make_alive_id :: proc(world: ^world_t, component: id_t) ---

	/** Test whether an entity exists.
	* Similar as ecs_is_alive(), but ignores entity generation count.
	*
	* @param world The world.
	* @param entity The entity.
	* @return True if the entity exists, false if the entity does not exist.
	*/
	exists :: proc(world: ^world_t, entity: entity_t) -> bool ---

	/** Override the generation of an entity.
	* The generation count of an entity is increased each time an entity is deleted
	* and is used to test whether an entity id is alive.
	*
	* This operation overrides the current generation of an entity with the
	* specified generation, which can be useful if an entity is externally managed,
	* like for external pools, savefiles or netcode.
	*
	* This operation is similar to ecs_make_alive(), except that it will also
	* override the generation of an alive entity.
	*
	* @param world The world.
	* @param entity Entity for which to set the generation with the new generation.
	*/
	set_version :: proc(world: ^world_t, entity: entity_t) ---

	/** Get generation of an entity.
	*
	* @param entity Entity for which to get the generation of.
	* @return The generation of the entity.
	*/
	get_version :: proc(entity: entity_t) -> u32 ---

	/** Get the type of an entity.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no components.
	*/
	get_type :: proc(world: ^world_t, entity: entity_t) -> ^type_t ---

	/** Get the table of an entity.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The table of the entity, NULL if the entity has no components/tags.
	*/
	get_table :: proc(world: ^world_t, entity: entity_t) -> ^table_t ---

	/** Convert type to string.
	* The result of this operation must be freed with ecs_os_free().
	*
	* @param world The world.
	* @param type The type.
	* @return The stringified type.
	*/
	type_str :: proc(world: ^world_t, type: ^type_t) -> cstring ---

	/** Convert table to string.
	* Same as `ecs_type_str(world, ecs_table_get_type(table))`. The result of this
	* operation must be freed with ecs_os_free().
	*
	* @param world The world.
	* @param table The table.
	* @return The stringified table type.
	*
	* @see ecs_table_get_type()
	* @see ecs_type_str()
	*/
	table_str :: proc(world: ^world_t, table: ^table_t) -> cstring ---

	/** Convert entity to string.
	* Same as combining:
	* - ecs_get_path(world, entity)
	* - ecs_type_str(world, ecs_get_type(world, entity))
	*
	* The result of this operation must be freed with ecs_os_free().
	*
	* @param world The world.
	* @param entity The entity.
	* @return The entity path with stringified type.
	*
	* @see ecs_get_path()
	* @see ecs_type_str()
	*/
	entity_str :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Test if an entity has a component.
	* This operation returns true if the entity has or inherits the component.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to test for.
	* @return True if the entity has the component, false if not.
	*
	* @see ecs_owns_id()
	*/
	has_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> bool ---

	/** Test if an entity owns a component.
	* This operation returns true if the entity has the component. The operation
	* behaves the same as ecs_has_id(), except that it will return false for
	* components that are inherited through an `IsA` relationship.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to test for.
	* @return True if the entity has the component, false if not.
	*/
	owns_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> bool ---

	/** Get the target of a relationship.
	* This will return a target (second element of a pair) of the entity for the
	* specified relationship. The index allows for iterating through the targets,
	* if a single entity has multiple targets for the same relationship.
	*
	* If the index is larger than the total number of instances the entity has for
	* the relationship, the operation will return 0.
	*
	* @param world The world.
	* @param entity The entity.
	* @param rel The relationship between the entity and the target.
	* @param index The index of the relationship instance.
	* @return The target for the relationship at the specified index.
	*/
	get_target :: proc(world: ^world_t, entity: entity_t, rel: entity_t, index: i32) -> entity_t ---

	/** Get parent (target of `ChildOf` relationship) for entity.
	* This operation is the same as calling:
	*
	* @code
	* ecs_get_target(world, entity, EcsChildOf, 0);
	* @endcode
	*
	* @param world The world.
	* @param entity The entity.
	* @return The parent of the entity, 0 if the entity has no parent.
	*
	* @see ecs_get_target()
	*/
	get_parent :: proc(world: ^world_t, entity: entity_t) -> entity_t ---

	/** Get the target of a relationship for a given component.
	* This operation returns the first entity that has the provided component by
	* following the relationship. If the entity itself has the component then it
	* will be returned. If the component cannot be found on the entity or by
	* following the relationship, the operation will return 0.
	*
	* This operation can be used to lookup, for example, which prefab is providing
	* a component by specifying the `IsA` relationship:
	*
	* @code
	* // Is Position provided by the entity or one of its base entities?
	* ecs_get_target_for_id(world, entity, EcsIsA, ecs_id(Position))
	* @endcode
	*
	* @param world The world.
	* @param entity The entity.
	* @param rel The relationship to follow.
	* @param component The component to lookup.
	* @return The entity for which the target has been found.
	*/
	get_target_for_id :: proc(world: ^world_t, entity: entity_t, rel: entity_t, component: id_t) -> entity_t ---

	/** Return depth for entity in tree for the specified relationship.
	* Depth is determined by counting the number of targets encountered while
	* traversing up the relationship tree for rel. Only acyclic relationships are
	* supported.
	*
	* @param world The world.
	* @param entity The entity.
	* @param rel The relationship.
	* @return The depth of the entity in the tree.
	*/
	get_depth :: proc(world: ^world_t, entity: entity_t, rel: entity_t) -> i32 ---

	/** Count entities that have the specified id.
	* Returns the number of entities that have the specified id.
	*
	* @param world The world.
	* @param entity The id to search for.
	* @return The number of entities that have the id.
	*/
	count_id :: proc(world: ^world_t, entity: id_t) -> i32 ---

	/** Get the name of an entity.
	* This will return the name stored in `(EcsIdentifier, EcsName)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no name.
	*
	* @see ecs_set_name()
	*/
	get_name :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get the symbol of an entity.
	* This will return the symbol stored in `(EcsIdentifier, EcsSymbol)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no name.
	*
	* @see ecs_set_symbol()
	*/
	get_symbol :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Set the name of an entity.
	* This will set or overwrite the name of an entity. If no entity is provided,
	* a new entity will be created.
	*
	* The name is stored in `(EcsIdentifier, EcsName)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @param name The name.
	* @return The provided entity, or a new entity if 0 was provided.
	*
	* @see ecs_get_name()
	*/
	set_name :: proc(world: ^world_t, entity: entity_t, name: cstring) -> entity_t ---

	/** Set the symbol of an entity.
	* This will set or overwrite the symbol of an entity. If no entity is provided,
	* a new entity will be created.
	*
	* The symbol is stored in (EcsIdentifier, EcsSymbol).
	*
	* @param world The world.
	* @param entity The entity.
	* @param symbol The symbol.
	* @return The provided entity, or a new entity if 0 was provided.
	*
	* @see ecs_get_symbol()
	*/
	set_symbol :: proc(world: ^world_t, entity: entity_t, symbol: cstring) -> entity_t ---

	/** Set alias for entity.
	* An entity can be looked up using its alias from the root scope without
	* providing the fully qualified name if its parent. An entity can only have
	* a single alias.
	*
	* The symbol is stored in `(EcsIdentifier, EcsAlias)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @param alias The alias.
	*/
	set_alias :: proc(world: ^world_t, entity: entity_t, alias: cstring) ---

	/** Lookup an entity by it's path.
	* This operation is equivalent to calling:
	*
	* @code
	* ecs_lookup_path_w_sep(world, 0, path, ".", NULL, true);
	* @endcode
	*
	* @param world The world.
	* @param path The entity path.
	* @return The entity with the specified path, or 0 if no entity was found.
	*
	* @see ecs_lookup_child()
	* @see ecs_lookup_path_w_sep()
	* @see ecs_lookup_symbol()
	*/
	lookup :: proc(world: ^world_t, path: cstring) -> entity_t ---

	/** Lookup a child entity by name.
	* Returns an entity that matches the specified name. Only looks for entities in
	* the provided parent. If no parent is provided, look in the current scope (
	* root if no scope is provided).
	*
	* @param world The world.
	* @param parent The parent for which to lookup the child.
	* @param name The entity name.
	* @return The entity with the specified name, or 0 if no entity was found.
	*
	* @see ecs_lookup()
	* @see ecs_lookup_path_w_sep()
	* @see ecs_lookup_symbol()
	*/
	lookup_child :: proc(world: ^world_t, parent: entity_t, name: cstring) -> entity_t ---

	/** Lookup an entity from a path.
	* Lookup an entity from a provided path, relative to the provided parent. The
	* operation will use the provided separator to tokenize the path expression. If
	* the provided path contains the prefix, the search will start from the root.
	*
	* If the entity is not found in the provided parent, the operation will
	* continue to search in the parent of the parent, until the root is reached. If
	* the entity is still not found, the lookup will search in the flecs.core
	* scope. If the entity is not found there either, the function returns 0.
	*
	* @param world The world.
	* @param parent The entity from which to resolve the path.
	* @param path The path to resolve.
	* @param sep The path separator.
	* @param prefix The path prefix.
	* @param recursive Recursively traverse up the tree until entity is found.
	* @return The entity if found, else 0.
	*
	* @see ecs_lookup()
	* @see ecs_lookup_child()
	* @see ecs_lookup_symbol()
	*/
	lookup_path_w_sep :: proc(world: ^world_t, parent: entity_t, path: cstring, sep: cstring, prefix: cstring, recursive: bool) -> entity_t ---

	/** Lookup an entity by its symbol name.
	* This looks up an entity by symbol stored in `(EcsIdentifier, EcsSymbol)`. The
	* operation does not take into account hierarchies.
	*
	* This operation can be useful to resolve, for example, a type by its C
	* identifier, which does not include the Flecs namespacing.
	*
	* @param world The world.
	* @param symbol The symbol.
	* @param lookup_as_path If not found as a symbol, lookup as path.
	* @param recursive If looking up as path, recursively traverse up the tree.
	* @return The entity if found, else 0.
	*
	* @see ecs_lookup()
	* @see ecs_lookup_child()
	* @see ecs_lookup_path_w_sep()
	*/
	lookup_symbol :: proc(world: ^world_t, symbol: cstring, lookup_as_path: bool, recursive: bool) -> entity_t ---

	/** Get a path identifier for an entity.
	* This operation creates a path that contains the names of the entities from
	* the specified parent to the provided entity, separated by the provided
	* separator. If no parent is provided the path will be relative to the root. If
	* a prefix is provided, the path will be prefixed by the prefix.
	*
	* If the parent is equal to the provided child, the operation will return an
	* empty string. If a nonzero component is provided, the path will be created by
	* looking for parents with that component.
	*
	* The returned path should be freed by the application.
	*
	* @param world The world.
	* @param parent The entity from which to create the path.
	* @param child The entity to which to create the path.
	* @param sep The separator to use between path elements.
	* @param prefix The initial character to use for root elements.
	* @return The relative entity path.
	*
	* @see ecs_get_path_w_sep_buf()
	*/
	get_path_w_sep :: proc(world: ^world_t, parent: entity_t, child: entity_t, sep: cstring, prefix: cstring) -> cstring ---

	/** Write path identifier to buffer.
	* Same as ecs_get_path_w_sep(), but writes result to an ecs_strbuf_t.
	*
	* @param world The world.
	* @param parent The entity from which to create the path.
	* @param child The entity to which to create the path.
	* @param sep The separator to use between path elements.
	* @param prefix The initial character to use for root elements.
	* @param buf The buffer to write to.
	*
	* @see ecs_get_path_w_sep()
	*/
	get_path_w_sep_buf :: proc(world: ^world_t, parent: entity_t, child: entity_t, sep: cstring, prefix: cstring, buf: ^strbuf_t, escape: bool) ---

	/** Find or create entity from path.
	* This operation will find or create an entity from a path, and will create any
	* intermediate entities if required. If the entity already exists, no entities
	* will be created.
	*
	* If the path starts with the prefix, then the entity will be created from the
	* root scope.
	*
	* @param world The world.
	* @param parent The entity relative to which the entity should be created.
	* @param path The path to create the entity for.
	* @param sep The separator used in the path.
	* @param prefix The prefix used in the path.
	* @return The entity.
	*/
	new_from_path_w_sep :: proc(world: ^world_t, parent: entity_t, path: cstring, sep: cstring, prefix: cstring) -> entity_t ---

	/** Add specified path to entity.
	* This operation is similar to ecs_new_from_path(), but will instead add the path
	* to an existing entity.
	*
	* If an entity already exists for the path, it will be returned instead.
	*
	* @param world The world.
	* @param entity The entity to which to add the path.
	* @param parent The entity relative to which the entity should be created.
	* @param path The path to create the entity for.
	* @param sep The separator used in the path.
	* @param prefix The prefix used in the path.
	* @return The entity.
	*/
	add_path_w_sep :: proc(world: ^world_t, entity: entity_t, parent: entity_t, path: cstring, sep: cstring, prefix: cstring) -> entity_t ---

	/** Set the current scope.
	* This operation sets the scope of the current stage to the provided entity.
	* As a result new entities will be created in this scope, and lookups will be
	* relative to the provided scope.
	*
	* It is considered good practice to restore the scope to the old value.
	*
	* @param world The world.
	* @param scope The entity to use as scope.
	* @return The previous scope.
	*
	* @see ecs_get_scope()
	*/
	set_scope :: proc(world: ^world_t, scope: entity_t) -> entity_t ---

	/** Get the current scope.
	* Get the scope set by ecs_set_scope(). If no scope is set, this operation will
	* return 0.
	*
	* @param world The world.
	* @return The current scope.
	*/
	get_scope :: proc(world: ^world_t) -> entity_t ---

	/** Set a name prefix for newly created entities.
	* This is a utility that lets C modules use prefixed names for C types and
	* C functions, while using names for the entity names that do not have the
	* prefix. The name prefix is currently only used by ECS_COMPONENT.
	*
	* @param world The world.
	* @param prefix The name prefix to use.
	* @return The previous prefix.
	*/
	set_name_prefix :: proc(world: ^world_t, prefix: cstring) -> cstring ---

	/** Set search path for lookup operations.
	* This operation accepts an array of entity ids that will be used as search
	* scopes by lookup operations. The operation returns the current search path.
	* It is good practice to restore the old search path.
	*
	* The search path will be evaluated starting from the last element.
	*
	* The default search path includes flecs.core. When a custom search path is
	* provided it overwrites the existing search path. Operations that rely on
	* looking up names from flecs.core without providing the namespace may fail if
	* the custom search path does not include flecs.core (EcsFlecsCore).
	*
	* The search path array is not copied into managed memory. The application must
	* ensure that the provided array is valid for as long as it is used as the
	* search path.
	*
	* The provided array must be terminated with a 0 element. This enables an
	* application to push/pop elements to an existing array without invoking the
	* ecs_set_lookup_path() operation again.
	*
	* @param world The world.
	* @param lookup_path 0-terminated array with entity ids for the lookup path.
	* @return Current lookup path array.
	*
	* @see ecs_get_lookup_path()
	*/
	set_lookup_path :: proc(world: ^world_t, lookup_path: ^entity_t) -> ^entity_t ---

	/** Get current lookup path.
	* Returns value set by ecs_set_lookup_path().
	*
	* @param world The world.
	* @return The current lookup path.
	*/
	get_lookup_path :: proc(world: ^world_t) -> ^entity_t ---

	/** Find or create a component.
	* This operation creates a new component, or finds an existing one. The find or
	* create behavior is the same as ecs_entity_init().
	*
	* When an existing component is found, the size and alignment are verified with
	* the provided values. If the values do not match, the operation will fail.
	*
	* See the documentation of ecs_component_desc_t for more details.
	*
	* @param world The world.
	* @param desc Component init parameters.
	* @return A handle to the new or existing component, or 0 if failed.
	*/
	component_init :: proc(world: ^world_t, desc: ^component_desc_t) -> entity_t ---

	/** Get the type info for an component.
	* This function returns the type information for a component. The component can
	* be a regular component or pair. For the rules on how type information is
	* determined based on a component id, see ecs_get_typeid().
	*
	* @param world The world.
	* @param component The component.
	* @return The type information of the id.
	*/
	get_type_info :: proc(world: ^world_t, component: id_t) -> ^type_info_t ---

	/** Register hooks for component.
	* Hooks allow for the execution of user code when components are constructed,
	* copied, moved, destructed, added, removed or set. Hooks can be assigned as
	* as long as a component has not yet been used (added to an entity).
	*
	* The hooks that are currently set can be accessed with ecs_get_type_info().
	*
	* @param world The world.
	* @param component The component for which to register the actions
	* @param hooks Type that contains the component actions.
	*/
	set_hooks_id :: proc(world: ^world_t, component: entity_t, hooks: ^type_hooks_t) ---

	/** Get hooks for component.
	*
	* @param world The world.
	* @param component The component for which to retrieve the hooks.
	* @return The hooks for the component, or NULL if not registered.
	*/
	get_hooks_id :: proc(world: ^world_t, component: entity_t) -> ^type_hooks_t ---

	/** Returns whether specified component is a tag.
	* This operation returns whether the specified component is a tag (a component
	* without data/size).
	*
	* An id is a tag when:
	* - it is an entity without the EcsComponent component
	* - it has an EcsComponent with size member set to 0
	* - it is a pair where both elements are a tag
	* - it is a pair where the first element has the #EcsPairIsTag tag
	*
	* @param world The world.
	* @param component The component.
	* @return Whether the provided id is a tag.
	*/
	id_is_tag :: proc(world: ^world_t, component: id_t) -> bool ---

	/** Returns whether specified component is in use.
	* This operation returns whether a component is in use in the world. A
	* component is in use if it has been added to one or more tables.
	*
	* @param world The world.
	* @param component The component.
	* @return Whether the component is in use.
	*/
	id_in_use :: proc(world: ^world_t, component: id_t) -> bool ---

	/** Get the type for a component.
	* This operation returns the type for a component id, if the id is associated
	* with a type. For a regular component with a non-zero size (an entity with the
	* EcsComponent component) the operation will return the component id itself.
	*
	* For an entity that does not have the EcsComponent component, or with an
	* EcsComponent value with size 0, the operation will return 0.
	*
	* For a pair id the operation will return the type associated with the pair, by
	* applying the following queries in order:
	* - The first pair element is returned if it is a component
	* - 0 is returned if the relationship entity has the Tag property
	* - The second pair element is returned if it is a component
	* - 0 is returned.
	*
	* @param world The world.
	* @param component The component.
	* @return The type of the component.
	*/
	get_typeid :: proc(world: ^world_t, component: id_t) -> entity_t ---

	/** Utility to match a component with a pattern.
	* This operation returns true if the provided pattern matches the provided
	* component. The pattern may contain a wildcard (or wildcards, when a pair).
	*
	* @param component The component.
	* @param pattern The pattern to compare with.
	* @return Whether the id matches the pattern.
	*/
	id_match :: proc(component: id_t, pattern: id_t) -> bool ---

	/** Utility to check if component is a pair.
	*
	* @param component The component.
	* @return True if component is a pair.
	*/
	id_is_pair :: proc(component: id_t) -> bool ---

	/** Utility to check if component is a wildcard.
	*
	* @param component The component.
	* @return True if component is a wildcard or a pair containing a wildcard.
	*/
	id_is_wildcard :: proc(component: id_t) -> bool ---

	/** Utility to check if component is an any wildcard.
	*
	* @param component The component.
	* @return True if component is an any wildcard or a pair containing an any wildcard.
	*/
	id_is_any :: proc(component: id_t) -> bool ---

	/** Utility to check if id is valid.
	* A valid id is an id that can be added to an entity. Invalid ids are:
	* - ids that contain wildcards
	* - ids that contain invalid entities
	* - ids that are 0 or contain 0 entities
	*
	* Note that the same rules apply to removing from an entity, with the exception
	* of wildcards.
	*
	* @param world The world.
	* @param component The component.
	* @return True if the id is valid.
	*/
	id_is_valid :: proc(world: ^world_t, component: id_t) -> bool ---

	/** Get flags associated with id.
	* This operation returns the internal flags (see api_flags.h) that are
	* associated with the provided id.
	*
	* @param world The world.
	* @param component The component.
	* @return Flags associated with the id, or 0 if the id is not in use.
	*/
	id_get_flags :: proc(world: ^world_t, component: id_t) -> flags32_t ---

	/** Convert component flag to string.
	* This operation converts a component flag to a string. Possible outputs are:
	*
	* - PAIR
	* - TOGGLE
	* - AUTO_OVERRIDE
	*
	* @param component_flags The component flag.
	* @return The id flag string, or NULL if no valid id is provided.
	*/
	id_flag_str :: proc(component_flags: id_t) -> cstring ---

	/** Convert component id to string.
	* This operation converts the provided component id to a string. It can output
	* strings of the following formats:
	*
	* - "ComponentName"
	* - "FLAG|ComponentName"
	* - "(Relationship, Target)"
	* - "FLAG|(Relationship, Target)"
	*
	* The PAIR flag never added to the string.
	*
	* @param world The world.
	* @param component The component to convert to a string.
	* @return The component converted to a string.
	*/
	id_str :: proc(world: ^world_t, component: id_t) -> cstring ---

	/** Write component string to buffer.
	* Same as ecs_id_str() but writes result to ecs_strbuf_t.
	*
	* @param world The world.
	* @param component The component to convert to a string.
	* @param buf The buffer to write to.
	*/
	id_str_buf :: proc(world: ^world_t, component: id_t, buf: ^strbuf_t) ---

	/** Convert string to a component.
	* This operation is the reverse of ecs_id_str(). The FLECS_SCRIPT addon
	* is required for this operation to work.
	*
	* @param world The world.
	* @param expr The string to convert to an id.
	*/
	id_from_str :: proc(world: ^world_t, expr: cstring) -> id_t ---

	/** Test whether term ref is set.
	* A term ref is a reference to an entity, component or variable for one of the
	* three parts of a term (src, first, second).
	*
	* @param ref The term ref.
	* @return True when set, false when not set.
	*/
	term_ref_is_set :: proc(ref: ^term_ref_t) -> bool ---

	/** Test whether a term is set.
	* This operation can be used to test whether a term has been initialized with
	* values or whether it is empty.
	*
	* An application generally does not need to invoke this operation. It is useful
	* when initializing a 0-initialized array of terms (like in ecs_term_desc_t) as
	* this operation can be used to find the last initialized element.
	*
	* @param term The term.
	* @return True when set, false when not set.
	*/
	term_is_initialized :: proc(term: ^term_t) -> bool ---

	/** Is term matched on $this variable.
	* This operation checks whether a term is matched on the $this variable, which
	* is the default source for queries.
	*
	* A term has a $this source when:
	* - ecs_term_t::src::id is EcsThis
	* - ecs_term_t::src::flags is EcsIsVariable
	*
	* If ecs_term_t::src is not populated, it will be automatically initialized to
	* the $this source for the created query.
	*
	* @param term The term.
	* @return True if term matches $this, false if not.
	*/
	term_match_this :: proc(term: ^term_t) -> bool ---

	/** Is term matched on 0 source.
	* This operation checks whether a term is matched on a 0 source. A 0 source is
	* a term that isn't matched against anything, and can be used just to pass
	* (component) ids to a query iterator.
	*
	* A term has a 0 source when:
	* - ecs_term_t::src::id is 0
	* - ecs_term_t::src::flags has EcsIsEntity set
	*
	* @param term The term.
	* @return True if term has 0 source, false if not.
	*/
	term_match_0 :: proc(term: ^term_t) -> bool ---

	/** Convert term to string expression.
	* Convert term to a string expression. The resulting expression is equivalent
	* to the same term, with the exception of And & Or operators.
	*
	* @param world The world.
	* @param term The term.
	* @return The term converted to a string.
	*/
	term_str :: proc(world: ^world_t, term: ^term_t) -> cstring ---

	/** Convert query to string expression.
	* Convert query to a string expression. The resulting expression can be
	* parsed to create the same query.
	*
	* @param query The query.
	* @return The query converted to a string.
	*/
	query_str :: proc(query: ^query_t) -> cstring ---

	/** Iterate all entities with specified (component id).
	* This returns an iterator that yields all entities with a single specified
	* component. This is a much lighter weight operation than creating and
	* iterating a query.
	*
	* Usage:
	* @code
	* ecs_iter_t it = ecs_each(world, Player);
	* while (ecs_each_next(&it)) {
	*   for (int i = 0; i < it.count; i ++) {
	*     // Iterate as usual.
	*   }
	* }
	* @endcode
	*
	* If the specified id is a component, it is possible to access the component
	* pointer with ecs_field just like with regular queries:
	*
	* @code
	* ecs_iter_t it = ecs_each(world, Position);
	* while (ecs_each_next(&it)) {
	*   Position *p = ecs_field(&it, Position, 0);
	*   for (int i = 0; i < it.count; i ++) {
	*     // Iterate as usual.
	*   }
	* }
	* @endcode
	*
	* @param world The world.
	* @param component The component to iterate.
	* @return An iterator that iterates all entities with the (component) id.
	*/
	each_id :: proc(world: ^world_t, component: id_t) -> iter_t ---

	/** Progress an iterator created with ecs_each_id().
	*
	* @param it The iterator.
	* @return True if the iterator has more results, false if not.
	*/
	each_next :: proc(it: ^iter_t) -> bool ---

	/** Iterate children of parent.
	* This operation is usually equivalent to doing:
	* @code
	* ecs_iter_t it = ecs_each_id(world, ecs_pair(EcsChildOf, parent));
	* @endcode
	*
	* The only exception is when the parent has the EcsOrderedChildren trait, in
	* which case this operation will return a single result with the ordered
	* child entity ids.
	*
	* This operation is equivalent to doing:
	*
	* @code
	* ecs_children_w_rel(world, EcsChildOf, parent);
	* @endcode
	*
	* @param world The world.
	* @param parent The parent.
	* @return An iterator that iterates all children of the parent.
	*
	* @see ecs_each_id()
	*/
	children :: proc(world: ^world_t, parent: entity_t) -> iter_t ---

	/** Same as ecs_children() but with custom relationship argument.
	*
	* @param world The world.
	* @param relationship The relationship.
	* @param parent The parent.
	* @return An iterator that iterates all children of the parent.
	*/
	children_w_rel :: proc(world: ^world_t, relationship: entity_t, parent: entity_t) -> iter_t ---

	/** Progress an iterator created with ecs_children().
	*
	* @param it The iterator.
	* @return True if the iterator has more results, false if not.
	*/
	children_next :: proc(it: ^iter_t) -> bool ---

	/** Create a query.
	*
	* @param world The world.
	* @param desc The descriptor (see ecs_query_desc_t)
	* @return The query.
	*/
	query_init :: proc(world: ^world_t, desc: ^query_desc_t) -> ^query_t ---

	/** Delete a query.
	*
	* @param query The query.
	*/
	query_fini :: proc(query: ^query_t) ---

	/** Find variable index.
	* This operation looks up the index of a variable in the query. This index can
	* be used in operations like ecs_iter_set_var() and ecs_iter_get_var().
	*
	* @param query The query.
	* @param name The variable name.
	* @return The variable index.
	*/
	query_find_var :: proc(query: ^query_t, name: cstring) -> i32 ---

	/** Get variable name.
	* This operation returns the variable name for an index.
	*
	* @param query The query.
	* @param var_id The variable index.
	* @return The variable name.
	*/
	query_var_name :: proc(query: ^query_t, var_id: i32) -> cstring ---

	/** Test if variable is an entity.
	* Internally the query engine has entity variables and table variables. When
	* iterating through query variables (by using ecs_query_variable_count()) only
	* the values for entity variables are accessible. This operation enables an
	* application to check if a variable is an entity variable.
	*
	* @param query The query.
	* @param var_id The variable id.
	* @return Whether the variable is an entity variable.
	*/
	query_var_is_entity :: proc(query: ^query_t, var_id: i32) -> bool ---

	/** Create a query iterator.
	* Use an iterator to iterate through the entities that match an entity. Queries
	* can return multiple results, and have to be iterated by repeatedly calling
	* ecs_query_next() until the operation returns false.
	*
	* Depending on the query, a single result can contain an entire table, a range
	* of entities in a table, or a single entity. Iteration code has an inner and
	* an outer loop. The outer loop loops through the query results, and typically
	* corresponds with a table. The inner loop loops entities in the result.
	*
	* Example:
	* @code
	* ecs_iter_t it = ecs_query_iter(world, q);
	*
	* while (ecs_query_next(&it)) {
	*   Position *p = ecs_field(&it, Position, 0);
	*   Velocity *v = ecs_field(&it, Velocity, 1);
	*
	*   for (int i = 0; i < it.count; i ++) {
	*     p[i].x += v[i].x;
	*     p[i].y += v[i].y;
	*   }
	* }
	* @endcode
	*
	* The world passed into the operation must be either the actual world or the
	* current stage, when iterating from a system. The stage is accessible through
	* the it.world member.
	*
	* Example:
	* @code
	* void MySystem(ecs_iter_t *it) {
	*   ecs_query_t *q = it->ctx; // Query passed as system context
	*
	*   // Create query iterator from system stage
	*   ecs_iter_t qit = ecs_query_iter(it->world, q);
	*   while (ecs_query_next(&qit)) {
	*     // Iterate as usual
	*   }
	* }
	* @endcode
	*
	* If query iteration is stopped without the last call to ecs_query_next()
	* returning false, iterator resources need to be cleaned up explicitly
	* with ecs_iter_fini().
	*
	* Example:
	* @code
	* ecs_iter_t it = ecs_query_iter(world, q);
	*
	* while (ecs_query_next(&it)) {
	*   if (!ecs_field_is_set(&it, 0)) {
	*     ecs_iter_fini(&it); // Free iterator resources
	*     break;
	*   }
	*
	*   for (int i = 0; i < it.count; i ++) {
	*     // ...
	*   }
	* }
	* @endcode
	*
	* @param world The world.
	* @param query The query.
	* @return An iterator.
	*
	* @see ecs_query_next()
	*/
	query_iter :: proc(world: ^world_t, query: ^query_t) -> iter_t ---

	/** Progress query iterator.
	*
	* @param it The iterator.
	* @return True if the iterator has more results, false if not.
	*
	* @see ecs_query_iter()
	*/
	query_next :: proc(it: ^iter_t) -> bool ---

	/** Match entity with query.
	* This operation matches an entity with a query and returns the result of the
	* match in the "it" out parameter. An application should free the iterator
	* resources with ecs_iter_fini() if this function returns true.
	*
	* Usage:
	* @code
	* ecs_iter_t it;
	* if (ecs_query_has(q, e, &it)) {
	*   ecs_iter_fini(&it);
	* }
	* @endcode
	*
	* @param query The query.
	* @param entity The entity to match
	* @param it The iterator with matched data.
	* @return True if entity matches the query, false if not.
	*/
	query_has :: proc(query: ^query_t, entity: entity_t, it: ^iter_t) -> bool ---

	/** Match table with query.
	* This operation matches a table with a query and returns the result of the
	* match in the "it" out parameter. An application should free the iterator
	* resources with ecs_iter_fini() if this function returns true.
	*
	* Usage:
	* @code
	* ecs_iter_t it;
	* if (ecs_query_has_table(q, t, &it)) {
	*   ecs_iter_fini(&it);
	* }
	* @endcode
	*
	* @param query The query.
	* @param table The table to match
	* @param it The iterator with matched data.
	* @return True if table matches the query, false if not.
	*/
	query_has_table :: proc(query: ^query_t, table: ^table_t, it: ^iter_t) -> bool ---

	/** Match range with query.
	* This operation matches a range with a query and returns the result of the
	* match in the "it" out parameter. An application should free the iterator
	* resources with ecs_iter_fini() if this function returns true.
	*
	* The entire range must match the query for the operation to return true.
	*
	* Usage:
	* @code
	* ecs_table_range_t range = {
	*   .table = table,
	*   .offset = 1,
	*   .count = 2
	* };
	*
	* ecs_iter_t it;
	* if (ecs_query_has_range(q, &range, &it)) {
	*   ecs_iter_fini(&it);
	* }
	* @endcode
	*
	* @param query The query.
	* @param range The range to match
	* @param it The iterator with matched data.
	* @return True if range matches the query, false if not.
	*/
	query_has_range :: proc(query: ^query_t, range: ^table_range_t, it: ^iter_t) -> bool ---

	/** Returns how often a match event happened for a cached query.
	* This operation can be used to determine whether the query cache has been
	* updated with new tables.
	*
	* @param query The query.
	* @return The number of match events happened.
	*/
	query_match_count :: proc(query: ^query_t) -> i32 ---

	/** Convert query to a string.
	* This will convert the query program to a string which can aid in debugging
	* the behavior of a query.
	*
	* The returned string must be freed with ecs_os_free().
	*
	* @param query The query.
	* @return The query plan.
	*/
	query_plan :: proc(query: ^query_t) -> cstring ---

	/** Convert query to string with profile.
	* To use this you must set the EcsIterProfile flag on an iterator before
	* starting iteration:
	*
	* @code
	*   it.flags |= EcsIterProfile
	* @endcode
	*
	* The returned string must be freed with ecs_os_free().
	*
	* @param query The query.
	* @param it The iterator with profile data.
	* @return The query plan with profile data.
	*/
	query_plan_w_profile :: proc(query: ^query_t, it: ^iter_t) -> cstring ---

	/** Populate variables from key-value string.
	* Convenience function to set query variables from a key-value string separated
	* by comma's. The string must have the following format:
	*
	* @code
	*   var_a: value, var_b: value
	* @endcode
	*
	* The key-value list may optionally be enclosed in parenthesis.
	*
	* This function uses the script addon.
	*
	* @param query The query.
	* @param it The iterator for which to set the variables.
	* @param expr The key-value expression.
	* @return Pointer to the next character after the last parsed one.
	*/
	query_args_parse :: proc(query: ^query_t, it: ^iter_t, expr: cstring) -> cstring ---

	/** Returns whether the query data changed since the last iteration.
	* The operation will return true after:
	* - new entities have been matched with
	* - new tables have been matched/unmatched with
	* - matched entities were deleted
	* - matched components were changed
	*
	* The operation will not return true after a write-only (EcsOut) or filter
	* (EcsInOutNone) term has changed, when a term is not matched with the
	* current table (This subject) or for tag terms.
	*
	* The changed state of a table is reset after it is iterated. If an iterator was
	* not iterated until completion, tables may still be marked as changed.
	*
	* If no iterator is provided the operation will return the changed state of the
	* all matched tables of the query.
	*
	* If an iterator is provided, the operation will return the changed state of
	* the currently returned iterator result. The following preconditions must be
	* met before using an iterator with change detection:
	*
	* - The iterator is a query iterator (created with ecs_query_iter())
	* - The iterator must be valid (ecs_query_next() must have returned true)
	*
	* @param query The query (optional if 'it' is provided).
	* @return true if entities changed, otherwise false.
	*/
	query_changed :: proc(query: ^query_t) -> bool ---

	/** Get query object.
	* Returns the query object. Can be used to access various information about
	* the query.
	*
	* @param world The world.
	* @param query The query.
	* @return The query object.
	*/
	query_get :: proc(world: ^world_t, query: entity_t) -> ^query_t ---

	/** Skip a table while iterating.
	* This operation lets the query iterator know that a table was skipped while
	* iterating. A skipped table will not reset its changed state, and the query
	* will not update the dirty flags of the table for its out columns.
	*
	* Only valid iterators must be provided (next has to be called at least once &
	* return true) and the iterator must be a query iterator.
	*
	* @param it The iterator result to skip.
	*/
	iter_skip :: proc(it: ^iter_t) ---

	/** Set group to iterate for query iterator.
	* This operation limits the results returned by the query to only the selected
	* group id. The query must have a group_by function, and the iterator must
	* be a query iterator.
	*
	* Groups are sets of tables that are stored together in the query cache based
	* on a group id, which is calculated per table by the group_by function. To
	* iterate a group, an iterator only needs to know the first and last cache node
	* for that group, which can both be found in a fast O(1) operation.
	*
	* As a result, group iteration is one of the most efficient mechanisms to
	* filter out large numbers of entities, even if those entities are distributed
	* across many tables. This makes it a good fit for things like dividing up
	* a world into cells, and only iterating cells close to a player.
	*
	* The group to iterate must be set before the first call to ecs_query_next(). No
	* operations that can add/remove components should be invoked between calling
	* ecs_iter_set_group() and ecs_query_next().
	*
	* @param it The query iterator.
	* @param group_id The group to iterate.
	*/
	iter_set_group :: proc(it: ^iter_t, group_id: u64) ---

	/** Get context of query group.
	* This operation returns the context of a query group as returned by the
	* on_group_create callback.
	*
	* @param query The query.
	* @param group_id The group for which to obtain the context.
	* @return The group context, NULL if the group doesn't exist.
	*/
	query_get_group_ctx :: proc(query: ^query_t, group_id: u64) -> rawptr ---

	/** Get information about query group.
	* This operation returns information about a query group, including the group
	* context returned by the on_group_create callback.
	*
	* @param query The query.
	* @param group_id The group for which to obtain the group info.
	* @return The group info, NULL if the group doesn't exist.
	*/
	query_get_group_info :: proc(query: ^query_t, group_id: u64) -> ^query_group_info_t ---
}

/** Struct returned by ecs_query_count(). */
query_count_t :: struct {
	results:  i32, /**< Number of results returned by query. */
	entities: i32, /**< Number of entities returned by query. */
	tables:   i32, /**< Number of tables returned by query. Only set for
                             * queries for which the table count can be reliably
                             * determined. */
}

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
	/** Returns number of entities and results the query matches with.
	* Only entities matching the $this variable as source are counted.
	*
	* @param query The query.
	* @return The number of matched entities.
	*/
	query_count :: proc(query: ^query_t) -> query_count_t ---

	/** Does query return one or more results.
	*
	* @param query The query.
	* @return True if query matches anything, false if not.
	*/
	query_is_true :: proc(query: ^query_t) -> bool ---

	/** Get query used to populate cache.
	* This operation returns the query that is used to populate the query cache.
	* For queries that are can be entirely cached, the returned query will be
	* equivalent to the query passed to ecs_query_get_cache_query().
	*
	* @param query The query.
	* @return The query used to populate the cache, NULL if query is not cached.
	*/
	query_get_cache_query :: proc(query: ^query_t) -> ^query_t ---

	/** Send event.
	* This sends an event to matching triggers & is the mechanism used by flecs
	* itself to send `OnAdd`, `OnRemove`, etc events.
	*
	* Applications can use this function to send custom events, where a custom
	* event can be any regular entity.
	*
	* Applications should not send builtin flecs events, as this may violate
	* assumptions the code makes about the conditions under which those events are
	* sent.
	*
	* Triggers are invoked synchronously. It is therefore safe to use stack-based
	* data as event context, which can be set in the "param" member.
	*
	* @param world The world.
	* @param desc Event parameters.
	*
	* @see ecs_enqueue()
	*/
	emit :: proc(world: ^world_t, desc: ^event_desc_t) ---

	/** Enqueue event.
	* Same as ecs_emit(), but enqueues an event in the command queue instead. The
	* event will be emitted when ecs_defer_end() is called.
	*
	* If this operation is called when the provided world is not in deferred mode
	* it behaves just like ecs_emit().
	*
	* @param world The world.
	* @param desc Event parameters.
	*/
	enqueue :: proc(world: ^world_t, desc: ^event_desc_t) ---

	/** Create observer.
	* Observers are like triggers, but can subscribe for multiple terms. An
	* observer only triggers when the source of the event meets all terms.
	*
	* See the documentation for ecs_observer_desc_t for more details.
	*
	* @param world The world.
	* @param desc The observer creation parameters.
	* @return The observer, or 0 if the operation failed.
	*/
	observer_init :: proc(world: ^world_t, desc: ^observer_desc_t) -> entity_t ---

	/** Get observer object.
	* Returns the observer object. Can be used to access various information about
	* the observer, like the query and context.
	*
	* @param world The world.
	* @param observer The observer.
	* @return The observer object.
	*/
	observer_get :: proc(world: ^world_t, observer: entity_t) -> ^observer_t ---

	/** Progress any iterator.
	* This operation is useful in combination with iterators for which it is not
	* known what created them. Example use cases are functions that should accept
	* any kind of iterator (such as serializers) or iterators created from poly
	* objects.
	*
	* This operation is slightly slower than using a type-specific iterator (e.g.
	* ecs_query_next, ecs_query_next) as it has to call a function pointer which
	* introduces a level of indirection.
	*
	* @param it The iterator.
	* @return True if iterator has more results, false if not.
	*/
	iter_next :: proc(it: ^iter_t) -> bool ---

	/** Cleanup iterator resources.
	* This operation cleans up any resources associated with the iterator.
	*
	* This operation should only be used when an iterator is not iterated until
	* completion (next has not yet returned false). When an iterator is iterated
	* until completion, resources are automatically freed.
	*
	* @param it The iterator.
	*/
	iter_fini :: proc(it: ^iter_t) ---

	/** Count number of matched entities in query.
	* This operation returns the number of matched entities. If a query contains no
	* matched entities but still yields results (e.g. it has no terms with This
	* sources) the operation will return 0.
	*
	* To determine the number of matched entities, the operation iterates the
	* iterator until it yields no more results.
	*
	* @param it The iterator.
	* @return True if iterator has more results, false if not.
	*/
	iter_count :: proc(it: ^iter_t) -> i32 ---

	/** Test if iterator is true.
	* This operation will return true if the iterator returns at least one result.
	* This is especially useful in combination with fact-checking queries (see the
	* queries addon).
	*
	* The operation requires a valid iterator. After the operation is invoked, the
	* application should no longer invoke next on the iterator and should treat it
	* as if the iterator is iterated until completion.
	*
	* @param it The iterator.
	* @return true if the iterator returns at least one result.
	*/
	iter_is_true :: proc(it: ^iter_t) -> bool ---

	/** Get first matching entity from iterator.
	* After this operation the application should treat the iterator as if it has
	* been iterated until completion.
	*
	* @param it The iterator.
	* @return The first matching entity, or 0 if no entities were matched.
	*/
	iter_first :: proc(it: ^iter_t) -> entity_t ---

	/** Set value for iterator variable.
	* This constrains the iterator to return only results for which the variable
	* equals the specified value. The default value for all variables is
	* EcsWildcard, which means the variable can assume any value.
	*
	* Example:
	*
	* @code
	* // Query that matches (Eats, *)
	* ecs_query_t *q = ecs_query(world, {
	*   .terms = {
	*     { .first.id = Eats, .second.name = "$food" }
	*   }
	* });
	*
	* int food_var = ecs_query_find_var(r, "food");
	*
	* // Set Food to Apples, so we're only matching (Eats, Apples)
	* ecs_iter_t it = ecs_query_iter(world, q);
	* ecs_iter_set_var(&it, food_var, Apples);
	*
	* while (ecs_query_next(&it)) {
	*   for (int i = 0; i < it.count; i ++) {
	*     // iterate as usual
	*   }
	* }
	* @endcode
	*
	* The variable must be initialized after creating the iterator and before the
	* first call to next.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @param entity The entity variable value.
	*
	* @see ecs_iter_set_var_as_range()
	* @see ecs_iter_set_var_as_table()
	*/
	iter_set_var :: proc(it: ^iter_t, var_id: i32, entity: entity_t) ---

	/** Same as ecs_iter_set_var(), but for a table.
	* This constrains the variable to all entities in a table.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @param table The table variable value.
	*
	* @see ecs_iter_set_var()
	* @see ecs_iter_set_var_as_range()
	*/
	iter_set_var_as_table :: proc(it: ^iter_t, var_id: i32, table: ^table_t) ---

	/** Same as ecs_iter_set_var(), but for a range of entities
	* This constrains the variable to a range of entities in a table.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @param range The range variable value.
	*
	* @see ecs_iter_set_var()
	* @see ecs_iter_set_var_as_table()
	*/
	iter_set_var_as_range :: proc(it: ^iter_t, var_id: i32, range: ^table_range_t) ---

	/** Get value of iterator variable as entity.
	* A variable can be interpreted as entity if it is set to an entity, or if it
	* is set to a table range with count 1.
	*
	* This operation can only be invoked on valid iterators. The variable index
	* must be smaller than the total number of variables provided by the iterator
	* (as set in ecs_iter_t::variable_count).
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return The variable value.
	*/
	iter_get_var :: proc(it: ^iter_t, var_id: i32) -> entity_t ---

	/** Get variable name.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return The variable name.
	*/
	iter_get_var_name :: proc(it: ^iter_t, var_id: i32) -> cstring ---

	/** Get number of variables.
	*
	* @param it The iterator.
	* @return The number of variables.
	*/
	iter_get_var_count :: proc(it: ^iter_t) -> i32 ---

	/** Get variable array.
	*
	* @param it The iterator.
	* @return The variable array (if any).
	*/
	iter_get_vars :: proc(it: ^iter_t) -> ^var_t ---

	/** Get value of iterator variable as table.
	* A variable can be interpreted as table if it is set as table range with
	* both offset and count set to 0, or if offset is 0 and count matches the
	* number of elements in the table.
	*
	* This operation can only be invoked on valid iterators. The variable index
	* must be smaller than the total number of variables provided by the iterator
	* (as set in ecs_iter_t::variable_count).
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return The variable value.
	*/
	iter_get_var_as_table :: proc(it: ^iter_t, var_id: i32) -> ^table_t ---

	/** Get value of iterator variable as table range.
	* A value can be interpreted as table range if it is set as table range, or if
	* it is set to an entity with a non-empty type (the entity must have at least
	* one component, tag or relationship in its type).
	*
	* This operation can only be invoked on valid iterators. The variable index
	* must be smaller than the total number of variables provided by the iterator
	* (as set in ecs_iter_t::variable_count).
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return The variable value.
	*/
	iter_get_var_as_range :: proc(it: ^iter_t, var_id: i32) -> table_range_t ---

	/** Returns whether variable is constrained.
	* This operation returns true for variables set by one of the ecs_iter_set_var*
	* operations.
	*
	* A constrained variable is guaranteed not to change values while results are
	* being iterated.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return Whether the variable is constrained to a specified value.
	*/
	iter_var_is_constrained :: proc(it: ^iter_t, var_id: i32) -> bool ---

	/** Return the group id for the currently iterated result.
	* This operation returns the group id for queries that use group_by. If this
	* operation is called on an iterator that is not iterating a query that uses
	* group_by it will fail.
	*
	* For queries that use cascade, this operation will return the hierarchy depth
	* of the currently iterated result.
	*
	* @param it The iterator.
	* @return The group id of the currently iterated result.
	*/
	iter_get_group :: proc(it: ^iter_t) -> u64 ---

	/** Returns whether current iterator result has changed.
	* This operation must be used in combination with a query that supports change
	* detection (e.g. is cached). The operation returns whether the currently
	* iterated result has changed since the last time it was iterated by the query.
	*
	* Change detection works on a per-table basis. Changes to individual entities
	* cannot be detected this way.
	*
	* @param it The iterator.
	* @return True if the result changed, false if it didn't.
	*/
	iter_changed :: proc(it: ^iter_t) -> bool ---

	/** Convert iterator to string.
	* Prints the contents of an iterator to a string. Useful for debugging and/or
	* testing the output of an iterator.
	*
	* The function only converts the currently iterated data to a string. To
	* convert all data, the application has to manually call the next function and
	* call ecs_iter_str() on each result.
	*
	* @param it The iterator.
	* @return A string representing the contents of the iterator.
	*/
	iter_str :: proc(it: ^iter_t) -> cstring ---

	/** Create a paged iterator.
	* Paged iterators limit the results to those starting from 'offset', and will
	* return at most 'limit' results.
	*
	* The iterator must be iterated with ecs_page_next().
	*
	* A paged iterator acts as a passthrough for data exposed by the parent
	* iterator, so that any data provided by the parent will also be provided by
	* the paged iterator.
	*
	* @param it The source iterator.
	* @param offset The number of entities to skip.
	* @param limit The maximum number of entities to iterate.
	* @return A page iterator.
	*/
	page_iter :: proc(it: ^iter_t, offset: i32, limit: i32) -> iter_t ---

	/** Progress a paged iterator.
	* Progresses an iterator created by ecs_page_iter().
	*
	* @param it The iterator.
	* @return true if iterator has more results, false if not.
	*/
	page_next :: proc(it: ^iter_t) -> bool ---

	/** Create a worker iterator.
	* Worker iterators can be used to equally divide the number of matched entities
	* across N resources (usually threads). Each resource will process the total
	* number of matched entities divided by 'count'.
	*
	* Entities are distributed across resources such that the distribution is
	* stable between queries. Two queries that match the same table are guaranteed
	* to match the same entities in that table.
	*
	* The iterator must be iterated with ecs_worker_next().
	*
	* A worker iterator acts as a passthrough for data exposed by the parent
	* iterator, so that any data provided by the parent will also be provided by
	* the worker iterator.
	*
	* @param it The source iterator.
	* @param index The index of the current resource.
	* @param count The total number of resources to divide entities between.
	* @return A worker iterator.
	*/
	worker_iter :: proc(it: ^iter_t, index: i32, count: i32) -> iter_t ---

	/** Progress a worker iterator.
	* Progresses an iterator created by ecs_worker_iter().
	*
	* @param it The iterator.
	* @return true if iterator has more results, false if not.
	*/
	worker_next :: proc(it: ^iter_t) -> bool ---

	/** Get data for field.
	* This operation retrieves a pointer to an array of data that belongs to the
	* term in the query. The index refers to the location of the term in the query,
	* and starts counting from zero.
	*
	* For example, the query `"Position, Velocity"` will return the `Position` array
	* for index 0, and the `Velocity` array for index 1.
	*
	* When the specified field is not owned by the entity this function returns a
	* pointer instead of an array. This happens when the source of a field is not
	* the entity being iterated, such as a shared component (from a prefab), a
	* component from a parent, or another entity. The ecs_field_is_self() operation
	* can be used to test dynamically if a field is owned.
	*
	* When a field contains a sparse component, use the ecs_field_at function. When
	* a field is guaranteed to be set and owned, the ecs_field_self() function can be
	* used. ecs_field_self() has slightly better performance, and provides stricter
	* validity checking.
	*
	* The provided size must be either 0 or must match the size of the type
	* of the returned array. If the size does not match, the operation may assert.
	* The size can be dynamically obtained with ecs_field_size().
	*
	* An example:
	*
	* @code
	* while (ecs_query_next(&it)) {
	*   Position *p = ecs_field(&it, Position, 0);
	*   Velocity *v = ecs_field(&it, Velocity, 1);
	*   for (int32_t i = 0; i < it->count; i ++) {
	*     p[i].x += v[i].x;
	*     p[i].y += v[i].y;
	*   }
	* }
	* @endcode
	*
	* @param it The iterator.
	* @param size The size of the field type.
	* @param index The index of the field.
	* @return A pointer to the data of the field.
	*/
	field_w_size :: proc(it: ^iter_t, size: c.size_t, index: i8) -> rawptr ---

	/** Get data for field at specified row.
	* This operation should be used instead of ecs_field_w_size for sparse
	* component fields. This operation should be called for each returned row in a
	* result. In the following example the Velocity component is sparse:
	*
	* @code
	* while (ecs_query_next(&it)) {
	*   Position *p = ecs_field(&it, Position, 0);
	*   for (int32_t i = 0; i < it->count; i ++) {
	*     Velocity *v = ecs_field_at(&it, Velocity, 1);
	*     p[i].x += v->x;
	*     p[i].y += v->y;
	*   }
	* }
	* @endcode
	*
	* @param it the iterator.
	* @param size The size of the field type.
	* @param index The index of the field.
	* @return A pointer to the data of the field.
	*/
	field_at_w_size :: proc(it: ^iter_t, size: c.size_t, index: i8, row: i32) -> rawptr ---

	/** Test whether the field is readonly.
	* This operation returns whether the field is readonly. Readonly fields are
	* annotated with [in], or are added as a const type in the C++ API.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return Whether the field is readonly.
	*/
	field_is_readonly :: proc(it: ^iter_t, index: i8) -> bool ---

	/** Test whether the field is writeonly.
	* This operation returns whether this is a writeonly field. Writeonly terms are
	* annotated with [out].
	*
	* Serializers are not required to serialize the values of a writeonly field.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return Whether the field is writeonly.
	*/
	field_is_writeonly :: proc(it: ^iter_t, index: i8) -> bool ---

	/** Test whether field is set.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return Whether the field is set.
	*/
	field_is_set :: proc(it: ^iter_t, index: i8) -> bool ---

	/** Return id matched for field.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return The id matched for the field.
	*/
	field_id :: proc(it: ^iter_t, index: i8) -> id_t ---

	/** Return index of matched table column.
	* This function only returns column indices for fields that have been matched
	* on the $this variable. Fields matched on other tables will return -1.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return The index of the matched column, -1 if not matched.
	*/
	field_column :: proc(it: ^iter_t, index: i8) -> i32 ---

	/** Return field source.
	* The field source is the entity on which the field was matched.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return The source for the field.
	*/
	field_src :: proc(it: ^iter_t, index: i8) -> entity_t ---

	/** Return field type size.
	* Return type size of the field. Returns 0 if the field has no data.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return The type size for the field.
	*/
	field_size :: proc(it: ^iter_t, index: i8) -> c.size_t ---

	/** Test whether the field is matched on self.
	* This operation returns whether the field is matched on the currently iterated
	* entity. This function will return false when the field is owned by another
	* entity, such as a parent or a prefab.
	*
	* When this operation returns false, the field must be accessed as a single
	* value instead of an array. Fields for which this operation returns true
	* return arrays with it->count values.
	*
	* @param it The iterator.
	* @param index The index of the field in the iterator.
	* @return Whether the field is matched on self.
	*/
	field_is_self :: proc(it: ^iter_t, index: i8) -> bool ---

	/** Get type for table.
	* The table type is a vector that contains all component, tag and pair ids.
	*
	* @param table The table.
	* @return The type of the table.
	*/
	table_get_type :: proc(table: ^table_t) -> ^type_t ---

	/** Get type index for component.
	* This operation returns the index for a component in the table's type.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component.
	* @return The index of the component in the table type, or -1 if not found.
	*
	* @see ecs_table_has_id()
	*/
	table_get_type_index :: proc(world: ^world_t, table: ^table_t, component: id_t) -> i32 ---

	/** Get column index for component.
	* This operation returns the column index for a component in the table's type.
	* If the component doesn't have data (it is a tag), the function will return -1.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component.
	* @return The column index of the id, or -1 if not found/not a component.
	*/
	table_get_column_index :: proc(world: ^world_t, table: ^table_t, component: id_t) -> i32 ---

	/** Return number of columns in table.
	* Similar to `ecs_table_get_type(table)->count`, except that the column count
	* only counts the number of components in a table.
	*
	* @param table The table.
	* @return The number of columns in the table.
	*/
	table_column_count :: proc(table: ^table_t) -> i32 ---

	/** Convert type index to column index.
	* Tables have an array of columns for each component in the table. This array
	* does not include elements for tags, which means that the index for a
	* component in the table type is not necessarily the same as the index in the
	* column array. This operation converts from an index in the table type to an
	* index in the column array.
	*
	* @param table The table.
	* @param index The index in the table type.
	* @return The index in the table column array.
	*
	* @see ecs_table_column_to_type_index()
	*/
	table_type_to_column_index :: proc(table: ^table_t, index: i32) -> i32 ---

	/** Convert column index to type index.
	* Same as ecs_table_type_to_column_index(), but converts from an index in the
	* column array to an index in the table type.
	*
	* @param table The table.
	* @param index The column index.
	* @return The index in the table type.
	*/
	table_column_to_type_index :: proc(table: ^table_t, index: i32) -> i32 ---

	/** Get column from table by column index.
	* This operation returns the component array for the provided index.
	*
	* @param table The table.
	* @param index The column index.
	* @param offset The index of the first row to return (0 for entire column).
	* @return The component array, or NULL if the index is not a component.
	*/
	table_get_column :: proc(table: ^table_t, index: i32, offset: i32) -> rawptr ---

	/** Get column from table by component.
	* This operation returns the component array for the provided component.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component for the column.
	* @param offset The index of the first row to return (0 for entire column).
	* @return The component array, or NULL if the index is not a component.
	*/
	table_get_id :: proc(world: ^world_t, table: ^table_t, component: id_t, offset: i32) -> rawptr ---

	/** Get column size from table.
	* This operation returns the component size for the provided index.
	*
	* @param table The table.
	* @param index The column index.
	* @return The component size, or 0 if the index is not a component.
	*/
	table_get_column_size :: proc(table: ^table_t, index: i32) -> c.size_t ---

	/** Returns the number of entities in the table.
	* This operation returns the number of entities in the table.
	*
	* @param table The table.
	* @return The number of entities in the table.
	*/
	table_count :: proc(table: ^table_t) -> i32 ---

	/** Returns allocated size of table.
	* This operation returns the number of elements allocated in the table
	* per column.
	*
	* @param table The table.
	* @return The number of allocated elements in the table.
	*/
	table_size :: proc(table: ^table_t) -> i32 ---

	/** Returns array with entity ids for table.
	* The size of the returned array is the result of ecs_table_count().
	*
	* @param table The table.
	* @return Array with entity ids for table.
	*/
	table_entities :: proc(table: ^table_t) -> ^entity_t ---

	/** Test if table has component.
	* Same as `ecs_table_get_type_index(world, table, component) != -1`.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component.
	* @return True if the table has the id, false if the table doesn't.
	*
	* @see ecs_table_get_type_index()
	*/
	table_has_id :: proc(world: ^world_t, table: ^table_t, component: id_t) -> bool ---

	/** Get relationship target for table.
	*
	* @param world The world.
	* @param table The table.
	* @param relationship The relationship for which to obtain the target.
	* @param index The index, in case the table has multiple instances of the relationship.
	* @return The requested relationship target.
	*
	* @see ecs_get_target()
	*/
	table_get_target :: proc(world: ^world_t, table: ^table_t, relationship: entity_t, index: i32) -> entity_t ---

	/** Return depth for table in tree for relationship rel.
	* Depth is determined by counting the number of targets encountered while
	* traversing up the relationship tree for rel. Only acyclic relationships are
	* supported.
	*
	* @param world The world.
	* @param table The table.
	* @param rel The relationship.
	* @return The depth of the table in the tree.
	*/
	table_get_depth :: proc(world: ^world_t, table: ^table_t, rel: entity_t) -> i32 ---

	/** Get table that has all components of current table plus the specified id.
	* If the provided table already has the provided id, the operation will return
	* the provided table.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component to add.
	* @result The resulting table.
	*/
	table_add_id :: proc(world: ^world_t, table: ^table_t, component: id_t) -> ^table_t ---

	/** Find table from id array.
	* This operation finds or creates a table with the specified array of
	* (component) ids. The ids in the array must be sorted, and it may not contain
	* duplicate elements.
	*
	* @param world The world.
	* @param ids The id array.
	* @param id_count The number of elements in the id array.
	* @return The table with the specified (component) ids.
	*/
	table_find :: proc(world: ^world_t, ids: ^id_t, id_count: i32) -> ^table_t ---

	/** Get table that has all components of current table minus the specified component.
	* If the provided table doesn't have the provided component, the operation will
	* return the provided table.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component to remove.
	* @result The resulting table.
	*/
	table_remove_id :: proc(world: ^world_t, table: ^table_t, component: id_t) -> ^table_t ---

	/** Lock a table.
	* When a table is locked, modifications to it will throw an assert. When the
	* table is locked recursively, it will take an equal amount of unlock
	* operations to actually unlock the table.
	*
	* Table locks can be used to build safe iterators where it is guaranteed that
	* the contents of a table are not modified while it is being iterated.
	*
	* The operation only works when called on the world, and has no side effects
	* when called on a stage. The assumption is that when called on a stage,
	* operations are deferred already.
	*
	* @param world The world.
	* @param table The table to lock.
	*/
	table_lock :: proc(world: ^world_t, table: ^table_t) ---

	/** Unlock a table.
	* Must be called after calling ecs_table_lock().
	*
	* @param world The world.
	* @param table The table to unlock.
	*/
	table_unlock :: proc(world: ^world_t, table: ^table_t) ---

	/** Test table for flags.
	* Test if table has all of the provided flags. See
	* include/flecs/private/api_flags.h for a list of table flags that can be used
	* with this function.
	*
	* @param table The table.
	* @param flags The flags to test for.
	* @return Whether the specified flags are set for the table.
	*/
	table_has_flags :: proc(table: ^table_t, flags: flags32_t) -> bool ---

	/** Check if table has traversable entities.
	* Traversable entities are entities that are used as target in a pair with a
	* relationship that has the Traversable trait.
	*
	* @param table The table.
	* @return Whether the table has traversable entities.
	*/
	table_has_traversable :: proc(table: ^table_t) -> bool ---

	/** Swaps two elements inside the table. This is useful for implementing custom
	* table sorting algorithms.
	* @param world The world
	* @param table The table to swap elements in
	* @param row_1 Table element to swap with row_2
	* @param row_2 Table element to swap with row_1
	*/
	table_swap_rows :: proc(world: ^world_t, table: ^table_t, row_1: i32, row_2: i32) ---

	/** Commit (move) entity to a table.
	* This operation moves an entity from its current table to the specified
	* table. This may cause the following actions:
	* - Ctor for each component in the target table
	* - Move for each overlapping component
	* - Dtor for each component in the source table.
	* - `OnAdd` triggers for non-overlapping components in the target table
	* - `OnRemove` triggers for non-overlapping components in the source table.
	*
	* This operation is a faster than adding/removing components individually.
	*
	* The application must explicitly provide the difference in components between
	* tables as the added/removed parameters. This can usually be derived directly
	* from the result of ecs_table_add_id() and ecs_table_remove_id(). These arrays are
	* required to properly execute `OnAdd`/`OnRemove` triggers.
	*
	* @param world The world.
	* @param entity The entity to commit.
	* @param record The entity's record (optional, providing it saves a lookup).
	* @param table The table to commit the entity to.
	* @return True if the entity got moved, false otherwise.
	*/
	commit :: proc(world: ^world_t, entity: entity_t, record: ^record_t, table: ^table_t, added: ^type_t, removed: ^type_t) -> bool ---

	/** Search for component in table type.
	* This operation returns the index of first occurrence of the component in the
	* table type. The component may be a pair or wildcard.
	*
	* When component_out is provided, the function will assign it with the found
	* component. The found component may be different from the provided component
	* if it is a wildcard.
	*
	* This is a constant time operation.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component to search for.
	* @param component_out If provided, it will be set to the found component (optional).
	* @return The index of the id in the table type.
	*
	* @see ecs_search_offset()
	* @see ecs_search_relation()
	*/
	search :: proc(world: ^world_t, table: ^table_t, component: id_t, component_out: ^id_t) -> i32 ---

	/** Search for component in table type starting from an offset.
	* This operation is the same as ecs_search(), but starts searching from an offset
	* in the table type.
	*
	* This operation is typically called in a loop where the resulting index is
	* used in the next iteration as offset:
	*
	* @code
	* int32_t index = -1;
	* while ((index = ecs_search_offset(world, table, offset, id, NULL))) {
	*   // do stuff
	* }
	* @endcode
	*
	* Depending on how the operation is used it is either linear or constant time.
	* When the id has the form `(id)` or `(rel, *)` and the operation is invoked as
	* in the above example, it is guaranteed to be constant time.
	*
	* If the provided component has the form `(*, tgt)` the operation takes linear
	* time. The reason for this is that ids for an target are not packed together,
	* as they are sorted relationship first.
	*
	* If the component at the offset does not match the provided id, the operation
	* will do a linear search to find a matching id.
	*
	* @param world The world.
	* @param table The table.
	* @param offset Offset from where to start searching.
	* @param component The component to search for.
	* @param component_out If provided, it will be set to the found component (optional).
	* @return The index of the id in the table type.
	*
	* @see ecs_search()
	* @see ecs_search_relation()
	*/
	search_offset :: proc(world: ^world_t, table: ^table_t, offset: i32, component: id_t, component_out: ^id_t) -> i32 ---

	/** Search for component/relationship id in table type starting from an offset.
	* This operation is the same as ecs_search_offset(), but has the additional
	* capability of traversing relationships to find a component. For example, if
	* an application wants to find a component for either the provided table or a
	* prefab (using the `IsA` relationship) of that table, it could use the operation
	* like this:
	*
	* @code
	* int32_t index = ecs_search_relation(
	*   world,            // the world
	*   table,            // the table
	*   0,                // offset 0
	*   ecs_id(Position), // the component id
	*   EcsIsA,           // the relationship to traverse
	*   0,                // start at depth 0 (the table itself)
	*   0,                // no depth limit
	*   NULL,             // (optional) entity on which component was found
	*   NULL,             // see above
	*   NULL);            // internal type with information about matched id
	* @endcode
	*
	* The operation searches depth first. If a table type has 2 `IsA` relationships, the
	* operation will first search the `IsA` tree of the first relationship.
	*
	* When choosing between ecs_search(), ecs_search_offset() and ecs_search_relation(),
	* the simpler the function the better its performance.
	*
	* @param world The world.
	* @param table The table.
	* @param offset Offset from where to start searching.
	* @param component The component to search for.
	* @param rel The relationship to traverse (optional).
	* @param flags Whether to search EcsSelf and/or EcsUp.
	* @param subject_out If provided, it will be set to the matched entity.
	* @param component_out If provided, it will be set to the found component (optional).
	* @param tr_out Internal datatype.
	* @return The index of the component in the table type.
	*
	* @see ecs_search()
	* @see ecs_search_offset()
	*/
	search_relation :: proc(world: ^world_t, table: ^table_t, offset: i32, component: id_t, rel: entity_t, flags: flags64_t, subject_out: ^entity_t, component_out: ^id_t, tr_out: ^^table_record_t) -> i32 ---

	/** Remove all entities in a table. Does not deallocate table memory.
	* Retaining table memory can be efficient when planning
	* to refill the table with operations like ecs_bulk_init
	*
	* @param world The world.
	* @param table The table to clear.
	*/
	table_clear_entities :: proc(world: ^world_t, table: ^table_t) ---

	/** Construct a value in existing storage
	*
	* @param world The world.
	* @param type The type of the value to create.
	* @param ptr Pointer to a value of type 'type'
	* @return Zero if success, nonzero if failed.
	*/
	value_init :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> i32 ---

	/** Construct a value in existing storage
	*
	* @param world The world.
	* @param ti The type info of the type to create.
	* @param ptr Pointer to a value of type 'type'
	* @return Zero if success, nonzero if failed.
	*/
	value_init_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, ptr: rawptr) -> i32 ---

	/** Construct a value in new storage
	*
	* @param world The world.
	* @param type The type of the value to create.
	* @return Pointer to type if success, NULL if failed.
	*/
	value_new :: proc(world: ^world_t, type: entity_t) -> rawptr ---

	/** Construct a value in new storage
	*
	* @param world The world.
	* @param ti The type info of the type to create.
	* @return Pointer to type if success, NULL if failed.
	*/
	value_new_w_type_info :: proc(world: ^world_t, ti: ^type_info_t) -> rawptr ---

	/** Destruct a value
	*
	* @param world The world.
	* @param ti Type info of the value to destruct.
	* @param ptr Pointer to constructed value of type 'type'.
	* @return Zero if success, nonzero if failed.
	*/
	value_fini_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, ptr: rawptr) -> i32 ---

	/** Destruct a value
	*
	* @param world The world.
	* @param type The type of the value to destruct.
	* @param ptr Pointer to constructed value of type 'type'.
	* @return Zero if success, nonzero if failed.
	*/
	value_fini :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> i32 ---

	/** Destruct a value, free storage
	*
	* @param world The world.
	* @param type The type of the value to destruct.
	* @param ptr A pointer to the value.
	* @return Zero if success, nonzero if failed.
	*/
	value_free :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> i32 ---

	/** Copy value.
	*
	* @param world The world.
	* @param ti Type info of the value to copy.
	* @param dst Pointer to the storage to copy to.
	* @param src Pointer to the value to copy.
	* @return Zero if success, nonzero if failed.
	*/
	value_copy_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> i32 ---

	/** Copy value.
	*
	* @param world The world.
	* @param type The type of the value to copy.
	* @param dst Pointer to the storage to copy to.
	* @param src Pointer to the value to copy.
	* @return Zero if success, nonzero if failed.
	*/
	value_copy :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> i32 ---

	/** Move value.
	*
	* @param world The world.
	* @param ti Type info of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> i32 ---

	/** Move value.
	*
	* @param world The world.
	* @param type The type of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> i32 ---

	/** Move construct value.
	*
	* @param world The world.
	* @param ti Type info of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_ctor_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> i32 ---

	/** Move construct value.
	*
	* @param world The world.
	* @param type The type of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_ctor :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> i32 ---
}

