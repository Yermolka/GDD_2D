@tool
class_name ActiveSkill extends GDDSkill

@export_category("Active Skill")
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 1000.0

@export var resource_type: String = "mana"
@export var resource_cost: float = 0.0

@export var min_range: float = 0.0
@export var max_range: float = 0.0

@export var cast_time: float = 0.0
@export var instant_effects: Array[AttributeEffect] = []

func activate(event: ActivationEvent) -> void:
	super.activate(event)

	var attribute_effect: AttributeEffect = AttributeEffect.new()
	var cost_effect: GameplayEffect = GameplayEffect.new()
	var player: Player = event.character as Player

	if player == null:
		return

	if cast_time != 0.0:
		event.ability_container.add_tag(CASTING_TAG)
		await _cast(player.get_tree().create_timer(cast_time), event.ability_container)
		event.ability_container.remove_tag(CASTING_TAG)
		if event.ability_container.has_tag("interrupted"):
			return

	attribute_effect.attribute_name = resource_type
	attribute_effect.maximum_value = -resource_cost
	attribute_effect.minimum_value = -resource_cost

	cost_effect.attributes_affected.append(attribute_effect)

	event.character.add_child(cost_effect)

	print("CAST")

func _cast(timer: SceneTreeTimer, ac: AbilityContainer) -> void:
	while true:
		if not timer or timer.time_left <= 0.0:
			return
		if ac.has_tag("interrupted"):
			return

		await ac.owner.get_tree().process_frame

func can_activate(event: ActivationEvent) -> bool:
	var caster_player: Player = event.character as Player
	var caster_enemy: Enemy = event.character as Enemy

	if (caster_player == null and caster_enemy == null) or not event.has_ability_container:
		return false

	if caster_player != null:
		var resource: AttributeSpec = caster_player.attribute_map.get_attribute_by_name(resource_type)
		if resource == null:
			return false

		var deducted: float = resource.current_buffed_value - resource_cost
		if deducted < 0.0:
			return false

		return super.can_activate(event)

	return false

func set_target(_target: CharacterBody2D) -> void:
	pass
