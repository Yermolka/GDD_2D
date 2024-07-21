@tool
class_name NonTargetedSkill extends ActiveSkill

func activate(event: ActivationEvent) -> void:
	var caster: Entity = event.character as Entity
	await super.activate(event)
	if cast_time > 0.0 and event.ability_container.has_tag("moving"):
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

	## special effect
	if projectile_scene != null and projectile_scene.can_instantiate():
		var scene: MeleeBase = projectile_scene.instantiate()
		scene.add_child(main_effect)
		scene.add_child(main_chance_effect)
		scene.add_child(main_timed_effect)
		# scene.position = caster.global_position
		# if grant_tags.has("type.melee"):
		caster.add_child(scene)
		# else:
		# 	caster.get_tree().root.add_child(scene)
		return

func can_activate(event: ActivationEvent) -> bool:
	return super.can_activate(event)
