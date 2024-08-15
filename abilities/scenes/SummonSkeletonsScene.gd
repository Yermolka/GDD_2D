extends Node3D

@onready var skeleton_scene: PackedScene = preload("res://enemies/enemy.tscn")
var radius: float = 1.0

func _ready() -> void:
    var player: Player = get_tree().get_first_node_in_group("player")
    await get_tree().physics_frame
    var enemy_0: Enemy = skeleton_scene.instantiate()
    get_tree().root.add_child(enemy_0)
    enemy_0.position = position + (Vector3.RIGHT * radius)
    enemy_0.nav_agent.target_position = player.global_position

    var enemy_1: Enemy = skeleton_scene.instantiate()
    get_tree().root.add_child(enemy_1)
    enemy_1.position = position + (Vector3.LEFT * radius)
    enemy_1.nav_agent.target_position = player.global_position

    player.death.connect(
        func () -> void: 
            if is_instance_valid(enemy_0):
                enemy_0.queue_free()
            if is_instance_valid(enemy_1):
                enemy_1.queue_free()
    )

    queue_free()
