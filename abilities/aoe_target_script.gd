class_name AoeTargetScript extends Sprite2D

signal targeting_ended(pos: Vector2, success: bool)
var radius: float:
	get:
		return radius
	set(value):
		radius = value
		if radius <= 0:
			radius = 0.01
		var width: float = texture.get_width()
		scale = Vector2.ONE
		scale *= radius / width

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func _input(event: InputEvent) -> void:
	event = event as InputEventMouseButton
	if not event:
		return

	if event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			targeting_ended.emit(Vector2.ZERO, false)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			targeting_ended.emit(global_position, true)
		queue_free()
