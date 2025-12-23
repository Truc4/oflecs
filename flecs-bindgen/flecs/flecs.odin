/**
 * @file flecs.h
 * @brief Flecs public API.
 *
 * This file contains the public API for Flecs.
 */
package flecs

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
id_t :: i32

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

world_t            :: struct {}
stage_t            :: struct {}
table_t            :: struct {}
observable_t       :: struct {}
ref_t              :: struct {}
record_t           :: struct {}
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

table_record_t :: struct {}

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
bool :: proc "c" (^i32) -> i32

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
uint64_t :: proc "c" (^i32) -> i32

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
hash_value_action_t :: proc "c" (rawptr) -> i32

/** Constructor/destructor callback */
xtor_t :: proc "c" (ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Copy is invoked when a component is copied into another component. */
copy_t :: proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Move is invoked when a component is moved to another component. */
move_t :: proc "c" (dst_ptr: rawptr, src_ptr: rawptr, count: i32, type_info: ^type_info_t)

/** Compare hook to compare component instances */
cmp_t :: proc "c" (a_ptr: rawptr, b_ptr: rawptr, type_info: ^type_info_t) -> i32

/** Equals operator hook */
equals_t :: proc "c" (rawptr, rawptr, ^type_info_t) -> i32

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
	inout:       i32,        /**< Access to contents matched by term */
	oper:        i32,        /**< Operator of term */
	field_index: i32,        /**< Index of field for term in iterator */
	flags_:      i32,        /**< Flags that help eval, set by ecs_query_init() */
}

/** Queries are lists of constraints (terms) that match entities.
* Created with ecs_query_init().
*/
query_t :: struct {
	hdr:          header_t, /**< Object header */
	terms:        ^term_t,  /**< Query terms */
	sizes:        ^i32,     /**< Component sizes. Indexed by field */
	ids:          ^id_t,    /**< Component ids. Indexed by field */
	bloom_filter: u64,      /**< Bitmask used to quickly discard tables */
	flags:        i32,      /**< Query flags */
	var_count:    i32,      /**< Number of query variables */
	term_count:   i32,      /**< Number of query terms */
	field_count:  i32,      /**< Number of fields returned by query */

	/* Bitmasks for quick field information lookups */
	fixed_fields:           i32,                /**< Fields with a fixed source */
	var_fields:             i32,                /**< Fields with non-$this variable source */
	static_id_fields:       i32,                /**< Fields with a static (component) id */
	data_fields:            i32,                /**< Fields that have data */
	write_fields:           i32,                /**< Fields that write data */
	read_fields:            i32,                /**< Fields that read data */
	row_fields:             i32,                /**< Fields that must be acquired with field_at */
	shared_readonly_fields: i32,                /**< Fields that don't write shared data */
	set_fields:             i32,                /**< Fields that will be set */
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
	flags: i32,

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
	size:      i32,          /**< Size of type */
	alignment: i32,          /**< Alignment of type */
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
	sizes:            ^i32,             /**< Component sizes */
	table:            ^table_t,         /**< Current table */
	other_table:      ^table_t,         /**< Prev or next table when adding/removing */
	ids:              ^id_t,            /**< (Component) ids */
	sources:          ^entity_t,        /**< Entity on which the id was matched (0 if same as entities) */
	constrained_vars: i32,              /**< Bitset that marks constrained variables */
	set_fields:       i32,              /**< Fields that are set */
	ref_fields:       i32,              /**< Bitset with fields that aren't component arrays */
	row_fields:       i32,              /**< Fields that must be obtained with field_at */
	up_fields:        i32,              /**< Bitset with fields matched through up traversal */

	/* Input information */
	system:    entity_t, /**< The system (if applicable) */
	event:     entity_t, /**< The event (if applicable) */
	event_id:  id_t,     /**< The (component) id for the event */
	event_cur: i32,      /**< Unique event id. Used to dedup observer calls */

	/* Query information */
	field_count: i32,      /**< Number of fields in iterator */
	term_index:  i32,      /**< Index of term that emitted an event.
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
	flags:          i32,      /**< Iterator flags */
	interrupted_by: entity_t, /**< When set, system execution is interrupted */
	priv_:          i32,      /**< Private data */

	/* Chained iterators */
	next:     i32,                /**< Function to progress iterator */
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
	flags: i32,

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
	group_by_callback: i32,

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
	term_index_:   i32,
	flags_:        i32,
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
	flags: i32,
}

/** Type with information about the current Flecs build */
build_info_t :: struct {
	compiler:      cstring,  /**< Compiler used to compile flecs */
	addons:        ^cstring, /**< Addons included in build */
	flags:         ^cstring, /**< Compile time settings */
	version:       cstring,  /**< Stringified version */
	version_major: i32,      /**< Major flecs version */
	version_minor: i32,      /**< Minor flecs version */
	version_patch: i32,      /**< Patch flecs version */
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
	frame_count_total:          i32,      /**< Total number of frames */
	merge_count_total:          i32,      /**< Total number of merges */
	eval_comp_monitors_total:   i32,      /**< Total number of monitor evaluations */
	rematch_count_total:        i32,      /**< Total number of rematches */
	id_create_total:            i32,      /**< Total number of times a new id was created */
	id_delete_total:            i32,      /**< Total number of times an id was deleted */
	table_create_total:         i32,      /**< Total number of times a table was created */
	table_delete_total:         i32,      /**< Total number of times a table was deleted */
	pipeline_build_count_total: i32,      /**< Total number of pipeline builds */
	systems_ran_total:          i32,      /**< Total number of systems ran */
	observers_ran_total:        i32,      /**< Total number of times observer was invoked */
	queries_ran_total:          i32,      /**< Total number of times a query was evaluated */
	tag_id_count:               i32,      /**< Number of tag (no data) ids in the world */
	component_id_count:         i32,      /**< Number of component (data) ids in the world */
	pair_id_count:              i32,      /**< Number of pair ids in the world */
	table_count:                i32,      /**< Number of tables */
	creation_time:              i32,      /**< Time when world was created */

	cmd: struct {
		add_count:             i32, /**< Add commands processed */
		remove_count:          i32, /**< Remove commands processed */
		delete_count:          i32, /**< Delete commands processed */
		clear_count:           i32, /**< Clear commands processed */
		set_count:             i32, /**< Set commands processed */
		ensure_count:          i32, /**< Ensure/emplace commands processed */
		modified_count:        i32, /**< Modified commands processed */
		discard_count:         i32, /**< Commands discarded, happens when entity is no longer alive when running the command */
		event_count:           i32, /**< Enqueued custom events */
		other_count:           i32, /**< Other commands processed */
		batched_entity_count:  i32, /**< Entities for which commands were batched */
		batched_command_count: i32, /**< Commands batched */
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
	value:      cstring, /**< Identifier string */
	length:     i32,     /**< Length of identifier */
	hash:       u64,     /**< Hash of current value */
	index_hash: u64,     /**< Hash of existing record in current index */
	index:      ^i32,    /**< Current index */
}

/** Component information. */
EcsComponent :: struct {
	size:      i32, /**< Component size */
	alignment: i32, /**< Component alignment */
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
	/** Delete a world.
	* This operation deletes the world, and everything it contains.
	*
	* @param world The world to delete.
	* @return Zero if successful, non-zero if failed.
	*/
	fini :: proc(world: ^world_t) -> i32 ---

	/** Register action to be executed when world is destroyed.
	* Fini actions are typically used when a module needs to clean up before a
	* world shuts down.
	*
	* @param world The world.
	* @param action The function to execute.
	* @param ctx Userdata to pass to the function */
	atfini :: proc(world: ^world_t, action: fini_action_t, ctx: rawptr) -> i32 ---
}

/** Type returned by ecs_get_entities(). */
entities_t :: struct {
	ids:         ^entity_t, /**< Array with all entity ids in the world. */
	count:       i32,       /**< Total number of entity ids. */
	alive_count: i32,       /**< Number of alive entity ids. */
}

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
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
	frame_begin :: proc(world: ^world_t, delta_time: f32) -> i32 ---

	/** End frame.
	* This operation must be called at the end of the frame, and always after
	* ecs_frame_begin().
	*
	* @param world The world.
	*/
	frame_end :: proc(world: ^world_t) -> i32 ---

	/** Register action to be executed once after frame.
	* Post frame actions are typically used for calling operations that cannot be
	* invoked during iteration, such as changing the number of threads.
	*
	* @param world The world.
	* @param action The function to execute.
	* @param ctx Userdata to pass to the function */
	run_post_frame :: proc(world: ^world_t, action: fini_action_t, ctx: rawptr) -> i32 ---

	/** Signal exit
	* This operation signals that the application should quit. It will cause
	* ecs_progress() to return false.
	*
	* @param world The world to quit.
	*/
	quit :: proc(world: ^world_t) -> i32 ---

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
	measure_frame_time :: proc(world: ^world_t, enable: bool) -> i32 ---

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
	measure_system_time :: proc(world: ^world_t, enable: bool) -> i32 ---

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
	set_target_fps :: proc(world: ^world_t, fps: f32) -> i32 ---

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
	set_default_query_flags :: proc(world: ^world_t, flags: i32) -> i32 ---

	/** End readonly mode.
	* This operation ends readonly mode, and must be called after
	* ecs_readonly_begin(). Operations that were deferred while the world was in
	* readonly mode will be flushed.
	*
	* @param world The world
	*/
	readonly_end :: proc(world: ^world_t) -> i32 ---

	/** Merge stage.
	* This will merge all commands enqueued for a stage.
	*
	* @param stage The stage.
	*/
	merge :: proc(stage: ^world_t) -> i32 ---

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
	defer_suspend :: proc(world: ^world_t) -> i32 ---

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
	defer_resume :: proc(world: ^world_t) -> i32 ---

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
	set_stage_count :: proc(world: ^world_t, stages: i32) -> i32 ---

	/** Free unmanaged stage.
	*
	* @param stage The stage to free.
	*/
	stage_free :: proc(stage: ^world_t) -> i32 ---

	/** Set a world context.
	* This operation allows an application to register custom data with a world
	* that can be accessed anywhere where the application has the world.
	*
	* @param world The world.
	* @param ctx A pointer to a user defined structure.
	* @param ctx_free A function that is invoked with ctx when the world is freed.
	*/
	set_ctx :: proc(world: ^world_t, ctx: rawptr, ctx_free: ctx_free_t) -> i32 ---

	/** Set a world binding context.
	* Same as ecs_set_ctx() but for binding context. A binding context is intended
	* specifically for language bindings to store binding specific data.
	*
	* @param world The world.
	* @param ctx A pointer to a user defined structure.
	* @param ctx_free A function that is invoked with ctx when the world is freed.
	*/
	set_binding_ctx :: proc(world: ^world_t, ctx: rawptr, ctx_free: ctx_free_t) -> i32 ---

	/** Get the world context.
	* This operation retrieves a previously set world context.
	*
	* @param world The world.
	* @return The context set with ecs_set_ctx(). If no context was set, the
	*         function returns NULL.
	*/
	get_ctx :: proc(world: ^world_t) -> ^i32 ---

	/** Get the world binding context.
	* This operation retrieves a previously set world binding context.
	*
	* @param world The world.
	* @return The context set with ecs_set_binding_ctx(). If no context was set, the
	*         function returns NULL.
	*/
	get_binding_ctx :: proc(world: ^world_t) -> ^i32 ---

	/** Dimension the world for a specified number of entities.
	* This operation will preallocate memory in the world for the specified number
	* of entities. Specifying a number lower than the current number of entities in
	* the world will have no effect.
	*
	* @param world The world.
	* @param entity_count The number of entities to preallocate.
	*/
	dim :: proc(world: ^world_t, entity_count: i32) -> i32 ---

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
	shrink :: proc(world: ^world_t) -> i32 ---

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
	set_entity_range :: proc(world: ^world_t, id_start: entity_t, id_end: entity_t) -> i32 ---

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
	run_aperiodic :: proc(world: ^world_t, flags: i32) -> i32 ---
}

/** Used with ecs_delete_empty_tables(). */
delete_empty_tables_desc_t :: struct {
	/** Free table data when generation > clear_generation. */
	clear_generation: i32,

	/** Delete table when generation > delete_generation. */
	delete_generation: i32,

	/** Amount of time operation is allowed to spend. */
	time_budget_seconds: f64,
}

@(default_calling_convention="c", link_prefix="ecs_")
foreign lib {
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
	exclusive_access_begin :: proc(world: ^world_t, thread_name: cstring) -> i32 ---

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
	exclusive_access_end :: proc(world: ^world_t, lock_world: bool) -> i32 ---

	/** Delete an entity.
	* This operation will delete an entity and all of its components. The entity id
	* will be made available for recycling. If the entity passed to ecs_delete() is
	* not alive, the operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	*/
	delete :: proc(world: ^world_t, entity: entity_t) -> i32 ---

	/** Delete all entities with the specified component.
	* This will delete all entities (tables) that have the specified id. The
	* component may be a wildcard and/or a pair.
	*
	* @param world The world.
	* @param component The component.
	*/
	delete_with :: proc(world: ^world_t, component: id_t) -> i32 ---

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
	set_child_order :: proc(world: ^world_t, parent: entity_t, children: ^entity_t, child_count: i32) -> i32 ---

	/** Add a (component) id to an entity.
	* This operation adds a single (component) id to an entity. If the entity
	* already has the id, this operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component id to add.
	*/
	add_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> i32 ---

	/** Remove a component from an entity.
	* This operation removes a single component from an entity. If the entity
	* does not have the component, this operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component to remove.
	*/
	remove_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> i32 ---

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
	auto_override_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> i32 ---

	/** Clear all components.
	* This operation will remove all components from an entity.
	*
	* @param world The world.
	* @param entity The entity.
	*/
	clear :: proc(world: ^world_t, entity: entity_t) -> i32 ---

	/** Remove all instances of the specified component.
	* This will remove the specified id from all entities (tables). The id may be
	* a wildcard and/or a pair.
	*
	* @param world The world.
	* @param component The component.
	*/
	remove_all :: proc(world: ^world_t, component: id_t) -> i32 ---

	/** Enable or disable entity.
	* This operation enables or disables an entity by adding or removing the
	* #EcsDisabled tag. A disabled entity will not be matched with any systems,
	* unless the system explicitly specifies the #EcsDisabled tag.
	*
	* @param world The world.
	* @param entity The entity to enable or disable.
	* @param enabled true to enable the entity, false to disable.
	*/
	enable :: proc(world: ^world_t, entity: entity_t, enabled: bool) -> i32 ---

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
	enable_id :: proc(world: ^world_t, entity: entity_t, component: id_t, enable: bool) -> i32 ---

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
	ensure_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t) -> ^i32 ---

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
	emplace_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t, is_new: bool) -> ^i32 ---

	/** Signal that a component has been modified.
	* This operation is usually used after modifying a component value obtained by
	* ecs_ensure_id(). The operation will mark the component as dirty, and invoke
	* OnSet observers and hooks.
	*
	* @param world The world.
	* @param entity The entity.
	* @param component The component that was modified.
	*/
	modified_id :: proc(world: ^world_t, entity: entity_t, component: id_t) -> i32 ---

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
	set_id :: proc(world: ^world_t, entity: entity_t, component: id_t, size: c.size_t, ptr: rawptr) -> i32 ---

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
	make_alive :: proc(world: ^world_t, entity: entity_t) -> i32 ---

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
	make_alive_id :: proc(world: ^world_t, component: id_t) -> i32 ---

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
	set_version :: proc(world: ^world_t, entity: entity_t) -> i32 ---

	/** Convert type to string.
	* The result of this operation must be freed with ecs_os_free().
	*
	* @param world The world.
	* @param type The type.
	* @return The stringified type.
	*/
	type_str :: proc(world: ^world_t, type: ^type_t) -> ^i32 ---

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
	table_str :: proc(world: ^world_t, table: ^table_t) -> ^i32 ---

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
	entity_str :: proc(world: ^world_t, entity: entity_t) -> ^i32 ---

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
	has_id :: proc(^world_t, entity_t, id_t) -> i32 ---

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
	owns_id :: proc(^world_t, entity_t, id_t) -> i32 ---

	/** Get the name of an entity.
	* This will return the name stored in `(EcsIdentifier, EcsName)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no name.
	*
	* @see ecs_set_name()
	*/
	get_name :: proc(world: ^world_t, entity: entity_t) -> ^i32 ---

	/** Get the symbol of an entity.
	* This will return the symbol stored in `(EcsIdentifier, EcsSymbol)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no name.
	*
	* @see ecs_set_symbol()
	*/
	get_symbol :: proc(world: ^world_t, entity: entity_t) -> ^i32 ---

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
	set_alias :: proc(world: ^world_t, entity: entity_t, alias: cstring) -> i32 ---

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
	get_path_w_sep :: proc(world: ^world_t, parent: entity_t, child: entity_t, sep: cstring, prefix: cstring) -> ^i32 ---

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
	get_path_w_sep_buf :: proc(world: ^world_t, parent: entity_t, child: entity_t, sep: cstring, prefix: cstring, buf: ^i32, escape: bool) -> i32 ---

	/** Set a name prefix for newly created entities.
	* This is a utility that lets C modules use prefixed names for C types and
	* C functions, while using names for the entity names that do not have the
	* prefix. The name prefix is currently only used by ECS_COMPONENT.
	*
	* @param world The world.
	* @param prefix The name prefix to use.
	* @return The previous prefix.
	*/
	set_name_prefix :: proc(world: ^world_t, prefix: cstring) -> ^i32 ---

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
	set_hooks_id :: proc(world: ^world_t, component: entity_t, hooks: ^type_hooks_t) -> i32 ---

	/** Utility to check if component is an any wildcard.
	*
	* @param component The component.
	* @return True if component is an any wildcard or a pair containing an any wildcard.
	*/
	id_is_any :: proc(id_t) -> i32 ---

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
	id_flag_str :: proc(component_flags: id_t) -> ^i32 ---

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
	id_str :: proc(world: ^world_t, component: id_t) -> ^i32 ---

	/** Write component string to buffer.
	* Same as ecs_id_str() but writes result to ecs_strbuf_t.
	*
	* @param world The world.
	* @param component The component to convert to a string.
	* @param buf The buffer to write to.
	*/
	id_str_buf :: proc(world: ^world_t, component: id_t, buf: ^i32) -> i32 ---

	/** Convert term to string expression.
	* Convert term to a string expression. The resulting expression is equivalent
	* to the same term, with the exception of And & Or operators.
	*
	* @param world The world.
	* @param term The term.
	* @return The term converted to a string.
	*/
	term_str :: proc(world: ^world_t, term: ^term_t) -> ^i32 ---

	/** Convert query to string expression.
	* Convert query to a string expression. The resulting expression can be
	* parsed to create the same query.
	*
	* @param query The query.
	* @return The query converted to a string.
	*/
	query_str :: proc(query: ^query_t) -> ^i32 ---

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

	/** Delete a query.
	*
	* @param query The query.
	*/
	query_fini :: proc(query: ^query_t) -> i32 ---

	/** Get variable name.
	* This operation returns the variable name for an index.
	*
	* @param query The query.
	* @param var_id The variable index.
	* @return The variable name.
	*/
	query_var_name :: proc(query: ^query_t, var_id: i32) -> ^i32 ---

	/** Convert query to a string.
	* This will convert the query program to a string which can aid in debugging
	* the behavior of a query.
	*
	* The returned string must be freed with ecs_os_free().
	*
	* @param query The query.
	* @return The query plan.
	*/
	query_plan :: proc(query: ^query_t) -> ^i32 ---

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
	query_plan_w_profile :: proc(query: ^query_t, it: ^iter_t) -> ^i32 ---

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
	query_args_parse :: proc(query: ^query_t, it: ^iter_t, expr: cstring) -> ^i32 ---

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
	iter_skip :: proc(it: ^iter_t) -> i32 ---

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
	iter_set_group :: proc(it: ^iter_t, group_id: u64) -> i32 ---

	/** Get context of query group.
	* This operation returns the context of a query group as returned by the
	* on_group_create callback.
	*
	* @param query The query.
	* @param group_id The group for which to obtain the context.
	* @return The group context, NULL if the group doesn't exist.
	*/
	query_get_group_ctx :: proc(query: ^query_t, group_id: u64) -> ^i32 ---
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
	emit :: proc(world: ^world_t, desc: ^event_desc_t) -> i32 ---

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
	enqueue :: proc(world: ^world_t, desc: ^event_desc_t) -> i32 ---

	/** Cleanup iterator resources.
	* This operation cleans up any resources associated with the iterator.
	*
	* This operation should only be used when an iterator is not iterated until
	* completion (next has not yet returned false). When an iterator is iterated
	* until completion, resources are automatically freed.
	*
	* @param it The iterator.
	*/
	iter_fini :: proc(it: ^iter_t) -> i32 ---

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
	iter_set_var :: proc(it: ^iter_t, var_id: i32, entity: entity_t) -> i32 ---

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
	iter_set_var_as_table :: proc(it: ^iter_t, var_id: i32, table: ^table_t) -> i32 ---

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
	iter_set_var_as_range :: proc(it: ^iter_t, var_id: i32, range: ^i32) -> i32 ---

	/** Get variable name.
	*
	* @param it The iterator.
	* @param var_id The variable index.
	* @return The variable name.
	*/
	iter_get_var_name :: proc(it: ^iter_t, var_id: i32) -> ^i32 ---

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
	iter_str :: proc(it: ^iter_t) -> ^i32 ---

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
	field_w_size :: proc(it: ^iter_t, size: c.size_t, index: i32) -> ^i32 ---

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
	field_at_w_size :: proc(it: ^iter_t, size: c.size_t, index: i32, row: i32) -> ^i32 ---

	/** Get column from table by column index.
	* This operation returns the component array for the provided index.
	*
	* @param table The table.
	* @param index The column index.
	* @param offset The index of the first row to return (0 for entire column).
	* @return The component array, or NULL if the index is not a component.
	*/
	table_get_column :: proc(table: ^table_t, index: i32, offset: i32) -> ^i32 ---

	/** Get column from table by component.
	* This operation returns the component array for the provided component.
	*
	* @param world The world.
	* @param table The table.
	* @param component The component for the column.
	* @param offset The index of the first row to return (0 for entire column).
	* @return The component array, or NULL if the index is not a component.
	*/
	table_get_id :: proc(world: ^world_t, table: ^table_t, component: id_t, offset: i32) -> ^i32 ---

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
	table_lock :: proc(world: ^world_t, table: ^table_t) -> i32 ---

	/** Unlock a table.
	* Must be called after calling ecs_table_lock().
	*
	* @param world The world.
	* @param table The table to unlock.
	*/
	table_unlock :: proc(world: ^world_t, table: ^table_t) -> i32 ---

	/** Swaps two elements inside the table. This is useful for implementing custom
	* table sorting algorithms.
	* @param world The world
	* @param table The table to swap elements in
	* @param row_1 Table element to swap with row_2
	* @param row_2 Table element to swap with row_1
	*/
	table_swap_rows :: proc(world: ^world_t, table: ^table_t, row_1: i32, row_2: i32) -> i32 ---

	/** Remove all entities in a table. Does not deallocate table memory.
	* Retaining table memory can be efficient when planning
	* to refill the table with operations like ecs_bulk_init
	*
	* @param world The world.
	* @param table The table to clear.
	*/
	table_clear_entities :: proc(world: ^world_t, table: ^table_t) -> i32 ---

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
	value_new :: proc(world: ^world_t, type: entity_t) -> ^i32 ---

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

