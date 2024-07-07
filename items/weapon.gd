class_name Weapon extends EquipmentBase

@export_category("Weapon")
@export var skill_tree: SkillTreeData = null
@export var skill: ActiveSkill = null
@export var skill_points: int = 0:
	get:
		return skill_points
	set(value):
		skill_points = value
		skill_points_changed.emit(value)

@export var level: int = 1
@export var current_xp: int = 0:
	get:
		return current_xp
	set(value):
		current_xp = value
		if xp_map.size() > level and current_xp >= xp_map[level]:
			current_xp -= xp_map[level]
			level += 1
			skill_points += 1
		if xp_map.size() > level:
			current_xp_changed.emit(current_xp, xp_map[level])
@export var xp_map: Array[int]
var max_level: int:
	get:
		return xp_map.size()

signal current_xp_changed(value: int, maxValue: int)
signal skill_points_changed(value: int)

func _equip(eq: Equipment, slot: EquipmentSlot) -> void:
	var player: Player = eq.owner as Player
	if not player:
		return

	player.ability_container.grant(skill)

func _unequip(eq: Equipment, slot: EquipmentSlot) -> void:
	var player: Player = eq.owner as Player
	if not player:
		return

	player.ability_container.revoke(skill)

func _can_equip(_equipment: Equipment) -> bool:
	if skill != null:
		var player: Player = _equipment.owner as Player
		for tag: String in skill.grant_tags_required:
			if not player.ability_container.has_tag(tag):
				return false

	return super._can_equip(_equipment)

func give_xp(amount: int) -> void:
	current_xp += amount
