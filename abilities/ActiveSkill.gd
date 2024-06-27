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

@export_group("Effects for target")
@export var instant_effects: Array[AttributeEffect] = []

@export var instant_timed_effects: Array[AttributeEffect] = []
@export var timed_effects_duration: float = 1.0

@export var chance_effects: Array[ChanceAttributeEffect] = []

@export_group("Effects for self")
@export var generator_effect: AttributeEffect = AttributeEffect.new()
@export var instant_self_effects: Array[AttributeEffect] = []

@export var instant_self_timed_effects: Array[AttributeEffect] = []
@export var instant_self_timed_effects_duration: float = 1.0

@export var self_chance_effects: Array[ChanceAttributeEffect] = []

func activate(event: ActivationEvent) -> void:
	super.activate(event)

	var attribute_effect: AttributeEffect = AttributeEffect.new()
	var cost_effect: GameplayEffect = GameplayEffect.new()
	var caster: Entity = event.character as Entity

	if caster == null:
		return

	if cast_time != 0.0:
		event.ability_container.add_tag(CASTING_TAG)
		await _cast(caster.get_tree().create_timer(cast_time), event.ability_container)
		event.ability_container.remove_tag(CASTING_TAG)
		if event.ability_container.has_tag("interrupted"):
			return

	attribute_effect.attribute_name = resource_type
	attribute_effect.maximum_value = -resource_cost
	attribute_effect.minimum_value = -resource_cost

	cost_effect.attributes_affected.append(attribute_effect)

	event.character.add_child(cost_effect)

	## Instant self
	var self_generator_effect: GameplayEffect = GameplayEffect.new()
	self_generator_effect.attributes_affected.append(generator_effect)
	self_generator_effect.set_stats(event.attribute_map)
	caster.add_child(self_generator_effect)

	var self_effect: GameplayEffect = GameplayEffect.new()
	self_effect.attributes_affected = instant_self_effects
	self_effect.set_stats(event.attribute_map)
	caster.add_child(self_effect)

	var self_timed_effect: TimedGameplayEffect = TimedGameplayEffect.new()
	self_timed_effect.attributes_affected = instant_self_timed_effects
	self_timed_effect.effect_time = instant_self_timed_effects_duration
	self_timed_effect.set_stats(event.attribute_map)
	caster.add_child(self_timed_effect)

	var self_chance_effect: GameplayEffect = GameplayEffect.new()
	for ce: ChanceAttributeEffect in self_chance_effects:
		if ce.proc:
			self_chance_effect.attributes_affected.append(ce)
	self_chance_effect.set_stats(event.attribute_map)
	caster.add_child(self_chance_effect)

	print("CAST")

func _cast(timer: SceneTreeTimer, ac: AbilityContainer) -> void:
	while true:
		if not timer or timer.time_left <= 0.0:
			return
		if ac.has_tag("interrupted"):
			return

		await ac.owner.get_tree().process_frame

func can_activate(event: ActivationEvent) -> bool:
	var caster: Entity = event.character as Entity

	if caster == null or not event.has_ability_container:
		return false

	if not resource_type.is_empty():
		var resource: AttributeSpec = caster.attribute_map.get_attribute_by_name(resource_type)
		if resource == null:
			return false

		var deducted: float = resource.current_buffed_value - resource_cost
		if deducted < 0.0:
			return false

	return super.can_activate(event)

func set_target(_target: Entity) -> void:
	pass
