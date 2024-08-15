extends Node3D

@onready var label: Label = $Label
var camera: CameraController:
	get:
		return get_viewport().get_camera_3d()


func _physics_process(delta: float) -> void:
	if get_tree().get_first_node_in_group("player").global_position.distance_to(global_position) < 5.0:
		if not get_parent().is_in_group("pick_up"):
			get_parent().add_to_group("pick_up")
		label.visible = true
		label.position = camera.unproject_position(global_position)
	else:
		if get_parent().is_in_group("pick_up"):
			get_parent().remove_from_group("pick_up")
		label.visible = false
