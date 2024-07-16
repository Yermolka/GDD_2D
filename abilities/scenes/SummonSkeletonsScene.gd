extends Node3D

@onready var skeleton_scene: PackedScene = preload("res://enemies/enemy.tscn")
var radius: float = 4.0

func _ready() -> void:
	var enemy_0: Enemy = skeleton_scene.instantiate()
	get_tree().root.add_child(enemy_0)
	enemy_0.global_position = global_position + (Vector3.RIGHT * radius)

	var enemy_1: Enemy = skeleton_scene.instantiate()
	get_tree().root.add_child(enemy_1)
	enemy_1.global_position = global_position + (Vector3.LEFT * radius)

	queue_free()
