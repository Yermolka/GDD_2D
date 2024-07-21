@tool
class_name QuestResource extends Resource


@export var nodes: Array[QuestNode] = []
@export var edges: Array[QuestEdge] = []


var name: String:
	get: return start_node.name

var description: String:
	get: return start_node.description

var start_node: QuestStart:
	get:
		_initialize()
		return start_node

var started: bool:
	get: return start_node.active

var available: bool = false
@export var required_level: int = 0
@export var remove_items_on_complete: bool = true

## Global requirements are what key:value should be in Globals to become available
@export var global_requirements: Dictionary = {}
@export var global_vars_on_turn_in: Dictionary = {}
@export var reward_xp: int = 0
@export var reward_currency: int = 0
@export var reward_guaranteed_items: Array[ItemBase] = []
@export var reward_choice_items: Array[ItemBase] = []

var completed: bool = false
var turned_in: bool = false
var is_instance := false


var _was_initialized: bool = false


func instantiate() -> QuestResource:
	if is_instance:
		return self
	var instance := duplicate(true) as QuestResource
	instance.is_instance = true
	instance.set_meta("resource_path", resource_path)
	return instance


func start() -> void:
	if not is_instance:
		printerr("Quest must be instantiated to be started. Use instantiate().")
		return
	if available and not completed and not started and not turned_in:
		available = false
		start_node.active = true
		Questify.quest_started.emit(self)
		_notify_active_objectives()
	update()


func update() -> void:
	if not is_instance:
		printerr("Quest must be instantiated to be updated. Use instantiate().")
		return
	if not started and not available:
		if not Globals.player_level >= required_level:
			return
		print(global_requirements, global_vars_on_turn_in)
		for key in global_requirements:
			if Globals.get_global_var(key) != global_requirements[key]:
				return
		available = true
		Questify.quest_available.emit(self)
	if not completed and not turned_in: 
		start_node.update()


func get_active_objectives() -> Array[QuestObjective]:
	var objectives: Array[QuestObjective] = []
	for node in nodes:
		if node is QuestObjective and node.get_active():
			objectives.append(node)
	return objectives


func get_next_nodes(node: QuestNode, edge_type: QuestEdge.EdgeType = QuestEdge.EdgeType.NORMAL) -> Array[QuestNode]:
	var result: Array[QuestNode] = []
	result.assign(edges.filter(
		func(edge: QuestEdge):
			return edge.from == node and edge.edge_type == edge_type
	).map(
		func(edge: QuestEdge):
			return edge.to
	))
	return result


func get_previous_nodes(node: QuestNode, edge_type: QuestEdge.EdgeType = QuestEdge.EdgeType.NORMAL) -> Array[QuestNode]:
	var result: Array[QuestNode] = []
	result.assign(edges.filter(
		func(edge: QuestEdge):
			return edge.to == node and edge.edge_type == edge_type
	).map(
		func(edge: QuestEdge):
			return edge.from
	))
	return result


func get_resource_path() -> String:
	if is_instance:
		return get_meta("resource_path")
	return resource_path


func request_query(type: String, key: String, value: Variant, requester: QuestCondition) -> void:
	Questify.condition_query_requested.emit(type, key, value, requester)


func complete_objective(objective: QuestObjective) -> void:
	Questify.quest_objective_completed.emit(self, objective)
	_notify_active_objectives()


func complete_quest() -> void:
	completed = true
	Questify.quest_completed.emit(self)


func turn_in() -> void:
	# TODO: show turn in window with reward choice, await results and turn in on success
	turned_in = true
	for key in global_vars_on_turn_in:
		Globals.set_global_var(key, global_vars_on_turn_in[key])
	Questify.quest_turned_in.emit(self)


func serialize() -> Dictionary:
	return {
		completed = completed,
		turned_in = turned_in,
		available = available,
		nodes = nodes.map(func(node: QuestNode): return node.serialize()),
		required_level = required_level,
		remove_items_on_complete = remove_items_on_complete,
		global_requirements = global_requirements,
		global_vars_on_turn_in = global_vars_on_turn_in,
		reward_xp = reward_xp,
		reward_currency = reward_currency,
		reward_choice_items = reward_choice_items,
		reward_guaranteed_items = reward_guaranteed_items
	}


func deserialize(data: Dictionary) -> void:
	if not is_instance:
		printerr("Quest must be instantiated to be deserialized. Use instantiate().")
		return

	available = data.available
	completed = data.completed
	turned_in = data.turned_in
	required_level = data.required_level
	remove_items_on_complete = data.remove_items_on_complete
	global_requirements = data.global_requirements
	global_vars_on_turn_in = data.global_vars_on_turn_in
	reward_xp = data.reward_xp
	reward_currency = data.reward_currency
	reward_choice_items = data.reward_choice_items
	reward_guaranteed_items = data.reward_guaranteed_items
	var node_map := {}
	for node in nodes:
		node_map[node.id] = node
	for node in data.nodes:
		if node_map.has(node.id):
			node_map[node.id].deserialize(node)


func _initialize() -> void:
	if not _was_initialized:
		for node in nodes:
			node.set_graph(self)
			if node is QuestStart:
				start_node = node as QuestStart
		_was_initialized = true


func _notify_active_objectives() -> void:
	for objective in get_active_objectives():
		Questify.quest_objective_added.emit(self, objective)


func load_vars(res: QuestResource) -> void:
	required_level = res.required_level
	remove_items_on_complete = res.remove_items_on_complete
	global_requirements = res.global_requirements
	global_vars_on_turn_in = res.global_vars_on_turn_in
	reward_xp = res.reward_xp
	reward_currency = res.reward_currency
	reward_choice_items = res.reward_choice_items
	reward_guaranteed_items = res.reward_guaranteed_items
