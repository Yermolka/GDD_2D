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
