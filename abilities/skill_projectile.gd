@tool
class_name SkillProjectile extends EffectedArea3D

@export_category("Projectile")

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var speed: float = 5.0
var target: Entity = null
var target_group: String = "enemies"
var radius: float = 1.0:
	get:
		return collision_shape.shape.radius
	set(value):
		radius = value
		collision_shape.shape.radius = value
		mesh.mesh.radius = value

func _physics_process(delta: float) -> void:
	if not target:
		queue_free()
		return

	var direction: Vector3 = global_position.direction_to(target.global_position)
	position += direction * speed * delta

func should_apply_effect(node: Node3D) -> bool:
	return node == target
