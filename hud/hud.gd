class_name HUD extends Control

@export_node_path("Player") var player_path: NodePath
var player: Player

@onready var inventory_hud: InventoryHUD = $Inventory

func _ready() -> void:
	await get_tree().physics_frame
	player = get_node(player_path) as Player
	inventory_hud.setup(player.inventory, player.equipment)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_hud.toggle_inventory()
	
	if Input.is_action_just_pressed("toggle_char_screen"):
		inventory_hud.toggle_char_screen()
