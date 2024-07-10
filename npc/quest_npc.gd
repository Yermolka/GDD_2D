class_name QuestNPC extends CharacterBody3D

@export var dialogue_data: DialogueData = null

@export var quest: QuestResource = null
var can_accept: bool = false
var can_turnin: bool = false

const INTERACTION_DIST: float = 200.0

func _ready() -> void:
	EventBus.dialogueSignal.connect(
		func(value: String) -> void:
			print(value)
			if value == "quests.test.accepted":
				Questify.start_quest(quest)
			elif value == "quests.test.completed":
				quest.turned_in = true
	)

	quest = quest.instantiate()

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	event = event as InputEventMouseButton
	if not event:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var dist: float = global_position.distance_to(get_tree().get_first_node_in_group("player").global_position)
		if dist > INTERACTION_DIST:
			return

		if not dialogue_data:
			return

		if not quest.started:
			EventBus.startDialogue.emit(dialogue_data, "start")
		elif not quest.completed and not quest.turned_in:
			EventBus.startDialogue.emit(dialogue_data, "not_ready")
		elif not quest.turned_in:
			EventBus.startDialogue.emit(dialogue_data, "turn_in")
