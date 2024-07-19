extends Camera3D

const CAMERA_OFFSET: Vector3 = Vector3(2.8, 6, 5.15)
const CAMERA_ROTATION: Vector3 = Vector3(-30, 30, 0)
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	global_rotation_degrees = CAMERA_ROTATION


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position + CAMERA_OFFSET
