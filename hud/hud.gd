class_name HUD extends Control

@export_node_path("Player") var player_path: NodePath
var player: Player

@onready var inventory_hud: InventoryHUD = $Inventory
@onready var in_game_bar: InGameBar = $InGameBar
@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var skill_tree: SkillTree = $SkillTree


func _ready() -> void:
	await get_tree().physics_frame
	setup()

	EventBus.startDialogue.connect(
		func(data: DialogueData, start: String) -> void:
			dialogue_box.data = data
			dialogue_box.start(start)
	)
	Globals.game_loaded.connect(setup)


func setup() -> void:
	player = get_tree().get_first_node_in_group("player") as Player
	inventory_hud.setup(player.inventory, player.equipment)

	in_game_bar.setup_ability_container(player.ability_container)
	in_game_bar.setup_gameplay_attribute_map(player.attribute_map)

	skill_tree.setup_ability_container(player.ability_container)
	skill_tree.setup_equipment(player.equipment)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_hud.toggle_inventory()
	
	if Input.is_action_just_pressed("toggle_char_screen"):
		inventory_hud.toggle_char_screen()

	if Input.is_action_just_pressed("toggle_ability_tree"):
		skill_tree.visible = not skill_tree.visible


func _on_skills_btn_pressed() -> void:
	skill_tree.visible = not skill_tree.visible


func _on_map_btn_pressed() -> void:
	pass


func _on_inventory_btn_pressed() -> void:
	inventory_hud.toggle_inventory()

func _on_character_btn_pressed() -> void:
	inventory_hud.toggle_char_screen()
