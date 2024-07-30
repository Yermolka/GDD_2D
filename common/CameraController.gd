class_name CameraController extends Camera3D

const CAMERA_OFFSET: Vector3 = Vector3(2.8, 6, 5.15)
const CAMERA_ROTATION: Vector3 = Vector3(-30, 30, 0)
@onready var player: Player = get_tree().get_first_node_in_group("player")
var last_ray_position: Vector3

func _ready() -> void:
	global_rotation_degrees = CAMERA_ROTATION


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position + CAMERA_OFFSET

	var ray: RayCast3D = $RayCast3D
	# ray.global_position = global_position
	var from: Vector3 = project_ray_origin(get_viewport().get_mouse_position())
	var to: Vector3 = from + project_ray_normal(get_viewport().get_mouse_position()) * 1000
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	# ray.global_position = from
	# ray.target_position = to
	ray.force_raycast_update()

	var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	var iray: Dictionary = space_state.intersect_ray(params)

	if iray.get("position"):
		last_ray_position = iray.position
		# player.look_at(iray.position)
		# player.global_rotation.z = 0
		# player.global_rotation.x = 0
	
	# print(get_viewport().get_mouse_position())
