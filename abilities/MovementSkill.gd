@tool
class_name MovementSkill extends ActiveSkill

@export_enum("Teleport", "Dash") var movement_type: int = 0
@export var tp_max_range: float = 500.0
## var for AI only
var tp_target: Vector3

@export var dash_speed: float = 500.0
## Duration in seconds
@export var dash_duration: float = 0.5

## Method for AI
func set_tp_target(target_pos: Vector3) -> void:
	tp_target = target_pos

func activate(event: ActivationEvent) -> void:
	await super.activate(event)

	var caster: Entity = event.character as Entity
	match movement_type:
		0:
			caster.global_position = tp_target
		1:
			event.ability_container.add_tag("movement.dashing")
			event.ability_container.add_tag("moving")

			var dir: Vector3 = caster.velocity
			if dir.length() == 0.0:
				dir = Vector3(1, 0, 0)
			else:
				dir = dir.normalized()
			await _dash(caster, dir)

			event.ability_container.remove_tag("movement.dashing")
			event.ability_container.remove_tag("moving")

func _dash(caster: Entity, dir: Vector3) -> void:
	var prev_time: float = dash_duration
	var delta: float = 0.0
	while true:
		if prev_time <= 0.0:
			return

		delta = caster.get_process_delta_time()
		prev_time -= delta
		caster.global_position += dir * dash_speed * delta

		#TODO: change to move_and_slide()

		await caster.get_tree().process_frame

func can_activate(event: ActivationEvent) -> bool:
	if not super.can_activate(event):
		return false

	var caster: Entity = event.character as Entity
	match movement_type:
		0:
			if caster is Player:
				tp_target = caster.get_viewport().get_camera_3d().project_ray_origin(caster.get_global_mouse_position())
			return caster.global_position.distance_to(tp_target) < tp_max_range
		1:
			return true

	return false
