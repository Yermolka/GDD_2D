@tool
class_name TargetedSkill extends ActiveSkill

var target: CharacterBody2D = null

func is_target_hostile(event: ActivationEvent) -> bool:
	return event.character.is_in_group("enemies") != target.is_in_group("enemies")

func activate(event: ActivationEvent) -> void:
	var player: Player = event.character as Player
	await super.activate(event)
	if cast_time > 0.0 and event.ability_container.has_tag("interrupted"):
		return

	## Projectile
	if projectile_scene != null and projectile_scene.can_instantiate():
		var scene: Node2D = projectile_scene.instantiate()
		player.get_tree().root.add_child(scene)
		scene.position = player.position
	## Instant
	else:
		print("Target cast")

func set_target(_target: CharacterBody2D) -> void:
	target = _target

func can_activate(event: ActivationEvent) -> bool:
	var _target: Node2D = event.character.get_tree().get_first_node_in_group("selected")
	if target == null:
		if _target == null:
			target = event.character
		else:
			target = _target.get_parent()

	var dist: float = event.character.global_position.distance_to(target.global_position)
	if dist < min_range or dist > max_range:
		return false

	return super.can_activate(event)
