class_name Selectable extends Area2D

var selected: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if owner == null:
		owner = get_parent()
	add_to_group("selectable")
	input_event.connect(_handle_input)

func select() -> void:
	for s: Selectable in get_tree().get_nodes_in_group("selectable"):
		s.deselect()

	add_to_group("selected")
	selected = true
	sprite.visible = true

func deselect() -> void:
	if selected:
		remove_from_group("selected")
		selected = false
		sprite.visible = false

func _handle_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if selected:
		return

	event = event as InputEventMouseButton
	if event == null:
		return

	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select()
