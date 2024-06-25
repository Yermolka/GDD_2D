@tool
class_name PassiveSkill extends GDDSkill

@export_category("Passive Skill")
@export var effects: Array[AttributeEffect] = []

func activate(event: ActivationEvent) -> void:
	super.activate(event)

	var result: GameplayEffect = GameplayEffect.new()

	if event.character != null:
		result.attributes_affected = effects
		event.character.add_child(result)

func can_end(event: ActivationEvent) -> bool:
	if event.has_ability_container:
		return event.ability_container.tags.has(GDDSkill.DEAD_TAG)

	return super.can_end(event)
