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

func _render() -> void:
	if not ability_container or not skill:
		disabled = true
		modulate.a = 0.1
		return
	
	disabled = not ability_container.can_grant(skill)
	if disabled:
		modulate.a = 0.1
	else:
		modulate.a = 1.0
