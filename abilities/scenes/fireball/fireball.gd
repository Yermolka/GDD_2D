class_name Fireball extends MeleeBase

@export var speed: float = 500.0
var forward: Vector3

func _ready() -> void:
	super._ready()
	# forward = -caster.global_transform.basis.z
	get_tree().create_timer(2.0).timeout.connect(func () -> void: queue_free())
	reparent(get_tree().root)
	forward = global_position.direction_to((get_viewport().get_camera_3d() as CameraController).last_ray_position + Vector3(0, 0.2, 0))


func _physics_process(delta: float) -> void:
	global_position += forward * speed * delta


func should_apply_effect(node: Node3D) -> bool:
	if not node is Entity:
		queue_free()
		return false

	return super.should_apply_effect(node)
