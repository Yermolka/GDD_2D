@tool
class_name ActiveSkill extends GDDSkill

@export_category("Active Skill")
@export var projectile_scene: PackedScene = null
@export var projectile_speed: float = 1000.0

@export var resource_costs: Dictionary = {}

@export var min_range: float = 0.0
@export var max_range: float = 0.0

@export var cast_time: float = 0.0

@export_group("Effects for target")
@export var instant_effects: Array[AttributeEffect] = []

@export var instant_timed_effects: Array[AttributeEffect] = []
@export var timed_effects_duration: float = 1.0

@export var chance_effects: Array[ChanceAttributeEffect] = []

@export_group("Effects for self")
@export var generator_effects: Array[AttributeEffect] = []
@export var instant_self_effects: Array[AttributeEffect] = []

@export var instant_self_timed_effects: Array[AttributeEffect] = []
@export var instant_self_timed_effects_duration: float = 1.0

@export var self_chance_effects: Array[ChanceAttributeEffect] = []

signal cast_started(skill: ActiveSkill)
signal cast_ended(skill: ActiveSkill, success: bool)

func activate(event: ActivationEvent) -> void:
	super.activate(event)

	var cost_effect: GameplayEffect = GameplayEffect.new()
	var caster: Entity = event.character as Entity

	if caster == null:
		return

	if cast_time != 0.0:
		cast_started.emit(self)
		event.ability_container.add_tag(CASTING_TAG)
		await _cast(caster.get_tree().create_timer(cast_time), event.ability_container)
		event.ability_container.remove_tag(CASTING_TAG)
		if event.ability_container.has_tag("moving") and tags_block.has("moving"):
			cast_ended.emit(self, false)
			return
		cast_ended.emit(self, true)

	for resource_type: String in resource_costs:
		var attribute_effect: AttributeEffect = AttributeEffect.new()
		attribute_effect.attribute_name = resource_type
		attribute_effect.maximum_value = -resource_costs[resource_type]
		attribute_effect.minimum_value = -resource_costs[resource_type]

		cost_effect.attributes_affected.append(attribute_effect)

	event.character.add_child(cost_effect)

	## Instant self
	var self_generator_effect: GameplayEffect = GameplayEffect.new()
	self_generator_effect.attributes_affected = generator_effects
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

	if self is TargetedSkill or self is AoeTargetSkill or self is NonTargetedSkill:
		return

	if projectile_scene != null and projectile_scene.can_instantiate():
		var scene: Node3D = projectile_scene.instantiate()
		caster.get_tree().root.add_child(scene)
		scene.global_position = caster.global_position


func _cast(timer: SceneTreeTimer, ac: AbilityContainer) -> void:
	while true:
		if not timer or timer.time_left <= 0.0:
			return
		if ac.has_tag("moving") and tags_block.has("moving"):
			return

		await ac.owner.get_tree().process_frame

func can_activate(event: ActivationEvent) -> bool:
	var caster: Entity = event.character as Entity

	if caster == null or not event.has_ability_container:
		return false

	if resource_costs.size() > 0:
		for resource_type: String in resource_costs:
			var resource: AttributeSpec = caster.attribute_map.get_attribute_by_name(resource_type)
			if resource == null:
				return false

			var deducted: float = resource.current_buffed_value - resource_costs[resource_type]
			if deducted < 0.0:
				return false

	return super.can_activate(event)

func set_target(_target: Entity) -> void:
	pass
