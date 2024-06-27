class_name SkillTree extends Control

@export var data: SkillTreeData = null:
	get:
		return data
	set(value):
		data = value
		_draw_items()
var ability_container: AbilityContainer = null
@export var available_points: int = 0:
	get:
		return available_points
	set(value):
		available_points = value
		_draw_items()
@onready var skill_tree_slot: PackedScene = preload("res://hud/skill_tree_node.tscn")
@onready var vbox_container: VBoxContainer = $Panel/VBoxContainer
@onready var hbox_container: HBoxContainer = $HBoxContainer

func _ready() -> void:
	visibility_changed.connect(_draw_items)

func _draw_items() -> void:
	if not visible or not vbox_container:
		return
	
	for c: Node in vbox_container.get_children():
		vbox_container.remove_child(c)
		c.queue_free()

	for tier: SkillTreeTierData in data.tiers:
		var hbox: HBoxContainer = hbox_container.duplicate()
		vbox_container.add_child(hbox)
		hbox.visible = true
		for skill: GDDSkill in tier.skills:
			var btn: SkillTreeNode = skill_tree_slot.instantiate()
			btn.ability_container = ability_container
			btn.skill = skill
			btn.force_set_disabled(btn.disabled or available_points == 0)
			hbox.add_child(btn)
			btn.skill_tree_node_pressed.connect(_ability_clicked)
	
func _ability_clicked(node: SkillTreeNode) -> void:
	ability_container.grant(node.skill)
	available_points -= 1
	_draw_items()

func setup_ability_container(ac: AbilityContainer) -> void:
	ability_container = ac
