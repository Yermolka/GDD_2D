@tool
class_name SkillProjectile extends EffectedArea2D

@export_category("Projectile")
@export var texture: Texture2D = null:
	get:
		return texture
	set(value):
		texture = value
		sprite2d.texture = texture
@export var texture_scale: Vector2 = Vector2.ONE:
	get:
		return texture_scale
	set(value):
		texture_scale = value
		sprite2d.scale = value

@onready var sprite2d: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var speed: float = 5.0
var target: Entity = null
var target_group: String = "enemies"
var radius: float = 1.0:
	get:
		return collision_shape.shape.radius
	set(value):
		radius = value
		collision_shape.shape.radius = value

func _physics_process(delta: float) -> void:
	if not target:
		queue_free()
		return

	var direction: Vector2 = global_position.direction_to(target.global_position)
	position += direction * speed * delta

func should_apply_effect(node: Node2D) -> bool:
	return node == target
