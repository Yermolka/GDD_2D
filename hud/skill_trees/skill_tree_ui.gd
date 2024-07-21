class_name SkillTreeUI extends Control

@export var available_points: int = 0:
	get:
		return available_points
	set(value):
		available_points = value
		update_buttons()

var buttons: Array[UnlockSkillButton]
var player: Player:
	get:
		return get_tree().get_first_node_in_group("player")


func setup() -> void:
	buttons.assign($Panel.get_children().filter(func (x: Control) -> bool: return x is UnlockSkillButton))
	for b: UnlockSkillButton in buttons:
		b.unlock_skill_btn_pressed.connect(_handle_btn_pressed)

	update_buttons()
	visibility_changed.connect(func() -> void: update_buttons())
	var weapon: Weapon = player.equipment.slots.filter(func (x: EquipmentSlot) -> bool: return x.name == "weapon")[0].equipped
	available_points = weapon.skill_points
	weapon.skill_points_changed.connect(func (x: int) -> void: available_points = weapon.skill_points)

	player.equipment.unequipped.connect(
		func (item: Item, slot: EquipmentSlot) -> void:
			if item != weapon:
				return
			
			for b: UnlockSkillButton in buttons:
				if player.ability_container.granted_abilities.has(b.skill):
					player.ability_container.revoke(b.skill)
	)

func update_buttons() -> void:
	for b: UnlockSkillButton in buttons:
		if player.ability_container.granted_abilities.has(b.skill):
			b.disabled = false
		else:
			b.disabled = not (available_points > 0 and player.ability_container.can_grant(b.skill))
		print(b.skill.ui_name + " disabled is ", b.disabled)
		print(player.ability_container.can_grant(b.skill))


func _handle_btn_pressed(btn: UnlockSkillButton) -> void:
	if player.ability_container.granted_abilities.has(btn.skill):
		for b: UnlockSkillButton in buttons:
			if player.ability_container.granted_abilities.has(b.skill):
				for tag: String in btn.skill.grant_tags:
					if tag in b.skill.grant_tags_required:
						return
		
		player.ability_container.revoke(btn.skill)
		available_points += 1
		print("Unlearned ", btn.skill.ui_name)
	else:
		player.ability_container.grant(btn.skill)
		available_points -= 1
		print("Learned ", btn.skill.ui_name)
