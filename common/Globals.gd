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

func _enter_tree() -> void:
	Questify.condition_query_requested.connect(
		func (type: String, key: String, value: Variant, requester: QuestCondition) -> void:
			if type == "global_var":
				requester.set_completed(get_global_var(key) == value)
	)

func set_global_var(key: String, value: Variant) -> void:
	global_state[key] = value
	Questify.update_quests()

func get_global_var(key: String) -> Variant:
	return global_state.get(key)

func save() -> void:
	var da: DirAccess = DirAccess.open("res://")
	if not da.dir_exists("saves"):
		da.make_dir("saves")

	var save_file: FileAccess = FileAccess.open_encrypted_with_pass("res://saves/test_save_bin.save", FileAccess.WRITE, "hard_password")
	# var to_save: Array[Node] = get_tree().get_nodes_in_group("persist")
	# for node: Node in to_save:
	# 	if node.scene_file_path.is_empty():
	# 		printerr(node.name, ": scene file is empty")
	# 		continue

	# 	if not node.has_method("serialize"):
	# 		printerr(node.name, ": doesn't have serialize method")
	# 		continue

	# 	var data: Dictionary = node.call("serialize")
	# 	var json_string: String = JSON.stringify(data)

	# 	save_file.store_line(json_string)

	# var json_string: String = JSON.stringify({"Questify": Questify.serialize()})
	# save_file.store_line(json_string)

	# json_string = JSON.stringify({"Globals": serialize()})
	# save_file.store_line(json_string)

	# game_saved.emit()

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

	# if not FileAccess.file_exists("res://saves/test_save_bin.save"):
	# 	return

	# var save_nodes: Array[Node] = get_tree().get_nodes_in_group("persist")
	# for node: Node in save_nodes:
	# 	node.queue_free()

	# var save_file: FileAccess = FileAccess.open("res://saves/test_save_bin.save", FileAccess.READ)
	# while save_file.get_position() < save_file.get_length():
	# 	var json_string: String = save_file.get_line()
	# 	var json: JSON = JSON.new()

	# 	var parse_result: int = json.parse(json_string)
	# 	if not parse_result == OK:
	# 		printerr("JSON load error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	# 		continue

	# 	var data: Dictionary = json.data
	# 	if data.has("Questify"):
	# 		Questify.deserialize(data["Questify"])
	# 		continue

	# 	if data.has("Globals"):
	# 		deserialize(data["Globals"])
	# 		continue

	# 	var new_obj: Node = load(data["filename"]).instantiate()
	# 	get_node(data["parent"]).add_child(new_obj)
	# 	new_obj.global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])

	# 	for key: String in data.keys():
	# 		if key == "filename" or key == "parent" or key == "pos_x" or key == "pos_y" or key == "pos_z":
	# 			continue

	# 		if key.ends_with("_path"):
	# 			if data[key] == null:
	# 				continue
	# 			new_obj.set(key.split("_path")[0], load(data[key]))
	# 		else:
	# 			new_obj.set(key, data[key])

	# get_tree().get_first_node_in_group("player").call_deferred("finalize_load")
	# game_loaded.emit()


func serialize() -> Dictionary:
	return {
		"player_level": player_level,
		"global_state": global_state
	}

func deserialize(body: Dictionary) -> void:
	player_level = body.player_level
	global_state = body.global_state
