class_name PassiveSkill extends Resource

signal applied_changed()

@export var ui_icon: Texture2D
@export var ui_name: String
@export var ui_description: String

@export_category("Passive Skill")
@export var effects: Array[AttributeEffect] = []
@export var new_resource: AttributeResource
var applied: bool = false

@export_category("Requirements")
@export var min_level: int = 0
@export var required_passives: Array[String]


func can_activate(player: Player) -> bool:
	for p: String in required_passives:
		if p not in player.unlocked_passives:
			return false

	return player.level >= min_level


func activate(player: Player) -> void:
	if applied:
		return

	if new_resource != null:
		var spec: AttributeSpec = AttributeSpec.from_attribute(new_resource)
		player.attribute_map.add_attribute(spec)
		player.ability_container.add_tag("resources." + spec.attribute_name)

	var g_effect: GameplayEffect = GameplayEffect.new()
	g_effect.attributes_affected = effects
	g_effect.set_stats(player.attribute_map)
	player.add_child(g_effect)

	applied = true
	player.unlocked_passives.append(ui_name)
	applied_changed.emit()


func deactivate(player: Player) -> void:
	if not applied:
		return

	if new_resource != null:
		player.attribute_map.remove_attribute(new_resource.attribute_name)
		player.ability_container.remove_tag("resources." + new_resource.attribute_name)

	var antieffects: GameplayEffect = GameplayEffect.new()
	for e: AttributeEffect in effects:
		var antieffect: AttributeEffect = e.duplicate() as AttributeEffect
		antieffect.minimum_value *= -1
		antieffect.maximum_value *= -1
		antieffects.attributes_affected.append(antieffect)

	player.add_child(antieffects)

	applied = false
	player.unlocked_passives.erase(ui_name)
	applied_changed.emit()
