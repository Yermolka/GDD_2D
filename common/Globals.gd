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

func save() -> void:
	var da: DirAccess = DirAccess.open("res://")
	if not da.dir_exists("saves"):
		da.make_dir("saves")

	var save_file: FileAccess = FileAccess.open("res://saves/test_save.save", FileAccess.WRITE)
	var to_save: Array[Node] = get_tree().get_nodes_in_group("persist")
	for node: Node in to_save:
		if node.scene_file_path.is_empty():
			printerr(node.name, ": scene file is empty")
			continue

		if not node.has_method("serialize"):
			printerr(node.name, ": doesn't have serialize method")
			continue
		
		var data: Dictionary = node.call("serialize")
		var json_string: String = JSON.stringify(data)

		save_file.store_line(json_string)

	var json_string: String = JSON.stringify({"Questify": Questify.serialize()})
	save_file.store_line(json_string)

	json_string = JSON.stringify({"Globals": serialize()})
	save_file.store_line(json_string)

	game_saved.emit()

func load() -> void:
	if not FileAccess.file_exists("res://saves/test_save.save"):
		return

	var save_nodes: Array[Node] = get_tree().get_nodes_in_group("persist")
	for node: Node in save_nodes:
		node.queue_free()

	var save_file: FileAccess = FileAccess.open("res://saves/test_save.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()

		var parse_result: int = json.parse(json_string)
		if not parse_result == OK:
			printerr("JSON load error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var data: Dictionary = json.data
		if data.has("Questify"):
			Questify.deserialize(data["Questify"])
			continue

		if data.has("Globals"):
			deserialize(data["Globals"])
			continue
		
		var new_obj: Node = load(data["filename"]).instantiate()
		get_node(data["parent"]).add_child(new_obj)
		new_obj.global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])

		for key: String in data.keys():
			if key == "filename" or key == "parent" or key == "pos_x" or key == "pos_y" or key == "pos_z":
				continue

			if key.ends_with("_path"):
				if data[key] == null:
					continue
				new_obj.set(key.split("_path")[0], load(data[key]))
			else:
				new_obj.set(key, data[key])

	get_tree().get_first_node_in_group("player").call_deferred("finalize_load")
	game_loaded.emit()


func serialize() -> Dictionary:
	return {
		"player_level": player_level,
		"global_state": global_state
	}

func deserialize(body: Dictionary) -> void:
	player_level = body.player_level
	global_state = body.global_state
