class_name Selectable extends Area3D

var selected: bool = false
@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	if owner == null:
		owner = get_parent()
	add_to_group("selectable")
	input_event.connect(_handle_input)

func select() -> void:
	for s: Selectable in get_tree().get_nodes_in_group("selectable"):
		s.deselect()

	get_parent().add_to_group("selected")
	selected = true
	sprite.visible = true
	EventBus.onTargetSelected.emit(get_parent())

func deselect() -> void:
	if selected:
		get_parent().remove_from_group("selected")
		selected = false
		sprite.visible = false

func _handle_input(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if selected:
		return

	event = event as InputEventMouseButton
	if event == null:
		return

	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select()
