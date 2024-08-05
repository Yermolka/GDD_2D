class_name GDDSkillUpgrade extends Resource

@export var ui_name: String = ""
@export var ui_icon: Texture2D = null
@export var ui_description: String = ""

@export var skill: ActiveSkill

@export_group("Tags")
@export var grant_tags_required: Array[String] = []
@export var grant_tags: Array[String] = []
var learned: bool = false

@export_group("General upgrades")
@export var upgrades_resource_costs: Dictionary = {}
@export var upgrade_min_range: float = 0.0
@export var upgrade_max_range: float = 0.0
@export var upgrade_cast_time: float = 0.0
@export var upgrade_cooldown: float = 0.0
@export var upgrade_remove_gcd: bool = false

@export_group("Upgrade scene effect")
@export var upgrade_projectile: PackedScene = null
@export var upgrade_projectile_speed: float = 1000.0

@export_group("Upgrades for target")
@export var upgrades_instant: Array[AttributeEffect] = []

@export var upgrades_instant_timed: Array[AttributeEffect] = []
@export var upgrades_instant_bonus_duration: float = 1.0

@export var upgrades_chance: Array[ChanceAttributeEffect] = []

@export_group("Upgrades for self")
@export var upgrades_generator: Array[AttributeEffect] = []
@export var upgrades_instant_self: Array[AttributeEffect] = []

@export var upgrades_instant_timed_self: Array[AttributeEffect] = []
@export var upgrades_instant_self_bonus_duration: float = 1.0

@export var upgrades_chance_self: Array[ChanceAttributeEffect] = []

func unlocked(ac: AbilityContainer) -> bool:
	if learned:
		return false

	for tag: String in grant_tags_required:
		if not ac.has_tag(tag):
			return false

	return skill in ac.granted_abilities

func apply(ac: AbilityContainer) -> void:
	ac.add_tags(grant_tags)

	for resource_type: String in upgrades_resource_costs:
		skill.resource_costs[resource_type] += upgrades_resource_costs[resource_type]

	skill.min_range += upgrade_min_range
	skill.max_range += upgrade_max_range
	skill.cast_time += upgrade_cast_time
	skill.cooldown_duration += upgrade_cooldown

	if upgrade_remove_gcd:
		skill.tags_activation.erase("gcd")
		skill.tags_block.erase("gcd")

	if skill.projectile_scene == null:
		skill.projectile_scene = upgrade_projectile
		skill.projectile_speed = upgrade_projectile_speed

	## Target
	skill.instant_effects.append_array(upgrades_instant)
	
	skill.instant_timed_effects.append_array(upgrades_instant_timed)
	skill.timed_effects_duration += upgrades_instant_bonus_duration

	skill.chance_effects.append_array(upgrades_chance)

	## Self
	skill.generator_effects.append_array(upgrades_generator)
	skill.instant_self_effects.append_array(upgrades_instant_self)

	skill.instant_self_timed_effects.append_array(upgrades_instant_timed_self)
	skill.instant_self_timed_effects_duration += upgrades_instant_self_bonus_duration

	skill.self_chance_effects.append_array(upgrades_chance_self)

	learned = true

func remove(ac: AbilityContainer) -> void:
	for tag: String in grant_tags:
		ac.remove_tag(tag)

	for resource_type: String in upgrades_resource_costs:
		skill.resource_costs[resource_type] -= upgrades_resource_costs[resource_type]

	skill.min_range -= upgrade_min_range
	skill.max_range -= upgrade_max_range
	skill.cast_time -= upgrade_cast_time
	skill.cooldown_duration -= upgrade_cooldown

	if upgrade_remove_gcd:
		skill.tags_activation.append("gcd")
		skill.tags_block.append("gcd")

	if skill.projectile_scene == upgrade_projectile:
		skill.projectile_scene = null

	## Target
	for up: AttributeEffect in upgrades_instant:
		skill.instant_effects.erase(up)

	for up: AttributeEffect in upgrades_instant_timed:
		skill.instant_timed_effects.erase(up)
	skill.timed_effects_duration -= upgrades_instant_bonus_duration

	for up: AttributeEffect in upgrades_chance:
		skill.chance_effects.erase(up)

	## Self
	for up: AttributeEffect in upgrades_generator:
		skill.generator_effects.erase(up)
	for up: AttributeEffect in upgrades_instant_self:
		skill.instant_self_effects.erase(up)
	
	for up: AttributeEffect in upgrades_instant_timed_self:
		skill.instant_self_timed_effects.erase(up)
	skill.instant_self_timed_effects_duration -= upgrades_instant_self_bonus_duration

	for up: AttributeEffect in upgrades_chance_self:
		skill.self_chance_effects.erase(up)

	learned = false
