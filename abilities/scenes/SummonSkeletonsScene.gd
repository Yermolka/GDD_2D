extends Node3D

@onready var skeleton_scene: PackedScene = preload("res://enemies/enemy.tscn")
var radius: float = 4.0

func _ready() -> void:
	await get_tree().physics_frame
	var enemy_0: Enemy = skeleton_scene.instantiate()
	get_tree().root.add_child(enemy_0)
	enemy_0.position = position + (Vector3.RIGHT * radius)

	var enemy_1: Enemy = skeleton_scene.instantiate()
	get_tree().root.add_child(enemy_1)
	enemy_1.position = position + (Vector3.LEFT * radius)

	print(global_position, " ", enemy_1.position, " ", enemy_0.position)

	queue_free()
