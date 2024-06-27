class_name SkillTreeNode extends TextureButton

var skill: GDDSkill = null:
	get:
		return skill
	set(value):
		skill = value
		texture_normal = skill.ui_icon
		texture_disabled = skill.ui_icon
		_render()
var ability_container: AbilityContainer = null:
	get:
		return ability_container
	set(value):
		ability_container = value
		_render()

signal skill_tree_node_pressed(node: SkillTreeNode)

func _ready() -> void:
	pressed.connect(func() -> void: skill_tree_node_pressed.emit(self))

func force_set_disabled(value: bool) -> void:
	if value:
		modulate.a = 0.1
	else:
		modulate.a = 1.0
	disabled = value

func _render() -> void:
	if not ability_container or not skill:
		force_set_disabled(true)
		return
	
	force_set_disabled(not ability_container.can_grant(skill))
