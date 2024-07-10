@tool
class_name AoeTargetSkill extends ActiveSkill

@export_group("AoE Targeting")
@export var targeting_scene: PackedScene

func activate(event: ActivationEvent) -> void:
	if targeting_scene == null or not targeting_scene.can_instantiate():
		printerr("targeting scene is null")
		return

	var scene: AoeTargetScript = targeting_scene.instantiate()
	event.character.get_tree().root.add_child(scene)
	scene.radius = ui_icon.get_width()
	var res: Array = await scene.targeting_ended
	if not res[1]: # not success
		return

	if event.character.global_position.distance_to(res[0]) > max_range:
		return

	await super.activate(event)
	if event.ability_container.has_tag("moving"):
		return

	## Instant target
	var main_effect: GameplayEffect = GameplayEffect.new()
	main_effect.attributes_affected = instant_effects
	main_effect.set_stats(event.attribute_map)

	var main_timed_effect: TimedGameplayEffect = TimedGameplayEffect.new()
	main_timed_effect.attributes_affected = instant_timed_effects
	main_timed_effect.effect_time = timed_effects_duration
	main_timed_effect.set_stats(event.attribute_map)

	var main_chance_effect: GameplayEffect = GameplayEffect.new()
	for ce: ChanceAttributeEffect in chance_effects:
		if ce.proc:
			main_chance_effect.attributes_affected.append(ce)
	main_chance_effect.set_stats(event.attribute_map)

	if projectile_scene != null and projectile_scene.can_instantiate():
		var p_scene: SkillAoe = projectile_scene.instantiate()
		event.character.get_tree().root.add_child(p_scene)
		p_scene.add_child(main_effect)
		p_scene.add_child(main_chance_effect)
		p_scene.add_child(main_timed_effect)
		p_scene.position = res[0]
		# p_scene.texture = ui_icon
		# p_scene.collision_shape.shape.radius = ui_icon.get_width() / 2.0
		p_scene.collision_shape.shape.radius = 5
		p_scene.speed = projectile_speed

func can_activate(event: ActivationEvent) -> bool:
	return super.can_activate(event)
