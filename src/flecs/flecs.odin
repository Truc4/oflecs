package oflecs

import "core:c"
import "core:fmt"
import "core:mem"

_ :: c


/* Flecs version macros */
FLECS_VERSION_MAJOR :: 4 /**< Flecs major version. */
FLECS_VERSION_MINOR :: 1 /**< Flecs minor version. */
FLECS_VERSION_PATCH :: 0 /**< Flecs patch version. */

// FLECS_VERSION :: #FLECS_VERSION_MAJO "." #FLECS_VERSION_MINO "." #FLECS_VERSION_PATCH

ecs_float_t :: f32

// ecs_ftime_t :: float_t

FLECS_HI_COMPONENT_ID :: 256
FLECS_HI_ID_RECORD_ID :: 1024
FLECS_ENTITY_PAGE_BITS :: 10

FLECS_SPARSE_PAGE_BITS :: 6

FLECS_ID_DESC_MAX :: 32

FLECS_EVENT_DESC_MAX :: 8

/** @def FLECS_VARIABLE_COUNT_MAX
 * Maximum number of query variables per query */
FLECS_VARIABLE_COUNT_MAX :: 64

FLECS_TERM_COUNT_MAX :: 32

FLECS_TERM_ARG_COUNT_MAX :: 16

FLECS_QUERY_VARIABLE_COUNT_MAX :: 64

FLECS_QUERY_SCOPE_NESTING_MAX :: 8

FLECS_DAG_DEPTH_MAX :: 128

////////////////////////////////////////////////////////////////////////////////
//// World flags
////////////////////////////////////////////////////////////////////////////////
WorldQuitWorkers :: 1 << 0
WorldReadonly :: 1 << 1
WorldInit :: 1 << 2
WorldQuit :: 1 << 3
WorldFini :: 1 << 4
WorldMeasureFrameTime :: 1 << 5
WorldMeasureSystemTime :: 1 << 6
WorldMultiThreaded :: 1 << 7
WorldFrameInProgress :: 1 << 8

////////////////////////////////////////////////////////////////////////////////
//// OS API flags
////////////////////////////////////////////////////////////////////////////////
OsApiHighResolutionTimer :: 1 << 0
OsApiLogWithColors :: 1 << 1
OsApiLogWithTimeStamp :: 1 << 2
OsApiLogWithTimeDelta :: 1 << 3

////////////////////////////////////////////////////////////////////////////////
//// Entity flags (set in upper bits of ecs_record_t::row)
////////////////////////////////////////////////////////////////////////////////
EntityIsId :: 1 << 31
EntityIsTarget :: 1 << 30
EntityIsTraversable :: 1 << 29
EntityHasDontFragment :: 1 << 28

////////////////////////////////////////////////////////////////////////////////
//// Id flags (used by ecs_component_record_t::flags)
////////////////////////////////////////////////////////////////////////////////
IdOnDeleteRemove :: 1 << 0
IdOnDeleteDelete :: 1 << 1
IdOnDeletePanic :: 1 << 2
IdOnDeleteMask :: IdOnDeletePanic | IdOnDeleteRemove | IdOnDeleteDelete

IdOnDeleteTargetRemove :: 1 << 3
IdOnDeleteTargetDelete :: 1 << 4
IdOnDeleteTargetPanic :: 1 << 5
IdOnDeleteTargetMask :: IdOnDeleteTargetPanic | IdOnDeleteTargetRemove | IdOnDeleteTargetDelete

IdOnInstantiateOverride :: 1 << 6
IdOnInstantiateInherit :: 1 << 7
IdOnInstantiateDontInherit :: 1 << 8
IdOnInstantiateMask ::
	IdOnInstantiateOverride | IdOnInstantiateInherit | IdOnInstantiateDontInherit

IdExclusive :: 1 << 9
IdTraversable :: 1 << 10
IdTag :: 1 << 11
IdWith :: 1 << 12
IdCanToggle :: 1 << 13
IdIsTransitive :: 1 << 14
IdIsInheritable :: 1 << 15

IdHasOnAdd :: 1 << 16 /* Same values as table flags */
IdHasOnRemove :: 1 << 17
IdHasOnSet :: 1 << 18
IdHasOnTableCreate :: 1 << 21
IdHasOnTableDelete :: 1 << 22
IdIsSparse :: 1 << 23
IdDontFragment :: 1 << 24
IdMatchDontFragment :: 1 << 25 /* For (*, T) wildcards */
IdOrderedChildren :: 1 << 28
IdEventMask ::
	IdHasOnAdd |
	IdHasOnRemove |
	IdHasOnSet |
	IdHasOnTableCreate |
	IdHasOnTableDelete |
	IdIsSparse |
	IdOrderedChildren

IdMarkedForDelete :: 1 << 30

////////////////////////////////////////////////////////////////////////////////
//// Bits set in world->non_trivial array
////////////////////////////////////////////////////////////////////////////////
NonTrivialIdSparse :: 1 << 0
NonTrivialIdNonFragmenting :: 1 << 1
NonTrivialIdInherit :: 1 << 2

////////////////////////////////////////////////////////////////////////////////
//// Iterator flags (used by ecs_iter_t::flags)
////////////////////////////////////////////////////////////////////////////////
IterIsValid :: 1 << 0 /* Does iterator contain valid result */
IterNoData :: 1 << 1 /* Does iterator provide (component) data */
IterNoResults :: 1 << 2 /* Iterator has no results */
IterMatchEmptyTables :: 1 << 3 /* Match empty tables */
IterIgnoreThis :: 1 << 4 /* Only evaluate non-this terms */
IterTrivialChangeDetection :: 1 << 5
IterHasCondSet :: 1 << 6 /* Does iterator have conditionally set fields */
IterProfile :: 1 << 7 /* Profile iterator performance */
IterTrivialSearch :: 1 << 8 /* Trivial iterator mode */
IterTrivialTest :: 1 << 11 /* Trivial test mode (constrained $this) */
IterTrivialCached :: 1 << 14 /* Trivial search for cached query */
IterCached :: 1 << 15 /* Cached query */
IterFixedInChangeComputed :: 1 << 16 /* Change detection for fixed in terms is done */
IterFixedInChanged :: 1 << 17 /* Fixed in terms changed */
IterSkip :: 1 << 18 /* Result was skipped for change detection */
IterCppEach :: 1 << 19 /* Uses C++ 'each' iterator */

/* Same as event flags */
IterTableOnly :: 1 << 20 /* Result only populates table */

////////////////////////////////////////////////////////////////////////////////
//// Event flags (used by ecs_event_decs_t::flags)
////////////////////////////////////////////////////////////////////////////////
EventTableOnly :: 1 << 20 /* Table event (no data, same as iter flags) */
EventNoOnSet :: 1 << 16 /* Don't emit OnSet for inherited ids */

/* Flags that can only be set by the query implementation */
QueryMatchThis :: 1 << 11 /* Query has terms with $this source */
QueryMatchOnlyThis :: 1 << 12 /* Query only has terms with $this source */
QueryMatchOnlySelf :: 1 << 13 /* Query has no terms with up traversal */
QueryMatchWildcards :: 1 << 14 /* Query matches wildcards */
QueryMatchNothing :: 1 << 15 /* Query matches nothing */
QueryHasCondSet :: 1 << 16 /* Query has conditionally set fields */
QueryHasPred :: 1 << 17 /* Query has equality predicates */
QueryHasScopes :: 1 << 18 /* Query has query scopes */
QueryHasRefs :: 1 << 19 /* Query has terms with static source */
QueryHasOutTerms :: 1 << 20 /* Query has [out] terms */
QueryHasNonThisOutTerms :: 1 << 21 /* Query has [out] terms with no $this source */
QueryHasChangeDetection :: 1 << 22 /* Query has monitor for change detection */
QueryIsTrivial :: 1 << 23 /* Query can use trivial evaluation function */
QueryHasCacheable :: 1 << 24 /* Query has cacheable terms */
QueryIsCacheable :: 1 << 25 /* All terms of query are cacheable */
QueryHasTableThisVar :: 1 << 26 /* Does query have $this table var */
QueryCacheYieldEmptyTables :: 1 << 27 /* Does query cache empty tables */
QueryTrivialCache ::
	1 << 28 /* Trivial cache (no wildcards, traversal, order_by, group_by, change detection) */
QueryNested :: 1 << 29 /* Query created by a query (for observer, cache) */

////////////////////////////////////////////////////////////////////////////////
//// Term flags (used by ecs_term_t::flags_)
////////////////////////////////////////////////////////////////////////////////
TermMatchAny :: 1 << 0
TermMatchAnySrc :: 1 << 1
TermTransitive :: 1 << 2
TermReflexive :: 1 << 3
TermIdInherited :: 1 << 4
TermIsTrivial :: 1 << 5
TermIsCacheable :: 1 << 7
TermIsScope :: 1 << 8
TermIsMember :: 1 << 9
TermIsToggle :: 1 << 10
TermKeepAlive :: 1 << 11
TermIsSparse :: 1 << 12
TermIsOr :: 1 << 13
TermDontFragment :: 1 << 14

////////////////////////////////////////////////////////////////////////////////
//// Observer flags (used by ecs_observer_t::flags)
////////////////////////////////////////////////////////////////////////////////
ObserverMatchPrefab :: 1 << 1 /* Same as query*/
ObserverMatchDisabled :: 1 << 2 /* Same as query*/
ObserverIsMulti :: 1 << 3 /* Does observer have multiple terms */
ObserverIsMonitor :: 1 << 4 /* Is observer a monitor */
ObserverIsDisabled :: 1 << 5 /* Is observer entity disabled */
ObserverIsParentDisabled :: 1 << 6 /* Is module parent of observer disabled  */
ObserverBypassQuery :: 1 << 7 /* Don't evaluate query for multi-component observer*/
ObserverYieldOnCreate :: 1 << 8 /* Yield matching entities when creating observer */
ObserverYieldOnDelete :: 1 << 9 /* Yield matching entities when deleting observer */
ObserverKeepAlive :: 1 << 11 /* Observer keeps component alive (same value as TermKeepAlive) */

////////////////////////////////////////////////////////////////////////////////
//// Table flags (used by ecs_table_t::flags)
////////////////////////////////////////////////////////////////////////////////
TableHasBuiltins :: 1 << 1 /* Does table have builtin components */
TableIsPrefab :: 1 << 2 /* Does the table store prefabs */
TableHasIsA :: 1 << 3 /* Does the table have IsA relationship */
TableHasChildOf :: 1 << 4 /* Does the table type ChildOf relationship */
TableHasName :: 1 << 5 /* Does the table type have (Identifier, Name) */
TableHasPairs :: 1 << 6 /* Does the table type have pairs */
TableHasModule :: 1 << 7 /* Does the table have module data */
TableIsDisabled :: 1 << 8 /* Does the table type has Disabled */
TableNotQueryable :: 1 << 9 /* Table should never be returned by queries */
TableHasCtors :: 1 << 10
TableHasDtors :: 1 << 11
TableHasCopy :: 1 << 12
TableHasMove :: 1 << 13
TableHasToggle :: 1 << 14
TableHasOverrides :: 1 << 15

TableHasOnAdd :: 1 << 16 /* Same values as id flags */
TableHasOnRemove :: 1 << 17
TableHasOnSet :: 1 << 18
TableHasOnTableFill :: 1 << 19
TableHasOnTableEmpty :: 1 << 20
TableHasOnTableCreate :: 1 << 21
TableHasOnTableDelete :: 1 << 22
TableHasSparse :: 1 << 23
TableHasDontFragment :: 1 << 24
TableOverrideDontFragment :: 1 << 25

TableHasTraversable :: 1 << 27
TableHasOrderedChildren :: 1 << 28
TableEdgeReparent :: 1 << 29
TableMarkedForDelete :: 1 << 30

/* Composite table flags */
TableHasLifecycle :: TableHasCtors | TableHasDtors
TableIsComplex :: TableHasLifecycle | TableHasToggle | TableHasSparse
TableHasAddActions :: TableHasIsA | TableHasCtors | TableHasOnAdd | TableHasOnSet
TableHasRemoveActions :: TableHasIsA | TableHasDtors | TableHasOnRemove
TableEdgeFlags :: TableHasOnAdd | TableHasOnRemove | TableHasSparse
TableAddEdgeFlags :: TableHasOnAdd | TableHasSparse
TableRemoveEdgeFlags :: TableHasOnRemove | TableHasSparse | TableHasOrderedChildren

////////////////////////////////////////////////////////////////////////////////
//// Aperiodic action flags (used by ecs_run_aperiodic)
////////////////////////////////////////////////////////////////////////////////
AperiodicComponentMonitors :: 1 << 2 /* Process component monitors */
AperiodicEmptyQueries :: 1 << 4 /* Process empty queries */

// CLANG_VERSION :: _clang_major__

// NORETURN :: _attribute__((noreturn))

// FLECS_DBG_API :: FLECS_API

// NULL :: (void*)0

// false :: 0
// true :: 1

/* Utility types to indicate usage as bitmask */
flags8_t :: u8

flags16_t :: u16

flags32_t :: u32

flags64_t :: u64

/* Bitset type that can store exactly as many bits as there are terms */
// ecs_termset_t :: flags##FLECS_TERM_COUNT_MAX##t

/* Keep unsigned integers out of the codebase as they do more harm than good */
size_t :: i32

// FLECS_ALWAYS_INLINE :: _attribute__((always_inline))

/* Magic number to identify the type of the object */
ecs_world_t_magic :: 0x65637377
ecs_stage_t_magic :: 0x65637373
ecs_query_t_magic :: 0x65637375
ecs_observer_t_magic :: 0x65637362

////////////////////////////////////////////////////////////////////////////////
//// Entity id macros
////////////////////////////////////////////////////////////////////////////////
ROW_MASK :: 0x0FFFFFFF
// ROW_FLAGS_MASK            :: ~ECS_ROW_MASK

ID_FLAGS_MASK :: 0xFF << 60
ENTITY_MASK :: 0xFFFFFFFF
GENERATION_MASK :: 0xFFFF << 32

// COMPONENT_MASK            :: ~ECS_ID_FLAGS_MASK

// ecs_pair_relation :: pair_first
// ecs_pair_target :: pair_second

/** A component column. */
vec_t :: struct {
	array: rawptr,
	count: i32,
	size:  i32,
}

/** The number of elements in a single page */
FLECS_SPARSE_PAGE_SIZE :: 1 << FLECS_SPARSE_PAGE_BITS

sparse_t :: struct {
	dense:          vec_t,
	/* Dense array with indices to sparse array. The
                              * dense array stores both alive and not alive
                              * sparse indices. The 'count' member keeps
                              * track of which indices are alive. */
	pages:          vec_t,
	/* Chunks with sparse arrays & data */
	size:           size_t,
	/* Element size */
	count:          i32,
	/* Number of alive entries */
	max_id:         u64,
	/* Local max index (if no global is set) */
	allocator:      ^allocator_t,
	page_allocator: ^block_allocator_t,
}

block_allocator_block_t :: struct {
	memory: rawptr,
	next:   ^block_allocator_block_t,
}

block_allocator_chunk_header_t :: struct {
	next: ^block_allocator_chunk_header_t,
}

block_allocator_t :: struct {
	data_size:        i32,
	chunk_size:       i32,
	chunks_per_block: i32,
	block_size:       i32,
	head:             ^block_allocator_chunk_header_t,
	block_head:       ^block_allocator_block_t,
}

/** Stack allocator for quick allocation of small temporary values */
stack_page_t :: struct {
	data: rawptr,
	next: ^stack_page_t,
	sp:   i16,
	id:   u32,
}

stack_cursor_t :: struct {
	prev:    ^stack_cursor_t,
	page:    ^stack_page_t,
	sp:      i16,
	is_free: bool,
	owner:   ^stack_t,
}

stack_t :: struct {
	first:        ^stack_page_t,
	tail_page:    ^stack_page_t,
	tail_cursor:  ^stack_cursor_t,
	cursor_count: i32,
}

FLECS_STACK_PAGE_OFFSET :: (c.size_t)(
	(((((c.size_t)((c.size_t)(size_of(stack_page_t)))) - 1) / (cast(c.size_t)16)) + 1) *
	(cast(c.size_t)16),
)
FLECS_STACK_PAGE_SIZE :: 1024 - FLECS_STACK_PAGE_OFFSET

map_data_t :: u64

map_key_t :: map_data_t

map_val_t :: map_data_t

/* Map type */
bucket_entry_t :: struct {
	key:   map_key_t,
	value: map_val_t,
	next:  ^bucket_entry_t,
}

bucket_t :: struct {
	first: ^bucket_entry_t,
}

map_t :: struct {
	buckets:      ^bucket_t,
	bucket_count: i32,
	count:        c.uint,
	bucket_shift: c.uint,
	allocator:    ^allocator_t,
}

map_iter_t :: struct {
	_map:   ^map_t,
	bucket: ^bucket_t,
	entry:  ^bucket_entry_t,
	res:    ^map_data_t,
}

map_params_t :: struct {
	allocator:       ^allocator_t,
	entry_allocator: block_allocator_t,
}

allocator_t :: struct {
	chunks: block_allocator_t,
	sizes:  sparse_t, /* <size, block_allocator_t> */
}

/* Fixes missing field initializer warning on g++ */
STRBUF_INIT :: (strbuf_t){}

STRBUF_SMALL_STRING_SIZE :: 512
STRBUF_MAX_LIST_DEPTH :: 32

strbuf_list_elem :: struct {
	count:     i32,
	separator: cstring,
}

strbuf_t :: struct {
	content:      cstring,
	length:       size_t,
	size:         size_t,
	list_stack:   [32]strbuf_list_elem,
	list_sp:      i32,
	small_string: [512]c.char,
}

/** Time type. */
time_t :: struct {
	sec:     u32, /**< Second part. */
	nanosec: u32, /**< Nanosecond part. */
}

/* Use handle types that _at least_ can store pointers */
os_thread_t :: c.uintptr_t

os_cond_t :: c.uintptr_t

os_mutex_t :: c.uintptr_t

os_dl_t :: c.uintptr_t

os_sock_t :: c.uintptr_t

/** 64 bit thread id. */
os_thread_id_t :: u64

/** Generic function pointer type. */
os_proc_t :: proc "c" ()

/** OS API init. */
os_api_init_t :: proc "c" ()

/** OS API deinit. */
os_api_fini_t :: proc "c" ()

/** OS API malloc function type. */
os_api_malloc_t :: proc "c" (_: size_t) -> rawptr

/** OS API free function type. */
os_api_free_t :: proc "c" (_: rawptr)

/** OS API realloc function type. */
os_api_realloc_t :: proc "c" (_: rawptr, _: size_t) -> rawptr

/** OS API calloc function type. */
os_api_calloc_t :: proc "c" (_: size_t) -> rawptr

/** OS API strdup function type. */
os_api_strdup_t :: proc "c" (_: cstring) -> cstring

/** OS API thread_callback function type. */
os_thread_callback_t :: proc "c" (_: rawptr) -> rawptr

/** OS API thread_new function type. */
os_api_thread_new_t :: proc "c" (_: os_thread_callback_t, _: rawptr) -> os_thread_t

/** OS API thread_join function type. */
os_api_thread_join_t :: proc "c" (_: os_thread_t) -> rawptr

/** OS API thread_self function type. */
os_api_thread_self_t :: proc "c" () -> os_thread_id_t

/** OS API task_new function type. */
os_api_task_new_t :: proc "c" (_: os_thread_callback_t, _: rawptr) -> os_thread_t

/** OS API task_join function type. */
os_api_task_join_t :: proc "c" (_: os_thread_t) -> rawptr

/* Atomic increment / decrement */
/** OS API ainc function type. */
os_api_ainc_t :: proc "c" (_: ^i32) -> i32

/** OS API lainc function type. */
os_api_lainc_t :: proc "c" (_: ^i64) -> i64

/* Mutex */
/** OS API mutex_new function type. */
os_api_mutex_new_t :: proc "c" () -> os_mutex_t

/** OS API mutex_lock function type. */
os_api_mutex_lock_t :: proc "c" (_: os_mutex_t)

/** OS API mutex_unlock function type. */
os_api_mutex_unlock_t :: proc "c" (_: os_mutex_t)

/** OS API mutex_free function type. */
os_api_mutex_free_t :: proc "c" (_: os_mutex_t)

/* Condition variable */
/** OS API cond_new function type. */
os_api_cond_new_t :: proc "c" () -> os_cond_t

/** OS API cond_free function type. */
os_api_cond_free_t :: proc "c" (_: os_cond_t)

/** OS API cond_signal function type. */
os_api_cond_signal_t :: proc "c" (_: os_cond_t)

/** OS API cond_broadcast function type. */
os_api_cond_broadcast_t :: proc "c" (_: os_cond_t)

/** OS API cond_wait function type. */
os_api_cond_wait_t :: proc "c" (_: os_cond_t, _: os_mutex_t)

/** OS API sleep function type. */
os_api_sleep_t :: proc "c" (_: i32, _: i32)

/** OS API enable_high_timer_resolution function type. */
os_api_enable_high_timer_resolution_t :: proc "c" (_: bool)

/** OS API get_time function type. */
os_api_get_time_t :: proc "c" (_: ^time_t)

/** OS API now function type. */
os_api_now_t :: proc "c" () -> u64

/** OS API log function type. */
os_api_log_t :: proc "c" (_: i32, _: cstring, _: i32, _: cstring)

/** OS API abort function type. */
os_api_abort_t :: proc "c" ()

/** OS API dlopen function type. */
os_api_dlopen_t :: proc "c" (_: cstring) -> os_dl_t

/** OS API dlproc function type. */
os_api_dlproc_t :: proc "c" (_: os_dl_t, _: cstring) -> os_proc_t

/** OS API dlclose function type. */
os_api_dlclose_t :: proc "c" (_: os_dl_t)

/** OS API module_to_path function type. */
os_api_module_to_path_t :: proc "c" (_: cstring) -> cstring

/* Performance tracing */
os_api_perf_trace_t :: proc "c" (_: cstring, _: c.size_t, _: cstring)

/** OS API interface. */
os_api_t :: struct {
	init_:               os_api_init_t, /**< init callback. */
	fini_:               os_api_fini_t, /**< fini callback. */
	malloc_:             os_api_malloc_t, /**< malloc callback. */
	realloc_:            os_api_realloc_t, /**< realloc callback. */
	calloc_:             os_api_calloc_t, /**< calloc callback. */
	free_:               os_api_free_t, /**< free callback. */
	strdup_:             os_api_strdup_t, /**< strdup callback. */
	thread_new_:         os_api_thread_new_t, /**< thread_new callback. */
	thread_join_:        os_api_thread_join_t, /**< thread_join callback. */
	thread_self_:        os_api_thread_self_t, /**< thread_self callback. */
	task_new_:           os_api_thread_new_t, /**< task_new callback. */
	task_join_:          os_api_thread_join_t, /**< task_join callback. */
	ainc_:               os_api_ainc_t, /**< ainc callback. */
	adec_:               os_api_ainc_t, /**< adec callback. */
	lainc_:              os_api_lainc_t, /**< lainc callback. */
	ladec_:              os_api_lainc_t, /**< ladec callback. */
	mutex_new_:          os_api_mutex_new_t, /**< mutex_new callback. */
	mutex_free_:         os_api_mutex_free_t, /**< mutex_free callback. */
	mutex_lock_:         os_api_mutex_lock_t, /**< mutex_lock callback. */
	mutex_unlock_:       os_api_mutex_lock_t, /**< mutex_unlock callback. */
	cond_new_:           os_api_cond_new_t, /**< cond_new callback. */
	cond_free_:          os_api_cond_free_t, /**< cond_free callback. */
	cond_signal_:        os_api_cond_signal_t, /**< cond_signal callback. */
	cond_broadcast_:     os_api_cond_broadcast_t, /**< cond_broadcast callback. */
	cond_wait_:          os_api_cond_wait_t, /**< cond_wait callback. */
	sleep_:              os_api_sleep_t, /**< sleep callback. */
	now_:                os_api_now_t, /**< now callback. */
	get_time_:           os_api_get_time_t, /**< get_time callback. */
	log_:                os_api_log_t, /**< log callback.
                            * The level should be interpreted as:
                            * >0: Debug tracing. Only enabled in debug builds.
                            *  0: Tracing. Enabled in debug/release builds.
                            * -2: Warning. An issue occurred, but operation was successful.
                            * -3: Error. An issue occurred, and operation was unsuccessful.
                            * -4: Fatal. An issue occurred, and application must quit. */
	abort_:              os_api_abort_t, /**< abort callback. */
	dlopen_:             os_api_dlopen_t, /**< dlopen callback. */
	dlproc_:             os_api_dlproc_t, /**< dlproc callback. */
	dlclose_:            os_api_dlclose_t, /**< dlclose callback. */
	module_to_dl_:       os_api_module_to_path_t, /**< module_to_dl callback. */
	module_to_etc_:      os_api_module_to_path_t, /**< module_to_etc callback. */

	/* Performance tracing */
	perf_trace_push_:    os_api_perf_trace_t,

	/* Performance tracing */
	perf_trace_pop_:     os_api_perf_trace_t,
	log_level_:          i32, /**< Tracing level. */
	log_indent_:         i32, /**< Tracing indentation level. */
	log_last_error_:     i32, /**< Last logged error code. */
	log_last_timestamp_: i64, /**< Last logged timestamp. */
	flags_:              flags32_t, /**< OS API flags */
	log_out_:            rawptr, /**< File used for logging output (type is FILE*)
                                                    * (hint, log_ decides where to write) */
}

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
	array: [^]id_t, /**< Array with ids. */
	count: i32, /**< Number of elements in array. */
}

/** A world is the container for all ECS data and supporting features.
* Applications can have multiple worlds, though in most cases will only need
* one. Worlds are isolated from each other, and can have separate sets of
* systems, components, modules etc.
*
* If an application has multiple worlds with overlapping components, it is
* common (though not strictly required) to use the same component ids across
* worlds, which can be achieved by declaring a global component id variable.
* To do this in the C API, see the entities/fwd_component_decl example. The
* C++ API automatically synchronizes component ids between worlds.
*
* Component id conflicts between worlds can occur when a world has already used
* an id for something else. There are a few ways to avoid this:
*
* - Ensure to register the same components in each world, in the same order.
* - Create a dummy world in which all components are preregistered which
*   initializes the global id variables.
*
* In some use cases, typically when writing tests, multiple worlds are created
* and deleted with different components, registered in different order. To
* ensure isolation between tests, the C++ API has a `flecs::reset` function
* that forces the API to ignore the old component ids. */
world_t :: struct {}

stage_t :: struct {}

/** A table stores entities and components for a specific type. */
table_t :: struct {}

ecs_observable_t :: struct {}
ecs_iter_t :: struct {}
ecs_ref_t :: struct {}
ecs_type_hooks_t :: struct {}
ecs_type_info_t :: struct {}
ecs_record_t :: struct {}

/** Information about a (component) id, such as type info and tables with the id */
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
poly_t :: rawptr

/** Type that stores poly mixins */
mixins_t :: struct {}

/** Header for ecs_poly_t objects. */
header_t :: struct {
	type:     i32, /**< Magic number indicating which type of flecs object */
	refcount: i32, /**< Refcount, to enable RAII handles */
	mixins:   ^mixins_t, /**< Table with offsets to (optional) mixins */
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
run_action_t :: proc "c" (_: ^iter_t)

/** Function prototype for iterables.
* A system may invoke a callback multiple times, typically once for each
* matched table.
*
* @param it The iterator containing the data for the current match.
*/
iter_action_t :: proc "c" (_: ^iter_t)

/** Function prototype for iterating an iterator.
* Stored inside initialized iterators. This allows an application to iterate
* an iterator without needing to know what created it.
*
* @param it The iterator to iterate.
* @return True if iterator has no more results, false if it does.
*/
iter_next_action_t :: proc "c" (_: ^iter_t) -> bool

/** Function prototype for freeing an iterator.
* Free iterator resources.
*
* @param it The iterator to free.
*/
iter_fini_action_t :: proc "c" (_: ^iter_t)

/** Callback used for comparing components */
order_by_action_t :: proc "c" (_: entity_t, _: rawptr, _: entity_t, _: rawptr) -> c.int

/** Callback used for sorting the entire table of components */
sort_table_action_t :: proc "c" (
	_: ^world_t,
	_: ^table_t,
	_: ^entity_t,
	_: rawptr,
	_: i32,
	_: i32,
	_: i32,
	_: order_by_action_t,
)

/** Callback used for grouping tables in a query */
group_by_action_t :: proc "c" (_: ^world_t, _: ^table_t, _: id_t, _: rawptr) -> u64

/** Callback invoked when a query creates a new group. */
group_create_action_t :: proc "c" (_: ^world_t, _: u64, _: rawptr) -> rawptr

/** Callback invoked when a query deletes an existing group. */
group_delete_action_t :: proc "c" (_: ^world_t, _: u64, _: rawptr, _: rawptr)

/** Initialization action for modules */
module_action_t :: proc "c" (_: ^world_t)

/** Action callback on world exit */
fini_action_t :: proc "c" (_: ^world_t, _: rawptr)

/** Function to cleanup context data */
ctx_free_t :: proc "c" (_: rawptr)

/** Callback used for sorting values */
compare_action_t :: proc "c" (_: rawptr, _: rawptr) -> c.int

/** Callback used for hashing values */
hash_value_action_t :: proc "c" (_: rawptr) -> u64

/** Constructor/destructor callback */
xtor_t :: proc "c" (_: rawptr, _: i32, _: ^type_info_t)

/** Copy is invoked when a component is copied into another component. */
copy_t :: proc "c" (_: rawptr, _: rawptr, _: i32, _: ^type_info_t)

/** Move is invoked when a component is moved to another component. */
move_t :: proc "c" (_: rawptr, _: rawptr, _: i32, _: ^type_info_t)

/** Compare hook to compare component instances */
cmp_t :: proc "c" (_: rawptr, _: rawptr, _: ^type_info_t) -> c.int

/** Equals operator hook */
equals_t :: proc "c" (_: rawptr, _: rawptr, _: ^type_info_t) -> bool

/** Destructor function for poly objects. */
flecs_poly_dtor_t :: proc "c" (_: poly_t)

/** Specify read/write access for term */
inout_kind_t :: enum c.int {
	InOutDefault, /**< InOut for regular terms, In for shared terms */
	InOutNone, /**< Term is neither read nor written */
	InOutFilter, /**< Same as InOutNone + prevents term from triggering observers */
	InOut, /**< Term is both read and written */
	In, /**< Term is only read */
	Out, /**< Term is only written */
}

/** Specify operator for term */
oper_kind_t :: enum c.int {
	And, /**< The term must match */
	Or, /**< One of the terms in an or chain must match */
	Not, /**< The term must not match */
	Optional, /**< The term may match */
	AndFrom, /**< Term must match all components from term id */
	OrFrom, /**< Term must match at least one component from term id */
	NotFrom, /**< Term must match none of the components from term id */
}

/** Specify cache policy for query */
query_cache_kind_t :: enum c.int {
	Default, /**< Behavior determined by query creation context */
	Auto, /**< Cache query terms that are cacheable */
	All, /**< Require that all query terms can be cached */
	None, /**< No caching */
}

/** Match on self.
 * Can be combined with other term flags on the ecs_term_t::flags_ field.
 * \ingroup queries
 */
Self :: 1 << 63

/** Match by traversing upwards.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
Up :: 1 << 62

/** Traverse relationship transitively.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
Trav :: 1 << 61

/** Sort results breadth first.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
Cascade :: 1 << 60

/** Iterate groups in descending order.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
Desc :: 1 << 59

/** Term id is a variable.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
IsVariable :: 1 << 58

/** Term id is an entity.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
IsEntity :: 1 << 57

/** Term id is a name (don't attempt to lookup as entity).
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
IsName :: 1 << 56

/** All term traversal flags.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
TraverseFlags :: Self | Up | Trav | Cascade | Desc

/** All term reference kind flags.
 * Can be combined with other term flags on the ecs_term_ref_t::id field.
 * \ingroup queries
 */
TermRefFlags :: TraverseFlags | IsVariable | IsEntity | IsName

/** Type that describes a reference to an entity or variable in a term. */
term_ref_t :: struct {
	id:   entity_t,
	/**< Entity id. If left to 0 and flags does not 
                                 * specify whether id is an entity or a variable
                                 * the id will be initialized to #This.
                                 * To explicitly set the id to 0, leave the id
                                 * member to 0 and set #IsEntity in flags. */
	name: cstring,
	/**< Name. This can be either the variable name
                                 * (when the #IsVariable flag is set) or an
                                 * entity name. When ecs_term_t::move is true,
                                 * the API assumes ownership over the string and
                                 * will free it when the term is destroyed. */
}

/** Type that describes a term (single element in a query). */
term_t :: struct {
	id:          id_t,
	/**< Component id to be matched by term. Can be
                                 * set directly, or will be populated from the
                                 * first/second members, which provide more
                                 * flexibility. */
	src:         term_ref_t,
	/**< Source of term */
	first:       term_ref_t,
	/**< Component or first element of pair */
	second:      term_ref_t,
	/**< Second element of pair */
	trav:        entity_t,
	/**< Relationship to traverse when looking for the
                                 * component. The relationship must have
                                 * the `Traversable` property. Default is `IsA`. */
	inout:       i16,
	/**< Access to contents matched by term */
	oper:        i16,
	/**< Operator of term */
	field_index: i8,
	/**< Index of field for term in iterator */
	flags_:      flags16_t,
	/**< Flags that help eval, set by ecs_query_init() */
}

/** Queries are lists of constraints (terms) that match entities.
* Created with ecs_query_init().
*/
query_t :: struct {
	hdr:                    header_t, /**< Object header */
	terms:                  ^term_t, /**< Query terms */
	sizes:                  ^i32, /**< Component sizes. Indexed by field */
	ids:                    ^id_t, /**< Component ids. Indexed by field */
	bloom_filter:           u64, /**< Bitmask used to quickly discard tables */
	flags:                  flags32_t, /**< Query flags */
	var_count:              i8, /**< Number of query variables */
	term_count:             i8, /**< Number of query terms */
	field_count:            i8, /**< Number of fields returned by query */
	fixed_fields:           flags32_t, /**< Fields with a fixed source */
	var_fields:             flags32_t, /**< Fields with non-$this variable source */
	static_id_fields:       flags32_t, /**< Fields with a static (component) id */
	data_fields:            flags32_t, /**< Fields that have data */
	write_fields:           flags32_t, /**< Fields that write data */
	read_fields:            flags32_t, /**< Fields that read data */
	row_fields:             flags32_t, /**< Fields that must be acquired with field_at */
	shared_readonly_fields: flags32_t, /**< Fields that don't write shared data */
	set_fields:             flags32_t, /**< Fields that will be set */
	cache_kind:             query_cache_kind_t, /**< Caching policy of query */
	vars:                   [^]cstring, /**< Array with variable names for iterator */
	ctx:                    rawptr, /**< User context to pass to callback */
	binding_ctx:            rawptr, /**< Context to be used for language bindings */
	entity:                 entity_t, /**< Entity associated with query (optional) */
	real_world:             ^world_t, /**< Actual world. */
	world:                  ^world_t, /**< World or stage query was created with. */
	eval_count:             i32, /**< Number of times query is evaluated */
}

/** An observer reacts to events matching a query.
* Created with ecs_observer_init().
*/
observer_t :: struct {
	hdr:               header_t, /**< Object header */
	query:             ^query_t, /**< Observer query */

	/** Observer events */
	events:            [8]entity_t,
	event_count:       i32, /**< Number of events */
	callback:          iter_action_t, /**< See ecs_observer_desc_t::callback */
	run:               run_action_t, /**< See ecs_observer_desc_t::run */
	ctx:               rawptr, /**< Observer context */
	callback_ctx:      rawptr, /**< Callback language binding context */
	run_ctx:           rawptr, /**< Run language binding context */
	ctx_free:          ctx_free_t, /**< Callback to free ctx */
	callback_ctx_free: ctx_free_t, /**< Callback to free callback_ctx */
	run_ctx_free:      ctx_free_t, /**< Callback to free run_ctx */
	observable:        ^observable_t, /**< Observable for observer */
	world:             ^world_t, /**< The world */
	entity:            entity_t, /**< Entity associated with observer */
}

/* Flags that can be used to check which hooks a type has set */
TYPE_HOOK_CTOR :: (flags32_t)(1)
TYPE_HOOK_DTOR :: (flags32_t)(1)
TYPE_HOOK_COPY :: (flags32_t)(1)
TYPE_HOOK_MOVE :: (flags32_t)(1)
TYPE_HOOK_COPY_CTOR :: (flags32_t)(1)
TYPE_HOOK_MOVE_CTOR :: (flags32_t)(1)
TYPE_HOOK_CTOR_MOVE_DTOR :: (flags32_t)(1)
TYPE_HOOK_MOVE_DTOR :: (flags32_t)(1)
TYPE_HOOK_CMP :: (flags32_t)(1)
TYPE_HOOK_EQUALS :: (flags32_t)(1)

/* Flags that can be used to set/check which hooks of a type are invalid */
TYPE_HOOK_CTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_DTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_COPY_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_MOVE_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_COPY_CTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_MOVE_CTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_CTOR_MOVE_DTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_MOVE_DTOR_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_CMP_ILLEGAL :: (flags32_t)(1)
TYPE_HOOK_EQUALS_ILLEGAL :: (flags32_t)(1)

// TYPE_HOOKS :: ECS_TYPE_HOOK_CTOR|ECS_TYPE_HOOK_DTOR| ECS_TYPE_HOOK_COPY|ECS_TYPE_HOOK_MOVE|ECS_TYPE_HOOK_COPY_CTOR| ECS_TYPE_HOOK_MOVE_CTOR|ECS_TYPE_HOOK_CTOR_MOVE_DTOR| ECS_TYPE_HOOK_MOVE_DTOR|ECS_TYPE_HOOK_CMP|ECS_TYPE_HOOK_EQUALS

// TYPE_HOOKS_ILLEGAL :: ECS_TYPE_HOOK_CTOR_ILLEGAL| ECS_TYPE_HOOK_DTOR_ILLEGAL|ECS_TYPE_HOOK_COPY_ILLEGAL| ECS_TYPE_HOOK_MOVE_ILLEGAL|ECS_TYPE_HOOK_COPY_CTOR_ILLEGAL| ECS_TYPE_HOOK_MOVE_CTOR_ILLEGAL|ECS_TYPE_HOOK_CTOR_MOVE_DTOR_ILLEGAL| ECS_TYPE_HOOK_MOVE_DTOR_ILLEGAL|ECS_TYPE_HOOK_CMP_ILLEGAL| ECS_TYPE_HOOK_EQUALS_ILLEGAL

type_hooks_t :: struct {
	ctor:               xtor_t, /**< ctor */
	dtor:               xtor_t, /**< dtor */
	copy:               copy_t, /**< copy assignment */
	move:               move_t, /**< move assignment */

	/** Ctor + copy */
	copy_ctor:          copy_t,

	/** Ctor + move */
	move_ctor:          move_t,

	/** Ctor + move + dtor (or move_ctor + dtor).
	* This combination is typically used when a component is moved from one
	* location to a new location, like when it is moved to a new table. If
	* not set explicitly it will be derived from other callbacks. */
	ctor_move_dtor:     move_t,

	/** Move + dtor.
	* This combination is typically used when a component is moved from one
	* location to an existing location, like what happens during a remove. If
	* not set explicitly it will be derived from other callbacks. */
	move_dtor:          move_t,

	/** Compare hook */
	cmp:                cmp_t,

	/** Equals hook */
	equals:             equals_t,

	/** Hook flags.
	* Indicates which hooks are set for the type, and which hooks are illegal.
	* When an ILLEGAL flag is set when calling ecs_set_hooks() a hook callback
	* will be set that panics when called. */
	flags:              flags32_t,

	/** Callback that is invoked when an instance of a component is added. This
	* callback is invoked before triggers are invoked. */
	on_add:             iter_action_t,

	/** Callback that is invoked when an instance of the component is set. This
	* callback is invoked before triggers are invoked, and enable the component
	* to respond to changes on itself before others can. */
	on_set:             iter_action_t,

	/** Callback that is invoked when an instance of the component is removed.
	* This callback is invoked after the triggers are invoked, and before the
	* destructor is invoked. */
	on_remove:          iter_action_t,

	/** Callback that is invoked with the existing and new value before the
	* value is assigned. Invoked after on_add and before on_set. Registering
	* an on_replace hook prevents using operations that return a mutable
	* pointer to the component like get_mut, ensure and emplace. */
	on_replace:         iter_action_t,
	ctx:                rawptr, /**< User defined context */
	binding_ctx:        rawptr, /**< Language binding context */
	lifecycle_ctx:      rawptr, /**< Component lifecycle context (see meta add-on)*/
	ctx_free:           ctx_free_t, /**< Callback to free ctx */
	binding_ctx_free:   ctx_free_t, /**< Callback to free binding_ctx */
	lifecycle_ctx_free: ctx_free_t, /**< Callback to free lifecycle_ctx */
}

/** Type that contains component information (passed to ctors/dtors/...)
*
* @ingroup components
*/
type_info_t :: struct {
	size:      size_t, /**< Size of type */
	alignment: size_t, /**< Alignment of type */
	hooks:     type_hooks_t, /**< Type hooks */
	component: entity_t, /**< Handle to component (do not set) */
	name:      cstring, /**< Type name. */
}

/* Cached query table data */
query_cache_match_t :: struct {}

/* Cached query group */
query_cache_group_t :: struct {}

event_id_record_t :: struct {}

/** All observers for a specific event */
event_record_t :: struct {
	any:           ^event_id_record_t,
	wildcard:      ^event_id_record_t,
	wildcard_pair: ^event_id_record_t,
	event_ids:     map_t, /* map<id, ecs_event_id_record_t> */
	event:         entity_t,
}

observable_t :: struct {
	on_add:           event_record_t,
	on_remove:        event_record_t,
	on_set:           event_record_t,
	on_wildcard:      event_record_t,
	events:           sparse_t, /* sparse<event, ecs_event_record_t> */
	last_observer_id: u64,
}

/** Range in table */
table_range_t :: struct {
	table:  ^table_t,
	offset: i32, /* Leave both members to 0 to cover entire table */
	count:  i32,
}

/** Value of query variable */
var_t :: struct {
	range:  table_range_t, /* Set when variable stores a range of entities */
	entity: entity_t, /* Set when variable stores single entity */
}

/** Cached reference. */
ref_t :: struct {
	entity:             entity_t, /* Entity */
	id:                 entity_t, /* Component id */
	table_id:           u64, /* Table id for detecting ABA issues */
	table_version_fast: u32, /* Fast change detection w/false positives */
	table_version:      u16, /* Change detection */
	record:             ^record_t, /* Entity index record */
	ptr:                rawptr, /* Cached component pointer */
}

/* Page-iterator specific data */
page_iter_t :: struct {
	offset:    i32,
	limit:     i32,
	remaining: i32,
}

/* Worker-iterator specific data */
worker_iter_t :: struct {
	index: i32,
	count: i32,
}

/* Convenience struct to iterate table array for id */
table_cache_iter_t :: struct {
	cur, next:  ^table_cache_hdr_t,
	iter_fill:  bool,
	iter_empty: bool,
}

/** Each iterator */
each_iter_t :: struct {
	it:      table_cache_iter_t,

	/* Storage for iterator fields */
	ids:     id_t,
	sources: entity_t,
	sizes:   size_t,
	columns: i32,
	trs:     ^table_record_t,
}

query_op_profile_t :: struct {
	count: [2]i32, /* 0 = enter, 1 = redo */
}

query_var_t :: struct {}
query_op_t :: struct {}
query_op_ctx_t :: struct {}

/** Query iterator */
query_iter_t :: struct {
	vars:              ^var_t, /* Variable storage */
	query_vars:        ^query_var_t, /* Query variable metadata */
	ops:               ^query_op_t, /* Query plan operations */
	op_ctx:            ^query_op_ctx_t, /* Operation-specific state */
	written:           ^u64,
	group:             ^query_cache_group_t, /* Currently iterated group */
	tables:            ^vec_t, /* Currently iterated table vector (vec<ecs_query_cache_match_t>) */
	all_tables:        ^vec_t, /* Different from .tables if iterating wildcard matches (vec<ecs_query_cache_match_t>) */
	elem:              ^query_cache_match_t, /* Current cache entry */
	cur, all_cur:      i32, /* Indices into tables & all_tables */
	profile:           ^query_op_profile_t,
	op:                i16, /* Currently iterated query plan operation (index into ops) */
	iter_single_group: bool,
}

/* Private iterator data. Used by iterator implementations to keep track of
* progress & to provide builtin storage. */
iter_private_t :: struct {
	iter:         struct #raw_union {
		query:  query_iter_t,
		page:   page_iter_t,
		worker: worker_iter_t,
		each:   each_iter_t,
	}, /* Iterator specific data */
	entity_iter:  rawptr, /* Query applied after matching a table */
	stack_cursor: ^stack_cursor_t, /* Stack cursor to restore to */
}

/* Data structures that store the command queue */
commands_t :: struct {
	queue:   vec_t,
	stack:   stack_t, /* Temp memory used by deferred commands */
	entries: sparse_t, /* <entity, op_entry_t> - command batching */
}

/** This is the largest possible component id. Components for the most part
 * occupy the same id range as entities, however they are not allowed to overlap
 * with (8) bits reserved for id flags. */
// MAX_COMPONENT_ID :: ~((u32)(ECS_ID_FLAGS_MASK >> 32))

/** The maximum number of nested function calls before the core will throw a
 * cycle detected error */
MAX_RECURSION :: 512

/** Maximum length of a parser token (used by parser-related addons) */
MAX_TOKEN_SIZE :: 256

/* Suspend/resume readonly state. To fully support implicit registration of
* components, it should be possible to register components while the world is
* in readonly mode. It is not uncommon that a component is used first from
* within a system, which are often ran while in readonly mode.
*
* Suspending readonly mode is only allowed when the world is not multithreaded.
* When a world is multithreaded, it is not safe to (even temporarily) leave
* readonly mode, so a multithreaded application should always explicitly
* register components in advance.
*
* These operations also suspend deferred mode.
*
* Functions are public to support language bindings.
*/
suspend_readonly_state_t :: struct {
	is_readonly:  bool,
	is_deferred:  bool,
	cmd_flushing: bool,
	defer_count:  i32,
	scope:        entity_t,
	with:         entity_t,
	cmd_stack:    [2]commands_t,
	cmd:          ^commands_t,
	stage:        ^stage_t,
}

hm_bucket_t :: struct {
	keys:   vec_t,
	values: vec_t,
}

hashmap_t :: struct {
	hash:              hash_value_action_t,
	compare:           compare_action_t,
	key_size:          size_t,
	value_size:        size_t,
	hashmap_allocator: ^block_allocator_t,
	bucket_allocator:  block_allocator_t,
	impl:              map_t,
}

flecs_hashmap_iter_t :: struct {
	it:     map_iter_t,
	bucket: ^hm_bucket_t,
	index:  i32,
}

flecs_hashmap_result_t :: struct {
	key:   rawptr,
	value: rawptr,
	hash:  u64,
}

/** Record for entity index. */
record_t :: struct {
	cr:    ^component_record_t, /**< component record to (*, entity) for target entities */
	table: ^table_t, /**< Identifies a type (and table) in world */
	row:   u32, /**< Table row of the entity */
	dense: i32, /**< Index in dense array of entity index */
}

table_cache_t :: struct {}

/** Header for table cache elements. */
table_cache_hdr_t :: struct {
	cache:      ^table_cache_t,
	/**< Table cache of element. Of type ecs_component_record_t* for component index elements. */
	table:      ^table_t,
	/**< Table associated with element. */
	prev, next: ^table_cache_hdr_t,
	/**< Next/previous elements for id in table cache. */
}

/** Record that stores location of a component in a table.
* Table records are registered with component records, which allows for quickly
* finding all tables for a specific component. */
table_record_t :: struct {
	hdr:    table_cache_hdr_t, /**< Table cache header */
	index:  i16, /**< First type index where id occurs in table */
	count:  i16, /**< Number of times id occurs in table */
	column: i16, /**< First column index where id occurs */
}

/** Type that contains information about which components got added/removed on
* a table edge. */
table_diff_t :: struct {
	added:         type_t, /* Components added between tables */
	removed:       type_t, /* Components removed between tables */
	added_flags:   flags32_t,
	removed_flags: flags32_t,
}

/** Struct returned by flecs_table_records(). */
table_records_t :: struct {
	array: ^table_record_t,
	count: i32,
}

/** Utility to hold a value of a dynamic type. */
value_t :: struct {
	type: entity_t, /**< Type of value. */
	ptr:  rawptr, /**< Pointer to value. */
}

/** Used with ecs_entity_init().
*
* @ingroup entities
*/
entity_desc_t :: struct {
	_canary:    i32, /**< Used for validity testing. Must be 0. */
	id:         entity_t, /**< Set to modify existing entity (optional) */
	parent:     entity_t, /**< Parent entity. */
	name:       cstring, /**< Name of the entity. If no entity is provided, an
                           * entity with this name will be looked up first. When
                           * an entity is provided, the name will be verified
                           * with the existing entity. */
	sep:        cstring, /**< Optional custom separator for hierarchical names.
                           * Leave to NULL for default ('.') separator. Set to
                           * an empty string to prevent tokenization of name. */
	root_sep:   cstring, /**< Optional, used for identifiers relative to root */
	symbol:     cstring, /**< Optional entity symbol. A symbol is an unscoped
                           * identifier that can be used to lookup an entity. The
                           * primary use case for this is to associate the entity
                           * with a language identifier, such as a type or
                           * function name, where these identifiers differ from
                           * the name they are registered with in flecs. For
                           * example, C type "Position" might be registered
                           * as "flecs.components.transform.Position", with the
                           * symbol set to "Position". */
	use_low_id: bool, /**< When set to true, a low id (typically reserved for
                           * components) will be used to create the entity, if
                           * no id is specified. */

	/** 0-terminated array of ids to add to the entity. */
	add:        ^id_t,

	/** 0-terminated array of values to set on the entity. */
	set:        ^value_t,

	/** String expression with components to add */
	add_expr:   cstring,
}

/** Used with ecs_bulk_init().
*
* @ingroup entities
*/
bulk_desc_t :: struct {
	_canary:  i32, /**< Used for validity testing. Must be 0. */
	entities: ^entity_t, /**< Entities to bulk insert. Entity ids provided by
                             * the application must be empty (cannot
                             * have components). If no entity ids are provided, the
                             * operation will create 'count' new entities. */
	count:    i32, /**< Number of entities to create/populate */
	ids:      [32]id_t, /**< Ids to create the entities with */
	data:     ^rawptr, /**< Array with component data to insert. Each element in
                        * the array must correspond with an element in the ids
                        * array. If an element in the ids array is a tag, the
                        * data array must contain a NULL. An element may be
                        * set to NULL for a component, in which case the
                        * component will not be set by the operation. */
	table:    ^table_t, /**< Table to insert the entities into. Should not be set
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
	entity:  entity_t,

	/** Parameters for type (size, hooks, ...) */
	type:    type_info_t,
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
	world:             ^world_t,
	/**< The world. Can point to stage when in deferred/readonly mode. */
	real_world:        ^world_t,
	/**< Actual world. Never points to a stage. */
	offset:            i32,
	/**< Offset relative to current table */
	count:             i32,
	/**< Number of entities to iterate */
	entities:          [^]entity_t,
	/**< Entity identifiers */
	ptrs:              ^rawptr,
	/**< Component pointers. If not set or if it's NULL for a field, use it.trs. */
	trs:               ^^table_record_t,
	/**< Info on where to find field in table */
	sizes:             ^size_t,
	/**< Component sizes */
	table:             ^table_t,
	/**< Current table */
	other_table:       ^table_t,
	/**< Prev or next table when adding/removing */
	ids:               [^]id_t,
	/**< (Component) ids */
	sources:           ^entity_t,
	/**< Entity on which the id was matched (0 if same as entities) */
	constrained_vars:  flags64_t,
	/**< Bitset that marks constrained variables */
	set_fields:        flags32_t,
	/**< Fields that are set */
	ref_fields:        flags32_t,
	/**< Bitset with fields that aren't component arrays */
	row_fields:        flags32_t,
	/**< Fields that must be obtained with field_at */
	up_fields:         flags32_t,
	/**< Bitset with fields matched through up traversal */
	system:            entity_t,
	/**< The system (if applicable) */
	event:             entity_t,
	/**< The event (if applicable) */
	event_id:          id_t,
	/**< The (component) id for the event */
	event_cur:         i32,
	/**< Unique event id. Used to dedup observer calls */
	field_count:       i8,
	/**< Number of fields in iterator */
	term_index:        i8,
	/**< Index of term that emitted an event.
                                   * This field will be set to the 'index' field
                                   * of an observer term. */
	query:             ^query_t,
	/**< Query being evaluated */
	param:             rawptr,
	/**< Param passed to ecs_run */
	ctx:               rawptr,
	/**< System context */
	binding_ctx:       rawptr,
	/**< System binding context */
	callback_ctx:      rawptr,
	/**< Callback language binding context */
	run_ctx:           rawptr,
	/**< Run language binding context */
	delta_time:        f32,
	/**< Time elapsed since last frame */
	delta_system_time: f32,
	/**< Time elapsed since last system invocation */
	frame_offset:      i32,
	/**< Offset relative to start of iteration */
	flags:             flags32_t,
	/**< Iterator flags */
	interrupted_by:    entity_t,
	/**< When set, system execution is interrupted */
	priv_:             iter_private_t,
	/**< Private data */
	next:              iter_next_action_t,
	/**< Function to progress iterator */
	callback:          iter_action_t,
	/**< Callback of system or observer */
	fini:              iter_fini_action_t,
	/**< Function to cleanup iterator resources */
	chain_it:          ^iter_t,
	/**< Optional, allows for creating iterator chains */
}

/** Query must match prefabs.
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * \ingroup queries
 */
QueryMatchPrefab :: 1 << 1

/** Query must match disabled entities.
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * \ingroup queries
 */
QueryMatchDisabled :: 1 << 2

/** Query must match empty tables.
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * \ingroup queries
 */
QueryMatchEmptyTables :: 1 << 3

/** Query may have unresolved entity identifiers.
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * \ingroup queries
 */
QueryAllowUnresolvedByName :: 1 << 6

/** Query only returns whole tables (ignores toggle/member fields).
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * \ingroup queries
 */
QueryTableOnly :: 1 << 7

/** Enable change detection for query.
 * Can be combined with other query flags on the ecs_query_desc_t::flags field.
 * 
 * Adding this flag makes it possible to use ecs_query_changed() and 
 * ecs_iter_changed() with the query. Change detection requires the query to be
 * cached. If cache_kind is left to the default value, this flag will cause it
 * to default to QueryCacheAuto.
 * 
 * \ingroup queries
 */
QueryDetectChanges :: 1 << 8

/** Used with ecs_query_init().
*
* \ingroup queries
*/
query_desc_t :: struct {
	/** Used for validity testing. Must be 0. */
	_canary:                 i32,

	/** Query terms */
	terms:                   [FLECS_TERM_COUNT_MAX]term_t,

	/** Query DSL expression (optional) */
	expr:                    cstring,

	/** Caching policy of query */
	cache_kind:              query_cache_kind_t,

	/** Flags for enabling query features */
	flags:                   flags32_t,

	/** Callback used for ordering query results. If order_by_id is 0, the
	* pointer provided to the callback will be NULL. If the callback is not
	* set, results will not be ordered. */
	order_by_callback:       order_by_action_t,

	/** Callback used for ordering query results. Same as order_by_callback,
	* but more efficient. */
	order_by_table_callback: sort_table_action_t,

	/** Component to sort on, used together with order_by_callback or
	* order_by_table_callback. */
	order_by:                entity_t,

	/** Component id to be used for grouping. Used together with the
	* group_by_callback. */
	group_by:                id_t,

	/** Callback used for grouping results. If the callback is not set, results
	* will not be grouped. When set, this callback will be used to calculate a
	* "rank" for each entity (table) based on its components. This rank is then
	* used to sort entities (tables), so that entities (tables) of the same
	* rank are "grouped" together when iterated. */
	group_by_callback:       group_by_action_t,

	/** Callback that is invoked when a new group is created. The return value of
	* the callback is stored as context for a group. */
	on_group_create:         group_create_action_t,

	/** Callback that is invoked when an existing group is deleted. The return
	* value of the on_group_create callback is passed as context parameter. */
	on_group_delete:         group_delete_action_t,

	/** Context to pass to group_by */
	group_by_ctx:            rawptr,

	/** Function to free group_by_ctx */
	group_by_ctx_free:       ctx_free_t,

	/** User context to pass to callback */
	ctx:                     rawptr,

	/** Context to be used for language bindings */
	binding_ctx:             rawptr,

	/** Callback to free ctx */
	ctx_free:                ctx_free_t,

	/** Callback to free binding_ctx */
	binding_ctx_free:        ctx_free_t,

	/** Entity associated with query (optional) */
	entity:                  entity_t,
}

/** Used with ecs_observer_init().
*
* @ingroup observers
*/
observer_desc_t :: struct {
	/** Used for validity testing. Must be 0. */
	_canary:           i32,

	/** Existing entity to associate with observer (optional) */
	entity:            entity_t,

	/** Query for observer */
	query:             query_desc_t,

	/** Events to observe (OnAdd, OnRemove, OnSet) */
	events:            [8]entity_t,

	/** When observer is created, generate events from existing data. For example,
	* #OnAdd `Position` would match all existing instances of `Position`. */
	yield_existing:    bool,

	/** Callback to invoke on an event, invoked when the observer matches. */
	callback:          iter_action_t,

	/** Callback invoked on an event. When left to NULL the default runner
	* is used which matches the event with the observer's query, and calls
	* 'callback' when it matches.
	* A reason to override the run function is to improve performance, if there
	* are more efficient way to test whether an event matches the observer than
	* the general purpose query matcher. */
	run:               run_action_t,

	/** User context to pass to callback */
	ctx:               rawptr,

	/** Callback to free ctx */
	ctx_free:          ctx_free_t,

	/** Context associated with callback (for language bindings). */
	callback_ctx:      rawptr,

	/** Callback to free callback ctx. */
	callback_ctx_free: ctx_free_t,

	/** Context associated with run (for language bindings). */
	run_ctx:           rawptr,

	/** Callback to free run ctx. */
	run_ctx_free:      ctx_free_t,

	/** Observable with which to register the observer */
	observable:        poly_t,

	/** Optional shared last event id for multiple observers. Ensures only one
	* of the observers with the shared id gets triggered for an event */
	last_event_id:     ^i32,

	/** Used for internal purposes */
	term_index_:       i8,
	flags_:            flags32_t,
}

/** Used with ecs_emit().
*
* @ingroup observers
*/
event_desc_t :: struct {
	/** The event id. Only observers for the specified event will be notified */
	event:       entity_t,

	/** Component ids. Only observers with a matching component id will be
	* notified. Observers are guaranteed to get notified once, even if they
	* match more than one id. */
	ids:         ^type_t,

	/** The table for which to notify. */
	table:       ^table_t,

	/** Optional 2nd table to notify. This can be used to communicate the
	* previous or next table, in case an entity is moved between tables. */
	other_table: ^table_t,

	/** Limit notified entities to ones starting from offset (row) in table */
	offset:      i32,

	/** Limit number of notified entities to count. offset+count must be less
	* than the total number of entities in the table. If left to 0, it will be
	* automatically determined by doing `ecs_table_count(table) - offset`. */
	count:       i32,

	/** Single-entity alternative to setting table / offset / count */
	entity:      entity_t,

	/** Optional context.
	* The type of the param must be the event, where the event is a component.
	* When an event is enqueued, the value of param is coped to a temporary
	* storage of the event type. */
	param:       rawptr,

	/** Same as param, but with the guarantee that the value won't be modified.
	* When an event with a const parameter is enqueued, the value of the param
	* is copied to a temporary storage of the event type. */
	const_param: rawptr,

	/** Observable (usually the world) */
	observable:  poly_t,

	/** Event flags */
	flags:       flags32_t,
}

/** Type with information about the current Flecs build */
build_info_t :: struct {
	compiler:      cstring, /**< Compiler used to compile flecs */
	addons:        [^]cstring, /**< Addons included in build */
	version:       cstring, /**< Stringified version */
	version_major: i16, /**< Major flecs version */
	version_minor: i16, /**< Minor flecs version */
	version_patch: i16, /**< Patch flecs version */
	debug:         bool, /**< Is this a debug build */
	sanitize:      bool, /**< Is this a sanitize build */
	perf_trace:    bool, /**< Is this a perf tracing build */
}

/** Type that contains information about the world. */
world_info_t :: struct {
	last_component_id:          entity_t, /**< Last issued component entity id */
	min_id:                     entity_t, /**< First allowed entity id */
	max_id:                     entity_t, /**< Last allowed entity id */
	delta_time_raw:             f32, /**< Raw delta time (no time scaling) */
	delta_time:                 f32, /**< Time passed to or computed by ecs_progress() */
	time_scale:                 f32, /**< Time scale applied to delta_time */
	target_fps:                 f32, /**< Target fps */
	frame_time_total:           f32, /**< Total time spent processing a frame */
	system_time_total:          f32, /**< Total time spent in systems */
	emit_time_total:            f32, /**< Total time spent notifying observers */
	merge_time_total:           f32, /**< Total time spent in merges */
	rematch_time_total:         f32, /**< Time spent on query rematching */
	world_time_total:           f64, /**< Time elapsed in simulation */
	world_time_total_raw:       f64, /**< Time elapsed in simulation (no scaling) */
	frame_count_total:          i64, /**< Total number of frames */
	merge_count_total:          i64, /**< Total number of merges */
	eval_comp_monitors_total:   i64, /**< Total number of monitor evaluations */
	rematch_count_total:        i64, /**< Total number of rematches */
	id_create_total:            i64, /**< Total number of times a new id was created */
	id_delete_total:            i64, /**< Total number of times an id was deleted */
	table_create_total:         i64, /**< Total number of times a table was created */
	table_delete_total:         i64, /**< Total number of times a table was deleted */
	pipeline_build_count_total: i64, /**< Total number of pipeline builds */
	systems_ran_frame:          i64, /**< Total number of systems ran in last frame */
	observers_ran_frame:        i64, /**< Total number of times observer was invoked */
	tag_id_count:               i32, /**< Number of tag (no data) ids in the world */
	component_id_count:         i32, /**< Number of component (data) ids in the world */
	pair_id_count:              i32, /**< Number of pair ids in the world */
	table_count:                i32, /**< Number of tables */

	/* -- Command counts -- */
	cmd:                        struct {
		add_count:             i64, /**< Add commands processed */
		remove_count:          i64, /**< Remove commands processed */
		delete_count:          i64, /**< Selete commands processed */
		clear_count:           i64, /**< Clear commands processed */
		set_count:             i64, /**< Set commands processed */
		ensure_count:          i64, /**< Ensure/emplace commands processed */
		modified_count:        i64, /**< Modified commands processed */
		discard_count:         i64, /**< Commands discarded, happens when entity is no longer alive when running the command */
		event_count:           i64, /**< Enqueued custom events */
		other_count:           i64, /**< Other commands processed */
		batched_entity_count:  i64, /**< Entities for which commands were batched */
		batched_command_count: i64, /**< Commands batched */
	},
	name_prefix:                cstring, /**< Value set by ecs_set_name_prefix(). Used
                                       * to remove library prefixes of symbol
                                       * names (such as ``, `ecs_`) when
                                       * registering them as names. */
}

/** Type that contains information about a query group. */
query_group_info_t :: struct {
	id:          u64,
	match_count: i32, /**< How often tables have been matched/unmatched */
	table_count: i32, /**< Number of tables in group */
	ctx:         rawptr, /**< Group context, returned by on_group_create */
}

/** A (string) identifier. Used as pair with #Name and #Symbol tags */
Identifier :: struct {
	value:      cstring, /**< Identifier string */
	length:     size_t, /**< Length of identifier */
	hash:       u64, /**< Hash of current value */
	index_hash: u64, /**< Hash of existing record in current index */
	index:      ^hashmap_t, /**< Current index */
}

/** Component information. */
Component :: struct {
	size:      size_t, /**< Component size */
	alignment: size_t, /**< Component alignment */
}

/** Component for storing a poly object */
Poly :: struct {
	poly: poly_t, /**< Pointer to poly object */
}

/** When added to an entity this informs serialization formats which component
* to use when a value is assigned to an entity without specifying the
* component. This is intended as a hint, serialization formats are not required
* to use it. Adding this component does not change the behavior of core ECS
* operations. */
DefaultChildComponent :: struct {
	component: id_t, /**< Default component id. */
}

/** Shortcut as Variable is typically used as source for singleton terms */
// Singleton :: Variable

/** Value used to quickly check if component is builtin. This is used to quickly
 * filter out tables with builtin components (for example for ecs_delete()) */
// LastInternalComponentId :: FLECS_ID##Poly##ID_

/** The first user-defined component starts from this id. Ids up to this number
 * are reserved for builtin components */
FirstUserComponentId :: 8

/** The first user-defined entity starts from this id. Ids up to this number
 * are reserved for builtin entities */
FirstUserEntityId :: FLECS_HI_COMPONENT_ID + 128

/** Type returned by ecs_get_entities(). */
entities_t :: struct {
	ids:         ^entity_t, /**< Array with all entity ids in the world. */
	count:       i32, /**< Total number of entity ids. */
	alive_count: i32, /**< Number of alive entity ids. */
}

/** Used with ecs_delete_empty_tables(). */
delete_empty_tables_desc_t :: struct {
	/** Free table data when generation > clear_generation. */
	clear_generation:    u16,

	/** Delete table when generation > delete_generation. */
	delete_generation:   u16,

	/** Amount of time operation is allowed to spend. */
	time_budget_seconds: f64,
}

/** Struct returned by ecs_query_count(). */
query_count_t :: struct {
	results:  i32, /**< Number of results returned by query. */
	entities: i32, /**< Number of entities returned by query. */
	tables:   i32, /**< Number of tables returned by query. Only set for
                             * queries for which the table count can be reliably
                             * determined. */
}

/** Forward declare an entity. */
// ENTITY_DECLARE :: ECS_DECLARE

/** Forward declare a tag. */
// TAG_DECLARE :: ECS_DECLARE

/** Forward declare a prefab. */
// PREFAB_DECLARE :: ECS_DECLARE

/* Default debug tracing is at level 1 */
// ecs_dbg :: dbg_1

// ecs_dummy_check :: if ((false)) { goto error; }

////////////////////////////////////////////////////////////////////////////////
//// Error codes
////////////////////////////////////////////////////////////////////////////////
INVALID_OPERATION :: 1
INVALID_PARAMETER :: 2
CONSTRAINT_VIOLATED :: 3
OUT_OF_MEMORY :: 4
OUT_OF_RANGE :: 5
UNSUPPORTED :: 6
INTERNAL_ERROR :: 7
ALREADY_DEFINED :: 8
MISSING_OS_API :: 9
OPERATION_FAILED :: 10
INVALID_CONVERSION :: 11
ID_IN_USE :: 12
CYCLE_DETECTED :: 13
LEAK_DETECTED :: 14
DOUBLE_FREE :: 15

INCONSISTENT_NAME :: 20
NAME_IN_USE :: 21
NOT_A_COMPONENT :: 22
INVALID_COMPONENT_SIZE :: 23
INVALID_COMPONENT_ALIGNMENT :: 24
COMPONENT_NOT_REGISTERED :: 25
INCONSISTENT_COMPONENT_ID :: 26
INCONSISTENT_COMPONENT_ACTION :: 27
MODULE_UNDEFINED :: 28
MISSING_SYMBOL :: 29
ALREADY_IN_USE :: 30

ACCESS_VIOLATION :: 40
COLUMN_INDEX_OUT_OF_RANGE :: 41
COLUMN_IS_NOT_SHARED :: 42
COLUMN_IS_SHARED :: 43
COLUMN_TYPE_MISMATCH :: 45

INVALID_WHILE_READONLY :: 70
LOCKED_STORAGE :: 71
INVALID_FROM_WORKER :: 72

////////////////////////////////////////////////////////////////////////////////
//// Used when logging with colors is enabled
////////////////////////////////////////////////////////////////////////////////
BLACK :: "\033[1;30m"
RED :: "\033[0;31m"
GREEN :: "\033[0;32m"
YELLOW :: "\033[0;33m"
BLUE :: "\033[0;34m"
MAGENTA :: "\033[0;35m"
CYAN :: "\033[0;36m"
WHITE :: "\033[1;37m"
GREY :: "\033[0;37m"
NORMAL :: "\033[0;49m"
BOLD :: "\033[1;49m"

/** Callback type for init action. */
app_init_action_t :: proc "c" (_: ^world_t) -> c.int

/** Used with ecs_app_run(). */
app_desc_t :: struct {
	target_fps:   f32, /**< Target FPS. */
	delta_time:   f32, /**< Frame time increment (0 for measured values) */
	threads:      i32, /**< Number of threads. */
	frames:       i32, /**< Number of frames to run (0 for infinite) */
	enable_rest:  bool, /**< Enables ECS access over HTTP, necessary for explorer */
	enable_stats: bool, /**< Periodically collect statistics */
	port:         u16, /**< HTTP port used by REST API */
	init:         app_init_action_t, /**< If set, function is ran before starting the
                                 * main loop. */
	ctx:          rawptr, /**< Reserved for custom run/frame actions */
}

/** Callback type for run action. */
app_run_action_t :: proc "c" (_: ^world_t, _: ^app_desc_t) -> c.int

/** Callback type for frame action. */
app_frame_action_t :: proc "c" (_: ^world_t, _: ^app_desc_t) -> c.int

/** Maximum number of headers in request. */
HTTP_HEADER_COUNT_MAX :: 32

/** Maximum number of query parameters in request. */
HTTP_QUERY_PARAM_COUNT_MAX :: 32

http_server_t :: struct {}

/** A connection manages communication with the remote host. */
http_connection_t :: struct {
	id:     u64,
	server: ^http_server_t,
	host:   [128]c.char,
	port:   [16]c.char,
}

/** Helper type used for headers & URL query parameters. */
http_key_value_t :: struct {
	key:   cstring,
	value: cstring,
}

/** Supported request methods. */
http_method_t :: enum c.int {
	Get,
	Post,
	Put,
	Delete,
	Options,
	MethodUnsupported,
}

/** An HTTP request. */
http_request_t :: struct {
	id:           u64,
	method:       http_method_t,
	path:         cstring,
	body:         cstring,
	headers:      [32]http_key_value_t,
	params:       [32]http_key_value_t,
	header_count: i32,
	param_count:  i32,
	conn:         ^http_connection_t,
}

/** An HTTP reply. */
http_reply_t :: struct {
	code:         c.int, /**< default = 200 */
	body:         strbuf_t, /**< default = "" */
	status:       cstring, /**< default = OK */
	content_type: cstring, /**< default = application/json */
	headers:      strbuf_t, /**< default = "" */
}

// HTTP_REPLY_INIT :: (ecs_http_reply_t){200, ECS_STRBUF_INIT, "OK", "application/json", ECS_STRBUF_INIT}

/** Request callback.
* Invoked for each valid request. The function should populate the reply and
* return true. When the function returns false, the server will reply with a
* 404 (Not found) code. */
http_reply_action_t :: proc "c" (_: ^http_request_t, _: ^http_reply_t, _: rawptr) -> bool

/** Used with ecs_http_server_init(). */
http_server_desc_t :: struct {
	callback:            http_reply_action_t, /**< Function called for each request  */
	ctx:                 rawptr, /**< Passed to callback (optional) */
	port:                u16, /**< HTTP port */
	ipaddr:              cstring, /**< Interface to listen on (optional) */
	send_queue_wait_ms:  i32, /**< Send queue wait time when empty */
	cache_timeout:       f64, /**< Cache invalidation timeout (0 disables caching) */
	cache_purge_timeout: f64, /**< Cache purge timeout (for purging cache entries) */
}

REST_DEFAULT_PORT :: 27750

/** Component that creates a REST API server when instantiated. */
Rest :: struct {
	port:   u16, /**< Port of server (optional, default = 27750) */
	ipaddr: cstring, /**< Interface address (optional, default = 0.0.0.0) */
	impl:   rawptr,
}

/** Component used for one shot/interval timer functionality */
Timer :: struct {
	timeout:     f32, /**< Timer timeout period */
	time:        f32, /**< Incrementing time value */
	overshoot:   f32, /**< Used to correct returned interval time */
	fired_count: i32, /**< Number of times ticked */
	active:      bool, /**< Is the timer active or not */
	single_shot: bool, /**< Is this a single shot timer */
}

/** Apply a rate filter to a tick source */
RateFilter :: struct {
	src:          entity_t, /**< Source of the rate filter */
	rate:         i32, /**< Rate of the rate filter */
	tick_count:   i32, /**< Number of times the rate filter ticked */
	time_elapsed: f32, /**< Time elapsed since last tick */
}

/** Pipeline descriptor, used with ecs_pipeline_init(). */
pipeline_desc_t :: struct {
	/** Existing entity to associate with pipeline (optional). */
	entity: entity_t,

	/** The pipeline query.
	* Pipelines are queries that are matched with system entities. Pipeline
	* queries are the same as regular queries, which means the same query rules
	* apply. A common mistake is to try a pipeline that matches systems in a
	* list of phases by specifying all the phases, like:
	*   OnUpdate, OnPhysics, OnRender
	*
	* That however creates a query that matches entities with OnUpdate _and_
	* OnPhysics _and_ OnRender tags, which is likely undesired. Instead, a
	* query could use the or operator match a system that has one of the
	* specified phases:
	*   OnUpdate || OnPhysics || OnRender
	*
	* This will return the correct set of systems, but they likely won't be in
	* the correct order. To make sure systems are returned in the correct order
	* two query ordering features can be used:
	* - group_by
	* - order_by
	*
	* Take a look at the system manual for a more detailed explanation of
	* how query features can be applied to pipelines, and how the builtin
	* pipeline query works.
	*/
	query:  query_desc_t,
}

/** Component used to provide a tick source to systems */
TickSource :: struct {
	tick:         bool, /**< True if providing tick */
	time_elapsed: f32, /**< Time elapsed since last tick */
}

/** Use with ecs_system_init() to create or update a system. */
system_desc_t :: struct {
	_canary:           i32,

	/** Existing entity to associate with system (optional) */
	entity:            entity_t,

	/** System query parameters */
	query:             query_desc_t,

	/** Callback that is ran for each result returned by the system's query. This
	* means that this callback can be invoked multiple times per system per
	* frame, typically once for each matching table. */
	callback:          iter_action_t,

	/** Callback that is invoked when a system is ran.
	* When left to NULL, the default system runner is used, which calls the
	* "callback" action for each result returned from the system's query.
	*
	* It should not be assumed that the input iterator can always be iterated
	* with ecs_query_next(). When a system is multithreaded and/or paged, the
	* iterator can be either a worker or paged iterator. The correct function
	* to use for iteration is ecs_iter_next().
	*
	* An implementation can test whether the iterator is a query iterator by
	* testing whether the it->next value is equal to ecs_query_next(). */
	run:               run_action_t,

	/** Context to be passed to callback (as ecs_iter_t::param) */
	ctx:               rawptr,

	/** Callback to free ctx. */
	ctx_free:          ctx_free_t,

	/** Context associated with callback (for language bindings). */
	callback_ctx:      rawptr,

	/** Callback to free callback ctx. */
	callback_ctx_free: ctx_free_t,

	/** Context associated with run (for language bindings). */
	run_ctx:           rawptr,

	/** Callback to free run ctx. */
	run_ctx_free:      ctx_free_t,

	/** Interval in seconds at which the system should run */
	interval:          f32,

	/** Rate at which the system should run */
	rate:              i32,

	/** External tick source that determines when system ticks */
	tick_source:       entity_t,

	/** If true, system will be ran on multiple threads */
	multi_threaded:    bool,

	/** If true, system will have access to the actual world. Cannot be true at the
	* same time as multi_threaded. */
	immediate:         bool,
}

/** System type, get with ecs_system_get() */
system_t :: struct {
	hdr:               header_t,

	/** See ecs_system_desc_t */
	run:               run_action_t,

	/** See ecs_system_desc_t */
	action:            iter_action_t,

	/** System query */
	query:             ^query_t,

	/** Tick source associated with system */
	tick_source:       entity_t,

	/** Is system multithreaded */
	multi_threaded:    bool,

	/** Is system ran in immediate mode */
	immediate:         bool,

	/** Cached system name (for perf tracing) */
	name:              cstring,

	/** Userdata for system */
	ctx:               rawptr,

	/** Callback language binding context */
	callback_ctx:      rawptr,

	/** Run language binding context */
	run_ctx:           rawptr,

	/** Callback to free ctx. */
	ctx_free:          ctx_free_t,

	/** Callback to free callback ctx. */
	callback_ctx_free: ctx_free_t,

	/** Callback to free run ctx. */
	run_ctx_free:      ctx_free_t,

	/** Time spent on running system */
	time_spent:        f32,

	/** Time passed since last invocation */
	time_passed:       f32,

	/** Last frame for which the system was considered */
	last_frame:        i64,

	/* Mixins */
	dtor:              flecs_poly_dtor_t,
}

STAT_WINDOW :: 60

/** Simple value that indicates current state */
gauge_t :: struct {
	avg: [60]f32,
	min: [60]f32,
	max: [60]f32,
}

/** Monotonically increasing counter */
counter_t :: struct {
	rate:  gauge_t, /**< Keep track of deltas too */
	value: [60]f64,
}

/** Make all metrics the same size, so we can iterate over fields */
metric_t :: struct #raw_union {
	gauge:   gauge_t,
	counter: counter_t,
}

world_stats_t :: struct {
	first_:      i64,

	/* Entities */
	entities:    struct {
		count:           metric_t, /**< Number of entities */
		not_alive_count: metric_t, /**< Number of not alive (recyclable) entity ids */
	},

	/* Component ids */
	components:  struct {
		tag_count:       metric_t, /**< Number of tag ids (ids without data) */
		component_count: metric_t, /**< Number of components ids (ids with data) */
		pair_count:      metric_t, /**< Number of pair ids */
		type_count:      metric_t, /**< Number of registered types */
		create_count:    metric_t, /**< Number of times id has been created */
		delete_count:    metric_t, /**< Number of times id has been deleted */
	},

	/* Tables */
	tables:      struct {
		count:        metric_t, /**< Number of tables */
		empty_count:  metric_t, /**< Number of empty tables */
		create_count: metric_t, /**< Number of times table has been created */
		delete_count: metric_t, /**< Number of times table has been deleted */
	},

	/* Queries & events */
	queries:     struct {
		query_count:    metric_t, /**< Number of queries */
		observer_count: metric_t, /**< Number of observers */
		system_count:   metric_t, /**< Number of systems */
	},

	/* Commands */
	commands:    struct {
		add_count:            metric_t,
		remove_count:         metric_t,
		delete_count:         metric_t,
		clear_count:          metric_t,
		set_count:            metric_t,
		ensure_count:         metric_t,
		modified_count:       metric_t,
		other_count:          metric_t,
		discard_count:        metric_t,
		batched_entity_count: metric_t,
		batched_count:        metric_t,
	},

	/* Frame data */
	frame:       struct {
		frame_count:          metric_t, /**< Number of frames processed. */
		merge_count:          metric_t, /**< Number of merges executed. */
		rematch_count:        metric_t, /**< Number of query rematches */
		pipeline_build_count: metric_t, /**< Number of system pipeline rebuilds (occurs when an inactive system becomes active). */
		systems_ran:          metric_t, /**< Number of systems ran. */
		observers_ran:        metric_t, /**< Number of times an observer was invoked. */
		event_emit_count:     metric_t, /**< Number of events emitted */
	},

	/* Timing */
	performance: struct {
		world_time_raw: metric_t,
		/**< Actual time passed since simulation start (first time progress() is called) */
		world_time:     metric_t,
		/**< Simulation time passed since simulation start. Takes into account time scaling */
		frame_time:     metric_t,
		/**< Time spent processing a frame. Smaller than world_time_total when load is not 100% */
		system_time:    metric_t,
		/**< Time spent on running systems. */
		emit_time:      metric_t,
		/**< Time spent on notifying observers. */
		merge_time:     metric_t,
		/**< Time spent on merging commands. */
		rematch_time:   metric_t,
		/**< Time spent on rematching. */
		fps:            metric_t,
		/**< Frames per second. */
		delta_time:     metric_t,
		/**< Delta_time. */
	},
	memory:      struct {
		alloc_count:                   metric_t, /**< Allocs per frame */
		realloc_count:                 metric_t, /**< Reallocs per frame */
		free_count:                    metric_t, /**< Frees per frame */
		outstanding_alloc_count:       metric_t, /**< Difference between allocs & frees */
		block_alloc_count:             metric_t, /**< Block allocations per frame */
		block_free_count:              metric_t, /**< Block frees per frame */
		block_outstanding_alloc_count: metric_t, /**< Difference between allocs & frees */
		stack_alloc_count:             metric_t, /**< Page allocations per frame */
		stack_free_count:              metric_t, /**< Page frees per frame */
		stack_outstanding_alloc_count: metric_t, /**< Difference between allocs & frees */
	},

	/* HTTP statistics */
	http:        struct {
		request_received_count:      metric_t,
		request_invalid_count:       metric_t,
		request_handled_ok_count:    metric_t,
		request_handled_error_count: metric_t,
		request_not_handled_count:   metric_t,
		request_preflight_count:     metric_t,
		send_ok_count:               metric_t,
		send_error_count:            metric_t,
		busy_count:                  metric_t,
	},
	last_:       i64,

	/** Current position in ring buffer */
	t:           i32,
}

/** Statistics for a single query (use ecs_query_cache_stats_get) */
query_stats_t :: struct {
	first_:               i64,
	result_count:         metric_t, /**< Number of query results */
	matched_table_count:  metric_t, /**< Number of matched tables */
	matched_entity_count: metric_t, /**< Number of matched entities */
	last_:                i64,

	/** Current position in ringbuffer */
	t:                    i32,
}

/** Statistics for a single system (use ecs_system_stats_get()) */
system_stats_t :: struct {
	first_:     i64,
	time_spent: metric_t, /**< Time spent processing a system */
	last_:      i64,
	task:       bool, /**< Is system a task */
	query:      query_stats_t,
}

/** Statistics for sync point */
sync_stats_t :: struct {
	first_:            i64,
	time_spent:        metric_t,
	commands_enqueued: metric_t,
	last_:             i64,
	system_count:      i32,
	multi_threaded:    bool,
	immediate:         bool,
}

/** Statistics for all systems in a pipeline. */
pipeline_stats_t :: struct {
	/* Allow for initializing struct with {0} */
	canary_:             i8,

	/** Vector with system ids of all systems in the pipeline. The systems are
	* stored in the order they are executed. Merges are represented by a 0. */
	systems:             vec_t,

	/** Vector with sync point stats */
	sync_points:         vec_t,

	/** Current position in ring buffer */
	t:                   i32,
	system_count:        i32, /**< Number of systems in pipeline */
	active_system_count: i32, /**< Number of active systems in pipeline */
	rebuild_count:       i32, /**< Number of times pipeline has rebuilt */
}

/** Common data for statistics. */
StatsHeader :: struct {
	elapsed:      f32,
	reduce_count: i32,
}

/** Component that stores world statistics. */
WorldStats :: struct {
	hdr:   StatsHeader,
	stats: world_stats_t,
}

/** Component that stores system statistics. */
SystemStats :: struct {
	hdr:   StatsHeader,
	stats: map_t,
}

/** Component that stores pipeline statistics. */
PipelineStats :: struct {
	hdr:   StatsHeader,
	stats: map_t,
}

/** Component that stores a summary of world statistics. */
WorldSummary :: struct {
	target_fps:        f64, /**< Target FPS */
	time_scale:        f64, /**< Simulation time scale */
	frame_time_total:  f64, /**< Total time spent processing a frame */
	system_time_total: f64, /**< Total time spent in systems */
	merge_time_total:  f64, /**< Total time spent in merges */
	frame_time_last:   f64, /**< Time spent processing a frame */
	system_time_last:  f64, /**< Time spent in systems */
	merge_time_last:   f64, /**< Time spent in merges */
	frame_count:       i64, /**< Number of frames processed */
	command_count:     i64, /**< Number of commands processed */
	build_info:        build_info_t, /**< Build info */
}

/** Component that stores metric value. */
MetricValue :: struct {
	value: f64,
}

/** Component that stores metric source. */
MetricSource :: struct {
	entity: entity_t,
}

/** Used with ecs_metric_init to create metric. */
metric_desc_t :: struct {
	_canary:   i32,

	/** Entity associated with metric */
	entity:    entity_t,

	/** Entity associated with member that stores metric value. Must not be set
	* at the same time as id. Cannot be combined with CounterId. */
	member:    entity_t,

	/* Member dot expression. Can be used instead of member and supports nested
	* members. Must be set together with id and should not be set at the same
	* time as member. */
	dotmember: cstring,

	/** Tracks whether entities have the specified component id. Must not be set
	* at the same time as member. */
	id:        id_t,

	/** If id is a (R, *) wildcard and relationship R has the OneOf property,
	* setting this value to true will track individual targets.
	* If the kind is CountId and the id is a (R, *) wildcard, this value
	* will create a metric per target. */
	targets:   bool,

	/** Must be Gauge, Counter, CounterIncrement or CounterId */
	kind:      entity_t,

	/** Description of metric. Will only be set if FLECS_DOC addon is enabled */
	brief:     cstring,
}

ALERT_MAX_SEVERITY_FILTERS :: 4

/** Component added to alert instance. */
AlertInstance :: struct {
	message: cstring, /**< Generated alert message */
}

/** Map with active alerts for entity. */
AlertsActive :: struct {
	info_count:    i32, /**< Number of alerts for source with info severity */
	warning_count: i32, /**< Number of alerts for source with warning severity */
	error_count:   i32, /**< Number of alerts for source with error severity */
	alerts:        map_t,
}

/** Alert severity filter.
* A severity filter can adjust the severity of an alert based on whether an
* entity in the alert query has a specific component. For example, a filter
* could check if an entity has the "Production" tag, and increase the default
* severity of an alert from Warning to Error.
*/
alert_severity_filter_t :: struct {
	severity:   entity_t, /* Severity kind */
	with:       id_t, /* Component to match */
	var:        cstring, /* Variable to match component on. Do not include the
                            * '$' character. Leave to NULL for $this. */
	_var_index: i32, /* Index of variable in filter (do not set) */
}

/** Alert descriptor, used with ecs_alert_init(). */
alert_desc_t :: struct {
	_canary:          i32,

	/** Entity associated with alert */
	entity:           entity_t,

	/** Alert query. An alert will be created for each entity that matches the
	* specified query. The query must have at least one term that uses the
	* $this variable (default). */
	query:            query_desc_t,

	/** Template for alert message. This string is used to generate the alert
	* message and may refer to variables in the query result. The format for
	* the template expressions is as specified by ecs_script_string_interpolate().
	*
	* Examples:
	*
	*     "$this has Position but not Velocity"
	*     "$this has a parent entity $parent without Position"
	*/
	message:          cstring,

	/** User friendly name. Will only be set if FLECS_DOC addon is enabled. */
	doc_name:         cstring,

	/** Description of alert. Will only be set if FLECS_DOC addon is enabled */
	brief:            cstring,

	/** Metric kind. Must be AlertInfo, AlertWarning, AlertError or
	* AlertCritical. Defaults to AlertError. */
	severity:         entity_t,

	/** Severity filters can be used to assign different severities to the same
	* alert. This prevents having to create multiple alerts, and allows
	* entities to transition between severities without resetting the
	* alert duration (optional). */
	severity_filters: [4]alert_severity_filter_t,

	/** The retain period specifies how long an alert must be inactive before it
	* is cleared. This makes it easier to track noisy alerts. While an alert is
	* inactive its duration won't increase.
	* When the retain period is 0, the alert will clear immediately after it no
	* longer matches the alert query. */
	retain_period:    f32,

	/** Alert when member value is out of range. Uses the warning/error ranges
	* assigned to the member in the MemberRanges component (optional). */
	member:           entity_t,

	/** (Component) id of member to monitor. If left to 0 this will be set to
	* the parent entity of the member (optional). */
	id:               id_t,

	/** Variable from which to fetch the member (optional). When left to NULL
	* 'id' will be obtained from $this. */
	var:              cstring,
}

/** Used with ecs_ptr_from_json(), ecs_entity_from_json(). */
from_json_desc_t :: struct {
	name:          cstring, /**< Name of expression (used for logging) */
	expr:          cstring, /**< Full expression (used for logging) */

	/** Callback that allows for specifying a custom lookup function. The
	* default behavior uses ecs_lookup() */
	lookup_action: proc "c" (_: ^world_t, _: cstring, _: rawptr) -> entity_t,
	lookup_ctx:    rawptr,

	/** Require components to be registered with reflection data. When not
	* in strict mode, values for components without reflection are ignored. */
	strict:        bool,
}

/** Used with ecs_iter_to_json(). */
entity_to_json_desc_t :: struct {
	serialize_entity_id:  bool, /**< Serialize entity id */
	serialize_doc:        bool, /**< Serialize doc attributes */
	serialize_full_paths: bool, /**< Serialize full paths for tags, components and pairs */
	serialize_inherited:  bool, /**< Serialize base components */
	serialize_values:     bool, /**< Serialize component values */
	serialize_builtin:    bool, /**< Serialize builtin data as components (e.g. "name", "parent") */
	serialize_type_info:  bool, /**< Serialize type info (requires serialize_values) */
	serialize_alerts:     bool, /**< Serialize active alerts for entity */
	serialize_refs:       entity_t, /**< Serialize references (incoming edges) for relationship */
	serialize_matches:    bool, /**< Serialize which queries entity matches with */
}

ENTITY_TO_JSON_INIT :: (entity_to_json_desc_t) {
	serialize_entity_id  = false,
	serialize_doc        = false,
	serialize_full_paths = true,
	serialize_inherited  = false,
	serialize_values     = true,
	serialize_builtin    = false,
	serialize_type_info  = false,
	serialize_alerts     = false,
	serialize_refs       = 0,
	serialize_matches    = false,
}

/** Used with ecs_iter_to_json(). */
iter_to_json_desc_t :: struct {
	serialize_entity_ids:    bool, /**< Serialize entity ids */
	serialize_values:        bool, /**< Serialize component values */
	serialize_builtin:       bool, /**< Serialize builtin data as components (e.g. "name", "parent") */
	serialize_doc:           bool, /**< Serialize doc attributes */
	serialize_full_paths:    bool, /**< Serialize full paths for tags, components and pairs */
	serialize_fields:        bool, /**< Serialize field data */
	serialize_inherited:     bool, /**< Serialize inherited components */
	serialize_table:         bool, /**< Serialize entire table vs. matched components */
	serialize_type_info:     bool, /**< Serialize type information */
	serialize_field_info:    bool, /**< Serialize metadata for fields returned by query */
	serialize_query_info:    bool, /**< Serialize query terms */
	serialize_query_plan:    bool, /**< Serialize query plan */
	serialize_query_profile: bool, /**< Profile query performance */
	dont_serialize_results:  bool, /**< If true, query won't be evaluated */
	serialize_alerts:        bool, /**< Serialize active alerts for entity */
	serialize_refs:          entity_t, /**< Serialize references (incoming edges) for relationship */
	serialize_matches:       bool, /**< Serialize which queries entity matches with */
	query:                   poly_t, /**< Query object (required for serialize_query_[plan|profile]). */
}

ITER_TO_JSON_INIT :: (iter_to_json_desc_t) {
	serialize_entity_ids    = false,
	serialize_values        = true,
	serialize_builtin       = false,
	serialize_doc           = false,
	serialize_full_paths    = true,
	serialize_fields        = true,
	serialize_inherited     = false,
	serialize_table         = false,
	serialize_type_info     = false,
	serialize_field_info    = false,
	serialize_query_info    = false,
	serialize_query_plan    = false,
	serialize_query_profile = false,
	dont_serialize_results  = false,
	serialize_alerts        = false,
	serialize_refs          = 0,
	serialize_matches       = false,
	query                   = nil,
}

/** Used with ecs_iter_to_json(). */
world_to_json_desc_t :: struct {
	serialize_builtin: bool, /**< Exclude flecs modules & contents */
	serialize_modules: bool, /**< Exclude modules & contents */
}

FLECS_SCRIPT_FUNCTION_ARGS_MAX :: 16

script_template_t :: struct {}

/** Script variable. */
script_var_t :: struct {
	name:      cstring,
	value:     value_t,
	type_info: ^type_info_t,
	sp:        i32,
	is_const:  bool,
}

/** Script variable scope. */
script_vars_t :: struct {
	parent:    ^script_vars_t,
	sp:        i32,
	var_index: hashmap_t,
	vars:      vec_t,
	world:     ^world_t,
	stack:     ^stack_t,
	cursor:    ^stack_cursor_t,
	allocator: ^allocator_t,
}

/** Script object. */
script_t :: struct {
	world: ^world_t,
	name:  cstring,
	code:  cstring,
}

script_runtime_t :: struct {}

/** Script component.
* This component is added to the entities of managed scripts and templates.
*/
Script :: struct {
	script:    ^script_t,
	template_: ^script_template_t, /* Only set for template scripts */
}

/** Script function context. */
function_ctx_t :: struct {
	world:    ^world_t,
	function: entity_t,
	ctx:      rawptr,
}

/** Script function callback. */
function_callback_t :: proc "c" (_: ^function_ctx_t, _: i32, _: ^value_t, _: ^value_t)

/** Function argument type. */
script_parameter_t :: struct {
	name: cstring,
	type: entity_t,
}

/** Const component.
* This component describes a const variable that can be used from scripts.
*/
ScriptConstVar :: struct {
	value:     value_t,
	type_info: ^type_info_t,
}

/** Function component.
* This component describes a function that can be called from a script.
*/
ScriptFunction :: struct {
	return_type: entity_t,
	params:      vec_t, /* vec<ecs_script_parameter_t> */
	callback:    function_callback_t,
	ctx:         rawptr,
}

/** Method component.
* This component describes a method that can be called from a script. Methods
* are functions that can be called on instances of a type. A method entity is
* stored in the scope of the type it belongs to.
*/
ScriptMethod :: struct {
	return_type: entity_t,
	params:      vec_t, /* vec<ecs_script_parameter_t> */
	callback:    function_callback_t,
	ctx:         rawptr,
}

/** Used with ecs_script_parse() and ecs_script_eval() */
script_eval_desc_t :: struct {
	vars:    ^script_vars_t, /**< Variables used by script */
	runtime: ^script_runtime_t, /**< Reusable runtime (optional) */
}

/** Used with ecs_script_init() */
script_desc_t :: struct {
	entity:   entity_t, /* Set to customize entity handle associated with script */
	filename: cstring, /* Set to load script from file */
	code:     cstring, /* Set to parse script from string */
}

/** Used with ecs_expr_run(). */
expr_eval_desc_t :: struct {
	name:                             cstring, /**< Script name */
	expr:                             cstring, /**< Full expression string */
	vars:                             ^script_vars_t, /**< Variables accessible in expression */
	type:                             entity_t, /**< Type of parsed value (optional) */
	lookup_action:                    proc "c" (
		_: ^world_t,
		_: cstring,
		_: rawptr,
	) -> entity_t, /**< Function for resolving entity identifiers */
	lookup_ctx:                       rawptr, /**< Context passed to lookup function */

	/** Disable constant folding (slower evaluation, faster parsing) */
	disable_folding:                  bool,

	/** This option instructs the expression runtime to lookup variables by
	* stack pointer instead of by name, which improves performance. Only enable
	* when provided variables are always declared in the same order. */
	disable_dynamic_variable_binding: bool,

	/** Allow for unresolved identifiers when parsing. Useful when entities can
	* be created in between parsing & evaluating. */
	allow_unresolved_identifiers:     bool,
	runtime:                          ^script_runtime_t, /**< Reusable runtime (optional) */
}

/** Used with ecs_const_var_init */
const_var_desc_t :: struct {
	/* Variable name. */
	name:   cstring,

	/* Variable parent (namespace). */
	parent: entity_t,

	/* Variable type. */
	type:   entity_t,

	/* Pointer to value of variable. The value will be copied to an internal
	* storage and does not need to be kept alive. */
	value:  rawptr,
}

/** Used with ecs_function_init and ecs_method_init */
function_desc_t :: struct {
	/** Function name. */
	name:        cstring,

	/** Parent of function. For methods the parent is the type for which the
	* method will be registered. */
	parent:      entity_t,

	/** Function parameters. */
	params:      [16]script_parameter_t,

	/** Function return type. */
	return_type: entity_t,

	/** Function implementation. */
	callback:    function_callback_t,

	/** Context passed to function implementation. */
	ctx:         rawptr,
}

/** Component that stores description.
* Used as pair together with the following tags to store entity documentation:
* - Name
* - DocBrief
* - DocDetail
* - DocLink
* - DocColor
*/
DocDescription :: struct {
	value: cstring,
}

/** Max number of constants/members that can be specified in desc structs. */
MEMBER_DESC_CACHE_SIZE :: 32

/** Primitive type definitions.
* These typedefs allow the builtin primitives to be used as regular components:
*
* @code
* ecs_set(world, e, ecs_i32_t, {10});
* @endcode
*
* Or a more useful example (create an enum constant with a manual value):
*
* @code
* ecs_set_pair_second(world, e, Constant, ecs_i32_t, {10});
* @endcode
*/
bool_t :: bool

char_t :: c.char

byte_t :: c.uchar

u8_t :: u8

u16_t :: u16

u32_t :: u32

u64_t :: u64

uptr_t :: c.uintptr_t

i8_t :: i8

i16_t :: i16

i32_t :: i32

i64_t :: i64

iptr_t :: c.intptr_t

f32_t :: f32

f64_t :: f64

string_t :: cstring

/** Type kinds supported by meta addon */
type_kind_t :: enum c.int {
	PrimitiveType,
	BitmaskType,
	EnumType,
	StructType,
	ArrayType,
	VectorType,
	OpaqueType,
	TypeKindLast = 6,
}

/** Component that is automatically added to every type with the right kind. */
Type :: struct {
	kind:     type_kind_t, /**< Type kind. */
	existing: bool, /**< Did the type exist or is it populated from reflection */
	partial:  bool, /**< Is the reflection data a partial type description */
}

/** Primitive type kinds supported by meta addon */
primitive_kind_t :: enum c.int {
	Bool = 1,
	Char,
	Byte,
	U8,
	U16,
	U32,
	U64,
	I8,
	I16,
	I32,
	I64,
	F32,
	F64,
	UPtr,
	IPtr,
	String,
	Entity,
	Id,
	PrimitiveKindLast = 18,
}

/** Component added to primitive types */
Primitive :: struct {
	kind: primitive_kind_t, /**< Primitive type kind. */
}

/** Component added to member entities */
Member :: struct {
	type:       entity_t, /**< Member type. */
	count:      i32, /**< Number of elements (for inline arrays). */
	unit:       entity_t, /**< Member unit. */
	offset:     i32, /**< Member offset. */
	use_offset: bool, /**< If offset should be explicitly used. */
}

/** Type expressing a range for a member value */
member_value_range_t :: struct {
	min: f64, /**< Min member value. */
	max: f64, /**< Max member value. */
}

/** Component added to member entities to express valid value ranges */
MemberRanges :: struct {
	value:   member_value_range_t, /**< Member value range. */
	warning: member_value_range_t, /**< Member value warning range. */
	error:   member_value_range_t, /**< Member value error range. */
}

/** Element type of members vector in Struct */
member_t :: struct {
	/** Must be set when used with ecs_struct_desc_t */
	name:          cstring,

	/** Member type. */
	type:          entity_t,

	/** Element count (for inline arrays). May be set when used with ecs_struct_desc_t */
	count:         i32,

	/** May be set when used with ecs_struct_desc_t. Member offset. */
	offset:        i32,

	/** May be set when used with ecs_struct_desc_t, will be auto-populated if
	* type entity is also a unit */
	unit:          entity_t,

	/** Set to true to prevent automatic offset computation. This option should
	* be used when members are registered out of order or where calculation of
	* member offsets doesn't match C type offsets. */
	use_offset:    bool,

	/** Numerical range that specifies which values member can assume. This
	* range may be used by UI elements such as a progress bar or slider. The
	* value of a member should not exceed this range. */
	range:         member_value_range_t,

	/** Numerical range outside of which the value represents an error. This
	* range may be used by UI elements to style a value. */
	error_range:   member_value_range_t,

	/** Numerical range outside of which the value represents an warning. This
	* range may be used by UI elements to style a value. */
	warning_range: member_value_range_t,

	/** Should not be set by ecs_struct_desc_t */
	size:          size_t,

	/** Should not be set by ecs_struct_desc_t */
	member:        entity_t,
}

/** Component added to struct type entities */
Struct :: struct {
	members: vec_t, /* vector<ecs_member_t> */
}

/** Type that describes an enum constant */
enum_constant_t :: struct {
	/** Must be set when used with ecs_enum_desc_t */
	name:           cstring,

	/** May be set when used with ecs_enum_desc_t */
	value:          i64,

	/** For when the underlying type is unsigned */
	value_unsigned: u64,

	/** Should not be set by ecs_enum_desc_t */
	constant:       entity_t,
}

/** Component added to enum type entities */
Enum :: struct {
	underlying_type:   entity_t,
	constants:         map_t, /**< map<i32_t, ecs_enum_constant_t> */
	ordered_constants: vec_t, /**< vector<ecs_enum_constants_t> */
}

/** Type that describes an bitmask constant */
bitmask_constant_t :: struct {
	/** Must be set when used with ecs_bitmask_desc_t */
	name:     cstring,

	/** May be set when used with ecs_bitmask_desc_t */
	value:    flags64_t,

	/** Keep layout the same with ecs_enum_constant_t */
	_unused:  i64,

	/** Should not be set by ecs_bitmask_desc_t */
	constant: entity_t,
}

/** Component added to bitmask type entities */
Bitmask :: struct {
	constants:         map_t, /**< map<u32_t, ecs_bitmask_constant_t> */
	ordered_constants: vec_t, /**< vector<ecs_bitmask_constants_t>  */
}

/** Component added to array type entities */
Array :: struct {
	type:  entity_t, /**< Element type */
	count: i32, /**< Number of elements */
}

/** Component added to vector type entities */
Vector :: struct {
	type: entity_t, /**< Element type */
}

/** Serializer interface */
serializer_t :: struct {
	/* Serialize value */
	value:  proc "c" (_: ^serializer_t, _: entity_t, _: rawptr) -> c.int,

	/* Serialize member */
	member: proc "c" (_: ^serializer_t, _: cstring) -> c.int,
	world:  ^world_t, /**< The world. */
	ctx:    rawptr, /**< Serializer context. */
}

/** Callback invoked serializing an opaque type. */
meta_serialize_t :: proc "c" (_: ^serializer_t, _: rawptr) -> c.int

/** Callback invoked to serialize an opaque struct member */
meta_serialize_member_t :: proc "c" (_: ^serializer_t, _: rawptr, _: cstring) -> c.int

/** Callback invoked to serialize an opaque vector/array element */
meta_serialize_element_t :: proc "c" (_: ^serializer_t, _: rawptr, _: c.size_t) -> c.int

/** Opaque type reflection data.
* An opaque type is a type with an unknown layout that can be mapped to a type
* known to the reflection framework. See the opaque type reflection examples.
*/
Opaque :: struct {
	as_type:           entity_t, /**< Type that describes the serialized output */
	serialize:         meta_serialize_t, /**< Serialize action */
	serialize_member:  meta_serialize_member_t, /**< Serialize member action */
	serialize_element: meta_serialize_element_t, /**< Serialize element action */

	/** Assign bool value */
	assign_bool:       proc "c" (_: rawptr, _: bool),

	/** Assign char value */
	assign_char:       proc "c" (_: rawptr, _: c.char),

	/** Assign int value */
	assign_int:        proc "c" (_: rawptr, _: i64),

	/** Assign unsigned int value */
	assign_uint:       proc "c" (_: rawptr, _: u64),

	/** Assign float value */
	assign_float:      proc "c" (_: rawptr, _: f64),

	/** Assign string value */
	assign_string:     proc "c" (_: rawptr, _: cstring),

	/** Assign entity value */
	assign_entity:     proc "c" (_: rawptr, _: ^world_t, _: entity_t),

	/** Assign (component) id value */
	assign_id:         proc "c" (_: rawptr, _: ^world_t, _: id_t),

	/** Assign null value */
	assign_null:       proc "c" (_: rawptr),

	/** Clear collection elements */
	clear:             proc "c" (_: rawptr),

	/** Ensure & get collection element */
	ensure_element:    proc "c" (_: rawptr, _: c.size_t) -> rawptr,

	/** Ensure & get element */
	ensure_member:     proc "c" (_: rawptr, _: cstring) -> rawptr,

	/** Return number of elements */
	count:             proc "c" (_: rawptr) -> c.size_t,

	/** Resize to number of elements */
	resize:            proc "c" (_: rawptr, _: c.size_t),
}

/** Helper type to describe translation between two units. Note that this
* is not intended as a generic approach to unit conversions (e.g. from celsius
* to fahrenheit) but to translate between units that derive from the same base
* (e.g. meters to kilometers).
*
* Note that power is applied to the factor. When describing a translation of
* 1000, either use {factor = 1000, power = 1} or {factor = 1, power = 3}. */
unit_translation_t :: struct {
	factor: i32, /**< Factor to apply (e.g. "1000", "1000000", "1024") */
	power:  i32, /**< Power to apply to factor (e.g. "1", "3", "-9") */
}

/** Component that stores unit data. */
Unit :: struct {
	symbol:      cstring, /**< Unit symbol. */
	prefix:      entity_t, /**< Order of magnitude prefix relative to derived */
	base:        entity_t, /**< Base unit (e.g. "meters") */
	over:        entity_t, /**< Over unit (e.g. "per second") */
	translation: unit_translation_t, /**< Translation for derived unit */
}

/** Component that stores unit prefix data. */
UnitPrefix :: struct {
	symbol:      cstring, /**< Symbol of prefix (e.g. "K", "M", "Ki") */
	translation: unit_translation_t, /**< Translation of prefix */
}

/** Serializer instruction opcodes.
* The meta type serializer works by generating a flattened array with
* instructions that tells a serializer what kind of fields can be found in a
* type at which offsets.
*/
meta_type_op_kind_t :: enum c.int {
	OpArray,
	OpVector,
	OpOpaque,
	OpPush,
	OpPop,
	OpScope, /**< Marks last constant that can open/close a scope */
	OpEnum,
	OpBitmask,
	OpPrimitive, /**< Marks first constant that's a primitive */
	OpBool,
	OpChar,
	OpByte,
	OpU8,
	OpU16,
	OpU32,
	OpU64,
	OpI8,
	OpI16,
	OpI32,
	OpI64,
	OpF32,
	OpF64,
	OpUPtr,
	OpIPtr,
	OpString,
	OpEntity,
	OpId,
	MetaTypeOpKindLast = 26,
}

/** Meta type serializer instruction data. */
meta_type_op_t :: struct {
	kind:         meta_type_op_kind_t, /**< Instruction opcode. */
	offset:       size_t, /**< Offset of current field */
	count:        i32, /**< Number of elements (for inline arrays). */
	name:         cstring, /**< Name of value (only used for struct members) */
	op_count:     i32, /**< Number of operations until next field or end */
	size:         size_t, /**< Size of type of operation */
	type:         entity_t, /**< Type entity */
	member_index: i32, /**< Index of member in struct */
	members:      ^hashmap_t, /**< string -> member index (structs only) */
}

/** Component that stores the type serializer.
* Added to all types with reflection data.
*/
TypeSerializer :: struct {
	ops: vec_t, /**< vector<ecs_meta_type_op_t> */
}

/** Maximum level of type nesting. 
 * >32 levels of nesting is not sane.
 */
META_MAX_SCOPE_DEPTH :: 32

/** Type with information about currently serialized scope. */
meta_scope_t :: struct {
	type:            entity_t, /**< The type being iterated */
	ops:             ^meta_type_op_t, /**< The type operations (see ecs_meta_type_op_t) */
	op_count:        i32, /**< Number of operations in ops array to process */
	op_cur:          i32, /**< Current operation */
	elem_cur:        i32, /**< Current element (for collections) */
	prev_depth:      i32, /**< Depth to restore, in case dotmember was used */
	ptr:             rawptr, /**< Pointer to the value being iterated */
	comp:            ^Component, /**< Pointer to component, in case size/alignment is needed */
	opaque:          ^Opaque, /**< Opaque type interface */
	vector:          ^vec_t, /**< Current vector, in case a vector is iterated */
	members:         ^hashmap_t, /**< string -> member index */
	is_collection:   bool, /**< Is the scope iterating elements? */
	is_inline_array: bool, /**< Is the scope iterating an inline array? */
	is_empty_scope:  bool, /**< Was scope populated (for collections) */
}

/** Type that enables iterating/populating a value using reflection data. */
meta_cursor_t :: struct {
	world:              ^world_t, /**< The world. */
	scope:              [32]meta_scope_t, /**< Cursor scope stack. */
	depth:              i32, /**< Current scope depth. */
	valid:              bool, /**< Does the cursor point to a valid field. */
	is_primitive_scope: bool, /**< If in root scope, this allows for a push for primitive types */

	/** Custom entity lookup action for overriding default ecs_lookup */
	lookup_action:      proc "c" (_: ^world_t, _: cstring, _: rawptr) -> entity_t,
	lookup_ctx:         rawptr, /**< Context for lookup_action */
}

/** Used with ecs_primitive_init(). */
primitive_desc_t :: struct {
	entity: entity_t, /**< Existing entity to use for type (optional). */
	kind:   primitive_kind_t, /**< Primitive type kind. */
}

/** Used with ecs_enum_init(). */
enum_desc_t :: struct {
	entity:          entity_t, /**< Existing entity to use for type (optional). */
	constants:       [32]enum_constant_t, /**< Enum constants. */
	underlying_type: entity_t,
}

/** Used with ecs_bitmask_init(). */
bitmask_desc_t :: struct {
	entity:    entity_t, /**< Existing entity to use for type (optional). */
	constants: [32]bitmask_constant_t, /**< Bitmask constants. */
}

/** Used with ecs_array_init(). */
array_desc_t :: struct {
	entity: entity_t, /**< Existing entity to use for type (optional). */
	type:   entity_t, /**< Element type. */
	count:  i32, /**< Number of elements. */
}

/** Used with ecs_vector_init(). */
vector_desc_t :: struct {
	entity: entity_t, /**< Existing entity to use for type (optional). */
	type:   entity_t, /**< Element type. */
}

/** Used with ecs_struct_init(). */
struct_desc_t :: struct {
	entity:  entity_t, /**< Existing entity to use for type (optional). */
	members: [32]member_t, /**< Struct members. */
}

/** Used with ecs_opaque_init(). */
opaque_desc_t :: struct {
	entity: entity_t, /**< Existing entity to use for type (optional). */
	type:   Opaque, /**< Type that the opaque type maps to. */
}

/** Used with ecs_unit_init(). */
unit_desc_t :: struct {
	/** Existing entity to associate with unit (optional). */
	entity:      entity_t,

	/** Unit symbol, e.g. "m", "%", "g". (optional). */
	symbol:      cstring,

	/** Unit quantity, e.g. distance, percentage, weight. (optional). */
	quantity:    entity_t,

	/** Base unit, e.g. "meters" (optional). */
	base:        entity_t,

	/** Over unit, e.g. "per second" (optional). */
	over:        entity_t,

	/** Translation to apply to derived unit (optional). */
	translation: unit_translation_t,

	/** Prefix indicating order of magnitude relative to the derived unit. If set
	* together with "translation", the values must match. If translation is not
	* set, setting prefix will auto-populate it.
	* Additionally, setting the prefix will enforce that the symbol (if set)
	* is consistent with the prefix symbol + symbol of the derived unit. If the
	* symbol is not set, it will be auto populated. */
	prefix:      entity_t,
}

/** Used with ecs_unit_prefix_init(). */
unit_prefix_desc_t :: struct {
	/** Existing entity to associate with unit prefix (optional). */
	entity:      entity_t,

	/** Unit symbol, e.g. "m", "%", "g". (optional). */
	symbol:      cstring,

	/** Translation to apply to derived unit (optional). */
	translation: unit_translation_t,
}

// STRUCT_ECS_META_IMPL :: ECS_STRUCT_IMPL

// ENUM_ECS_META_IMPL :: ECS_ENUM_IMPL

// BITMASK_ECS_META_IMPL :: ECS_BITMASK_IMPL

cpp_get_mut_t :: struct {
	ptr:           rawptr,
	call_modified: bool,
}

foreign import flecs "flecs.lib"

@(default_calling_convention = "c", link_prefix = "ecs_")
foreign flecs {
	vec_init :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_init_w_dbg_info :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32, type_name: cstring) ---
	vec_init_if :: proc(vec: ^vec_t, size: size_t) ---
	vec_fini :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) ---
	vec_reset :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) -> ^vec_t ---
	vec_clear :: proc(vec: ^vec_t) ---
	vec_append :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) -> rawptr ---
	vec_remove :: proc(vec: ^vec_t, size: size_t, elem: i32) ---
	vec_remove_ordered :: proc(v: ^vec_t, size: size_t, index: i32) ---
	vec_remove_last :: proc(vec: ^vec_t) ---
	vec_copy :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) -> vec_t ---
	vec_copy_shrink :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) -> vec_t ---
	vec_reclaim :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t) ---
	vec_set_size :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_set_min_size :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_set_min_count :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_set_min_count_zeromem :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_set_count :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) ---
	vec_grow :: proc(allocator: ^allocator_t, vec: ^vec_t, size: size_t, elem_count: i32) -> rawptr ---
	vec_count :: proc(vec: ^vec_t) -> i32 ---
	vec_size :: proc(vec: ^vec_t) -> i32 ---
	vec_get :: proc(vec: ^vec_t, size: size_t, index: i32) -> rawptr ---
	vec_first :: proc(vec: ^vec_t) -> rawptr ---
	vec_last :: proc(vec: ^vec_t, size: size_t) -> rawptr ---

	/** Initialize sparse set */
	flecs_sparse_init :: proc(result: ^sparse_t, allocator: ^allocator_t, page_allocator: ^block_allocator_t, size: size_t) ---
	flecs_sparse_fini :: proc(sparse: ^sparse_t) ---

	/** Remove all elements from sparse set */
	flecs_sparse_clear :: proc(sparse: ^sparse_t) ---

	/** Add element to sparse set, this generates or recycles an id */
	flecs_sparse_add :: proc(sparse: ^sparse_t, elem_size: size_t) -> rawptr ---

	/** Get last issued id. */
	flecs_sparse_last_id :: proc(sparse: ^sparse_t) -> u64 ---

	/** Generate or recycle a new id. */
	flecs_sparse_new_id :: proc(sparse: ^sparse_t) -> u64 ---

	/** Remove an element */
	flecs_sparse_remove :: proc(sparse: ^sparse_t, size: size_t, id: u64) -> bool ---

	/** Remove an element, increase generation */
	flecs_sparse_remove_w_gen :: proc(sparse: ^sparse_t, size: size_t, id: u64) -> bool ---

	/** Test if id is alive, which requires the generation count to match. */
	flecs_sparse_is_alive :: proc(sparse: ^sparse_t, id: u64) -> bool ---

	/** Get value from sparse set by dense id. This function is useful in
	* combination with flecs_sparse_count for iterating all values in the set. */
	flecs_sparse_get_dense :: proc(sparse: ^sparse_t, elem_size: size_t, index: i32) -> rawptr ---

	/** Get the number of alive elements in the sparse set. */
	flecs_sparse_count :: proc(sparse: ^sparse_t) -> i32 ---

	/** Check if sparse set has id */
	flecs_sparse_has :: proc(sparse: ^sparse_t, id: u64) -> bool ---

	/** Like get_sparse, but don't care whether element is alive or not. */
	flecs_sparse_get :: proc(sparse: ^sparse_t, elem_size: size_t, id: u64) -> rawptr ---

	/** Create element by (sparse) id. */
	flecs_sparse_insert :: proc(sparse: ^sparse_t, elem_size: size_t, id: u64) -> rawptr ---

	/** Get or create element by (sparse) id. */
	flecs_sparse_ensure :: proc(sparse: ^sparse_t, elem_size: size_t, id: u64, is_new: ^bool) -> rawptr ---

	/** Fast version of ensure, no liveliness checking */
	flecs_sparse_ensure_fast :: proc(sparse: ^sparse_t, elem_size: size_t, id: u64) -> rawptr ---

	/** Get pointer to ids (alive and not alive). Use with count() or size(). */
	flecs_sparse_ids :: proc(sparse: ^sparse_t) -> ^u64 ---
	flecs_sparse_shrink :: proc(sparse: ^sparse_t) ---

	/* Publicly exposed APIs
	* These APIs are not part of the public API and as a result may change without
	* notice (though they haven't changed in a long time). */
	sparse_init :: proc(sparse: ^sparse_t, elem_size: size_t) ---
	sparse_add :: proc(sparse: ^sparse_t, elem_size: size_t) -> rawptr ---
	sparse_last_id :: proc(sparse: ^sparse_t) -> u64 ---
	sparse_count :: proc(sparse: ^sparse_t) -> i32 ---
	sparse_get_dense :: proc(sparse: ^sparse_t, elem_size: size_t, index: i32) -> rawptr ---
	sparse_get :: proc(sparse: ^sparse_t, elem_size: size_t, id: u64) -> rawptr ---
	flecs_ballocator_init :: proc(ba: ^block_allocator_t, size: size_t) ---
	flecs_ballocator_new :: proc(size: size_t) -> ^block_allocator_t ---
	flecs_ballocator_fini :: proc(ba: ^block_allocator_t) ---
	flecs_ballocator_free :: proc(ba: ^block_allocator_t) ---
	flecs_balloc :: proc(allocator: ^block_allocator_t) -> rawptr ---
	flecs_balloc_w_dbg_info :: proc(allocator: ^block_allocator_t, type_name: cstring) -> rawptr ---
	flecs_bcalloc :: proc(allocator: ^block_allocator_t) -> rawptr ---
	flecs_bcalloc_w_dbg_info :: proc(allocator: ^block_allocator_t, type_name: cstring) -> rawptr ---
	flecs_bfree :: proc(allocator: ^block_allocator_t, memory: rawptr) ---
	flecs_bfree_w_dbg_info :: proc(allocator: ^block_allocator_t, memory: rawptr, type_name: cstring) ---
	flecs_brealloc :: proc(dst: ^block_allocator_t, src: ^block_allocator_t, memory: rawptr) -> rawptr ---
	flecs_brealloc_w_dbg_info :: proc(dst: ^block_allocator_t, src: ^block_allocator_t, memory: rawptr, type_name: cstring) -> rawptr ---
	flecs_bdup :: proc(ba: ^block_allocator_t, memory: rawptr) -> rawptr ---
	flecs_stack_init :: proc(stack: ^stack_t) ---
	flecs_stack_fini :: proc(stack: ^stack_t) ---
	flecs_stack_alloc :: proc(stack: ^stack_t, size: size_t, align: size_t) -> rawptr ---
	flecs_stack_calloc :: proc(stack: ^stack_t, size: size_t, align: size_t) -> rawptr ---
	flecs_stack_free :: proc(ptr: rawptr, size: size_t) ---
	flecs_stack_reset :: proc(stack: ^stack_t) ---
	flecs_stack_get_cursor :: proc(stack: ^stack_t) -> ^stack_cursor_t ---
	flecs_stack_restore_cursor :: proc(stack: ^stack_t, cursor: ^stack_cursor_t) ---

	/* Function/macro postfixes meaning:
	*   _ptr:    access ecs_map_val_t as void*
	*   _ref:    access ecs_map_val_t* as T**
	*   _deref:  dereferences a _ref
	*   _alloc:  if _ptr is NULL, alloc
	*   _free:   if _ptr is not NULL, free
	*/
	map_params_init :: proc(params: ^map_params_t, allocator: ^allocator_t) ---
	map_params_fini :: proc(params: ^map_params_t) ---

	/** Initialize new map. */
	map_init :: proc(_map: ^map_t, allocator: ^allocator_t) ---

	/** Initialize new map. */
	map_init_w_params :: proc(_map: ^map_t, params: ^map_params_t) ---

	/** Initialize new map if uninitialized, leave as is otherwise */
	map_init_if :: proc(_map: ^map_t, allocator: ^allocator_t) ---
	map_init_w_params_if :: proc(result: ^map_t, params: ^map_params_t) ---

	/** Deinitialize map. */
	map_fini :: proc(_map: ^map_t) ---

	/** Get element for key, returns NULL if they key doesn't exist. */
	map_get :: proc(_map: ^map_t, key: map_key_t) -> ^map_val_t ---

	/* Get element as pointer (auto-dereferences _ptr) */
	map_get_deref_ :: proc(_map: ^map_t, key: map_key_t) -> rawptr ---

	/** Get or insert element for key. */
	map_ensure :: proc(_map: ^map_t, key: map_key_t) -> ^map_val_t ---

	/** Get or insert pointer element for key, allocate if the pointer is NULL */
	map_ensure_alloc :: proc(_map: ^map_t, elem_size: size_t, key: map_key_t) -> rawptr ---

	/** Insert element for key. */
	map_insert :: proc(_map: ^map_t, key: map_key_t, value: map_val_t) ---

	/** Insert pointer element for key, populate with new allocation. */
	map_insert_alloc :: proc(_map: ^map_t, elem_size: size_t, key: map_key_t) -> rawptr ---

	/** Remove key from map. */
	map_remove :: proc(_map: ^map_t, key: map_key_t) -> map_val_t ---

	/* Remove pointer element, free if not NULL */
	map_remove_free :: proc(_map: ^map_t, key: map_key_t) ---

	/** Remove all elements from map. */
	map_clear :: proc(_map: ^map_t) ---

	/** Return iterator to map contents. */
	map_iter :: proc(_map: ^map_t) -> map_iter_t ---

	/** Obtain next element in map from iterator. */
	map_next :: proc(iter: ^map_iter_t) -> bool ---

	/** Copy map. */
	map_copy :: proc(dst: ^map_t, src: ^map_t) ---
	flecs_allocator_init :: proc(a: ^allocator_t) ---
	flecs_allocator_fini :: proc(a: ^allocator_t) ---
	flecs_allocator_get :: proc(a: ^allocator_t, size: size_t) -> ^block_allocator_t ---
	flecs_strdup :: proc(a: ^allocator_t, str: cstring) -> cstring ---
	flecs_strfree :: proc(a: ^allocator_t, str: cstring) ---
	flecs_dup :: proc(a: ^allocator_t, size: size_t, src: rawptr) -> rawptr ---

	/* Append format string to a buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_append :: proc(buffer: ^strbuf_t, fmt: cstring, #c_vararg _: ..any) ---

	/* Append format string with argument list to a buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_vappend :: proc(buffer: ^strbuf_t, fmt: cstring, args: ^c.va_list) ---

	/* Append string to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendstr :: proc(buffer: ^strbuf_t, str: cstring) ---

	/* Append character to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendch :: proc(buffer: ^strbuf_t, ch: c.char) ---

	/* Append int to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendint :: proc(buffer: ^strbuf_t, v: i64) ---

	/* Append float to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendflt :: proc(buffer: ^strbuf_t, v: f64, nan_delim: c.char) ---

	/* Append boolean to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendbool :: proc(buffer: ^strbuf_t, v: bool) ---

	/* Append source buffer to destination buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_mergebuff :: proc(dst_buffer: ^strbuf_t, src_buffer: ^strbuf_t) ---

	/* Append n characters to buffer.
	* Returns false when max is reached, true when there is still space */
	strbuf_appendstrn :: proc(buffer: ^strbuf_t, str: cstring, n: i32) ---

	/* Return result string */
	strbuf_get :: proc(buffer: ^strbuf_t) -> cstring ---

	/* Return small string from first element (appends \0) */
	strbuf_get_small :: proc(buffer: ^strbuf_t) -> cstring ---

	/* Reset buffer without returning a string */
	strbuf_reset :: proc(buffer: ^strbuf_t) ---

	/* Push a list */
	strbuf_list_push :: proc(buffer: ^strbuf_t, list_open: cstring, separator: cstring) ---

	/* Pop a new list */
	strbuf_list_pop :: proc(buffer: ^strbuf_t, list_close: cstring) ---

	/* Insert a new element in list */
	strbuf_list_next :: proc(buffer: ^strbuf_t) ---

	/* Append character to as new element in list. */
	strbuf_list_appendch :: proc(buffer: ^strbuf_t, ch: c.char) ---

	/* Append formatted string as a new element in list */
	strbuf_list_append :: proc(buffer: ^strbuf_t, fmt: cstring, #c_vararg _: ..any) ---

	/* Append string as a new element in list */
	strbuf_list_appendstr :: proc(buffer: ^strbuf_t, str: cstring) ---

	/* Append string as a new element in list */
	strbuf_list_appendstrn :: proc(buffer: ^strbuf_t, str: cstring, n: i32) ---
	strbuf_written :: proc(buffer: ^strbuf_t) -> i32 ---

	/** Initialize OS API.
	* This operation is not usually called by an application. To override callbacks
	* of the OS API, use the following pattern:
	*
	* @code
	* ecs_os_set_api_defaults();
	* ecs_os_api_t os_api = ecs_os_get_api();
	* os_api.abort_ = my_abort;
	* ecs_os_set_api(&os_api);
	* @endcode
	*/
	os_init :: proc() ---

	/** Deinitialize OS API.
	* This operation is not usually called by an application.
	*/
	os_fini :: proc() ---

	/** Override OS API.
	* This overrides the OS API struct with new values for callbacks. See
	* ecs_os_init() on how to use the function.
	*
	* @param os_api Pointer to struct with values to set.
	*/
	os_set_api :: proc(os_api: ^os_api_t) ---

	/** Get OS API.
	*
	* @return A value with the current OS API callbacks
	* @see ecs_os_init()
	*/
	os_get_api :: proc() -> os_api_t ---

	/** Set default values for OS API.
	* This initializes the OS API struct with default values for callbacks like
	* malloc and free.
	*
	* @see ecs_os_init()
	*/
	os_set_api_defaults :: proc() ---

	/** Log at debug level.
	*
	* @param file The file to log.
	* @param line The line to log.
	* @param msg The message to log.
	*/
	os_dbg :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Log at trace level.
	*
	* @param file The file to log.
	* @param line The line to log.
	* @param msg The message to log.
	*/
	os_trace :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Log at warning level.
	*
	* @param file The file to log.
	* @param line The line to log.
	* @param msg The message to log.
	*/
	os_warn :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Log at error level.
	*
	* @param file The file to log.
	* @param line The line to log.
	* @param msg The message to log.
	*/
	os_err :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Log at fatal level.
	*
	* @param file The file to log.
	* @param line The line to log.
	* @param msg The message to log.
	*/
	os_fatal :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Convert errno to string.
	*
	* @param err The error number.
	* @return A string describing the error.
	*/
	os_strerror :: proc(err: c.int) -> cstring ---

	/** Utility for assigning strings.
	* This operation frees an existing string and duplicates the input string.
	*
	* @param str Pointer to a string value.
	* @param value The string value to assign.
	*/
	os_strset :: proc(str: [^]cstring, value: cstring) ---
	os_perf_trace_push_ :: proc(file: cstring, line: c.size_t, name: cstring) ---
	os_perf_trace_pop_ :: proc(file: cstring, line: c.size_t, name: cstring) ---

	/** Sleep with floating point time.
	*
	* @param t The time in seconds.
	*/
	sleepf :: proc(t: f64) ---

	/** Measure time since provided timestamp.
	* Use with a time value initialized to 0 to obtain the number of seconds since
	* the epoch. The operation will write the current timestamp in start.
	*
	* Usage:
	* @code
	* ecs_time_t t = {};
	* ecs_time_measure(&t);
	* // code
	* double elapsed = ecs_time_measure(&t);
	* @endcode
	*
	* @param start The starting timestamp.
	* @return The time elapsed since start.
	*/
	time_measure :: proc(start: ^time_t) -> f64 ---

	/** Calculate difference between two timestamps.
	*
	* @param t1 The first timestamp.
	* @param t2 The first timestamp.
	* @return The difference between timestamps.
	*/
	time_sub :: proc(t1: time_t, t2: time_t) -> time_t ---

	/** Convert time value to a double.
	*
	* @param t The timestamp.
	* @return The timestamp converted to a double.
	*/
	time_to_double :: proc(t: time_t) -> f64 ---

	/** Return newly allocated memory that contains a copy of src.
	*
	* @param src The source pointer.
	* @param size The number of bytes to copy.
	* @return The duplicated memory.
	*/
	os_memdup :: proc(src: rawptr, size: size_t) -> rawptr ---

	/** Are heap functions available? */
	os_has_heap :: proc() -> bool ---

	/** Are threading functions available? */
	os_has_threading :: proc() -> bool ---

	/** Are task functions available? */
	os_has_task_support :: proc() -> bool ---

	/** Are time functions available? */
	os_has_time :: proc() -> bool ---

	/** Are logging functions available? */
	os_has_logging :: proc() -> bool ---

	/** Are dynamic library functions available? */
	os_has_dl :: proc() -> bool ---

	/** Are module path functions available? */
	os_has_modules :: proc() -> bool ---

	/** Convert a C module name into a path.
	* This operation converts a PascalCase name to a path, for example MyFooModule
	* into my.foo.module.
	*
	* @param c_name The C module name
	* @return The path.
	*/
	flecs_module_path_from_c :: proc(c_name: cstring) -> cstring ---

	/** Constructor that zeromem's a component value.
	*
	* @param ptr Pointer to the value.
	* @param count Number of elements to construct.
	* @param type_info Type info for the component.
	*/
	flecs_default_ctor :: proc(ptr: rawptr, count: i32, type_info: ^type_info_t) ---

	/** Create allocated string from format.
	*
	* @param fmt The format string.
	* @param args Format arguments.
	* @return The formatted string.
	*/
	flecs_vasprintf :: proc(fmt: cstring, args: ^c.va_list) -> cstring ---

	/** Create allocated string from format.
	*
	* @param fmt The format string.
	* @return The formatted string.
	*/
	flecs_asprintf :: proc(fmt: cstring, #c_vararg _: ..any) -> cstring ---

	/** Write an escaped character.
	* Write a character to an output string, insert escape character if necessary.
	*
	* @param out The string to write the character to.
	* @param in The input character.
	* @param delimiter The delimiter used (for example '"')
	* @return Pointer to the character after the last one written.
	*/
	flecs_chresc :: proc(out: cstring, _in: c.char, delimiter: c.char) -> cstring ---

	/** Parse an escaped character.
	* Parse a character with a potential escape sequence.
	*
	* @param in Pointer to character in input string.
	* @param out Output string.
	* @return Pointer to the character after the last one read.
	*/
	flecs_chrparse :: proc(_in: cstring, out: cstring) -> cstring ---

	/** Write an escaped string.
	* Write an input string to an output string, escape characters where necessary.
	* To determine the size of the output string, call the operation with a NULL
	* argument for 'out', and use the returned size to allocate a string that is
	* large enough.
	*
	* @param out Pointer to output string (must be).
	* @param size Maximum number of characters written to output.
	* @param delimiter The delimiter used (for example '"').
	* @param in The input string.
	* @return The number of characters that (would) have been written.
	*/
	flecs_stresc :: proc(out: cstring, size: size_t, delimiter: c.char, _in: cstring) -> size_t ---

	/** Return escaped string.
	* Return escaped version of input string. Same as flecs_stresc(), but returns an
	* allocated string of the right size.
	*
	* @param delimiter The delimiter used (for example '"').
	* @param in The input string.
	* @return Escaped string.
	*/
	flecs_astresc :: proc(delimiter: c.char, _in: cstring) -> cstring ---

	/** Skip whitespace and newline characters.
	* This function skips whitespace characters.
	*
	* @param ptr Pointer to (potential) whitespaces to skip.
	* @return Pointer to the next non-whitespace character.
	*/
	flecs_parse_ws_eol :: proc(ptr: cstring) -> cstring ---

	/** Parse digit.
	* This function will parse until the first non-digit character is found. The
	* provided expression must contain at least one digit character.
	*
	* @param ptr The expression to parse.
	* @param token The output buffer.
	* @return Pointer to the first non-digit character.
	*/
	flecs_parse_digit :: proc(ptr: cstring, token: cstring) -> cstring ---

	/* Convert identifier to snake case */
	flecs_to_snake_case :: proc(str: cstring) -> cstring ---
	flecs_suspend_readonly :: proc(world: ^world_t, state: ^suspend_readonly_state_t) -> ^world_t ---
	flecs_resume_readonly :: proc(world: ^world_t, state: ^suspend_readonly_state_t) ---

	/** Number of observed entities in table.
	* Operation is public to support test cases.
	*
	* @param table The table.
	*/
	flecs_table_observed_count :: proc(table: ^table_t) -> i32 ---

	/** Print backtrace to specified stream.
	*
	* @param stream The stream to use for printing the backtrace.
	*/
	flecs_dump_backtrace :: proc(stream: rawptr) ---

	/** Increase refcount of poly object.
	*
	* @param poly The poly object.
	* @return The refcount after incrementing.
	*/
	flecs_poly_claim_ :: proc(poly: poly_t) -> i32 ---

	/** Decrease refcount of poly object.
	*
	* @param poly The poly object.
	* @return The refcount after decrementing.
	*/
	flecs_poly_release_ :: proc(poly: poly_t) -> i32 ---

	/** Return refcount of poly object.
	*
	* @param poly The poly object.
	* @return Refcount of the poly object.
	*/
	flecs_poly_refcount :: proc(poly: poly_t) -> i32 ---

	/** Get unused index for static world local component id array.
	* This operation returns an unused index for the world-local component id
	* array. This index can be used by language bindings to obtain a component id.
	*
	* @return Unused index for component id array.
	*/
	flecs_component_ids_index_get :: proc() -> i32 ---

	/** Get world local component id.
	*
	* @param world The world.
	* @param index Component id array index.
	* @return The component id.
	*/
	flecs_component_ids_get :: proc(world: ^world_t, index: i32) -> entity_t ---

	/** Get alive world local component id.
	* Same as flecs_component_ids_get, but return 0 if component is no longer
	* alive.
	*
	* @param world The world.
	* @param index Component id array index.
	* @return The component id.
	*/
	flecs_component_ids_get_alive :: proc(world: ^world_t, index: i32) -> entity_t ---

	/** Set world local component id.
	*
	* @param world The world.
	* @param index Component id array index.
	* @param id The component id.
	*/
	flecs_component_ids_set :: proc(world: ^world_t, index: i32, id: entity_t) ---

	/** Query iterator function for trivially cached queries.
	* This operation can be called if an iterator matches the conditions for
	* trivial iteration:
	*
	* @param it The query iterator.
	* @return Whether the query has more results.
	*/
	flecs_query_trivial_cached_next :: proc(it: ^iter_t) -> bool ---

	/** Check if current thread has exclusive access to world.
	* This operation checks if the current thread is allowed to access the world.
	* The operation is called by internal functions before mutating the world, and
	* will panic if the current thread does not have exclusive access to the world.
	*
	* Exclusive access is controlled by the ecs_exclusive_access_begin() and
	* ecs_exclusive_access_end() operations.
	*
	* This operation is public so that it shows up in stack traces, but code such
	* as language bindings or wrappers could also use it to verify that the world
	* is accessed from the correct thread.
	*
	* @param world The world.
	*/
	flecs_check_exclusive_world_access_write :: proc(world: ^world_t) ---

	/** Same as flecs_check_exclusive_world_access_write, but for read access.
	*
	* @param world The world.
	*/
	flecs_check_exclusive_world_access_read :: proc(world: ^world_t) ---
	flecs_hashmap_init_ :: proc(hm: ^hashmap_t, key_size: size_t, value_size: size_t, hash: hash_value_action_t, compare: compare_action_t, allocator: ^allocator_t) ---
	flecs_hashmap_fini :: proc(_map: ^hashmap_t) ---
	flecs_hashmap_get_ :: proc(_map: ^hashmap_t, key_size: size_t, key: rawptr, value_size: size_t) -> rawptr ---
	flecs_hashmap_ensure_ :: proc(_map: ^hashmap_t, key_size: size_t, key: rawptr, value_size: size_t) -> flecs_hashmap_result_t ---
	flecs_hashmap_set_ :: proc(_map: ^hashmap_t, key_size: size_t, key: rawptr, value_size: size_t, value: rawptr) ---
	flecs_hashmap_remove_ :: proc(_map: ^hashmap_t, key_size: size_t, key: rawptr, value_size: size_t) ---
	flecs_hashmap_remove_w_hash_ :: proc(_map: ^hashmap_t, key_size: size_t, key: rawptr, value_size: size_t, hash: u64) ---
	flecs_hashmap_get_bucket :: proc(_map: ^hashmap_t, hash: u64) -> ^hm_bucket_t ---
	flecs_hm_bucket_remove :: proc(_map: ^hashmap_t, bucket: ^hm_bucket_t, hash: u64, index: i32) ---
	flecs_hashmap_copy :: proc(dst: ^hashmap_t, src: ^hashmap_t) ---
	flecs_hashmap_iter :: proc(_map: ^hashmap_t) -> flecs_hashmap_iter_t ---
	flecs_hashmap_next_ :: proc(it: ^flecs_hashmap_iter_t, key_size: size_t, key_out: rawptr, value_size: size_t) -> rawptr ---

	/** Find record for entity.
	* An entity record contains the table and row for the entity.
	*
	* To use ecs_record_t::row as the record in the table, use:
	*   ECS_RECORD_TO_ROW(r->row)
	*
	* This removes potential entity bitflags from the row field.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The record, NULL if the entity does not exist.
	*/
	record_find :: proc(world: ^world_t, entity: entity_t) -> ^record_t ---

	/** Get entity corresponding with record.
	* This operation only works for entities that are not empty.
	*
	* @param record The record for which to obtain the entity id.
	* @return The entity id for the record.
	*/
	record_get_entity :: proc(record: ^record_t) -> entity_t ---

	/** Begin exclusive write access to entity.
	* This operation provides safe exclusive access to the components of an entity
	* without the overhead of deferring operations.
	*
	* When this operation is called simultaneously for the same entity more than
	* once it will throw an assert. Note that for this to happen, asserts must be
	* enabled. It is up to the application to ensure that access is exclusive, for
	* example by using a read-write mutex.
	*
	* Exclusive access is enforced at the table level, so only one entity can be
	* exclusively accessed per table. The exclusive access check is thread safe.
	*
	* This operation must be followed up with ecs_write_end().
	*
	* @param world The world.
	* @param entity The entity.
	* @return A record to the entity.
	*/
	write_begin :: proc(world: ^world_t, entity: entity_t) -> ^record_t ---

	/** End exclusive write access to entity.
	* This operation ends exclusive access, and must be called after
	* ecs_write_begin().
	*
	* @param record Record to the entity.
	*/
	write_end :: proc(record: ^record_t) ---

	/** Begin read access to entity.
	* This operation provides safe read access to the components of an entity.
	* Multiple simultaneous reads are allowed per entity.
	*
	* This operation ensures that code attempting to mutate the entity's table will
	* throw an assert. Note that for this to happen, asserts must be enabled. It is
	* up to the application to ensure that this does not happen, for example by
	* using a read-write mutex.
	*
	* This operation does *not* provide the same guarantees as a read-write mutex,
	* as it is possible to call ecs_read_begin() after calling ecs_write_begin(). It is
	* up to application has to ensure that this does not happen.
	*
	* This operation must be followed up with ecs_read_end().
	*
	* @param world The world.
	* @param entity The entity.
	* @return A record to the entity.
	*/
	read_begin :: proc(world: ^world_t, entity: entity_t) -> ^record_t ---

	/** End read access to entity.
	* This operation ends read access, and must be called after ecs_read_begin().
	*
	* @param record Record to the entity.
	*/
	read_end :: proc(record: ^record_t) ---

	/** Get component from entity record.
	* This operation returns a pointer to a component for the entity
	* associated with the provided record. For safe access to the component, obtain
	* the record with ecs_read_begin() or ecs_write_begin().
	*
	* Obtaining a component from a record is faster than obtaining it from the
	* entity handle, as it reduces the number of lookups required.
	*
	* @param world The world.
	* @param record Record to the entity.
	* @param id The (component) id.
	* @return Pointer to component, or NULL if entity does not have the component.
	*
	* @see ecs_record_ensure_id()
	*/
	record_get_id :: proc(world: ^world_t, record: ^record_t, id: id_t) -> rawptr ---

	/** Same as ecs_record_get_id(), but returns a mutable pointer.
	* For safe access to the component, obtain the record with ecs_write_begin().
	*
	* @param world The world.
	* @param record Record to the entity.
	* @param id The (component) id.
	* @return Pointer to component, or NULL if entity does not have the component.
	*/
	record_ensure_id :: proc(world: ^world_t, record: ^record_t, id: id_t) -> rawptr ---

	/** Test if entity for record has a (component) id.
	*
	* @param world The world.
	* @param record Record to the entity.
	* @param id The (component) id.
	* @return Whether the entity has the component.
	*/
	record_has_id :: proc(world: ^world_t, record: ^record_t, id: id_t) -> bool ---

	/** Get component pointer from column/record.
	* This returns a pointer to the component using a table column index. The
	* table's column index can be found with ecs_table_get_column_index().
	*
	* Usage:
	* @code
	* ecs_record_t *r = ecs_record_find(world, entity);
	* int32_t column = ecs_table_get_column_index(world, table, ecs_id(Position));
	* Position *ptr = ecs_record_get_by_column(r, column, sizeof(Position));
	* @endcode
	*
	* @param record The record.
	* @param column The column index in the entity's table.
	* @param size The component size.
	* @return The component pointer.
	*/
	record_get_by_column :: proc(record: ^record_t, column: i32, size: c.size_t) -> rawptr ---

	/** Get component record for component id.
	*
	* @param world The world.
	* @param id The component id.
	* @return The component record, or NULL if it doesn't exist.
	*/
	flecs_components_get :: proc(world: ^world_t, id: id_t) -> ^component_record_t ---

	/** Get component id from component record.
	*
	* @param cr The component record.
	* @return The component id.
	*/
	flecs_component_get_id :: proc(cr: ^component_record_t) -> id_t ---

	/** Find table record for component record.
	* This operation returns the table record for the table/component record if it
	* exists. If the record exists, it means the table has the component.
	*
	* @param cr The component record.
	* @param table The table.
	* @return The table record if the table has the component, or NULL if not.
	*/
	flecs_component_get_table :: proc(cr: ^component_record_t, table: ^table_t) -> ^table_record_t ---

	/** Create component record iterator.
	* A component record iterator iterates all tables for the specified component
	* record.
	*
	* The iterator should be used like this:
	*
	* @code
	* ecs_table_cache_iter_t it;
	* if (flecs_component_iter(cr, &it)) {
	*   const ecs_table_record_t *tr;
	*   while ((tr = flecs_component_next(&it))) {
	*     ecs_table_t *table = tr->hdr.table;
	*     // ...
	*   }
	* }
	* @endcode
	*
	* @param cr The component record.
	* @param iter_out Out parameter for the iterator.
	* @return True if there are results, false if there are no results.
	*/
	flecs_component_iter :: proc(cr: ^component_record_t, iter_out: ^table_cache_iter_t) -> bool ---

	/** Get next table record for iterator.
	* Returns next table record for iterator.
	*
	* @param iter The iterator.
	* @return The next table record, or NULL if there are no more results.
	*/
	flecs_component_next :: proc(iter: ^table_cache_iter_t) -> ^table_record_t ---

	/** Get table records.
	* This operation returns an array with all records for the specified table.
	*
	* @param table The table.
	* @return The table records for the table.
	*/
	flecs_table_records :: proc(table: ^table_t) -> table_records_t ---

	/** Get component record from table record.
	*
	* @param tr The table record.
	* @return The component record.
	*/
	flecs_table_record_get_component :: proc(tr: ^table_record_t) -> ^component_record_t ---

	/** Get table id.
	* This operation returns a unique numerical identifier for a table.
	*
	* @param table The table.
	* @return The table records for the table.
	*/
	flecs_table_id :: proc(table: ^table_t) -> u64 ---

	/** Find table by adding id to current table.
	* Same as ecs_table_add_id, but with additional diff parameter that contains
	* information about the traversed edge.
	*
	* @param world The world.
	* @param table The table.
	* @param id_ptr Pointer to component id to add.
	* @param diff Information about traversed edge (out parameter).
	* @return The table that was traversed to.
	*/
	flecs_table_traverse_add :: proc(world: ^world_t, table: ^table_t, id_ptr: ^id_t, diff: ^table_diff_t) -> ^table_t ---

	/** Create a new world.
	* This operation automatically imports modules from addons Flecs has been built
	* with, except when the module specifies otherwise.
	*
	* @return A new world
	*/
	@(link_prefix = "")
	ecs_init :: proc() -> ^world_t ---

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
	init_w_args :: proc(argc: c.int, argv: [^]cstring) -> ^world_t ---

	/** Delete a world.
	* This operation deletes the world, and everything it contains.
	*
	* @param world The world to delete.
	* @return Zero if successful, non-zero if failed.
	*/
	fini :: proc(world: ^world_t) -> c.int ---

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
	*  - `QueryMatchEmptyTables`
	*  - `QueryMatchDisabled`
	*  - `QueryMatchPrefab`
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

	/** Merge world or stage.
	* When automatic merging is disabled, an application can call this
	* operation on either an individual stage, or on the world which will merge
	* all stages. This operation may only be called when staging is not enabled
	* (either after ecs_progress() or after ecs_readonly_end()).
	*
	* This operation may be called on an already merged stage or world.
	*
	* @param world The world.
	*/
	merge :: proc(world: ^world_t) ---

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
	*/
	defer_begin :: proc(world: ^world_t) -> bool ---

	/** Test if deferring is enabled for current stage.
	*
	* @param world The world.
	* @return True if deferred, false if not.
	*
	* @see ecs_defer_begin()
	* @see ecs_defer_end()
	* @see ecs_defer_resume()
	* @see ecs_defer_suspend()
	*/
	is_deferred :: proc(world: ^world_t) -> bool ---

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
	* run all actions. Supported flags start with 'Aperiodic'. Flags identify
	* internal mechanisms and may change unannounced.
	*
	* @param world The world.
	* @param flags The flags specifying which actions to run.
	*/
	run_aperiodic :: proc(world: ^world_t, flags: flags32_t) ---

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
	get_world :: proc(poly: poly_t) -> ^world_t ---

	/** Get entity from poly.
	*
	* @param poly A pointer to a poly object.
	* @return Entity associated with the poly object.
	*/
	get_entity :: proc(poly: poly_t) -> entity_t ---

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
	flecs_poly_is_ :: proc(object: poly_t, type: i32) -> bool ---

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
	* @param id The component id to initialize the new entity with.
	* @return The new entity.
	*/
	new_w_id :: proc(world: ^world_t, id: id_t) -> entity_t ---

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
	* @param id The component id to create the entities with.
	* @param count The number of entities to create.
	* @return The first entity id of the newly created entities.
	*/
	bulk_new_w_id :: proc(world: ^world_t, id: id_t, count: i32) -> ^entity_t ---

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
	@(link_prefix = "")
	ecs_delete :: proc(world: ^world_t, entity: entity_t) ---

	/** Delete all entities with the specified id.
	* This will delete all entities (tables) that have the specified id. The id
	* may be a wildcard and/or a pair.
	*
	* @param world The world.
	* @param id The id.
	*/
	delete_with :: proc(world: ^world_t, id: id_t) ---

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
	* @param id The id to add.
	*/
	add_id :: proc(world: ^world_t, entity: entity_t, id: id_t) ---

	/** Remove a (component) id from an entity.
	* This operation removes a single (component) id to an entity. If the entity
	* does not have the id, this operation will have no side effects.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id to remove.
	*/
	remove_id :: proc(world: ^world_t, entity: entity_t, id: id_t) ---

	/** Add auto override for (component) id.
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
	* ecs_entity_t inst = ecs_new_w_pair(world, IsA, prefab);
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
	* ecs_entity_t inst = ecs_new_w_pair(world, IsA, prefab);
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
	* @param id The (component) id to auto override.
	*/
	auto_override_id :: proc(world: ^world_t, entity: entity_t, id: id_t) ---

	/** Clear all components.
	* This operation will remove all components from an entity.
	*
	* @param world The world.
	* @param entity The entity.
	*/
	clear :: proc(world: ^world_t, entity: entity_t) ---

	/** Remove all instances of the specified (component) id.
	* This will remove the specified id from all entities (tables). The id may be
	* a wildcard and/or a pair.
	*
	* @param world The world.
	* @param id The id.
	*/
	remove_all :: proc(world: ^world_t, id: id_t) ---

	/** Set current with id.
	* New entities are automatically created with the specified id.
	*
	* @param world The world.
	* @param id The id.
	* @return The previous id.
	*/
	set_with :: proc(world: ^world_t, id: id_t) -> entity_t ---

	/** Get current with id.
	* Get the id set with ecs_set_with().
	*
	* @param world The world.
	* @return The last id provided to ecs_set_with().
	*/
	get_with :: proc(world: ^world_t) -> id_t ---

	/** Enable or disable entity.
	* This operation enables or disables an entity by adding or removing the
	* #Disabled tag. A disabled entity will not be matched with any systems,
	* unless the system explicitly specifies the #Disabled tag.
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
	* @param id The component.
	* @param enable True to enable the component, false to disable.
	*/
	enable_id :: proc(world: ^world_t, entity: entity_t, id: id_t, enable: bool) ---

	/** Test if component is enabled.
	* Test whether a component is currently enabled or disabled. This operation
	* will return true when the entity has the component and if it has not been
	* disabled by ecs_enable_component().
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The component.
	* @return True if the component is enabled, otherwise false.
	*/
	is_enabled_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> bool ---

	/** Get an immutable pointer to a component.
	* This operation obtains a const pointer to the requested component. The
	* operation accepts the component entity id.
	*
	* This operation can return inherited components reachable through an `IsA`
	* relationship.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id of the component to get.
	* @return The component pointer, NULL if the entity does not have the component.
	*
	* @see ecs_get_mut_id()
	*/
	get_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> rawptr ---

	/** Get a mutable pointer to a component.
	* This operation obtains a mutable pointer to the requested component. The
	* operation accepts the component entity id.
	*
	* Unlike ecs_get_id(), this operation does not return inherited components.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id of the component to get.
	* @return The component pointer, NULL if the entity does not have the component.
	*/
	get_mut_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> rawptr ---

	/** Get a mutable pointer to a component.
	* This operation returns a mutable pointer to a component. If the component did
	* not yet exist, it will be added.
	*
	* If ensure is called when the world is in deferred/readonly mode, the
	* function will:
	* - return a pointer to a temp storage if the component does not yet exist, or
	* - return a pointer to the existing component if it exists
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The entity id of the component to obtain.
	* @return The component pointer.
	*
	* @see ecs_emplace_id()
	*/
	ensure_id :: proc(world: ^world_t, entity: entity_t, id: id_t, size: c.size_t) -> rawptr ---

	/** Create a component ref.
	* A ref is a handle to an entity + component which caches a small amount of
	* data to reduce overhead of repeatedly accessing the component. Use
	* ecs_ref_get() to get the component data.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id of the component.
	* @return The reference.
	*/
	ref_init_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> ref_t ---

	/** Get component from ref.
	* Get component pointer from ref. The ref must be created with ecs_ref_init().
	*
	* @param world The world.
	* @param ref The ref.
	* @param id The component id.
	* @return The component pointer, NULL if the entity does not have the component.
	*/
	ref_get_id :: proc(world: ^world_t, ref: ^ref_t, id: id_t) -> rawptr ---

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
	* @param id The component to obtain.
	* @param is_new Whether this is an existing or new component.
	* @return The (uninitialized) component pointer.
	*/
	emplace_id :: proc(world: ^world_t, entity: entity_t, id: id_t, is_new: ^bool) -> rawptr ---

	/** Signal that a component has been modified.
	* This operation is usually used after modifying a component value obtained by
	* ecs_ensure_id(). The operation will mark the component as dirty, and invoke
	* OnSet observers and hooks.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id of the component that was modified.
	*/
	modified_id :: proc(world: ^world_t, entity: entity_t, id: id_t) ---

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
	* @param id The id of the component to set.
	* @param size The size of the pointed-to value.
	* @param ptr The pointer to the value.
	*/
	set_id :: proc(world: ^world_t, entity: entity_t, id: id_t, size: c.size_t, ptr: rawptr) ---

	/** Test whether an entity is valid.
	* Entities that are valid can be used with API functions. Using invalid
	* entities with API operations will cause the function to panic.
	*
	* An entity is valid if it is not 0 and if it is alive.
	*
	* ecs_is_valid() will return true for ids that don't exist (alive or not alive). This
	* allows for using ids that have never been created by ecs_new_w() or similar. In
	* this the function differs from ecs_is_alive(), which will return false for
	* entities that do not yet exist.
	*
	* The operation will return false for an id that exists and is not alive, as
	* using this id with an API operation would cause it to assert.
	*
	* @param world The world.
	* @param e The entity.
	* @return True if the entity is valid, false if the entity is not valid.
	*/
	is_valid :: proc(world: ^world_t, e: entity_t) -> bool ---

	/** Test whether an entity is alive.
	* Entities are alive after they are created, and become not alive when they are
	* deleted. Operations that return alive ids are (amongst others) ecs_new(),
	* ecs_new_low_id() and ecs_entity_init(). Ids can be made alive with the ecs_make_alive()
	* function.
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
	* @param world The world.
	* @param e The entity.
	* @return True if the entity is alive, false if the entity is not alive.
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

	/** Same as ecs_make_alive(), but for (component) ids.
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
	* @param id The id to make alive.
	*/
	make_alive_id :: proc(world: ^world_t, id: id_t) ---

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

	/** Get the type of an entity.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no components.
	*/
	@(link_prefix = "")
	ecs_get_type :: proc(world: ^world_t, entity: entity_t) -> ^type_t ---

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
	@(link_prefix = "", private)
	ecs_type_str :: proc(world: ^world_t, type: ^type_t) -> cstring ---

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

	/** Test if an entity has an id.
	* This operation returns true if the entity has or inherits the specified id.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id to test for.
	* @return True if the entity has the id, false if not.
	*
	* @see ecs_owns_id()
	*/
	has_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> bool ---

	/** Test if an entity owns an id.
	* This operation returns true if the entity has the specified id. The operation
	* behaves the same as ecs_has_id(), except that it will return false for
	* components that are inherited through an `IsA` relationship.
	*
	* @param world The world.
	* @param entity The entity.
	* @param id The id to test for.
	* @return True if the entity has the id, false if not.
	*/
	owns_id :: proc(world: ^world_t, entity: entity_t, id: id_t) -> bool ---

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
	* ecs_get_target(world, entity, ChildOf, 0);
	* @endcode
	*
	* @param world The world.
	* @param entity The entity.
	* @return The parent of the entity, 0 if the entity has no parent.
	*
	* @see ecs_get_target()
	*/
	get_parent :: proc(world: ^world_t, entity: entity_t) -> entity_t ---

	/** Get the target of a relationship for a given id.
	* This operation returns the first entity that has the provided id by following
	* the specified relationship. If the entity itself has the id then entity will
	* be returned. If the id cannot be found on the entity or by following the
	* relationship, the operation will return 0.
	*
	* This operation can be used to lookup, for example, which prefab is providing
	* a component by specifying the `IsA` relationship:
	*
	* @code
	* // Is Position provided by the entity or one of its base entities?
	* ecs_get_target_for_id(world, entity, IsA, ecs_id(Position))
	* @endcode
	*
	* @param world The world.
	* @param entity The entity.
	* @param rel The relationship to follow.
	* @param id The id to lookup.
	* @return The entity for which the target has been found.
	*/
	get_target_for_id :: proc(world: ^world_t, entity: entity_t, rel: entity_t, id: id_t) -> entity_t ---

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
	* This will return the name stored in `(Identifier, Name)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @return The type of the entity, NULL if the entity has no name.
	*
	* @see ecs_set_name()
	*/
	@(link_prefix = "")
	ecs_get_name :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get the symbol of an entity.
	* This will return the symbol stored in `(Identifier, Symbol)`.
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
	* The name is stored in `(Identifier, Name)`.
	*
	* @param world The world.
	* @param entity The entity.
	* @param name The name.
	* @return The provided entity, or a new entity if 0 was provided.
	*
	* @see ecs_get_name()
	*/
	@(link_prefix = "")
	ecs_set_name :: proc(world: ^world_t, entity: entity_t, name: cstring) -> entity_t ---

	/** Set the symbol of an entity.
	* This will set or overwrite the symbol of an entity. If no entity is provided,
	* a new entity will be created.
	*
	* The symbol is stored in (Identifier, Symbol).
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
	* The symbol is stored in `(Identifier, Alias)`.
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
	@(link_prefix = "")
	ecs_lookup :: proc(world: ^world_t, path: cstring) -> entity_t ---

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
	* This looks up an entity by symbol stored in `(Identifier, Symbol)`. The
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
	* the custom search path does not include flecs.core (FlecsCore).
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

	/** Get the type for an id.
	* This function returns the type information for an id. The specified id can be
	* any valid id. For the rules on how type information is determined based on
	* id, see ecs_get_typeid().
	*
	* @param world The world.
	* @param id The id.
	* @return The type information of the id.
	*/
	get_type_info :: proc(world: ^world_t, id: id_t) -> ^type_info_t ---

	/** Register hooks for component.
	* Hooks allow for the execution of user code when components are constructed,
	* copied, moved, destructed, added, removed or set. Hooks can be assigned as
	* as long as a component has not yet been used (added to an entity).
	*
	* The hooks that are currently set can be accessed with ecs_get_type_info().
	*
	* @param world The world.
	* @param id The component id for which to register the actions
	* @param hooks Type that contains the component actions.
	*/
	set_hooks_id :: proc(world: ^world_t, id: entity_t, hooks: ^type_hooks_t) ---

	/** Get hooks for component.
	*
	* @param world The world.
	* @param id The component id for which to retrieve the hooks.
	* @return The hooks for the component, or NULL if not registered.
	*/
	get_hooks_id :: proc(world: ^world_t, id: entity_t) -> ^type_hooks_t ---

	/** Returns whether specified id a tag.
	* This operation returns whether the specified type is a tag (a component
	* without data/size).
	*
	* An id is a tag when:
	* - it is an entity without the Component component
	* - it has an Component with size member set to 0
	* - it is a pair where both elements are a tag
	* - it is a pair where the first element has the #PairIsTag tag
	*
	* @param world The world.
	* @param id The id.
	* @return Whether the provided id is a tag.
	*/
	id_is_tag :: proc(world: ^world_t, id: id_t) -> bool ---

	/** Returns whether specified id is in use.
	* This operation returns whether an id is in use in the world. An id is in use
	* if it has been added to one or more tables.
	*
	* @param world The world.
	* @param id The id.
	* @return Whether the id is in use.
	*/
	id_in_use :: proc(world: ^world_t, id: id_t) -> bool ---

	/** Get the type for an id.
	* This operation returns the component id for an id, if the id is associated
	* with a type. For a regular component with a non-zero size (an entity with the
	* Component component) the operation will return the entity itself.
	*
	* For an entity that does not have the Component component, or with an
	* Component value with size 0, the operation will return 0.
	*
	* For a pair id the operation will return the type associated with the pair, by
	* applying the following queries in order:
	* - The first pair element is returned if it is a component
	* - 0 is returned if the relationship entity has the Tag property
	* - The second pair element is returned if it is a component
	* - 0 is returned.
	*
	* @param world The world.
	* @param id The id.
	* @return The type id of the id.
	*/
	get_typeid :: proc(world: ^world_t, id: id_t) -> entity_t ---

	/** Utility to match an id with a pattern.
	* This operation returns true if the provided pattern matches the provided
	* id. The pattern may contain a wildcard (or wildcards, when a pair).
	*
	* @param id The id.
	* @param pattern The pattern to compare with.
	* @return Whether the id matches the pattern.
	*/
	id_match :: proc(id: id_t, pattern: id_t) -> bool ---

	/** Utility to check if id is a pair.
	*
	* @param id The id.
	* @return True if id is a pair.
	*/
	id_is_pair :: proc(id: id_t) -> bool ---

	/** Utility to check if id is a wildcard.
	*
	* @param id The id.
	* @return True if id is a wildcard or a pair containing a wildcard.
	*/
	id_is_wildcard :: proc(id: id_t) -> bool ---

	/** Utility to check if id is an any wildcard.
	*
	* @param id The id.
	* @return True if id is an any wildcard or a pair containing an any wildcard.
	*/
	id_is_any :: proc(id: id_t) -> bool ---

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
	* @param id The id.
	* @return True if the id is valid.
	*/
	id_is_valid :: proc(world: ^world_t, id: id_t) -> bool ---

	/** Get flags associated with id.
	* This operation returns the internal flags (see api_flags.h) that are
	* associated with the provided id.
	*
	* @param world The world.
	* @param id The id.
	* @return Flags associated with the id, or 0 if the id is not in use.
	*/
	id_get_flags :: proc(world: ^world_t, id: id_t) -> flags32_t ---

	/** Convert id flag to string.
	* This operation converts an id flag to a string.
	*
	* @param id_flags The id flag.
	* @return The id flag string, or NULL if no valid id is provided.
	*/
	id_flag_str :: proc(id_flags: id_t) -> cstring ---

	/** Convert (component) id to string.
	* This operation interprets the structure of an id and converts it to a string.
	*
	* @param world The world.
	* @param id The id to convert to a string.
	* @return The id converted to a string.
	*/
	id_str :: proc(world: ^world_t, id: id_t) -> cstring ---

	/** Write (component) id string to buffer.
	* Same as ecs_id_str() but writes result to ecs_strbuf_t.
	*
	* @param world The world.
	* @param id The id to convert to a string.
	* @param buf The buffer to write to.
	*/
	id_str_buf :: proc(world: ^world_t, id: id_t, buf: ^strbuf_t) ---

	/** Convert string to a (component) id.
	* This operation is the reverse of ecs_id_str(). The FLECS_SCRIPT addon
	* is required for this operation to work.
	*
	* @param world The world.
	* @param expr The string to convert to an id.
	*/
	id_from_str :: proc(world: ^world_t, expr: cstring) -> id_t ---

	/** Test whether term id is set.
	*
	* @param id The term id.
	* @return True when set, false when not set.
	*/
	term_ref_is_set :: proc(id: ^term_ref_t) -> bool ---

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
	* - ecs_term_t::src::id is This
	* - ecs_term_t::src::flags is IsVariable
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
	* - ecs_term_t::src::flags has IsEntity set
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
	* @param id The (component) id to iterate.
	* @return An iterator that iterates all entities with the (component) id.
	*/
	each_id :: proc(world: ^world_t, id: id_t) -> iter_t ---

	/** Progress an iterator created with ecs_each_id().
	*
	* @param it The iterator.
	* @return True if the iterator has more results, false if not.
	*/
	each_next :: proc(it: ^iter_t) -> bool ---

	/** Iterate children of parent.
	* This operation is usually equivalent to doing:
	* @code
	* ecs_iter_t it = ecs_each_id(world, ecs_pair(ChildOf, parent));
	* @endcode
	*
	* The only exception is when the parent has the OrderedChildren trait, in
	* which case this operation will return a single result with the ordered
	* child entity ids.
	*
	* @param world The world.
	* @param parent The parent.
	* @return An iterator that iterates all children of the parent.
	*
	* @see ecs_each_id()
	*/
	children :: proc(world: ^world_t, parent: entity_t) -> iter_t ---

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
	* To use this you must set the IterProfile flag on an iterator before
	* starting iteration:
	*
	* @code
	*   it.flags |= IterProfile
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
	* The operation will not return true after a write-only (Out) or filter
	* (InOutNone) term has changed, when a term is not matched with the
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
	* Wildcard, which means the variable can assume any value.
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

	/** Get type index for id.
	* This operation returns the index for an id in the table's type.
	*
	* @param world The world.
	* @param table The table.
	* @param id The id.
	* @return The index of the id in the table type, or -1 if not found.
	*
	* @see ecs_table_has_id()
	*/
	table_get_type_index :: proc(world: ^world_t, table: ^table_t, id: id_t) -> i32 ---

	/** Get column index for id.
	* This operation returns the column index for an id in the table's type. If the
	* id is not a component, the function will return -1.
	*
	* @param world The world.
	* @param table The table.
	* @param id The component id.
	* @return The column index of the id, or -1 if not found/not a component.
	*/
	table_get_column_index :: proc(world: ^world_t, table: ^table_t, id: id_t) -> i32 ---

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

	/** Get column from table by component id.
	* This operation returns the component array for the provided component  id.
	*
	* @param world The world.
	* @param table The table.
	* @param id The component id for the column.
	* @param offset The index of the first row to return (0 for entire column).
	* @return The component array, or NULL if the index is not a component.
	*/
	table_get_id :: proc(world: ^world_t, table: ^table_t, id: id_t, offset: i32) -> rawptr ---

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

	/** Test if table has id.
	* Same as `ecs_table_get_type_index(world, table, id) != -1`.
	*
	* @param world The world.
	* @param table The table.
	* @param id The id.
	* @return True if the table has the id, false if the table doesn't.
	*
	* @see ecs_table_get_type_index()
	*/
	table_has_id :: proc(world: ^world_t, table: ^table_t, id: id_t) -> bool ---

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
	* @param id The id to add.
	* @result The resulting table.
	*/
	table_add_id :: proc(world: ^world_t, table: ^table_t, id: id_t) -> ^table_t ---

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

	/** Get table that has all components of current table minus the specified id.
	* If the provided table doesn't have the provided id, the operation will return
	* the provided table.
	*
	* @param world The world.
	* @param table The table.
	* @param id The id to remove.
	* @result The resulting table.
	*/
	table_remove_id :: proc(world: ^world_t, table: ^table_t, id: id_t) -> ^table_t ---

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

	/** Search for component id in table type.
	* This operation returns the index of first occurrence of the id in the table
	* type. The id may be a wildcard.
	*
	* When id_out is provided, the function will assign it with the found id. The
	* found id may be different from the provided id if it is a wildcard.
	*
	* This is a constant time operation.
	*
	* @param world The world.
	* @param table The table.
	* @param id The id to search for.
	* @param id_out If provided, it will be set to the found id (optional).
	* @return The index of the id in the table type.
	*
	* @see ecs_search_offset()
	* @see ecs_search_relation()
	*/
	search :: proc(world: ^world_t, table: ^table_t, id: id_t, id_out: ^id_t) -> i32 ---

	/** Search for component id in table type starting from an offset.
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
	* If the provided id has the form `(*, tgt)` the operation takes linear time. The
	* reason for this is that ids for an target are not packed together, as they
	* are sorted relationship first.
	*
	* If the id at the offset does not match the provided id, the operation will do
	* a linear search to find a matching id.
	*
	* @param world The world.
	* @param table The table.
	* @param offset Offset from where to start searching.
	* @param id The id to search for.
	* @param id_out If provided, it will be set to the found id (optional).
	* @return The index of the id in the table type.
	*
	* @see ecs_search()
	* @see ecs_search_relation()
	*/
	search_offset :: proc(world: ^world_t, table: ^table_t, offset: i32, id: id_t, id_out: ^id_t) -> i32 ---

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
	*   IsA,           // the relationship to traverse
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
	* @param id The id to search for.
	* @param rel The relationship to traverse (optional).
	* @param flags Whether to search Self and/or Up.
	* @param subject_out If provided, it will be set to the matched entity.
	* @param id_out If provided, it will be set to the found id (optional).
	* @param tr_out Internal datatype.
	* @return The index of the id in the table type.
	*
	* @see ecs_search()
	* @see ecs_search_offset()
	*/
	search_relation :: proc(world: ^world_t, table: ^table_t, offset: i32, id: id_t, rel: entity_t, flags: flags64_t, subject_out: ^entity_t, id_out: ^id_t, tr_out: ^^table_record_t) -> i32 ---

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
	value_init :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> c.int ---

	/** Construct a value in existing storage
	*
	* @param world The world.
	* @param ti The type info of the type to create.
	* @param ptr Pointer to a value of type 'type'
	* @return Zero if success, nonzero if failed.
	*/
	value_init_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, ptr: rawptr) -> c.int ---

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
	value_fini_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, ptr: rawptr) -> c.int ---

	/** Destruct a value
	*
	* @param world The world.
	* @param type The type of the value to destruct.
	* @param ptr Pointer to constructed value of type 'type'.
	* @return Zero if success, nonzero if failed.
	*/
	value_fini :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> c.int ---

	/** Destruct a value, free storage
	*
	* @param world The world.
	* @param type The type of the value to destruct.
	* @param ptr A pointer to the value.
	* @return Zero if success, nonzero if failed.
	*/
	value_free :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> c.int ---

	/** Copy value.
	*
	* @param world The world.
	* @param ti Type info of the value to copy.
	* @param dst Pointer to the storage to copy to.
	* @param src Pointer to the value to copy.
	* @return Zero if success, nonzero if failed.
	*/
	value_copy_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Copy value.
	*
	* @param world The world.
	* @param type The type of the value to copy.
	* @param dst Pointer to the storage to copy to.
	* @param src Pointer to the value to copy.
	* @return Zero if success, nonzero if failed.
	*/
	value_copy :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Move value.
	*
	* @param world The world.
	* @param ti Type info of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Move value.
	*
	* @param world The world.
	* @param type The type of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Move construct value.
	*
	* @param world The world.
	* @param ti Type info of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_ctor_w_type_info :: proc(world: ^world_t, ti: ^type_info_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Move construct value.
	*
	* @param world The world.
	* @param type The type of the value to move.
	* @param dst Pointer to the storage to move to.
	* @param src Pointer to the value to move.
	* @return Zero if success, nonzero if failed.
	*/
	value_move_ctor :: proc(world: ^world_t, type: entity_t, dst: rawptr, src: rawptr) -> c.int ---

	/** Log message indicating an operation is deprecated. */
	deprecated_ :: proc(file: cstring, line: i32, msg: cstring) ---

	/** Increase log stack.
	* This operation increases the indent_ value of the OS API and can be useful to
	* make nested behavior more visible.
	*
	* @param level The log level.
	*/
	log_push_ :: proc(level: i32) ---

	/** Decrease log stack.
	* This operation decreases the indent_ value of the OS API and can be useful to
	* make nested behavior more visible.
	*
	* @param level The log level.
	*/
	log_pop_ :: proc(level: i32) ---

	/** Should current level be logged.
	* This operation returns true when the specified log level should be logged
	* with the current log level.
	*
	* @param level The log level to check for.
	* @return Whether logging is enabled for the current level.
	*/
	should_log :: proc(level: i32) -> bool ---

	/** Get description for error code */
	strerror :: proc(error_code: i32) -> cstring ---

	////////////////////////////////////////////////////////////////////////////////
	//// Logging functions (do nothing when logging is enabled)
	////////////////////////////////////////////////////////////////////////////////
	print_ :: proc(level: i32, file: cstring, line: i32, fmt: cstring, #c_vararg _: ..any) ---
	printv_ :: proc(level: c.int, file: cstring, line: i32, fmt: cstring, args: ^c.va_list) ---
	log_ :: proc(level: i32, file: cstring, line: i32, fmt: cstring, #c_vararg _: ..any) ---
	logv_ :: proc(level: c.int, file: cstring, line: i32, fmt: cstring, args: ^c.va_list) ---
	abort_ :: proc(error_code: i32, file: cstring, line: i32, fmt: cstring, #c_vararg _: ..any) ---
	assert_log_ :: proc(error_code: i32, condition_str: cstring, file: cstring, line: i32, fmt: cstring, #c_vararg _: ..any) ---
	parser_error_ :: proc(name: cstring, expr: cstring, column: i64, fmt: cstring, #c_vararg _: ..any) ---
	parser_errorv_ :: proc(name: cstring, expr: cstring, column: i64, fmt: cstring, args: ^c.va_list) ---
	parser_warning_ :: proc(name: cstring, expr: cstring, column: i64, fmt: cstring, #c_vararg _: ..any) ---
	parser_warningv_ :: proc(name: cstring, expr: cstring, column: i64, fmt: cstring, args: ^c.va_list) ---

	/** Enable or disable log.
	* This will enable builtin log. For log to work, it will have to be
	* compiled in which requires defining one of the following macros:
	*
	* FLECS_LOG_0 - All log is disabled
	* FLECS_LOG_1 - Enable log level 1
	* FLECS_LOG_2 - Enable log level 2 and below
	* FLECS_LOG_3 - Enable log level 3 and below
	*
	* If no log level is defined and this is a debug build, FLECS_LOG_3 will
	* have been automatically defined.
	*
	* The provided level corresponds with the log level. If -1 is provided as
	* value, warnings are disabled. If -2 is provided, errors are disabled as well.
	*
	* @param level Desired tracing level.
	* @return Previous log level.
	*/
	log_set_level :: proc(level: c.int) -> c.int ---

	/** Get current log level.
	*
	* @return Previous log level.
	*/
	log_get_level :: proc() -> c.int ---

	/** Enable/disable tracing with colors.
	* By default colors are enabled.
	*
	* @param enabled Whether to enable tracing with colors.
	* @return Previous color setting.
	*/
	log_enable_colors :: proc(enabled: bool) -> bool ---

	/** Enable/disable logging timestamp.
	* By default timestamps are disabled. Note that enabling timestamps introduces
	* overhead as the logging code will need to obtain the current time.
	*
	* @param enabled Whether to enable tracing with timestamps.
	* @return Previous timestamp setting.
	*/
	log_enable_timestamp :: proc(enabled: bool) -> bool ---

	/** Enable/disable logging time since last log.
	* By default deltatime is disabled. Note that enabling timestamps introduces
	* overhead as the logging code will need to obtain the current time.
	*
	* When enabled, this logs the amount of time in seconds passed since the last
	* log, when this amount is non-zero. The format is a '+' character followed by
	* the number of seconds:
	*
	*     +1 trace: log message
	*
	* @param enabled Whether to enable tracing with timestamps.
	* @return Previous timestamp setting.
	*/
	log_enable_timedelta :: proc(enabled: bool) -> bool ---

	/** Get last logged error code.
	* Calling this operation resets the error code.
	*
	* @return Last error, 0 if none was logged since last call to last_error.
	*/
	log_last_error :: proc() -> c.int ---

	/** Run application.
	* This will run the application with the parameters specified in desc. After
	* the application quits (ecs_quit() is called) the world will be cleaned up.
	*
	* If a custom run action is set, it will be invoked by this operation. The
	* default run action calls the frame action in a loop until it returns a
	* non-zero value.
	*
	* @param world The world.
	* @param desc Application parameters.
	*/
	app_run :: proc(world: ^world_t, desc: ^app_desc_t) -> c.int ---

	/** Default frame callback.
	* This operation will run a single frame. By default this operation will invoke
	* ecs_progress() directly, unless a custom frame action is set.
	*
	* @param world The world.
	* @param desc The desc struct passed to ecs_app_run().
	* @return value returned by ecs_progress()
	*/
	app_run_frame :: proc(world: ^world_t, desc: ^app_desc_t) -> c.int ---

	/** Set custom run action.
	* See ecs_app_run().
	*
	* @param callback The run action.
	*/
	app_set_run_action :: proc(callback: app_run_action_t) -> c.int ---

	/** Set custom frame action.
	* See ecs_app_run_frame().
	*
	* @param callback The frame action.
	*/
	app_set_frame_action :: proc(callback: app_frame_action_t) -> c.int ---

	/** Create server.
	* Use ecs_http_server_start() to start receiving requests.
	*
	* @param desc Server configuration parameters.
	* @return The new server, or NULL if creation failed.
	*/
	http_server_init :: proc(desc: ^http_server_desc_t) -> ^http_server_t ---

	/** Destroy server.
	* This operation will stop the server if it was still running.
	*
	* @param server The server to destroy.
	*/
	http_server_fini :: proc(server: ^http_server_t) ---

	/** Start server.
	* After this operation the server will be able to accept requests.
	*
	* @param server The server to start.
	* @return Zero if successful, non-zero if failed.
	*/
	http_server_start :: proc(server: ^http_server_t) -> c.int ---

	/** Process server requests.
	* This operation invokes the reply callback for each received request. No new
	* requests will be enqueued while processing requests.
	*
	* @param server The server for which to process requests.
	*/
	http_server_dequeue :: proc(server: ^http_server_t, delta_time: f32) ---

	/** Stop server.
	* After this operation no new requests can be received.
	*
	* @param server The server.
	*/
	http_server_stop :: proc(server: ^http_server_t) ---

	/** Emulate a request.
	* The request string must be a valid HTTP request. A minimal example:
	*
	*     GET /entity/flecs/core/World?label=true HTTP/1.1
	*
	* @param srv The server.
	* @param req The request.
	* @param len The length of the request (optional).
	* @return The reply.
	*/
	http_server_http_request :: proc(srv: ^http_server_t, req: cstring, len: size_t, reply_out: ^http_reply_t) -> c.int ---

	/** Convenience wrapper around ecs_http_server_http_request(). */
	http_server_request :: proc(srv: ^http_server_t, method: cstring, req: cstring, body: cstring, reply_out: ^http_reply_t) -> c.int ---

	/** Get context provided in ecs_http_server_desc_t */
	http_server_ctx :: proc(srv: ^http_server_t) -> rawptr ---

	/** Find header in request.
	*
	* @param req The request.
	* @param name name of the header to find
	* @return The header value, or NULL if not found.
	*/
	http_get_header :: proc(req: ^http_request_t, name: cstring) -> cstring ---

	/** Find query parameter in request.
	*
	* @param req The request.
	* @param name The parameter name.
	* @return The decoded parameter value, or NULL if not found.
	*/
	http_get_param :: proc(req: ^http_request_t, name: cstring) -> cstring ---

	/** Create HTTP server for REST API.
	* This allows for the creation of a REST server that can be managed by the
	* application without using Flecs systems.
	*
	* @param world The world.
	* @param desc The HTTP server descriptor.
	* @return The HTTP server, or NULL if failed.
	*/
	rest_server_init :: proc(world: ^world_t, desc: ^http_server_desc_t) -> ^http_server_t ---

	/** Cleanup REST HTTP server.
	* The server must have been created with ecs_rest_server_init().
	*/
	rest_server_fini :: proc(srv: ^http_server_t) ---

	/** Rest module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsRest)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsRestImport :: proc(world: ^world_t) ---

	/** Set timer timeout.
	* This operation executes any systems associated with the timer after the
	* specified timeout value. If the entity contains an existing timer, the
	* timeout value will be reset. The timer can be started and stopped with
	* ecs_start_timer() and ecs_stop_timer().
	*
	* The timer is synchronous, and is incremented each frame by delta_time.
	*
	* The tick_source entity will be a tick source after this operation. Tick
	* sources can be read by getting the TickSource component. If the tick
	* source ticked this frame, the 'tick' member will be true. When the tick
	* source is a system, the system will tick when the timer ticks.
	*
	* @param world The world.
	* @param tick_source The timer for which to set the timeout (0 to create one).
	* @param timeout The timeout value.
	* @return The timer entity.
	*/
	set_timeout :: proc(world: ^world_t, tick_source: entity_t, timeout: f32) -> entity_t ---

	/** Get current timeout value for the specified timer.
	* This operation returns the value set by ecs_set_timeout(). If no timer is
	* active for this entity, the operation returns 0.
	*
	* After the timeout expires the Timer component is removed from the entity.
	* This means that if ecs_get_timeout() is invoked after the timer is expired, the
	* operation will return 0.
	*
	* The timer is synchronous, and is incremented each frame by delta_time.
	*
	* The tick_source entity will be a tick source after this operation. Tick
	* sources can be read by getting the TickSource component. If the tick
	* source ticked this frame, the 'tick' member will be true. When the tick
	* source is a system, the system will tick when the timer ticks.
	*
	* @param world The world.
	* @param tick_source The timer.
	* @return The current timeout value, or 0 if no timer is active.
	*/
	get_timeout :: proc(world: ^world_t, tick_source: entity_t) -> f32 ---

	/** Set timer interval.
	* This operation will continuously invoke systems associated with the timer
	* after the interval period expires. If the entity contains an existing timer,
	* the interval value will be reset.
	*
	* The timer is synchronous, and is incremented each frame by delta_time.
	*
	* The tick_source entity will be a tick source after this operation. Tick
	* sources can be read by getting the TickSource component. If the tick
	* source ticked this frame, the 'tick' member will be true. When the tick
	* source is a system, the system will tick when the timer ticks.
	*
	* @param world The world.
	* @param tick_source The timer for which to set the interval (0 to create one).
	* @param interval The interval value.
	* @return The timer entity.
	*/
	set_interval :: proc(world: ^world_t, tick_source: entity_t, interval: f32) -> entity_t ---

	/** Get current interval value for the specified timer.
	* This operation returns the value set by ecs_set_interval(). If the entity is
	* not a timer, the operation will return 0.
	*
	* @param world The world.
	* @param tick_source The timer for which to set the interval.
	* @return The current interval value, or 0 if no timer is active.
	*/
	get_interval :: proc(world: ^world_t, tick_source: entity_t) -> f32 ---

	/** Start timer.
	* This operation resets the timer and starts it with the specified timeout.
	*
	* @param world The world.
	* @param tick_source The timer to start.
	*/
	start_timer :: proc(world: ^world_t, tick_source: entity_t) ---

	/** Stop timer
	* This operation stops a timer from triggering.
	*
	* @param world The world.
	* @param tick_source The timer to stop.
	*/
	stop_timer :: proc(world: ^world_t, tick_source: entity_t) ---

	/** Reset time value of timer to 0.
	* This operation resets the timer value to 0.
	*
	* @param world The world.
	* @param tick_source The timer to reset.
	*/
	reset_timer :: proc(world: ^world_t, tick_source: entity_t) ---

	/** Enable randomizing initial time value of timers.
	* Initializes timers with a random time value, which can improve scheduling as
	* systems/timers for the same interval don't all happen on the same tick.
	*
	* @param world The world.
	*/
	randomize_timers :: proc(world: ^world_t) ---

	/** Set rate filter.
	* This operation initializes a rate filter. Rate filters sample tick sources
	* and tick at a configurable multiple. A rate filter is a tick source itself,
	* which means that rate filters can be chained.
	*
	* Rate filters enable deterministic system execution which cannot be achieved
	* with interval timers alone. For example, if timer A has interval 2.0 and
	* timer B has interval 4.0, it is not guaranteed that B will tick at exactly
	* twice the multiple of A. This is partly due to the indeterministic nature of
	* timers, and partly due to floating point rounding errors.
	*
	* Rate filters can be combined with timers (or other rate filters) to ensure
	* that a system ticks at an exact multiple of a tick source (which can be
	* another system). If a rate filter is created with a rate of 1 it will tick
	* at the exact same time as its source.
	*
	* If no tick source is provided, the rate filter will use the frame tick as
	* source, which corresponds with the number of times ecs_progress() is called.
	*
	* The tick_source entity will be a tick source after this operation. Tick
	* sources can be read by getting the TickSource component. If the tick
	* source ticked this frame, the 'tick' member will be true. When the tick
	* source is a system, the system will tick when the timer ticks.
	*
	* @param world The world.
	* @param tick_source The rate filter entity (0 to create one).
	* @param rate The rate to apply.
	* @param source The tick source (0 to use frames)
	* @return The filter entity.
	*/
	set_rate :: proc(world: ^world_t, tick_source: entity_t, rate: i32, source: entity_t) -> entity_t ---

	/** Assign tick source to system.
	* Systems can be their own tick source, which can be any of the tick sources
	* (one shot timers, interval times and rate filters). However, in some cases it
	* is must be guaranteed that different systems tick on the exact same frame.
	*
	* This cannot be guaranteed by giving two systems the same interval/rate filter
	* as it is possible that one system is (for example) disabled, which would
	* cause the systems to go out of sync. To provide these guarantees, systems
	* must use the same tick source, which is what this operation enables.
	*
	* When two systems share the same tick source, it is guaranteed that they tick
	* in the same frame. The provided tick source can be any entity that is a tick
	* source, including another system. If the provided entity is not a tick source
	* the system will not be ran.
	*
	* To disassociate a tick source from a system, use 0 for the tick_source
	* parameter.
	*
	* @param world The world.
	* @param system The system to associate with the timer.
	* @param tick_source The tick source to associate with the system.
	*/
	set_tick_source :: proc(world: ^world_t, system: entity_t, tick_source: entity_t) ---

	/** Timer module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsTimer)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsTimerImport :: proc(world: ^world_t) ---

	/** Create a custom pipeline.
	*
	* @param world The world.
	* @param desc The pipeline descriptor.
	* @return The pipeline, 0 if failed.
	*/
	pipeline_init :: proc(world: ^world_t, desc: ^pipeline_desc_t) -> entity_t ---

	/** Set a custom pipeline.
	* This operation sets the pipeline to run when ecs_progress() is invoked.
	*
	* @param world The world.
	* @param pipeline The pipeline to set.
	*/
	set_pipeline :: proc(world: ^world_t, pipeline: entity_t) ---

	/** Get the current pipeline.
	* This operation gets the current pipeline.
	*
	* @param world The world.
	* @return The current pipeline.
	*/
	get_pipeline :: proc(world: ^world_t) -> entity_t ---

	/** Progress a world.
	* This operation progresses the world by running all systems that are both
	* enabled and periodic on their matching entities.
	*
	* An application can pass a delta_time into the function, which is the time
	* passed since the last frame. This value is passed to systems so they can
	* update entity values proportional to the elapsed time since their last
	* invocation.
	*
	* When an application passes 0 to delta_time, ecs_progress() will automatically
	* measure the time passed since the last frame. If an application does not uses
	* time management, it should pass a non-zero value for delta_time (1.0 is
	* recommended). That way, no time will be wasted measuring the time.
	*
	* @param world The world to progress.
	* @param delta_time The time passed since the last frame.
	* @return false if ecs_quit() has been called, true otherwise.
	*/
	progress :: proc(world: ^world_t, delta_time: f32) -> bool ---

	/** Set time scale.
	* Increase or decrease simulation speed by the provided multiplier.
	*
	* @param world The world.
	* @param scale The scale to apply (default = 1).
	*/
	set_time_scale :: proc(world: ^world_t, scale: f32) ---

	/** Reset world clock.
	* Reset the clock that keeps track of the total time passed in the simulation.
	*
	* @param world The world.
	*/
	reset_clock :: proc(world: ^world_t) ---

	/** Run pipeline.
	* This will run all systems in the provided pipeline. This operation may be
	* invoked from multiple threads, and only when staging is disabled, as the
	* pipeline manages staging and, if necessary, synchronization between threads.
	*
	* If 0 is provided for the pipeline id, the default pipeline will be ran (this
	* is either the builtin pipeline or the pipeline set with set_pipeline()).
	*
	* When using progress() this operation will be invoked automatically for the
	* default pipeline (either the builtin pipeline or the pipeline set with
	* set_pipeline()). An application may run additional pipelines.
	*
	* @param world The world.
	* @param pipeline The pipeline to run.
	* @param delta_time The delta_time to pass to systems.
	*/
	run_pipeline :: proc(world: ^world_t, pipeline: entity_t, delta_time: f32) ---

	/** Set number of worker threads.
	* Setting this value to a value higher than 1 will start as many threads and
	* will cause systems to evenly distribute matched entities across threads. The
	* operation may be called multiple times to reconfigure the number of threads
	* used, but never while running a system / pipeline.
	* Calling ecs_set_threads() will also end the use of task threads setup with
	* ecs_set_task_threads() and vice-versa.
	*
	* @param world The world.
	* @param threads The number of threads to create.
	*/
	set_threads :: proc(world: ^world_t, threads: i32) ---

	/** Set number of worker task threads.
	* ecs_set_task_threads() is similar to ecs_set_threads(), except threads are treated
	* as short-lived tasks and will be created and joined around each update of the world.
	* Creation and joining of these tasks will use the os_api_t tasks APIs rather than the
	* the standard thread API functions, although they may be the same if desired.
	* This function is useful for multithreading world updates using an external
	* asynchronous job system rather than long running threads by providing the APIs
	* to create tasks for your job system and then wait on their conclusion.
	* The operation may be called multiple times to reconfigure the number of task threads
	* used, but never while running a system / pipeline.
	* Calling ecs_set_task_threads() will also end the use of threads setup with
	* ecs_set_threads() and vice-versa
	*
	* @param world The world.
	* @param task_threads The number of task threads to create.
	*/
	set_task_threads :: proc(world: ^world_t, task_threads: i32) ---

	/** Returns true if task thread use have been requested.
	*
	* @param world The world.
	* @result Whether the world is using task threads.
	*/
	using_task_threads :: proc(world: ^world_t) -> bool ---

	/** Pipeline module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsPipeline)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsPipelineImport :: proc(world: ^world_t) ---

	/** Create a system */
	system_init :: proc(world: ^world_t, desc: ^system_desc_t) -> entity_t ---

	/** Get system object.
	* Returns the system object. Can be used to access various information about
	* the system, like the query and context.
	*
	* @param world The world.
	* @param system The system.
	* @return The system object.
	*/
	system_get :: proc(world: ^world_t, system: entity_t) -> ^system_t ---

	/** Run a specific system manually.
	* This operation runs a single system manually. It is an efficient way to
	* invoke logic on a set of entities, as manual systems are only matched to
	* tables at creation time or after creation time, when a new table is created.
	*
	* Manual systems are useful to evaluate lists of pre-matched entities at
	* application defined times. Because none of the matching logic is evaluated
	* before the system is invoked, manual systems are much more efficient than
	* manually obtaining a list of entities and retrieving their components.
	*
	* An application may pass custom data to a system through the param parameter.
	* This data can be accessed by the system through the param member in the
	* ecs_iter_t value that is passed to the system callback.
	*
	* Any system may interrupt execution by setting the interrupted_by member in
	* the ecs_iter_t value. This is particularly useful for manual systems, where
	* the value of interrupted_by is returned by this operation. This, in
	* combination with the param argument lets applications use manual systems
	* to lookup entities: once the entity has been found its handle is passed to
	* interrupted_by, which is then subsequently returned.
	*
	* @param world The world.
	* @param system The system to run.
	* @param delta_time The time passed since the last system invocation.
	* @param param A user-defined parameter to pass to the system.
	* @return handle to last evaluated entity if system was interrupted.
	*/
	@(link_prefix = "")
	ecs_run :: proc(world: ^world_t, system: entity_t, delta_time: f32, param: rawptr) -> entity_t ---

	/** Same as ecs_run(), but subdivides entities across number of provided stages.
	*
	* @param world The world.
	* @param system The system to run.
	* @param stage_current The id of the current stage.
	* @param stage_count The total number of stages.
	* @param delta_time The time passed since the last system invocation.
	* @param param A user-defined parameter to pass to the system.
	* @return handle to last evaluated entity if system was interrupted.
	*/
	run_worker :: proc(world: ^world_t, system: entity_t, stage_current: i32, stage_count: i32, delta_time: f32, param: rawptr) -> entity_t ---

	/** System module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsSystem)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsSystemImport :: proc(world: ^world_t) ---

	/** Get world statistics.
	*
	* @param world The world.
	* @param stats Out parameter for statistics.
	*/
	world_stats_get :: proc(world: ^world_t, stats: ^world_stats_t) ---

	/** Reduce source measurement window into single destination measurement. */
	world_stats_reduce :: proc(dst: ^world_stats_t, src: ^world_stats_t) ---

	/** Reduce last measurement into previous measurement, restore old value. */
	world_stats_reduce_last :: proc(stats: ^world_stats_t, old: ^world_stats_t, count: i32) ---

	/** Repeat last measurement. */
	world_stats_repeat_last :: proc(stats: ^world_stats_t) ---

	/** Copy last measurement from source to destination. */
	world_stats_copy_last :: proc(dst: ^world_stats_t, src: ^world_stats_t) ---
	world_stats_log :: proc(world: ^world_t, stats: ^world_stats_t) ---

	/** Get query statistics.
	* Obtain statistics for the provided query.
	*
	* @param world The world.
	* @param query The query.
	* @param stats Out parameter for statistics.
	*/
	query_stats_get :: proc(world: ^world_t, query: ^query_t, stats: ^query_stats_t) ---

	/** Reduce source measurement window into single destination measurement. */
	query_cache_stats_reduce :: proc(dst: ^query_stats_t, src: ^query_stats_t) ---

	/** Reduce last measurement into previous measurement, restore old value. */
	query_cache_stats_reduce_last :: proc(stats: ^query_stats_t, old: ^query_stats_t, count: i32) ---

	/** Repeat last measurement. */
	query_cache_stats_repeat_last :: proc(stats: ^query_stats_t) ---

	/** Copy last measurement from source to destination. */
	query_cache_stats_copy_last :: proc(dst: ^query_stats_t, src: ^query_stats_t) ---

	/** Get system statistics.
	* Obtain statistics for the provided system.
	*
	* @param world The world.
	* @param system The system.
	* @param stats Out parameter for statistics.
	* @return true if success, false if not a system.
	*/
	system_stats_get :: proc(world: ^world_t, system: entity_t, stats: ^system_stats_t) -> bool ---

	/** Reduce source measurement window into single destination measurement */
	system_stats_reduce :: proc(dst: ^system_stats_t, src: ^system_stats_t) ---

	/** Reduce last measurement into previous measurement, restore old value. */
	system_stats_reduce_last :: proc(stats: ^system_stats_t, old: ^system_stats_t, count: i32) ---

	/** Repeat last measurement. */
	system_stats_repeat_last :: proc(stats: ^system_stats_t) ---

	/** Copy last measurement from source to destination. */
	system_stats_copy_last :: proc(dst: ^system_stats_t, src: ^system_stats_t) ---

	/** Get pipeline statistics.
	* Obtain statistics for the provided pipeline.
	*
	* @param world The world.
	* @param pipeline The pipeline.
	* @param stats Out parameter for statistics.
	* @return true if success, false if not a pipeline.
	*/
	pipeline_stats_get :: proc(world: ^world_t, pipeline: entity_t, stats: ^pipeline_stats_t) -> bool ---

	/** Free pipeline stats.
	*
	* @param stats The stats to free.
	*/
	pipeline_stats_fini :: proc(stats: ^pipeline_stats_t) ---

	/** Reduce source measurement window into single destination measurement */
	pipeline_stats_reduce :: proc(dst: ^pipeline_stats_t, src: ^pipeline_stats_t) ---

	/** Reduce last measurement into previous measurement, restore old value. */
	pipeline_stats_reduce_last :: proc(stats: ^pipeline_stats_t, old: ^pipeline_stats_t, count: i32) ---

	/** Repeat last measurement. */
	pipeline_stats_repeat_last :: proc(stats: ^pipeline_stats_t) ---

	/** Copy last measurement to destination.
	* This operation copies the last measurement into the destination. It does not
	* modify the cursor.
	*
	* @param dst The metrics.
	* @param src The metrics to copy.
	*/
	pipeline_stats_copy_last :: proc(dst: ^pipeline_stats_t, src: ^pipeline_stats_t) ---

	/** Reduce all measurements from a window into a single measurement. */
	metric_reduce :: proc(dst: ^metric_t, src: ^metric_t, t_dst: i32, t_src: i32) ---

	/** Reduce last measurement into previous measurement */
	metric_reduce_last :: proc(m: ^metric_t, t: i32, count: i32) ---

	/** Copy measurement */
	metric_copy :: proc(m: ^metric_t, dst: i32, src: i32) ---

	/** Stats module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsStats)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsStatsImport :: proc(world: ^world_t) ---

	/** Create a new metric.
	* Metrics are entities that store values measured from a range of different
	* properties in the ECS storage. Metrics provide a single unified interface to
	* discovering and reading these values, which can be useful for monitoring
	* utilities, or for debugging.
	*
	* Examples of properties that can be measured by metrics are:
	*  - Component member values
	*  - How long an entity has had a specific component
	*  - How long an entity has had a specific target for a relationship
	*  - How many entities have a specific component
	*
	* Metrics can either be created as a "gauge" or "counter". A gauge is a metric
	* that represents the value of something at a specific point in time, for
	* example "velocity". A counter metric represents a value that is monotonically
	* increasing, for example "miles driven".
	*
	* There are three different kinds of counter metric kinds:
	* - Counter
	*   When combined with a member, this will store the actual value of the member
	*   in the metric. This is useful for values that are already counters, such as
	*   a MilesDriven component.
	*   This kind creates a metric per entity that has the member/id.
	*
	* - CounterIncrement
	*   When combined with a member, this will increment the value of the metric by
	*   the value of the member * delta_time. This is useful for values that are
	*   not counters, such as a Velocity component.
	*   This kind creates a metric per entity that has the member.
	*
	* - CounterId
	*   This metric kind will count the number of entities with a specific
	*   (component) id. This kind creates a single metric instance for regular ids,
	*   and a metric instance per target for wildcard ids when targets is set.
	*
	* @param world The world.
	* @param desc Metric description.
	* @return The metric entity.
	*/
	metric_init :: proc(world: ^world_t, desc: ^metric_desc_t) -> entity_t ---

	/** Metrics module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsMetrics)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsMetricsImport :: proc(world: ^world_t) ---

	/** Create a new alert.
	* An alert is a query that is evaluated periodically and creates alert
	* instances for each entity that matches the query. Alerts can be used to
	* automate detection of errors in an application.
	*
	* Alerts are automatically cleared when a query is no longer true for an alert
	* instance. At most one alert instance will be created per matched entity.
	*
	* Alert instances have three components:
	* - AlertInstance: contains the alert message for the instance
	* - MetricSource: contains the entity that triggered the alert
	* - MetricValue: contains how long the alert has been active
	*
	* Alerts reuse components from the metrics addon so that alert instances can be
	* tracked and discovered as metrics. Just like metrics, alert instances are
	* created as children of the alert.
	*
	* When an entity has active alerts, it will have the AlertsActive component
	* which contains a map with active alerts for the entity. This component
	* will be automatically removed once all alerts are cleared for the entity.
	*
	* @param world The world.
	* @param desc Alert description.
	* @return The alert entity.
	*/
	alert_init :: proc(world: ^world_t, desc: ^alert_desc_t) -> entity_t ---

	/** Return number of active alerts for entity.
	* When a valid alert entity is specified for the alert parameter, the operation
	* will return whether the specified alert is active for the entity. When no
	* alert is specified, the operation will return the total number of active
	* alerts for the entity.
	*
	* @param world The world.
	* @param entity The entity.
	* @param alert The alert to test for (optional).
	* @return The number of active alerts for the entity.
	*/
	get_alert_count :: proc(world: ^world_t, entity: entity_t, alert: entity_t) -> i32 ---

	/** Return alert instance for specified alert.
	* This operation returns the alert instance for the specified alert. If the
	* alert is not active for the entity, the operation will return 0.
	*
	* @param world The world.
	* @param entity The entity.
	* @param alert The alert to test for.
	* @return The alert instance for the specified alert.
	*/
	get_alert :: proc(world: ^world_t, entity: entity_t, alert: entity_t) -> entity_t ---

	/** Alert module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsAlerts)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsAlertsImport :: proc(world: ^world_t) ---

	/** Parse JSON string into value.
	* This operation parses a JSON expression into the provided pointer. The
	* memory pointed to must be large enough to contain a value of the used type.
	*
	* @param world The world.
	* @param type The type of the expression to parse.
	* @param ptr Pointer to the memory to write to.
	* @param json The JSON expression to parse.
	* @param desc Configuration parameters for deserializer.
	* @return Pointer to the character after the last one read, or NULL if failed.
	*/
	ptr_from_json :: proc(world: ^world_t, type: entity_t, ptr: rawptr, json: cstring, desc: ^from_json_desc_t) -> cstring ---

	/** Parse JSON object with multiple component values into entity. The format
	* is the same as the one outputted by ecs_entity_to_json(), but at the moment
	* only supports the "ids" and "values" member.
	*
	* @param world The world.
	* @param entity The entity to serialize to.
	* @param json The JSON expression to parse (see entity in JSON format manual).
	* @param desc Configuration parameters for deserializer.
	* @return Pointer to the character after the last one read, or NULL if failed.
	*/
	entity_from_json :: proc(world: ^world_t, entity: entity_t, json: cstring, desc: ^from_json_desc_t) -> cstring ---

	/** Parse JSON object with multiple entities into the world. The format is the
	* same as the one outputted by ecs_world_to_json().
	*
	* @param world The world.
	* @param json The JSON expression to parse (see iterator in JSON format manual).
	* @param desc Deserialization parameters.
	* @return Last deserialized character, NULL if failed.
	*/
	world_from_json :: proc(world: ^world_t, json: cstring, desc: ^from_json_desc_t) -> cstring ---

	/** Same as ecs_world_from_json(), but loads JSON from file.
	*
	* @param world The world.
	* @param filename The file from which to load the JSON.
	* @param desc Deserialization parameters.
	* @return Last deserialized character, NULL if failed.
	*/
	world_from_json_file :: proc(world: ^world_t, filename: cstring, desc: ^from_json_desc_t) -> cstring ---

	/** Serialize array into JSON string.
	* This operation serializes a value of the provided type to a JSON string. The
	* memory pointed to must be large enough to contain a value of the used type.
	*
	* If count is 0, the function will serialize a single value, not wrapped in
	* array brackets. If count is >= 1, the operation will serialize values to a
	* a comma-separated list inside of array brackets.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @param count The number of elements to serialize.
	* @return String with JSON expression, or NULL if failed.
	*/
	array_to_json :: proc(world: ^world_t, type: entity_t, data: rawptr, count: i32) -> cstring ---

	/** Serialize array into JSON string buffer.
	* Same as ecs_array_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @param count The number of elements to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	array_to_json_buf :: proc(world: ^world_t, type: entity_t, data: rawptr, count: i32, buf_out: ^strbuf_t) -> c.int ---

	/** Serialize value into JSON string.
	* Same as ecs_array_to_json(), with count = 0.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @return String with JSON expression, or NULL if failed.
	*/
	ptr_to_json :: proc(world: ^world_t, type: entity_t, data: rawptr) -> cstring ---

	/** Serialize value into JSON string buffer.
	* Same as ecs_ptr_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	ptr_to_json_buf :: proc(world: ^world_t, type: entity_t, data: rawptr, buf_out: ^strbuf_t) -> c.int ---

	/** Serialize type info to JSON.
	* This serializes type information to JSON, and can be used to store/transmit
	* the structure of a (component) value.
	*
	* If the provided type does not have reflection data, "0" will be returned.
	*
	* @param world The world.
	* @param type The type to serialize to JSON.
	* @return A JSON string with the serialized type info, or NULL if failed.
	*/
	type_info_to_json :: proc(world: ^world_t, type: entity_t) -> cstring ---

	/** Serialize type info into JSON string buffer.
	* Same as ecs_type_info_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param type The type to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	type_info_to_json_buf :: proc(world: ^world_t, type: entity_t, buf_out: ^strbuf_t) -> c.int ---

	/** Serialize entity into JSON string.
	* This creates a JSON object with the entity's (path) name, which components
	* and tags the entity has, and the component values.
	*
	* The operation may fail if the entity contains components with invalid values.
	*
	* @param world The world.
	* @param entity The entity to serialize to JSON.
	* @return A JSON string with the serialized entity data, or NULL if failed.
	*/
	entity_to_json :: proc(world: ^world_t, entity: entity_t, desc: ^entity_to_json_desc_t) -> cstring ---

	/** Serialize entity into JSON string buffer.
	* Same as ecs_entity_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param entity The entity to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	entity_to_json_buf :: proc(world: ^world_t, entity: entity_t, buf_out: ^strbuf_t, desc: ^entity_to_json_desc_t) -> c.int ---

	/** Serialize iterator into JSON string.
	* This operation will iterate the contents of the iterator and serialize them
	* to JSON. The function accepts iterators from any source.
	*
	* @param iter The iterator to serialize to JSON.
	* @return A JSON string with the serialized iterator data, or NULL if failed.
	*/
	iter_to_json :: proc(iter: ^iter_t, desc: ^iter_to_json_desc_t) -> cstring ---

	/** Serialize iterator into JSON string buffer.
	* Same as ecs_iter_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param iter The iterator to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	iter_to_json_buf :: proc(iter: ^iter_t, buf_out: ^strbuf_t, desc: ^iter_to_json_desc_t) -> c.int ---

	/** Serialize world into JSON string.
	* This operation iterates the contents of the world to JSON. The operation is
	* equivalent to the following code:
	*
	* @code
	* ecs_query_t *f = ecs_query(world, {
	*   .terms = {{ .id = Any }}
	* });
	*
	* ecs_iter_t it = ecs_query_init(world, &f);
	* ecs_iter_to_json_desc_t desc = { .serialize_table = true };
	* ecs_iter_to_json(iter, &desc);
	* @endcode
	*
	* @param world The world to serialize.
	* @return A JSON string with the serialized iterator data, or NULL if failed.
	*/
	world_to_json :: proc(world: ^world_t, desc: ^world_to_json_desc_t) -> cstring ---

	/** Serialize world into JSON string buffer.
	* Same as ecs_world_to_json(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world to serialize.
	* @param buf_out The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	world_to_json_buf :: proc(world: ^world_t, buf_out: ^strbuf_t, desc: ^world_to_json_desc_t) -> c.int ---

	/** Units module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsUnits)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsUnitsImport :: proc(world: ^world_t) ---

	/** Parse script.
	* This operation parses a script and returns a script object upon success. To
	* run the script, call ecs_script_eval().
	*
	* If the script uses outside variables, an ecs_script_vars_t object must be
	* provided in the vars member of the desc object that defines all variables
	* with the correct types.
	*
	* @param world The world.
	* @param name Name of the script (typically a file/module name).
	* @param code The script code.
	* @param desc Parameters for script runtime.
	* @return Script object if success, NULL if failed.
	*/
	script_parse :: proc(world: ^world_t, name: cstring, code: cstring, desc: ^script_eval_desc_t) -> ^script_t ---

	/** Evaluate script.
	* This operation evaluates (runs) a parsed script.
	*
	* If variables were provided to ecs_script_parse(), an application may pass
	* a different ecs_script_vars_t object to ecs_script_eval(), as long as the
	* object has all referenced variables and they are of the same type.
	*
	* @param script The script.
	* @param desc Parameters for script runtime.
	* @return Zero if success, non-zero if failed.
	*/
	script_eval :: proc(script: ^script_t, desc: ^script_eval_desc_t) -> c.int ---

	/** Free script.
	* This operation frees a script object.
	*
	* Templates created by the script rely upon resources in the script object,
	* and for that reason keep the script alive until all templates created by the
	* script are deleted.
	*
	* @param script The script.
	*/
	script_free :: proc(script: ^script_t) ---

	/** Parse script.
	* This parses a script and instantiates the entities in the world.
	* This operation is the equivalent to doing:
	*
	* @code
	* ecs_script_t *script = ecs_script_parse(world, name, code);
	* ecs_script_eval(script);
	* ecs_script_free(script);
	* @endcode
	*
	* @param world The world.
	* @param name The script name (typically the file).
	* @param code The script.
	* @return Zero if success, non-zero otherwise.
	*/
	script_run :: proc(world: ^world_t, name: cstring, code: cstring) -> c.int ---

	/** Parse script file.
	* This parses a script file and instantiates the entities in the world. This
	* operation is equivalent to loading the file contents and passing it to
	* ecs_script_run().
	*
	* @param world The world.
	* @param filename The script file name.
	* @return Zero if success, non-zero if failed.
	*/
	script_run_file :: proc(world: ^world_t, filename: cstring) -> c.int ---

	/** Create runtime for script.
	* A script runtime is a container for any data created during script
	* evaluation. By default calling ecs_script_run() or ecs_script_eval() will
	* create a runtime on the spot. A runtime can be created in advance and reused
	* across multiple script evaluations to improve performance.
	*
	* When scripts are evaluated on multiple threads, each thread should have its
	* own script runtime.
	*
	* A script runtime must be deleted with ecs_script_runtime_free().
	*
	* @return A new script runtime.
	*/
	script_runtime_new :: proc() -> ^script_runtime_t ---

	/** Free script runtime.
	* This operation frees a script runtime created by ecs_script_runtime_new().
	*
	* @param runtime The runtime to free.
	*/
	script_runtime_free :: proc(runtime: ^script_runtime_t) ---

	/** Convert script AST to string.
	* This operation converts the script abstract syntax tree to a string, which
	* can be used to debug a script.
	*
	* @param script The script.
	* @param buf The buffer to write to.
	* @return Zero if success, non-zero if failed.
	*/
	script_ast_to_buf :: proc(script: ^script_t, buf: ^strbuf_t, colors: bool) -> c.int ---

	/** Convert script AST to string.
	* This operation converts the script abstract syntax tree to a string, which
	* can be used to debug a script.
	*
	* @param script The script.
	* @return The string if success, NULL if failed.
	*/
	script_ast_to_str :: proc(script: ^script_t, colors: bool) -> cstring ---

	/** Load managed script.
	* A managed script tracks which entities it creates, and keeps those entities
	* synchronized when the contents of the script are updated. When the script is
	* updated, entities that are no longer in the new version will be deleted.
	*
	* This feature is experimental.
	*
	* @param world The world.
	* @param desc Script descriptor.
	*/
	script_init :: proc(world: ^world_t, desc: ^script_desc_t) -> entity_t ---

	/** Update script with new code.
	*
	* @param world The world.
	* @param script The script entity.
	* @param instance An template instance (optional).
	* @param code The script code.
	*/
	script_update :: proc(world: ^world_t, script: entity_t, instance: entity_t, code: cstring) -> c.int ---

	/** Clear all entities associated with script.
	*
	* @param world The world.
	* @param script The script entity.
	* @param instance The script instance.
	*/
	script_clear :: proc(world: ^world_t, script: entity_t, instance: entity_t) ---

	/** Create new variable scope.
	* Create root variable scope. A variable scope contains one or more variables.
	* Scopes can be nested, which allows variables in different scopes to have the
	* same name. Variables from parent scopes will be shadowed by variables in
	* child scopes with the same name.
	*
	* Use the `ecs_script_vars_push()` and `ecs_script_vars_pop()` functions to
	* push and pop variable scopes.
	*
	* When a variable contains allocated resources (e.g. a string), its resources
	* will be freed when `ecs_script_vars_pop()` is called on the scope, the
	* ecs_script_vars_t::type_info field is initialized for the variable, and
	* `ecs_type_info_t::hooks::dtor` is set.
	*
	* @param world The world.
	*/
	script_vars_init :: proc(world: ^world_t) -> ^script_vars_t ---

	/** Free variable scope.
	* Free root variable scope. The provided scope should not have a parent. This
	* operation calls `ecs_script_vars_pop()` on the scope.
	*
	* @param vars The variable scope.
	*/
	script_vars_fini :: proc(vars: ^script_vars_t) ---

	/** Push new variable scope.
	*
	* Scopes created with ecs_script_vars_push() must be cleaned up with
	* ecs_script_vars_pop().
	*
	* If the stack and allocator arguments are left to NULL, their values will be
	* copied from the parent.
	*
	* @param parent The parent scope (provide NULL for root scope).
	* @return The new variable scope.
	*/
	script_vars_push :: proc(parent: ^script_vars_t) -> ^script_vars_t ---

	/** Pop variable scope.
	* This frees up the resources for a variable scope. The scope must be at the
	* top of a vars stack. Calling ecs_script_vars_pop() on a scope that is not the
	* last scope causes undefined behavior.
	*
	* @param vars The scope to free.
	* @return The parent scope.
	*/
	script_vars_pop :: proc(vars: ^script_vars_t) -> ^script_vars_t ---

	/** Declare a variable.
	* This operation declares a new variable in the current scope. If a variable
	* with the specified name already exists, the operation will fail.
	*
	* This operation does not allocate storage for the variable. This is done to
	* allow for variables that point to existing storage, which prevents having
	* to copy existing values to a variable scope.
	*
	* @param vars The variable scope.
	* @param name The variable name.
	* @return The new variable, or NULL if the operation failed.
	*/
	script_vars_declare :: proc(vars: ^script_vars_t, name: cstring) -> ^script_var_t ---

	/** Define a variable.
	* This operation calls `ecs_script_vars_declare()` and allocates storage for
	* the variable. If the type has a ctor, it will be called on the new storage.
	*
	* The scope's stack allocator will be used to allocate the storage. After
	* `ecs_script_vars_pop()` is called on the scope, the variable storage will no
	* longer be valid.
	*
	* The operation will fail if the type argument is not a type.
	*
	* @param vars The variable scope.
	* @param name The variable name.
	* @param type The variable type.
	* @return The new variable, or NULL if the operation failed.
	*/
	script_vars_define_id :: proc(vars: ^script_vars_t, name: cstring, type: entity_t) -> ^script_var_t ---

	/** Lookup a variable.
	* This operation looks up a variable in the current scope. If the variable
	* can't be found in the current scope, the operation will recursively search
	* the parent scopes.
	*
	* @param vars The variable scope.
	* @param name The variable name.
	* @return The variable, or NULL if one with the provided name does not exist.
	*/
	script_vars_lookup :: proc(vars: ^script_vars_t, name: cstring) -> ^script_var_t ---

	/** Lookup a variable by stack pointer.
	* This operation provides a faster way to lookup variables that are always
	* declared in the same order in a ecs_script_vars_t scope.
	*
	* The stack pointer of a variable can be obtained from the ecs_script_var_t
	* type. The provided frame offset must be valid for the provided variable
	* stack. If the frame offset is not valid, this operation will panic.
	*
	* @param vars The variable scope.
	* @param sp The stack pointer to the variable.
	* @return The variable.
	*/
	script_vars_from_sp :: proc(vars: ^script_vars_t, sp: i32) -> ^script_var_t ---

	/** Print variables.
	* This operation prints all variables in the vars scope and parent scopes.asm
	*
	* @param vars The variable scope.
	*/
	script_vars_print :: proc(vars: ^script_vars_t) ---

	/** Preallocate space for variables.
	* This operation preallocates space for the specified number of variables. This
	* is a performance optimization only, and is not necessary before declaring
	* variables in a scope.
	*
	* @param vars The variable scope.
	* @param count The number of variables to preallocate space for.
	*/
	script_vars_set_size :: proc(vars: ^script_vars_t, count: i32) ---

	/** Convert iterator to vars
	* This operation converts an iterator to a variable array. This allows for
	* using iterator results in expressions. The operation only converts a
	* single result at a time, and does not progress the iterator.
	*
	* Iterator fields with data will be made available as variables with as name
	* the field index (e.g. "$1"). The operation does not check if reflection data
	* is registered for a field type. If no reflection data is registered for the
	* type, using the field variable in expressions will fail.
	*
	* Field variables will only contain single elements, even if the iterator
	* returns component arrays. The offset parameter can be used to specify which
	* element in the component arrays to return. The offset parameter must be
	* smaller than it->count.
	*
	* The operation will create a variable for query variables that contain a
	* single entity.
	*
	* The operation will attempt to use existing variables. If a variable does not
	* yet exist, the operation will create it. If an existing variable exists with
	* a mismatching type, the operation will fail.
	*
	* Accessing variables after progressing the iterator or after the iterator is
	* destroyed will result in undefined behavior.
	*
	* If vars contains a variable that is not present in the iterator, the variable
	* will not be modified.
	*
	* @param it The iterator to convert to variables.
	* @param vars The variables to write to.
	* @param offset The offset to the current element.
	*/
	script_vars_from_iter :: proc(it: ^iter_t, vars: ^script_vars_t, offset: c.int) ---

	/** Run expression.
	* This operation runs an expression and stores the result in the provided
	* value. If the value contains a type that is different from the type of the
	* expression, the expression will be cast to the value.
	*
	* If the provided value for value.ptr is NULL, the value must be freed with
	* ecs_value_free() afterwards.
	*
	* @param world The world.
	* @param ptr The pointer to the expression to parse.
	* @param value The value containing type & pointer to write to.
	* @param desc Configuration parameters for the parser.
	* @return Pointer to the character after the last one read, or NULL if failed.
	*/
	expr_run :: proc(world: ^world_t, ptr: cstring, value: ^value_t, desc: ^expr_eval_desc_t) -> cstring ---

	/** Parse expression.
	* This operation parses an expression and returns an object that can be
	* evaluated multiple times with ecs_expr_eval().
	*
	* @param world The world.
	* @param expr The expression string.
	* @param desc Configuration parameters for the parser.
	* @return A script object if parsing is successful, NULL if parsing failed.
	*/
	expr_parse :: proc(world: ^world_t, expr: cstring, desc: ^expr_eval_desc_t) -> ^script_t ---

	/** Evaluate expression.
	* This operation evaluates an expression parsed with ecs_expr_parse()
	* and stores the result in the provided value. If the value contains a type
	* that is different from the type of the expression, the expression will be
	* cast to the value.
	*
	* If the provided value for value.ptr is NULL, the value must be freed with
	* ecs_value_free() afterwards.
	*
	* @param script The script containing the expression.
	* @param value The value in which to store the expression result.
	* @param desc Configuration parameters for the parser.
	* @return Zero if successful, non-zero if failed.
	*/
	expr_eval :: proc(script: ^script_t, value: ^value_t, desc: ^expr_eval_desc_t) -> c.int ---

	/** Evaluate interpolated expressions in string.
	* This operation evaluates expressions in a string, and replaces them with
	* their evaluated result. Supported expression formats are:
	*  - $variable_name
	*  - {expression}
	*
	* The $, { and } characters can be escaped with a backslash (\).
	*
	* @param world The world.
	* @param str The string to evaluate.
	* @param vars The variables to use for evaluation.
	*/
	script_string_interpolate :: proc(world: ^world_t, str: cstring, vars: ^script_vars_t) -> cstring ---

	/** Create a const variable that can be accessed by scripts.
	*
	* @param world The world.
	* @param desc Const var parameters.
	* @return The const var, or 0 if failed.
	*/
	const_var_init :: proc(world: ^world_t, desc: ^const_var_desc_t) -> entity_t ---

	/** Create new function.
	* This operation creates a new function that can be called from a script.
	*
	* @param world The world.
	* @param desc Function init parameters.
	* @return The function, or 0 if failed.
	*/
	function_init :: proc(world: ^world_t, desc: ^function_desc_t) -> entity_t ---

	/** Create new method.
	* This operation creates a new method that can be called from a script. A
	* method is like a function, except that it can be called on every instance of
	* a type.
	*
	* Methods automatically receive the instance on which the method is invoked as
	* first argument.
	*
	* @param world Method The world.
	* @param desc Method init parameters.
	* @return The function, or 0 if failed.
	*/
	method_init :: proc(world: ^world_t, desc: ^function_desc_t) -> entity_t ---

	/** Serialize value into expression string.
	* This operation serializes a value of the provided type to a string. The
	* memory pointed to must be large enough to contain a value of the used type.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @return String with expression, or NULL if failed.
	*/
	ptr_to_expr :: proc(world: ^world_t, type: entity_t, data: rawptr) -> cstring ---

	/** Serialize value into expression buffer.
	* Same as ecs_ptr_to_expr(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @param buf The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	ptr_to_expr_buf :: proc(world: ^world_t, type: entity_t, data: rawptr, buf: ^strbuf_t) -> c.int ---

	/** Similar as ecs_ptr_to_expr(), but serializes values to string.
	* Whereas the output of ecs_ptr_to_expr() is a valid expression, the output of
	* ecs_ptr_to_str() is a string representation of the value. In most cases the
	* output of the two operations is the same, but there are some differences:
	* - Strings are not quoted
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @return String with result, or NULL if failed.
	*/
	ptr_to_str :: proc(world: ^world_t, type: entity_t, data: rawptr) -> cstring ---

	/** Serialize value into string buffer.
	* Same as ecs_ptr_to_str(), but serializes to an ecs_strbuf_t instance.
	*
	* @param world The world.
	* @param type The type of the value to serialize.
	* @param data The value to serialize.
	* @param buf The strbuf to append the string to.
	* @return Zero if success, non-zero if failed.
	*/
	ptr_to_str_buf :: proc(world: ^world_t, type: entity_t, data: rawptr, buf: ^strbuf_t) -> c.int ---

	/** Script module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsScript)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsScriptImport :: proc(world: ^world_t) ---

	/** Add UUID to entity.
	* Associate entity with an (external) UUID.
	*
	* @param world The world.
	* @param entity The entity to which to add the UUID.
	* @param uuid The UUID to add.
	*
	* @see ecs_doc_get_uuid()
	* @see flecs::doc::set_uuid()
	* @see flecs::entity_builder::set_doc_uuid()
	*/
	doc_set_uuid :: proc(world: ^world_t, entity: entity_t, uuid: cstring) ---

	/** Add human-readable name to entity.
	* Contrary to entity names, human readable names do not have to be unique and
	* can contain special characters used in the query language like '*'.
	*
	* @param world The world.
	* @param entity The entity to which to add the name.
	* @param name The name to add.
	*
	* @see ecs_doc_get_name()
	* @see flecs::doc::set_name()
	* @see flecs::entity_builder::set_doc_name()
	*/
	doc_set_name :: proc(world: ^world_t, entity: entity_t, name: cstring) ---

	/** Add brief description to entity.
	*
	* @param world The world.
	* @param entity The entity to which to add the description.
	* @param description The description to add.
	*
	* @see ecs_doc_get_brief()
	* @see flecs::doc::set_brief()
	* @see flecs::entity_builder::set_doc_brief()
	*/
	doc_set_brief :: proc(world: ^world_t, entity: entity_t, description: cstring) ---

	/** Add detailed description to entity.
	*
	* @param world The world.
	* @param entity The entity to which to add the description.
	* @param description The description to add.
	*
	* @see ecs_doc_get_detail()
	* @see flecs::doc::set_detail()
	* @see flecs::entity_builder::set_doc_detail()
	*/
	doc_set_detail :: proc(world: ^world_t, entity: entity_t, description: cstring) ---

	/** Add link to external documentation to entity.
	*
	* @param world The world.
	* @param entity The entity to which to add the link.
	* @param link The link to add.
	*
	* @see ecs_doc_get_link()
	* @see flecs::doc::set_link()
	* @see flecs::entity_builder::set_doc_link()
	*/
	doc_set_link :: proc(world: ^world_t, entity: entity_t, link: cstring) ---

	/** Add color to entity.
	* UIs can use color as hint to improve visualizing entities.
	*
	* @param world The world.
	* @param entity The entity to which to add the link.
	* @param color The color to add.
	*
	* @see ecs_doc_get_color()
	* @see flecs::doc::set_color()
	* @see flecs::entity_builder::set_doc_color()
	*/
	doc_set_color :: proc(world: ^world_t, entity: entity_t, color: cstring) ---

	/** Get UUID from entity.
	* @param world The world.
	* @param entity The entity from which to get the UUID.
	* @return The UUID.
	*
	* @see ecs_doc_set_uuid()
	* @see flecs::doc::get_uuid()
	* @see flecs::entity_view::get_doc_uuid()
	*/
	doc_get_uuid :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get human readable name from entity.
	* If entity does not have an explicit human readable name, this operation will
	* return the entity name.
	*
	* To test if an entity has a human readable name, use:
	*
	* @code
	* ecs_has_pair(world, e, ecs_id(DocDescription), Name);
	* @endcode
	*
	* Or in C++:
	*
	* @code
	* e.has<flecs::doc::Description>(flecs::Name);
	* @endcode
	*
	* @param world The world.
	* @param entity The entity from which to get the name.
	* @return The name.
	*
	* @see ecs_doc_set_name()
	* @see flecs::doc::get_name()
	* @see flecs::entity_view::get_doc_name()
	*/
	doc_get_name :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get brief description from entity.
	*
	* @param world The world.
	* @param entity The entity from which to get the description.
	* @return The description.
	*
	* @see ecs_doc_set_brief()
	* @see flecs::doc::get_brief()
	* @see flecs::entity_view::get_doc_brief()
	*/
	doc_get_brief :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get detailed description from entity.
	*
	* @param world The world.
	* @param entity The entity from which to get the description.
	* @return The description.
	*
	* @see ecs_doc_set_detail()
	* @see flecs::doc::get_detail()
	* @see flecs::entity_view::get_doc_detail()
	*/
	doc_get_detail :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get link to external documentation from entity.
	*
	* @param world The world.
	* @param entity The entity from which to get the link.
	* @return The link.
	*
	* @see ecs_doc_set_link()
	* @see flecs::doc::get_link()
	* @see flecs::entity_view::get_doc_link()
	*/
	doc_get_link :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Get color from entity.
	*
	* @param world The world.
	* @param entity The entity from which to get the color.
	* @return The color.
	*
	* @see ecs_doc_set_color()
	* @see flecs::doc::get_color()
	* @see flecs::entity_view::get_doc_color()
	*/
	doc_get_color :: proc(world: ^world_t, entity: entity_t) -> cstring ---

	/** Doc module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsDoc)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsDocImport :: proc(world: ^world_t) ---

	/** Create meta cursor.
	* A meta cursor allows for walking over, reading and writing a value without
	* having to know its type at compile time.
	*
	* When a value is assigned through the cursor API, it will get converted to
	* the actual value of the underlying type. This allows the underlying type to
	* change without having to update the serialized data. For example, an integer
	* field can be set by a string, a floating point can be set as integer etc.
	*
	* @param world The world.
	* @param type The type of the value.
	* @param ptr Pointer to the value.
	* @return A meta cursor for the value.
	*/
	meta_cursor :: proc(world: ^world_t, type: entity_t, ptr: rawptr) -> meta_cursor_t ---

	/** Get pointer to current field.
	*
	* @param cursor The cursor.
	* @return A pointer to the current field.
	*/
	meta_get_ptr :: proc(cursor: ^meta_cursor_t) -> rawptr ---

	/** Move cursor to next field.
	*
	* @param cursor The cursor.
	* @return Zero if success, non-zero if failed.
	*/
	meta_next :: proc(cursor: ^meta_cursor_t) -> c.int ---

	/** Move cursor to a field.
	*
	* @param cursor The cursor.
	* @return Zero if success, non-zero if failed.
	*/
	meta_elem :: proc(cursor: ^meta_cursor_t, elem: i32) -> c.int ---

	/** Move cursor to member.
	*
	* @param cursor The cursor.
	* @param name The name of the member.
	* @return Zero if success, non-zero if failed.
	*/
	meta_member :: proc(cursor: ^meta_cursor_t, name: cstring) -> c.int ---

	/** Move cursor to member.
	* Same as ecs_meta_member(), but with support for "foo.bar" syntax.
	*
	* @param cursor The cursor.
	* @param name The name of the member.
	* @return Zero if success, non-zero if failed.
	*/
	meta_dotmember :: proc(cursor: ^meta_cursor_t, name: cstring) -> c.int ---

	/** Push a scope (required/only valid for structs & collections).
	*
	* @param cursor The cursor.
	* @return Zero if success, non-zero if failed.
	*/
	meta_push :: proc(cursor: ^meta_cursor_t) -> c.int ---

	/** Pop a struct or collection scope (must follow a push).
	*
	* @param cursor The cursor.
	* @return Zero if success, non-zero if failed.
	*/
	meta_pop :: proc(cursor: ^meta_cursor_t) -> c.int ---

	/** Is the current scope a collection?.
	*
	* @param cursor The cursor.
	* @return True if current scope is a collection, false if not.
	*/
	meta_is_collection :: proc(cursor: ^meta_cursor_t) -> bool ---

	/** Get type of current field.
	*
	* @param cursor The cursor.
	* @return The type of the current field.
	*/
	meta_get_type :: proc(cursor: ^meta_cursor_t) -> entity_t ---

	/** Get unit of current field.
	*
	* @param cursor The cursor.
	* @return The unit of the current field.
	*/
	meta_get_unit :: proc(cursor: ^meta_cursor_t) -> entity_t ---

	/** Get member name of current field.
	*
	* @param cursor The cursor.
	* @return The member name of the current field.
	*/
	meta_get_member :: proc(cursor: ^meta_cursor_t) -> cstring ---

	/** Get member entity of current field.
	*
	* @param cursor The cursor.
	* @return The member entity of the current field.
	*/
	meta_get_member_id :: proc(cursor: ^meta_cursor_t) -> entity_t ---

	/** Set field with boolean value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_bool :: proc(cursor: ^meta_cursor_t, value: bool) -> c.int ---

	/** Set field with char value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_char :: proc(cursor: ^meta_cursor_t, value: c.char) -> c.int ---

	/** Set field with int value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_int :: proc(cursor: ^meta_cursor_t, value: i64) -> c.int ---

	/** Set field with uint value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_uint :: proc(cursor: ^meta_cursor_t, value: u64) -> c.int ---

	/** Set field with float value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_float :: proc(cursor: ^meta_cursor_t, value: f64) -> c.int ---

	/** Set field with string value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_string :: proc(cursor: ^meta_cursor_t, value: cstring) -> c.int ---

	/** Set field with string literal value (has enclosing "").
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_string_literal :: proc(cursor: ^meta_cursor_t, value: cstring) -> c.int ---

	/** Set field with entity value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_entity :: proc(cursor: ^meta_cursor_t, value: entity_t) -> c.int ---

	/** Set field with (component) id value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_id :: proc(cursor: ^meta_cursor_t, value: id_t) -> c.int ---

	/** Set field with null value.
	*
	* @param cursor The cursor.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_null :: proc(cursor: ^meta_cursor_t) -> c.int ---

	/** Set field with dynamic value.
	*
	* @param cursor The cursor.
	* @param value The value to set.
	* @return Zero if success, non-zero if failed.
	*/
	meta_set_value :: proc(cursor: ^meta_cursor_t, value: ^value_t) -> c.int ---

	/** Get field value as boolean.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_bool :: proc(cursor: ^meta_cursor_t) -> bool ---

	/** Get field value as char.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_char :: proc(cursor: ^meta_cursor_t) -> c.char ---

	/** Get field value as signed integer.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_int :: proc(cursor: ^meta_cursor_t) -> i64 ---

	/** Get field value as unsigned integer.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_uint :: proc(cursor: ^meta_cursor_t) -> u64 ---

	/** Get field value as float.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_float :: proc(cursor: ^meta_cursor_t) -> f64 ---

	/** Get field value as string.
	* This operation does not perform conversions. If the field is not a string,
	* this operation will fail.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_string :: proc(cursor: ^meta_cursor_t) -> cstring ---

	/** Get field value as entity.
	* This operation does not perform conversions.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_entity :: proc(cursor: ^meta_cursor_t) -> entity_t ---

	/** Get field value as (component) id.
	* This operation can convert from an entity.
	*
	* @param cursor The cursor.
	* @return The value of the current field.
	*/
	meta_get_id :: proc(cursor: ^meta_cursor_t) -> id_t ---

	/** Convert pointer of primitive kind to float.
	*
	* @param type_kind The primitive type kind of the value.
	* @param ptr Pointer to a value of a primitive type.
	* @return The value in floating point format.
	*/
	meta_ptr_to_float :: proc(type_kind: primitive_kind_t, ptr: rawptr) -> f64 ---

	/** Create a new primitive type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	primitive_init :: proc(world: ^world_t, desc: ^primitive_desc_t) -> entity_t ---

	/** Create a new enum type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	enum_init :: proc(world: ^world_t, desc: ^enum_desc_t) -> entity_t ---

	/** Create a new bitmask type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	bitmask_init :: proc(world: ^world_t, desc: ^bitmask_desc_t) -> entity_t ---

	/** Create a new array type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	array_init :: proc(world: ^world_t, desc: ^array_desc_t) -> entity_t ---

	/** Create a new vector type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	vector_init :: proc(world: ^world_t, desc: ^vector_desc_t) -> entity_t ---

	/** Create a new struct type.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	struct_init :: proc(world: ^world_t, desc: ^struct_desc_t) -> entity_t ---

	/** Create a new opaque type.
	* Opaque types are types of which the layout doesn't match what can be modelled
	* with the primitives of the meta framework, but which have a structure
	* that can be described with meta primitives. Typical examples are STL types
	* such as std::string or std::vector, types with a nontrivial layout, and types
	* that only expose getter/setter methods.
	*
	* An opaque type is a combination of a serialization function, and a handle to
	* a meta type which describes the structure of the serialized output. For
	* example, an opaque type for std::string would have a serializer function that
	* accesses .c_str(), and with type ecs_string_t.
	*
	* The serializer callback accepts a serializer object and a pointer to the
	* value of the opaque type to be serialized. The serializer has two methods:
	*
	* - value, which serializes a value (such as .c_str())
	* - member, which specifies a member to be serialized (in the case of a struct)
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new type, 0 if failed.
	*/
	opaque_init :: proc(world: ^world_t, desc: ^opaque_desc_t) -> entity_t ---

	/** Create a new unit.
	*
	* @param world The world.
	* @param desc The unit descriptor.
	* @return The new unit, 0 if failed.
	*/
	unit_init :: proc(world: ^world_t, desc: ^unit_desc_t) -> entity_t ---

	/** Create a new unit prefix.
	*
	* @param world The world.
	* @param desc The type descriptor.
	* @return The new unit prefix, 0 if failed.
	*/
	unit_prefix_init :: proc(world: ^world_t, desc: ^unit_prefix_desc_t) -> entity_t ---

	/** Create a new quantity.
	*
	* @param world The world.
	* @param desc The quantity descriptor.
	* @return The new quantity, 0 if failed.
	*/
	quantity_init :: proc(world: ^world_t, desc: ^entity_desc_t) -> entity_t ---

	/** Meta module import function.
	* Usage:
	* @code
	* ECS_IMPORT(world, FlecsMeta)
	* @endcode
	*
	* @param world The world.
	*/
	FlecsMetaImport :: proc(world: ^world_t) ---

	/** Populate meta information from type descriptor. */
	meta_from_desc :: proc(world: ^world_t, component: entity_t, kind: type_kind_t, desc: cstring) -> c.int ---
	set_os_api_impl :: proc() ---

	/** Import a module.
	* This operation will load a modules and store the public module handles in the
	* handles_out out parameter. The module name will be used to verify if the
	* module was already loaded, in which case it won't be reimported. The name
	* will be translated from PascalCase to an entity path (pascal.case) before the
	* lookup occurs.
	*
	* Module contents will be stored as children of the module entity. This
	* prevents modules from accidentally defining conflicting identifiers. This is
	* enforced by setting the scope before and after loading the module to the
	* module entity id.
	*
	* A more convenient way to import a module is by using the ECS_IMPORT macro.
	*
	* @param world The world.
	* @param module The module import function.
	* @param module_name The name of the module.
	* @return The module entity.
	*/
	_import :: proc(world: ^world_t, module: module_action_t, module_name: cstring) -> entity_t ---

	/** Same as ecs_import(), but with name to scope conversion.
	* PascalCase names are automatically converted to scoped names.
	*
	* @param world The world.
	* @param module The module import function.
	* @param module_name_c The name of the module.
	* @return The module entity.
	*/
	import_c :: proc(world: ^world_t, module: module_action_t, module_name_c: cstring) -> entity_t ---

	/** Import a module from a library.
	* Similar to ecs_import(), except that this operation will attempt to load the
	* module from a dynamic library.
	*
	* A library may contain multiple modules, which is why both a library name and
	* a module name need to be provided. If only a library name is provided, the
	* library name will be reused for the module name.
	*
	* The library will be looked up using a canonical name, which is in the same
	* form as a module, like `flecs.components.transform`. To transform this
	* identifier to a platform specific library name, the operation relies on the
	* module_to_dl callback of the os_api which the application has to override if
	* the default does not yield the correct library name.
	*
	* @param world The world.
	* @param library_name The name of the library to load.
	* @param module_name The name of the module to load.
	*/
	import_from_library :: proc(world: ^world_t, library_name: cstring, module_name: cstring) -> entity_t ---

	/** Register a new module. */
	module_init :: proc(world: ^world_t, c_name: cstring, desc: ^component_desc_t) -> entity_t ---
	cpp_get_type_name :: proc(type_name: cstring, func_name: cstring, len: c.size_t, front_len: c.size_t) -> cstring ---
	cpp_get_symbol_name :: proc(symbol_name: cstring, type_name: cstring, len: c.size_t) -> cstring ---
	cpp_get_constant_name :: proc(constant_name: cstring, func_name: cstring, len: c.size_t, back_len: c.size_t) -> cstring ---
	cpp_trim_module :: proc(world: ^world_t, type_name: cstring) -> cstring ---
	cpp_component_register :: proc(world: ^world_t, id: entity_t, ids_index: i32, name: cstring, cpp_name: cstring, cpp_symbol: cstring, size: c.size_t, alignment: c.size_t, is_component: bool, explicit_registration: bool, registered_out: ^bool, existing_out: ^bool) -> entity_t ---
	cpp_enum_init :: proc(world: ^world_t, id: entity_t, underlying_type: entity_t) ---
	cpp_enum_constant_register :: proc(world: ^world_t, parent: entity_t, id: entity_t, name: cstring, value: rawptr, value_type: entity_t, value_size: c.size_t) -> entity_t ---
	cpp_set :: proc(world: ^world_t, entity: entity_t, component: id_t, new_ptr: rawptr, size: c.size_t) -> cpp_get_mut_t ---
	cpp_assign :: proc(world: ^world_t, entity: entity_t, component: id_t, new_ptr: rawptr, size: c.size_t) -> cpp_get_mut_t ---
	cpp_last_member :: proc(world: ^world_t, type: entity_t) -> ^member_t ---

	/* Stuff */
	os_api: os_api_t
}

// TODO: make private?
@(default_calling_convention = "c", link_prefix = "Ecs")
foreign flecs {
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

/* NON CODEGEN STUFF */
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
