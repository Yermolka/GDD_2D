@tool
class_name TargetedSkill extends ActiveSkill

var target: Entity = null
@export_enum("Hostile", "Friendly") var allowed_targets: int = 0

func is_target_hostile(event: ActivationEvent) -> bool:
	return event.character.is_in_group("enemies") != target.is_in_group("enemies")

func activate(event: ActivationEvent) -> void:
	var caster: Entity = event.character as Entity
	await super.activate(event)
	if cast_time > 0.0 and event.ability_container.has_tag("interrupted"):
		return

	## Projectile
	if projectile_scene != null and projectile_scene.can_instantiate():
		var scene: Node2D = projectile_scene.instantiate()
		caster.get_tree().root.add_child(scene)
		scene.position = caster.position

	## Instant target
	var main_effect: GameplayEffect = GameplayEffect.new()
	main_effect.attributes_affected = instant_effects
	target.add_child(main_effect)

	var main_timed_effect: TimedGameplayEffect = TimedGameplayEffect.new()
	main_timed_effect.attributes_affected = instant_timed_effects
	main_timed_effect.effect_time = timed_effects_duration
	target.add_child(main_timed_effect)

	var main_chance_effect: GameplayEffect = GameplayEffect.new()
	for ce: ChanceAttributeEffect in chance_effects:
		if ce.proc:
			main_chance_effect.attributes_affected.append(ce)
	target.add_child(main_chance_effect)

func set_target(_target: Entity) -> void:
	target = _target

func can_activate(event: ActivationEvent) -> bool:
	if allowed_targets == 1 and target == null:
		target = event.character

	if target == null or not is_instance_valid(target):
		return false

	var dist: float = event.character.global_position.distance_to(target.global_position)
	if dist < min_range or dist > max_range:
		return false

	if allowed_targets == 0 and is_target_hostile(event):
		return super.can_activate(event)
	elif allowed_targets == 1 and not is_target_hostile(event):
		return super.can_activate(event)
	
	return false
