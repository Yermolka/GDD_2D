class_name AoeTargetScript extends Sprite3D

signal targeting_ended(pos: Vector3, success: bool)
var radius: float:
	get:
		return radius
	set(value):
		radius = value
		if radius <= 0:
			radius = 0.01
		var width: float = texture.get_width()
		scale = Vector3.ONE
		scale *= radius / width

@onready var raycast: RayCast3D = $RayCast3D

# func _process(_delta: float) -> void:
# 	global_position = get_viewport().get_camera_3d().project_ray_origin(get_viewport().get_global_mouse_position())

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		event = event as InputEventMouseButton
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				targeting_ended.emit(Vector3.ZERO, false)
			elif event.button_index == MOUSE_BUTTON_LEFT:
				targeting_ended.emit(global_position, true)
			queue_free()
		return
	elif event is InputEventMouseMotion:
		event = event as InputEventMouseMotion
		var camera_pos: Vector3 = get_viewport().get_camera_3d().global_position
		var mouse_pos: Vector3 = get_viewport().get_camera_3d().project_ray_normal(get_viewport().get_mouse_position()) * 1000
		raycast.global_position = camera_pos
		raycast.target_position = camera_pos + mouse_pos
		
		raycast.force_raycast_update()

		if raycast.is_colliding():
			global_position = raycast.get_collision_point() + Vector3(0, 0.01, 0)
