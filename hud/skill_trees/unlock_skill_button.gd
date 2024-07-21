@tool
class_name UnlockSkillButton extends TextureButton

signal unlock_skill_btn_pressed(btn: UnlockSkillButton)

@export var skill: NonTargetedSkill:
	get:
		return skill
	set(value):
		skill = value
		if skill == null:
			texture_normal = null
		else:
			texture_normal = skill.ui_icon
			_update_arrows()

@onready var arrows: Array = get_children()
var player: Player:
	get:
		return get_tree().get_first_node_in_group("player")
var __setup: bool = true


func _ready() -> void:
	pressed.connect(
		func() -> void:
			print(skill.ui_name)
			unlock_skill_btn_pressed.emit(self)
	)
	__setup = false


func _update_arrows() -> void:
	if Engine.is_editor_hint() or __setup:
		return

	if skill in player.ability_container.granted_abilities:
		arrows.map(func (x: UITreeArrow) -> void: x.texture = x.active_texture)
	else:
		arrows.map(func (x: UITreeArrow) -> void: x.texture = x.not_active_texture)
