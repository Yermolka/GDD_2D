extends Node

var player_level: int:
	get:
		var player: Player = get_tree().get_first_node_in_group("player")
		if player:
			return player.level
		else:
			return 0

var global_state: Dictionary = {}

signal game_saved()
signal game_loaded()
signal global_var_changed(key: String, value: Variant)

func _enter_tree() -> void:
	Questify.condition_query_requested.connect(
		func (type: String, key: String, value: Variant, requester: QuestCondition) -> void:
			if type == "global_var":
				requester.set_completed(get_global_var(key) == value)
	)
	EventBus.dialogueSetVariable.connect(
		func (key: String, value: String) -> void:
			if key.begins_with("global_"):
				set_global_var(key.split("_", true, 1)[1], value)
	)

func set_global_var(key: String, value: Variant) -> void:
	global_state[key] = value
	Questify.update_quests()
	global_var_changed.emit(key, value)


func get_global_var(key: String) -> Variant:
	return global_state.get(key)


func save() -> void:
	var da: DirAccess = DirAccess.open("res://")
	if not da.dir_exists("saves"):
		da.make_dir("saves")

	var save_file: FileAccess = FileAccess.open_encrypted_with_pass("res://saves/test_save_bin.save", FileAccess.WRITE, "hard_password")
	var player: Player = get_tree().get_first_node_in_group("player")
	save_file.store_var(player.serialize())


func load() -> void:
	var save_file: FileAccess = FileAccess.open_encrypted_with_pass("res://saves/test_save_bin.save", FileAccess.READ, "hard_password")
	var player_dict: Dictionary = save_file.get_var()
	
	var player: Player = get_tree().get_first_node_in_group("player")
	var player_parent: Node = player.get_parent()
	var player_path: String = player.scene_file_path
	player.queue_free()
	
	await get_tree().process_frame

	player = load(player_path).instantiate()
	player_parent.add_child(player)
	player.deserialize(player_dict["player"])

	game_loaded.emit()


func serialize() -> Dictionary:
	return {
		"player_level": player_level,
		"global_state": global_state
	}


func deserialize(body: Dictionary) -> void:
	player_level = body.player_level
	global_state = body.global_state
