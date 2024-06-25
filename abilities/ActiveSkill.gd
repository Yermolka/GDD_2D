@tool
class_name ActiveSkill extends GDDSkill

@export_category("Active Skill")
@export var projectile_skill: PackedScene = null
@export var projectile_velocity: float = 1000.0

@export var resource_type: String = "mana"
@export var resource_cost: float = 0.0

@export var min_range: float = 0.0
@export var max_range: float = 0.0

func activate(event: ActivationEvent) -> void:
	var attribute_effect: AttributeEffect = AttributeEffect.new()
	var cost_effect: GameplayEffect = GameplayEffect.new()
	var player: Player = event.character as Player
	
	if player == null:
		return

	attribute_effect.attribute_name = resource_type
	attribute_effect.maximum_value = resource_cost
	attribute_effect.minimum_value = resource_cost

	cost_effect.attributes_affected.append(attribute_effect)

	event.character.add_child(cost_effect)

	print("CAST")


func can_activate(event: ActivationEvent) -> bool:
	var caster_player: Player = event.character as Player
	var caster_enemy: Enemy = event.character as Enemy

	if (caster_player == null and caster_enemy == null) or not event.has_ability_container:
		return false

	if caster_player != null:
		var target: CharacterBody2D = caster_player.get_tree().get_first_node_in_group("selected")
		if target == null:
			target = caster_player

		var resource: AttributeSpec = caster_player.attribute_map.get_attribute_by_name(resource_type)
		if resource == null:
			return false

		var deducted: float = resource.current_buffed_value - resource_cost
		if deducted < 0.0:
			return false

		var dist: float = caster_player.global_position.distance_to(target.global_position)
		if dist < min_range or dist > max_range:
			return false

		return true

	return false
	## caster is enemy

