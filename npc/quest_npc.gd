class_name QuestNPC extends CharacterBody3D

@onready var quest_excl_texture: Texture2D = preload("res://quests/quest_excl.png")
@onready var quest_excl_highlight_texture: Texture2D = preload("res://quests/quest_excl_highlight.png")
@onready var quest_excl_gray_texture: Texture2D = preload("res://quests/quest_excl_gray.png")
@onready var quest_excl_gray_highlight_texture: Texture2D = preload("res://quests/quest_excl_gray_highlight.png")
@onready var quest_not_done_texture: Texture2D = preload("res://quests/quest_not_done.png")
@onready var quest_not_done_highlight_texture: Texture2D = preload("res://quests/quest_not_done_highlight.png")
@onready var quest_done_texture: Texture2D = preload("res://quests/quest_done.png")
@onready var quest_done_highlight_texture: Texture2D = preload("res://quests/quest_done_highlight.png")
@onready var icon_sprite: Sprite3D = $Sprite3D

var texture_map: Dictionary = {}
var current_texture_name: String = "none":
	get:
		return current_texture_name
	set(value):
		current_texture_name = value
		icon_sprite.texture = texture_map[value]

@export var dialogue_data: DialogueData = null

@export var quest: QuestResource = null:
	get:
		return quest
	set(value):
		quest = value
		quest = quest.instantiate()

const INTERACTION_DIST: float = 200.0

func _ready() -> void:
	add_to_group("persist")

	texture_map["excl"] = quest_excl_texture
	texture_map["excl_highlight"] = quest_excl_highlight_texture
	texture_map["excl_gray"] = quest_excl_gray_texture
	texture_map["excl_gray_highlight"] = quest_excl_gray_highlight_texture
	texture_map["not_done"] = quest_not_done_texture
	texture_map["not_done_highlight"] = quest_not_done_highlight_texture
	texture_map["done"] = quest_done_texture
	texture_map["done_highlight"] = quest_done_highlight_texture
	texture_map["none"] = null

	if quest:
		if quest.name == "Quest line":
			quest.global_requirements = {"test_quest_done": true}
		quest = quest.instantiate()

	EventBus.dialogueSignal.connect(
		func(value: String) -> void:
			# print(value)
			if value == "quests." + quest.name + ".accepted":
				Questify.start_quest(quest)
			elif value == "quests." + quest.name + ".completed":
				quest.turn_in()
				current_texture_name = "none"
	)
	Questify.quest_available.connect(
		func (q: QuestResource) -> void:
			if q.name == quest.name:
				current_texture_name = "excl"
	)
	Questify.quest_completed.connect(
		func(q: QuestResource) -> void:
			if q.name == quest.name:
				current_texture_name = "done"
	)
	Questify.quest_started.connect(
		func(q: QuestResource) -> void:
			if q.name == quest.name:
				current_texture_name = "not_done"
				print(current_texture_name)
	)

	await get_tree().process_frame

	if quest:
		Questify.register_quest(quest)

		if quest.available:
			print(quest.name)
			current_texture_name = "excl"
		elif not quest.available and not quest.started and not quest.completed and not quest.turned_in:
			current_texture_name = "excl_gray"
		elif quest.completed and not quest.turned_in:
			current_texture_name = "done"
		elif quest.started and not quest.completed:
			current_texture_name = "not_done"

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	event = event as InputEventMouseButton
	if not event:
		return

	if not quest.available and not quest.started and not quest.completed and not quest.turned_in:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var dist: float = global_position.distance_to(get_tree().get_first_node_in_group("player").global_position)
		if dist > INTERACTION_DIST:
			return

		if not dialogue_data:
			return

		if quest.available:
			EventBus.startDialogue.emit(dialogue_data, "start")
		elif not quest.completed and not quest.turned_in:
			EventBus.startDialogue.emit(dialogue_data, "not_ready")
		elif not quest.turned_in:
			EventBus.startDialogue.emit(dialogue_data, "turn_in")



func _on_mouse_exited() -> void:
	if current_texture_name != "none":
		current_texture_name = current_texture_name.split("_highlight")[0]


func _on_mouse_entered() -> void:
	if current_texture_name != "none":
		current_texture_name += "_highlight"


func serialize() -> Dictionary:
	var quest_path: Variant = null
	if quest:
		quest_path = quest.get_resource_path()

	var dialogue_path: Variant = null
	if dialogue_data:
		dialogue_path = dialogue_data.resource_path

	return {
		"filename": scene_file_path,
		"parent": get_parent().get_path(),
		"pos_x": global_position.x,
		"pos_y": global_position.y,
		"pos_z": global_position.z,
		"current_texture_name": current_texture_name,
		"quest_path": quest_path,
		"dialogue_data_path": dialogue_path,
	}
