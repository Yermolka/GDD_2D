@tool
class_name TargetedSkill extends ActiveSkill

var target: CharacterBody2D = null

func is_target_hostile(event: ActivationEvent) -> bool:
	return event.character.is_in_group("enemies") != target.is_in_group("enemies")

func activate(event: ActivationEvent) -> void:
	var player: Player = event.character as Player
	var enemy: Enemy = target as Enemy
	await super.activate(event)
	if cast_time > 0.0 and event.ability_container.has_tag("interrupted"):
		return

	## Projectile
	if projectile_scene != null and projectile_scene.can_instantiate():
		var scene: Node2D = projectile_scene.instantiate()
		player.get_tree().root.add_child(scene)
		scene.position = player.position

	var main_effect: GameplayEffect = GameplayEffect.new()
	main_effect.attributes_affected = instant_effects
	enemy.add_child(main_effect)

	var main_timed_effect: TimedGameplayEffect = TimedGameplayEffect.new()
	main_timed_effect.attributes_affected = instant_timed_effects
	main_timed_effect.effect_time = timed_effects_duration
	enemy.add_child(main_timed_effect)

	var generator_effect: GameplayEffect = GameplayEffect.new()
	var generator: AttributeEffect = AttributeEffect.new()
	generator.attribute_name = generate_resource_type
	generator.minimum_value = generate_resource_min_amount
	generator.maximum_value = generate_resource_max_amount
	generator_effect.attributes_affected.append(generator)
	player.add_child(generator_effect)

func set_target(_target: CharacterBody2D) -> void:
	target = _target

func can_activate(event: ActivationEvent) -> bool:
	var dist: float = event.character.global_position.distance_to(target.global_position)
	print(dist)
	if dist < min_range or dist > max_range:
		return false

	return super.can_activate(event)
