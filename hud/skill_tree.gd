class_name SkillTree extends Control

@export var root_skill: ActiveSkill = null
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

	var hbox_root: HBoxContainer = hbox_container.duplicate()
	vbox_container.add_child(hbox_root)
	hbox_root.visible = true
	var btn_root: SkillTreeNode = skill_tree_slot.instantiate()
	btn_root.ability_container = ability_container
	btn_root.skill = root_skill
	btn_root.force_set_disabled(btn_root.disabled or available_points == 0)
	hbox_root.add_child(btn_root)
	btn_root.skill_tree_node_pressed.connect(_ability_clicked)

	for tier: SkillTreeTierData in data.tiers:
		var hbox: HBoxContainer = hbox_container.duplicate()
		vbox_container.add_child(hbox)
		hbox.visible = true
		for upgrade: GDDSkillUpgrade in tier.skills:
			var btn: SkillTreeNode = skill_tree_slot.instantiate()
			btn.ability_container = ability_container
			btn.upgrade = upgrade
			btn.force_set_disabled(btn.disabled or available_points == 0)
			hbox.add_child(btn)
			btn.skill_tree_node_pressed.connect(_ability_clicked)
	
func can_remove_upgrade(_upgrade: GDDSkillUpgrade) -> bool:
	for tier: SkillTreeTierData in data.tiers:
		for upgrade: GDDSkillUpgrade in tier.skills:
			if not upgrade.learned:
				continue
				
			for tag: String in _upgrade.grant_tags:
				if upgrade.required_tags.has(tag):
					return false
	return true

func _ability_clicked(node: SkillTreeNode) -> void:
	if node.skill:
		ability_container.grant(node.skill)
	if node.upgrade:
		node.upgrade.apply(root_skill, ability_container)
	available_points -= 1
	_draw_items()
	print(123)

func setup_ability_container(ac: AbilityContainer) -> void:
	ability_container = ac


func _on_close_button_pressed() -> void:
	visible = false