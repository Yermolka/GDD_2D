class_name HUD extends Control

@export_node_path("Player") var player_path: NodePath
var player: Player

@onready var inventory_hud: InventoryHUD = $Inventory
@onready var in_game_bar: InGameBar = $InGameBar

func _ready() -> void:
	await get_tree().physics_frame
	player = get_node(player_path) as Player
	inventory_hud.setup(player.inventory, player.equipment)

	in_game_bar.setup_ability_container(player.ability_container)
	in_game_bar.setup_gameplay_attribute_map(player.attribute_map)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_hud.toggle_inventory()
	
	if Input.is_action_just_pressed("toggle_char_screen"):
		inventory_hud.toggle_char_screen()
