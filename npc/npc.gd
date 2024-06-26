class_name NPC extends CharacterBody2D

@onready var dialogue_bubble: DialogueBubble = $DialogueBubble
@export var dialogue_data: DialogueData = null

@onready var timer: Timer = $Timer

const INTERACTION_DIST: float = 200.0

func _ready() -> void:
	dialogue_bubble.data = dialogue_data

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	event = event as InputEventMouseButton
	if not event:
		return

	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var dist: float = global_position.distance_to(get_tree().get_first_node_in_group("player").global_position)
		if dist > INTERACTION_DIST:
			return

		if dialogue_data:
			dialogue_bubble.start("start")
			while dialogue_bubble.is_running():
				timer.start(2.0)
				await timer.timeout
				dialogue_bubble.select_option(0)
