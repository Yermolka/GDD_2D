extends Node3D

@onready var combat_text_scene: PackedScene = preload("res://hud/combat_text/text.tscn")
@onready var combat_text_crit_scene: PackedScene = preload("res://hud/combat_text/text.tscn")
@onready var combat_text_pool: Node3D
@onready var combat_text_crit_pool: Node3D


func _ready() -> void:
    combat_text_pool = Node3D.new()
    add_child(combat_text_pool)

    combat_text_crit_pool = Node3D.new()
    add_child(combat_text_crit_pool)

    for i in range(20):
        var combat_text: CombatText = combat_text_scene.instantiate()
        combat_text.visible = false
        combat_text_pool.add_child(combat_text)

        var combat_text_crit: CombatText = combat_text_crit_scene.instantiate()
        combat_text_crit.visible = false
        combat_text_crit_pool.add_child(combat_text_crit)


func spawn_normal_text(text_owner: Node3D, amount: int) -> void:
    var text: CombatText = get_first_normal_text()
    text.text = str(amount)
    text.crit = false
    text.visible = true
    text.text_owner = text_owner


func spawn_crit_text(text_owner: Node3D, amount: int) -> void:
    printerr("crit")
    var text: CombatText = get_first_crit_text()
    text.text = str(amount)
    text.crit = true
    text.visible = true
    text.text_owner = text_owner


func get_first_normal_text() -> CombatText:
    for child: CombatText in combat_text_pool.get_children():
        if not child.visible:
            return child

    var combat_text: CombatText = combat_text_scene.instantiate()
    combat_text.visible = false
    combat_text_pool.add_child(combat_text)
    return combat_text


func get_first_crit_text() -> CombatText:
    for child: CombatText in combat_text_crit_pool.get_children():
        if not child.visible:
            return child

    var combat_text_crit: CombatText = combat_text_crit_scene.instantiate()
    combat_text_crit.visible = false
    combat_text_crit_pool.add_child(combat_text_crit)
    return combat_text_crit
